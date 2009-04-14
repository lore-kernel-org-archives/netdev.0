From: Duncan Gibb <duncan.gibb@siriusit.co.uk>
Subject: 2.6.29 ALB bonding printk()s every arp (was Re: [PATCH 2/3] bonding:
 Fix ALB mode to balance traffic on VLANs)
Date: Wed, 15 Apr 2009 00:15:04 +0100
Message-ID: <49E518F8.3030109@siriusit.co.uk>
References: <1225849876-8930-1-git-send-email-fubar@us.ibm.com> <1225849876-8930-2-git-send-email-fubar@us.ibm.com> <1225849876-8930-3-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from snail.duncangibb.com ([217.169.3.184]:2260 "EHLO
	snail.duncangibb.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242AbZDNXi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 19:38:28 -0400
In-Reply-To: <1225849876-8930-3-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05 Nov 2008 at 01:51, Jay Vosburgh wrote:

JV> The current ALB function that processes incoming ARPs does
JV> not handle traffic for VLANs configured above bonding.  This
JV> causes traffic on those VLANs to all be assigned the same slave.
JV> This patch corrects that misbehavior by locating the bonding
JV> interface nested below the VLAN interface.

> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
> index 87437c7..e170fa2 100644
> --- a/drivers/net/bonding/bond_alb.c
> +++ b/drivers/net/bonding/bond_alb.c

> @@ -368,6 +372,9 @@ static int rlb_arp_recv(struct sk_buff *skb, struct net_device *bond_dev, struct
>  
>  	if (arp->op_code == htons(ARPOP_REPLY)) {
>  		/* update rx hash table for this ARP */
> +		printk("rar: update orig %s bond_dev %s\n", orig_dev->name,
> +		       bond_dev->name);
> +		bond = bond_dev->priv;
>  		rlb_update_entry_from_arp(bond, arp);
>  		dprintk("Server received an ARP Reply from client\n");
>  	}

Is the printk() in this patch necessary?

We recently put a 2.6.29 kernel on a router with multiple ALB bonds each
of several e1000 devices.  It now generates a log entry every time an
arp is-at packet arrives at a bonded interface.  I'm not sure that's a
feature...

Cheers


Duncan

-- 
Duncan Gibb - Technical Director
Sirius Corporation plc - control through freedom
http://www.siriusit.co.uk/ || t: +44 870 608 0063
