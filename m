From: Jesse Young <jlyo@jlyo.org>
Subject: Re: Missing TCP SYN on loopback, retransmits after 1s
Date: Tue, 22 Nov 2011 18:37:27 -0600
Message-ID: <20111122183727.01ab6f04@telperion.jlyo.org>
References: <20111122181320.38a70cf8@telperion.jlyo.org>
	<20111122.192338.1206677511966747729.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:58239 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759123Ab1KWAh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 19:37:29 -0500
Received: from compute3.internal (compute3.nyi.mail.srv.osa [10.202.2.43])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id D4D3720B3E
	for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 19:37:28 -0500 (EST)
In-Reply-To: <20111122.192338.1206677511966747729.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Nov 2011 19:23:38 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Jesse Young <jlyo@jlyo.org>
> Date: Tue, 22 Nov 2011 18:13:20 -0600
>
> > What's also puzzling, is that I see no packet drop reporting in
> > $ ifconfig lo
> > lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 16436  metric 1
> > inet 127.0.0.1  netmask 255.0.0.0
> > inet6 ::1  prefixlen 128  scopeid 0x10<host>
> > loop  txqueuelen 0  (Local Loopback)
> > RX packets 276411482  bytes 15822880567 (14.7 GiB)
> > RX errors 0  dropped 0  overruns 0  frame 0
> > TX packets 276411482 bytes 15822880567 (14.7 GiB)
> > TX errors 0 dropped 0 overruns 0 carrier 0 collisions
>
> The device driver therefore isn't even seeing the packets, they are
> being dropped elsewhere.
>
> Why is this "puzzling"?
>
> There's layers upon layers and thousands of places where packets can
> be dropped between the originating network stack and the actual device
> driver.

Maybe puzzling isn't the best word... just some more relevant
information.  Also, this is the loopback interface, there is no device
driver, PHY or DLL layer in question here (just the loopback's mock
driver/PHY/DLL).

I presume that the drop is occuring in between the NET layer, and the sys
call interface, do you agree?  Where should I begin looking?
