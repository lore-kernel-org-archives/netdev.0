From: Stefan Wahren <info@lategoodbye.de>
Subject: Re: Packet loss when txqueuelen is zero
Date: Sun, 29 Jun 2014 15:51:33 +0200
Message-ID: <53B019E5.4060905@lategoodbye.de>
References: <53AEA00F.6060500@lategoodbye.de> <1403966418.15139.27.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.augenpunkt.de ([213.239.207.9]:57333 "EHLO
	www.augenpunkt.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753211AbaF2NfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2014 09:35:03 -0400
In-Reply-To: <1403966418.15139.27.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 28.06.2014 16:40, schrieb Eric Dumazet:
>>
>> Is the packet loss a expected result for this scenario?
>
> Sure it is totally expected.
>
> -f is a flood ping, and you remove ability to store packets in the Qdisc
> (pifo_fast limit is device txqueuelen).
>
> If you have txqueuelen = 100, then the socket used by ping will more
> likely hit its SO_SNDBUF limit and ping will handle this properly (it
> detects that a sendmsg() returns -1, errno = ENOBUF
>
> If QCA7000 network driver has a tx ring size of 10 packets, you really
> want a qdisc being able to store bursts.

Thanks for your explanation. So it's not a network driver bug.

>
> If bufferbloat is your concern, you can switch pfifo_fast to fq_codel or
> fq
>
> tc qdisc replace dev eth0 root fq_codel  (or fq to get TCP pacing)
>

But fq_codel requires BQL in the QCA7000 network driver. Right?
