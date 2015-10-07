From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 5/5] bpf: split state from prandom_u32() and
 consolidate {c,e}BPF prngs
Date: Wed, 07 Oct 2015 23:01:57 +0200
Message-ID: <56158845.4090809@iogearbox.net>
References: <cover.1444224502.git.daniel@iogearbox.net> <2b3b623837d040c99186d76966c3524f17057745.1444224502.git.daniel@iogearbox.net> <56154A84.5020206@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	Chema Gonzalez <chema@google.com>
To: Alexei Starovoitov <ast@plumgrid.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55899 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754773AbbJGVCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 17:02:02 -0400
In-Reply-To: <56154A84.5020206@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/07/2015 06:38 PM, Alexei Starovoitov wrote:
> On 10/7/15 6:43 AM, Daniel Borkmann wrote:
>> +void bpf_user_rnd_init_once(void)
>> +{
>> +    prandom_init_once(&bpf_user_rnd_state);
>> +}
>
> here the helper is definitely needed, since it's called from two
> places and we must make sure that prandom_init_once doesn't
> duplicate its static_key in two places.

Yes, sure.

> Probably makes sense to add a comment to do_once api that
>
> do_once(func, arg);
> do_once(func, arg);
>
> is not equal to
>
> void my_helper(void) { do_once(func, arg); }
> my_helper();
> my_helper();

Makes sense, added a comment.

> For this patch:
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>
>
