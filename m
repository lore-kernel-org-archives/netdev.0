From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: Regarding bottlenecks for high speed packet generation
Date: Thu, 25 Oct 2012 21:39:46 +0200
Message-ID: <CAD6jFUScXX0x7yU2f-Cq4B6RZdnQx4dkbADHBL9aYhzQmeKGgA@mail.gmail.com>
References: <CADAe=+KJ2QuL7ZdrfDWQe8R1vF_r_bu3QBS-5kwZBgQ21QTMtg@mail.gmail.com>
	<CAD6jFUTL9-Uyf-0YPwB7Fd5V71NvJh4ameZMF2GCQjDXh_DVzw@mail.gmail.com>
	<CADAe=++9KHUx3qX+2==+q0Fq44CJ9tjYcO=HdLYOF3FVuM5Vtg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Ajith Adapa <adapa.ajith@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45799 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934077Ab2JYTjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 15:39:54 -0400
Received: from [78.46.4.229] (helo=sslproxy03.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TRTHV-0004yO-N1
	for netdev@vger.kernel.org; Thu, 25 Oct 2012 21:39:53 +0200
Received: from [209.85.215.174] (helo=mail-ea0-f174.google.com)
	by sslproxy03.your-server.de with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TRTHS-0006YA-2z
	for netdev@vger.kernel.org; Thu, 25 Oct 2012 21:39:50 +0200
Received: by mail-ea0-f174.google.com with SMTP id c13so630035eaa.19
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 12:39:46 -0700 (PDT)
In-Reply-To: <CADAe=++9KHUx3qX+2==+q0Fq44CJ9tjYcO=HdLYOF3FVuM5Vtg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Please reply to all, so that also netdev gets CC'ed as well.)

On Thu, Oct 25, 2012 at 8:25 PM, Ajith Adapa <adapa.ajith@gmail.com> wrote:
>> Actually in my experience not. On Gigabit Ethernet (depending on your
>> machine) you should be able to generate about 80k pps with 1500 byte
>> (e.g. with netsniff-ng's trafgen) having the default tc discipline.
>>
> Currently I can see that my machine is able to generate 80MBytes/sec
> for 1500 byte packets with
> default tc discipline. Its a simple desktop with i5 dual core machine, 4GB RAM.

Hmm, what is the interconnect of the NIC? PCIe? I've seen some _PCI_
devices on simple desktop machines where this number could fit.

>> Have you looked how much pps the kernel space pktgen can generate on
>> your machine with 1500 byte packets?
>>
>> What tool do you use to measure this reported rate? Do you analyze
>> driver statistics from e.g. procfs, or do you use a libpcap-based tool
>> to measure the stuff (which you shouldn't since it could falsify your
>> stats)? How was your measurement setup?
>
> Currently I am using IXIA for the destination to confirm the numbers
> and also basic stats from system monitor.

Ok.

> I have tried pktgen quite long back but I could make a try and confirm
> the rate at which generates on my machine.

Yes, might be worth a try.

> When I tried powertop tool I see that out of list processes who
> consume more amount of power I can see that the NIC interface
> on which I am trying to burst the traffic is consuming around 63% with
> interrupts. But does the NIC card drop a interrupt for
> every packet which it has successfully sent ?

If the driver uses NAPI [1] / the chip supports that, then not. You
can observe the hardware / software interrupts via ifpps or watching
procfs or some other tools, or simply look at the driver
implementation.

[1] http://www.linuxfoundation.org/collaborate/workgroups/networking/napi
