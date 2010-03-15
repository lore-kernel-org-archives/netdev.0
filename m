From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: Re: [PATCH v2.6.33 2/2] jme: Adding lock to protect vlgrp structure.
Date: Tue, 16 Mar 2010 03:13:33 +0800
Message-ID: <20100315191339.M2560@cooldavid.org>
References: <1268630132-10410-1-git-send-email-cooldavid@cooldavid.org> <1268630132-10410-2-git-send-email-cooldavid@cooldavid.org> <97949e3e1003151122q68ce19f4ja7f53ad380d3033f@mail.gmail.com>
Reply-To: cooldavid@cooldavid.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset=iso-8859-1
Cc: David Miller <davem@davemloft.net>,
	Ethan Hsiao <ethanhsiao@jmicron.com>,
	linux-netdev <netdev@vger.kernel.org>
To: Laurent Chavey <chavey@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:50541 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965673Ab0COTN4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Mar 2010 15:13:56 -0400
In-Reply-To: <97949e3e1003151122q68ce19f4ja7f53ad380d3033f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Laurent:

The vlan_rx_register is called through ioctl.
And the packet feeding is called in the tasklet.
I see no lock in register_vlan_dev(), register_vlan_device(), and vlan_ioctl_handler()
which is related to the vlan_hwaccel_receive_skb(), vlan_hwaccel_rx().

It prevents the vlgrp pointer be modified while trying to feed the packet.
Ex:
> if (jme->vlgrp) {
True.
vlan_rx_register called, vlgrp set to NULL.
>         jme->jme_vlan_rx(skb, jme->vlgrp,
>                          le16_to_cpu(rxdesc->descwb.vlan));
passing vlgrp with the value "NULL" to jme_vlan_rx.
Or it might even be modified during the vlan_hwaccel_{receive_skb|rx} call.

Please correct me if I'm wrong.

On Mon, 15 Mar 2010 11:22:48 -0700, Laurent Chavey wrote
> what does the spinlock protect ?
> 

--
Guo-Fu Tseng

