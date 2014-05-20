From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v5 net-next 1/3] net: flow_dissector: avoid multiple calls
 in BPF
Date: Tue, 20 May 2014 11:58:59 +0200
Message-ID: <537B2763.5090402@redhat.com>
References: <1398882591-30422-1-git-send-email-chema@google.com> <1400265701-10333-1-git-send-email-chema@google.com> <CAMEtUuxBCNqbYctdxvWiJbp0mY__dKjP-RU8Ao-x3osVbFkxVg@mail.gmail.com> <CA+ZOOTPmSPeBrSHAsJtyxkAUnZDpgdhhw2PkrCJ3LhmG+ZSRYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>
To: Chema Gonzalez <chema@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13981 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750808AbaETJ7G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2014 05:59:06 -0400
In-Reply-To: <CA+ZOOTPmSPeBrSHAsJtyxkAUnZDpgdhhw2PkrCJ3LhmG+ZSRYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/20/2014 12:23 AM, Chema Gonzalez wrote:
> On Fri, May 16, 2014 at 3:00 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
...
>> Other than design issue there is technical problem too.
>> You're not updating eBPF JIT and context->flow_initted will have junk,
>> so ld_poff will be returning junk too.
>> JITs and interpreter must match. That was always the case even in
>> old days of classic BPF. Interpreter initialized A and X to zero,
>> JITs had to do the same. If you add stuff like this to interpreter,
>> JITs would have to follow. Fast forward few years and this is not scalable.
>> You have several JITs around and adding custom stuff to interpreter
>> may not even be possible to do in JITs.
> This is a fair point. In fact my patch is breaking "ld poff."
>
> I think the previous mechanism where a new insn added to BPF would
> cause the BPF JIT engine to refuse to run was a more scalable: New
> stuff always went in the non-jitted runner, and people interested in
> the jitted version will port when they needed it. We definitely not
> want to require people adding new features to provide 6 versions of
> the code.

Absolutely, "we definitely not want to require people adding new features
to provide 6 versions of the code". I agree with this statement and that
is exactly one of the goals of the new BPF mechanism. You might have seen
how the internal conversion function performs this task for all current
BPF extensions, and that is exactly so that JITs, once they are in place,
do not need to be upgraded 6 times anymore (in contrast to your previous
statement -- as people who want to use one of the extensions, needed to
port them to each of their arch-specific JITs before).

Best,

Daniel
