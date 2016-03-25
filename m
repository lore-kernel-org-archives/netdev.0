From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Thu, 24 Mar 2016 20:24:46 -0400 (EDT)
Message-ID: <20160324.202446.41433213332686770.davem@davemloft.net>
References: <CALx6S36Ej1es8qFi2Q3=199f+rmG=Za02N5ZBWT5DCRqrBEWvQ@mail.gmail.com>
	<56F42A00.7050002@iogearbox.net>
	<CAKQ1sVP_bbGYnVW=9WDnuzJ7qcC1xrM3qmeYFk-c3fi696F5-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com,
	eric.dumazet@gmail.com, w@1wt.eu, tolga.ceylan@gmail.com,
	cgallek@google.com, josh@code406.com, aconole@bytheb.org,
	daniel@iogearbox.net
To: ylavic.dev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56492 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248AbcCYAYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 20:24:51 -0400
In-Reply-To: <CAKQ1sVP_bbGYnVW=9WDnuzJ7qcC1xrM3qmeYFk-c3fi696F5-g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yann Ylavic <ylavic.dev@gmail.com>
Date: Thu, 24 Mar 2016 23:40:30 +0100

> On Thu, Mar 24, 2016 at 6:55 PM, Daniel Borkmann wrote:
>> On 03/24/2016 06:26 PM, Tom Herbert wrote:
>>>
>>> On Thu, Mar 24, 2016 at 10:01 AM, Eric Dumazet wrote:
>>>>
>>>> Really, when BPF can be the solution, we wont allow adding new stuff in
>>>> the kernel in the old way.
>>>
>>> I completely agree with this, but I wonder if we now need a repository
>>> of useful BPF modules. So in the case of implementing functionality
>>> like in SO_REUSEPORT_LISTEN_OFF that might just become a common BPF
>>> program we could direct people to use.
>>
>> Good point. There's tools/testing/selftests/net/ containing already
>> reuseport
>> BPF example, maybe it could be extended.
> 
> FWIW, I find:
> 
>     const struct bpf_insn prog[] = {
>         /* BPF_MOV64_REG(BPF_REG_6, BPF_REG_1) */
>         { BPF_ALU64 | BPF_MOV | BPF_X, BPF_REG_6, BPF_REG_1, 0, 0 },
>         /* BPF_LD_ABS(BPF_W, 0) R0 = (uint32_t)skb[0] */
>         { BPF_LD | BPF_ABS | BPF_W, 0, 0, 0, 0 },
>         /* BPF_ALU64_IMM(BPF_MOD, BPF_REG_0, mod) */
>         { BPF_ALU64 | BPF_MOD | BPF_K, BPF_REG_0, 0, 0, mod },
>         /* BPF_EXIT_INSN() */
>         { BPF_JMP | BPF_EXIT, 0, 0, 0, 0 }
>     };
> (and all the way to make it run)
> 
> something quite unintuitive from a web server developper perspective,
> simply to make SO_REUSEPORT work with forked TCP listeners (probably
> as it should out of the box)...

If we encapsulate this into libraries and helper wrappers, there is
no reason web server developers should be looking at these details
anyways.

Please don't make a mountain out of a mole-hill.

We build things on top of good infrastructure, rather than build
duplicate ways to do the same exact thing.

BPF is good infrastructure, therefore that is what things will be
built on top of.

Thanks.
