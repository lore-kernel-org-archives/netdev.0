From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: Re: [PATCH v2.6.33 2/2] jme: Adding lock to protect vlgrp structure.
Date: Tue, 16 Mar 2010 15:15:50 +0800
Message-ID: <20100316071242.M65171@cooldavid.org>
References: <1268630132-10410-2-git-send-email-cooldavid@cooldavid.org> <97949e3e1003151122q68ce19f4ja7f53ad380d3033f@mail.gmail.com> <20100315191339.M2560@cooldavid.org> <20100315.155350.26952440.davem@davemloft.net>
Reply-To: cooldavid@cooldavid.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset=big5
Cc: chavey@google.com, ethanhsiao@jmicron.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:38230 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937470Ab0CPHQI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Mar 2010 03:16:08 -0400
In-Reply-To: <20100315.155350.26952440.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Mar 2010 15:53:50 -0700 (PDT), David Miller wrote
> From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
> Date: Tue, 16 Mar 2010 03:13:33 +0800
> 
> > The vlan_rx_register is called through ioctl.
> > And the packet feeding is called in the tasklet.
> > I see no lock in register_vlan_dev(), register_vlan_device(), and vlan_ioctl_handler()
> > which is related to the vlan_hwaccel_receive_skb(), vlan_hwaccel_rx().
> > 
> > It prevents the vlgrp pointer be modified while trying to feed the packet.
> 
> This is not how you fix this.  Adding a new lock to your hot code
> path of packet receiving is the last thing you should be doing.
> 
> Instead, do what other drivers do, take down the device and bring it
> back up again when changing the ->vlgrp pointer.
> 
> See drivers/net/tg3.c:tg3_vlan_rx_register() for an example.
I see. I'll work on it.

--
Guo-Fu Tseng

