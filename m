From: Jim Baxter <jim_baxter@mentor.com>
Subject: VLAN driver question
Date: Mon, 17 Jun 2013 20:12:01 +0100
Message-ID: <51BF5F81.2040207@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:59784 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042Ab3FQTMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 15:12:05 -0400
Received: from svr-orw-exc-10.mgc.mentorg.com ([147.34.98.58])
	by relay1.mentorg.com with esmtp
	id 1UoeqR-0005Ls-V7 from Jim_Baxter@mentor.com
	for netdev@vger.kernel.org; Mon, 17 Jun 2013 12:12:03 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a network card that has a single flag to indicate if a received
packet contains a vlan packet.

Can I use this to accelerate the kernels handling of the packet with
something like the following?

/* Handle received VLAN packets */
if ((ndev->features & NETIF_F_HW_VLAN_CTAG_RX) && ebdp &&
					(ebdp->cbd_esc &
					BD_ENET_RX_VLAN)) {
	/* Push and remove the vlan tag */
	struct vlan_hdr *vlan_header;
	u16 vlan_tag;
	vlan_header = (struct vlan_hdr *) skb->data;
	vlan_tag = ntohs(vlan_header->h_vlan_TCI);
	__vlan_hwaccel_put_tag(skb, vlan_tag);
	skb->len -= VLAN_HLEN;
	skb->data += VLAN_HLEN;
	vlan_set_encap_proto(skb, vlan_header);
}

napi_gro_receive(&fep->napi, skb);



Also I cannot find any documentation stating what the difference is
between NETIF_F_HW_VLAN_CTAG_RX and NETIF_F_HW_VLAN_CTAG_FILTER, can
anyone define it?
The FILTER word on NETIF_F_HW_VLAN_CTAG_FILTER suggests it may be
applicable to received packets.

Thank you for your help and comments.
Jim Baxter
