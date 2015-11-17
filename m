From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: How to do TCP tx checksums
Date: Tue, 17 Nov 2015 20:40:40 +0100
Message-ID: <564B82B8.8060507@iogearbox.net>
References: <564A72D3.1050407@candelatech.com> <CALx6S37AZz6UZctRxY9DOO+-x6MQ2gB9FQ2wSt8frEnegyh82Q@mail.gmail.com> <564B677C.8000603@candelatech.com> <1447784807.22599.125.camel@edumazet-glaptop2.roam.corp.google.com> <564B72BC.6060702@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39203 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932085AbbKQTkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 14:40:43 -0500
In-Reply-To: <564B72BC.6060702@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/17/2015 07:32 PM, Ben Greear wrote:
> On 11/17/2015 10:26 AM, Eric Dumazet wrote:
>> On Tue, 2015-11-17 at 09:44 -0800, Ben Greear wrote:
>>
>>> And in case it helps, here is the output from dmesg.
>>>
>>> This is an Ethernet frame, and in this case csum-start is the
>>> index of the first byte of the TCP header as far as I can tell.
>>>
>>> [64967.194251] check: 0xf51b  csum-start: 34  offset: 16 summed: 0x3  saddr: 0x201010a  daddr: 0x101010a len: 1514
>>>
>>
>> You forgot to clear tcp header @check before calling
>> __tcp_v4_send_check(), I think.
>>
>> ( th->check = 0; )
>
>  From printk I added to e1000e, it looks like I have bad offsets
> somehow.  I'll try clearing check as well, however.
>
>> Anyway, just use trafgen and get ~6 Mpps, more easily than with pktgen.
>
> I do plan to look at this...but need to make sure I can get similar
> features before I ditch pktgen.  It's not just raw throughput that is
> of interest to me, but also randomizing, sequential, etc header fields
> to test various network equipment (routers, MAC tables in switches, etc).

trafgen has a number of these things you mentioned. It started out as a
hobby project longer time ago as a simple way to tx raw frames, which was
needed to test some kernel project back in the days. Of course, nothing
is perfect and patches are always welcome. And if we can also get AF_PACKET
into a better shape by this, even better. ;)
