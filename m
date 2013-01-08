From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 1/2] net: dev_queue_xmit_nit: fix skb->vlan_tci
 field value
Date: Tue, 08 Jan 2013 12:42:45 -0800
Message-ID: <1357677765.18156.507.camel@edumazet-glaptop>
References: <1357671093-9605-1-git-send-email-dborkman@redhat.com>
	 <1357671093-9605-2-git-send-email-dborkman@redhat.com>
	 <1357675492.18156.420.camel@edumazet-glaptop>
	 <20130108202208.GE1621@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ani Sinha <ani@aristanetworks.com>,
	Jiri Pirko <jpirko@redhat.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36369 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390Ab3AHUms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 15:42:48 -0500
Received: by mail-pa0-f42.google.com with SMTP id rl6so559505pac.1
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 12:42:47 -0800 (PST)
In-Reply-To: <20130108202208.GE1621@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-08 at 21:22 +0100, Jiri Pirko wrote:

> 
> The issue is that for exmaple in af_packet the function packet_rcv()
> expects vlan_tci to be filled out as that is on RX path ensured by
> __netif_receive_skb(). However on TX path, dev_queue_xmit_nit() is
> called with vlan_tci cleaned in case the device does not have TX vlan
> accel enabled. This patch is trying to fix this difference.

I perfectly understood that, and I repeat :

I want to see the difference.

A filter cannot expect skb->vlan_tci is set for all packets.

If a device doesn't have TX vlan accel, vlan_tci is 0.

packet sniffing is already slow, we don't want to force an extra copy
with vlan_untag() killer.

If you want to fix/extend af_packet, do this in af_packet.
