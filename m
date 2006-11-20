From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/4] atl1: Main C file for Attansic L1 driver
Date: Mon, 20 Nov 2006 14:35:10 -0500
Message-ID: <4562036E.3020409@garzik.org>
References: <20061119203050.GD29736@osprey.hogchain.net>	<200611200057.45274.arnd@arndb.de>	<45614769.4020005@redhat.com>	<200611201322.00495.arnd@arndb.de> <20061120100202.6a79e382@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, Chris Snook <csnook@redhat.com>,
	Jay Cliburn <jacliburn@bellsouth.net>, romieu@fr.zoreil.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43939 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S966535AbWKTTf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 14:35:26 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061120100202.6a79e382@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Using common MII code is good, but one problem with the existing MII code is that
> it doesn't work when device is down. This makes it impossible to set speed/duplex
> before device comes up.


That's not true at all.  drivers/net/mii.c uses caller-provided locking 
in all cases, and there is nothing that prevents the common code from 
being called when the interface is down.

You are probably thinking about all the netif_running() checks found in 
the drivers, particularly in the ->begin() hook.

	Jeff


