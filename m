From: sdrb@onet.eu
Subject: Re: Variable download speed
Date: Tue, 23 Feb 2016 14:57:41 +0100 (CET)
Message-ID: <alpine.LNX.2.20.1602231455260.29937@localhost.localdomain>
References: <alpine.LNX.2.20.1602231216240.29937@localhost.localdomain> <CADVnQyngzgLhbo6of1vTq5MH4mk4rSR6_KLWCCXkndK6QYynAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpo67.poczta.onet.pl ([141.105.16.17]:40957 "EHLO
	smtpo67.poczta.onet.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752356AbcBWN5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 08:57:47 -0500
Received: from nowy9.kat.adbgroup.pl (unknown [91.230.58.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: sdrb@onet.eu)
	by smtp.poczta.onet.pl (Onet) with ESMTPSA id 3q8hlq07Jxz1XNBJd
	for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 14:57:41 +0100 (CET)
In-Reply-To: <CADVnQyngzgLhbo6of1vTq5MH4mk4rSR6_KLWCCXkndK6QYynAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 23 Feb 2016, Neal Cardwell wrote:

> On Tue, Feb 23, 2016 at 6:19 AM, <sdrb@onet.eu> wrote:
>> My question is: what causes such dynamic change in
>> the window size (while transferring data)?
>> Is it some kernel parameter wrong set or something like this?
>
> That sounds like TCP receive buffer auto-tuning (also called "Dynamic
> right-sizing (DRS)" (Fisk and Feng, 2001):
>
>  http://permalink.lanl.gov/object/tr?what=info:lanl-repo/lareport/LA-UR-01-5460
>
> The Linux TCP receiver will, by default, dynamically adjust the
> receive window to a value that supports the rate at which the
> application successfully reads data out of the socket.
>
>> Do I have any influence on such dynamic change in tcp window size?
>
> You might check on the receiver host with top/mpstat/strace/etc to see
> whether the receiving application is limiting performance in some way.
> This kind of behavior can show up if the receiver is sometimes
> CPU-saturated, or limited by the throughput of the medium on to which
> it is writing the data.
>
> If you control the receiver software, you can use
> setsockopt(SO_RCVBUF) to explicitly set the receive buffer size, and
> see if that helps. If it doesn't, that would suggest that it is indeed
> the receiving application that is limiting performance.
>
> If you could provide a tcpdump trace (headers only, e.g.,  -s 96)
> taken on the sender, we could check to see if we can see any problems
> in the TCP sender or receiver behavior.
>

Hi,

I published example pcap file under following link:

https://www.dropbox.com/s/v8375ub16seyt1a/test7.pcap?dl=0

I hope it is possible to download it without creating dropbox account.

sdrb
