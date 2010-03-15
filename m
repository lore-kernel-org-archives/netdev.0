From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.6.33 2/2] jme: Adding lock to protect vlgrp
 structure.
Date: Mon, 15 Mar 2010 15:53:50 -0700 (PDT)
Message-ID: <20100315.155350.26952440.davem@davemloft.net>
References: <1268630132-10410-2-git-send-email-cooldavid@cooldavid.org>
	<97949e3e1003151122q68ce19f4ja7f53ad380d3033f@mail.gmail.com>
	<20100315191339.M2560@cooldavid.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chavey@google.com, ethanhsiao@jmicron.com, netdev@vger.kernel.org
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40890
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932386Ab0COWx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 18:53:28 -0400
In-Reply-To: <20100315191339.M2560@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Date: Tue, 16 Mar 2010 03:13:33 +0800

> The vlan_rx_register is called through ioctl.
> And the packet feeding is called in the tasklet.
> I see no lock in register_vlan_dev(), register_vlan_device(), and vlan_ioctl_handler()
> which is related to the vlan_hwaccel_receive_skb(), vlan_hwaccel_rx().
> 
> It prevents the vlgrp pointer be modified while trying to feed the packet.

This is not how you fix this.  Adding a new lock to your hot code
path of packet receiving is the last thing you should be doing.

Instead, do what other drivers do, take down the device and bring it
back up again when changing the ->vlgrp pointer.

See drivers/net/tg3.c:tg3_vlan_rx_register() for an example.

