From: Oliver Neukum <oliver@neukum.org>
Subject: Re: future developments of usbnet
Date: Thu, 12 May 2011 09:59:28 +0200
Message-ID: <201105120959.28473.oliver@neukum.org>
References: <Pine.LNX.4.44L0.1105091130440.2002-100000@iolanthe.rowland.org> <201105111937.47448.oliver@neukum.org> <20110511.134727.957370621658043260.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, stern@rowland.harvard.edu,
	tom.leiming@gmail.com, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:53367 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449Ab1ELH5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 03:57:45 -0400
In-Reply-To: <20110511.134727.957370621658043260.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 11. Mai 2011, 19:47:27 schrieb David Miller:

> Basically once you take you interrupt, and disable device interrupts,
> the generic net device layer calls your ->poll() routing with a "weight"
> You should not process more RX packets than this value.
> 
> If you have less than "weight" work to do, you should do a napi_complete(),
> which takes you out of the polling group, and re-enable device interrupts.
> 
> So the idea is that you keep getting ->poll()'d until there is no more
> RX work to do.
> 
> The "weight" argument implements fairness amongst competing, actively
> polling, devices on the same CPU.
> 

Thank you, this is very informative. Our problem here is that USB doesn't work
sanely without interrupts. We can stop IO regarding rx, but we cannot stop
interrupts if we want to do rx.

	Regards
		Oliver
