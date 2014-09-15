From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Ring parameter information
Date: Mon, 15 Sep 2014 08:19:15 -0700
Message-ID: <54170373.5070303@hp.com>
References: <06FE00B9-3F10-48CD-ABC7-7817006FDBDD@gmail.com> <F225A4E9-1298-4262-8F24-9BF368100C78@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Hosam Hittini <h.hittini@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hp.com ([15.217.136.92]:13724 "EHLO
	g2t1383g.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752656AbaIOPT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 11:19:29 -0400
Received: from g5t1625.atlanta.hp.com (g5t1625.atlanta.hp.com [15.192.137.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by g2t1383g.austin.hp.com (Postfix) with ESMTPS id 6073E2217
	for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 15:19:28 +0000 (UTC)
In-Reply-To: <F225A4E9-1298-4262-8F24-9BF368100C78@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/14/2014 11:14 PM, Hosam Hittini wrote:
> Hi,
>
> I have two network interfaces and I used "ethtool -g" to get their ri=
ng parameters, but I don=92t quite understand the output
> For the ethernet interface the output says the operation is not suppo=
rted
> For the wireless interface the output says the sending and receiving =
buffer sizes are equal to zero
> I wonder if anyone can help me with that
>
> hosam@Robin-01:~$ sudo ethtool -g eth0
> Ring parameters for eth0:
> Cannot get device ring settings: Operation not supported

That means what it says - the driver/device for eth0 does not support=20
reporting ring settings.

> hosam@Robin-01:~$ sudo ethtool -g wlan1
> Ring parameters for wlan1:
> Pre-set maximums:
> RX:			0
> RX Mini:		0
> RX Jumbo:	0
> TX:			0
> Current hardware settings:
> RX:			0
> RX Mini:		0
> RX Jumbo:	0
> TX:			0

I am just guessing, but I would guess one of two things - either that=20
driver doesn't "really" support retrieving ring settings, or there is a=
=20
bug or no way for it to report them in a meaningful way.  You should=20
look-up the driver name (ethtool -i) and then go to a kernel source tre=
e=20
and find that driver under drivers/net/ and see what its ethtool suppor=
t=20
code looks like.

rick jones
