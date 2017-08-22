From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next 4/4] bpf/verifier: document liveness analysis
Date: Tue, 22 Aug 2017 16:55:38 +0100
Message-ID: <127935e3-d7a0-d626-09ca-462152b2a9cc@solarflare.com>
References: <f25f46bd-27cb-2182-2551-2887757c1e0f@solarflare.com>
 <60838927-7286-60c9-ad69-3b97350a05a4@solarflare.com>
 <36605f53-479d-a32d-ed2e-721c13f0080a@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>
To: Alexei Starovoitov <ast@fb.com>, <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:56567 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750812AbdHVPzs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 11:55:48 -0400
In-Reply-To: <36605f53-479d-a32d-ed2e-721c13f0080a@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/08/17 16:42, Alexei Starovoitov wrote:
> On 8/22/17 6:27 AM, Edward Cree wrote:
>>  static bool do_propagate_liveness(const struct bpf_verifier_state *state,
>>                    struct bpf_verifier_state *parent)
>>  {
>> @@ -3457,6 +3463,15 @@ static bool do_propagate_liveness(const struct bpf_verifier_state *state,
>>      return touched;
>>  }
>>
>> +/* "parent" is "a state from which we reach the current state", but initially
>> + * it is not the state->parent (i.e. "the state whose straight-line code leads
>> + * to the current state"), instead it is the state that happened to arrive at
>> + * a (prunable) equivalent of the current state.  See comment above
>> + * do_propagate_liveness() for consequences of this.
>> + * This function is just a more efficient way of calling mark_reg_read() or
>> + * mark_stack_slot_read() on each reg in "parent" that is read in "state", so
>> + * long as parent != state->parent.
>> + */
>
> i'm confused with 'so long as parent != state->parent' which implies
> looping and multiple iterations, whereas 'parent != state->parent'
> condition is true only for the first iteration of
> 'while (do_propagate_liveness(state, parent))' loop.
> right ?
I phrased it badly.  I mean that, the statement "this function is just a
 way to mark_reg_read() all the things" is true only "so long as" (i.e.
 under the condition) parent != state->parent.
How about
/* This function is just a more efficient way of calling mark_reg_read() or
 * mark_stack_slot_read() on each reg in "parent" that is read in "state",
 * though it requires that parent != state->parent in the call arguments.
 */
?
