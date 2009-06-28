From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Sun, 28 Jun 2009 21:56:08 +0200
Message-ID: <20090628195608.GA2741@ami.dom.local>
References: <19012.37515.146191.198843@robur.slu.se> <20090627192057.GA5041@ami.dom.local> <19015.20051.432572.460207@robur.slu.se> <20090628143511.GA20541@ami.dom.local> <4A478D02.10805@itcare.pl> <4A4790C3.508@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Robert Olsson <robert@robur.slu.se>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:59607 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901AbZF1T4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2009 15:56:34 -0400
Received: by fxm18 with SMTP id 18so614218fxm.37
        for <netdev@vger.kernel.org>; Sun, 28 Jun 2009 12:56:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A4790C3.508@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 28, 2009 at 05:48:19PM +0200, Pawe=B3 Staszewski wrote:
>
> After apply this patch something is wrong
>
> Traffic is not forwarded
> no info in dmesg / no info from bgp
> and also i can't connect to bgpd process
>
> I revert kernel to past version with first Jarek patch
>

Thank you very much, Pawel, for trying this. I'm starting to look for
the reason. In the meantime try to get some fib_trie stats for Robert.

Jarek P.
>
>
> Pawe=B3 Staszewski pisze:
>>
>>
>> After 18 hours from apply first Jarek patch i have no info about Fix=
 =20
>> inflate_threshold_root
>> even if i make: "clear ip bgp *" on router
>> So i change Jarek patch from previous to this new one for test and w=
e =20
>> will see ...
>>
>> Regards
>> Pawel Staszewski
>>
>>
>> Jarek Poplawski pisze:
>>> On Sun, Jun 28, 2009 at 01:04:51PM +0200, Robert Olsson wrote:
>>> ...
>>> =20
>>>>  The memory patches and "manual RCU" are also interesting to addre=
ss
>>>>  the case with PREEMTP's.
>>>>    =20
>>>
>>> Since 2.6.29 looks like prefered here, and there were a lot of take=
s
>>> in this thread, I attach below a combined all-in-one patch includin=
g:
>>> - 2.6.29 -> 2.6.30 preemption disable patch
>>> - 2 RCU vs. preemption fixes from 2.6.31-rc
>>> - "manual RCU" patch to force vfree/kfree before root's resize (tak=
e 3)
>>> - "automatic" inflate_threshold_root fix (take 2)
>>>
>>> Thanks,
>>> Jarek P.
>>>
>>> --- (for 2.6.29.x or even .28 or .27; any testing appreciated)
>>>
>>> diff -Nurp a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
>>> --- a/net/ipv4/fib_trie.c    2009-06-27 20:25:06.000000000 +0200
>>> +++ b/net/ipv4/fib_trie.c    2009-06-28 15:45:02.000000000 +0200
=2E..
