From: Jim Sansing <jjsansing@verizon.net>
Subject: Re: Comment on nf_queue NF_STOLEN patch
Date: Tue, 18 Oct 2011 17:34:35 -0400
Message-ID: <4E9DF0EB.8080008@verizon.net>
References: <4E988B1E.5000606@itcare.pl>
 <CAEuXFEy89F_=J_PJMSbQ1fDcOEkkpz2vucq3LcToi7rTcZHcDA@mail.gmail.com>
 <4E9DCEAD.7070603@verizon.net> <1318973032.19139.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms173011pub.verizon.net ([206.46.173.11]:41870 "EHLO
	vms173011pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296Ab1JRXRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 19:17:23 -0400
Received: from [192.168.1.5] ([unknown] [108.15.85.191])
 by vms173011.mailsrvcs.net
 (Sun Java(tm) System Messaging Server 7u2-7.02 32bit (built Apr 16 2009))
 with ESMTPA id <0LTA00MQ68KBQ8N2@vms173011.mailsrvcs.net> for
 netdev@vger.kernel.org; Tue, 18 Oct 2011 17:17:00 -0500 (CDT)
In-reply-to: <1318973032.19139.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le mardi 18 octobre 2011 =C3=A0 15:08 -0400, Jim Sansing a =C3=A9crit=
 :
>  =20
>> I have been working on a kernel module that registers with netfilter=
,
>> and I noticed that a patch was added to nf_queue that changed the
>> handling of return code NF_FILTER from 'do nothing' to 'free the skb=
'.=20
>> I'm not sure which kernel version this went in, but the date of the
>> patch is Feb, 19, 2010.
>>
>> Everything I have read about netfilter states that it is up to the
>> netfilter hook to free the skb if NF_STOLEN is returned.  The
>> implications of this patch from a hook programming perspective are:
>>
>> 1) If the skb is used after the return from the hook, it must be clo=
ned.
>> 2) The original skb must not be freed.
>>
>> I suggest that a comment be added to include/linux/netfilter.h that =
says
>> explicitly the skb will be freed if NF_STOLEN is returned.
>>    =20
>
> But its not true. Just read the code.
>
> If you are working on this stuff I recommend you take a look at
> commits :
>
> c6675233f9015d3c0460c8aab53ed9b99d915c64
> (netfilter: nf_queue: reject NF_STOLEN verdicts from userspace)
>
> fad54440438a7c231a6ae347738423cbabc936d9
> (netfilter: avoid double free in nf_reinject)
>
> 64507fdbc29c3a622180378210ecea8659b14e40
> (netfilter: nf_queue: fix NF_STOLEN skb leak)
>
> 3bc38712e3a6e0596ccb6f8299043a826f983701
> ([NETFILTER]: nf_queue: handle NF_STOP and unknown verdicts in
> nf_reinject)
>
>  =20

I see that fad54440438a7c231a6ae347738423cbabc936d9 (netfilter: avoid
double free in nf_reinject) returns the switch case for NF_STOLEN back
to the original state, but I just downloaded 3.0.4, and the skb is stil=
l
freed.  So for some versions of the kernel, the situation exists.=20
Hopefully anyone who runs into it will find this thread.

Later . . .   Jim
