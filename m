From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/2] ebpf: add prandom helper for packet sampling
Date: Fri, 13 Mar 2015 23:44:38 +0100
Message-ID: <55036856.1040309@iogearbox.net>
References: <cover.1426249641.git.daniel@iogearbox.net> <83348b7717b2f044140539fc7faa36bebcc3da58.1426249641.git.daniel@iogearbox.net> <55031730.5030303@plumgrid.com> <55031860.20903@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48148 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111AbbCMWop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 18:44:45 -0400
In-Reply-To: <55031860.20903@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/2015 06:03 PM, Daniel Borkmann wrote:
> On 03/13/2015 05:58 PM, Alexei Starovoitov wrote:
...
>>> +static u64 bpf_random(u64 dw, u64 r2, u64 r3, u64 r4, u64 r5)
>>> +{
>>> +    return prandom_u32() | (dw ? ((u64)prandom_u32() << 32) : 0);
>>
>> can you make first argument to be a flag instead of bool ?
>> 0 to return u32, 1 to return u64 and >=2 to be reserved and
>> return -EINVAL?
...
>> This way we can extend it later. For example 2 might return
>> 8 truly random bytes from get_random_bytes_arch()

Hmm, just got back to this thinking about it a bit more. I don't
like that we would return with a negative error here. An eBPF
application would then need to check for errors as well to make
sure, and the signature returns max u64. So _theoretically_,
-EINVAL could also come as a result from prandom() albeit unlikely.
That would make the interface a bit ugly, imho.

I think the interface should be as simple as possible for
obtaining a random number. I think that if we would want to
support something like get_random_bytes_arch(), it would be
better to do so in a new interface, where the name also more
clearly indicates where the random data comes from.

That said, I'd rather prefer to leave the code as is, but go
with the rename, maybe even BPF_FUNC_get_prandom_val so it
indicates it's pseudo-random as opposed to, say, something like
BPF_FUNC_get_srandom_val if we need that one day.

Cheers,
Daniel
