From: "Perla, Sathya" <Sathya.Perla@Emulex.Com>
Subject: RE: [net PATCH] be2net: take care of __vlan_put_tag return value
Date: Mon, 15 Apr 2013 06:13:37 +0000
Message-ID: <3b9ba2cb-c3b1-477e-8e39-4e2f36700dec@CMEXHTCAS2.ad.emulex.com>
References: <1365778164-16857-1-git-send-email-ivecera@redhat.com>
 <20130412.145508.740030576340567517.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Seetharaman, Subramanian" <subbu.seetharaman@emulex.com>,
	"Khaparde, Ajit" <Ajit.Khaparde@Emulex.Com>
To: David Miller <davem@davemloft.net>,
	"ivecera@redhat.com" <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:58529 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543Ab3DOGNl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 02:13:41 -0400
In-Reply-To: <20130412.145508.740030576340567517.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> 
> From: Ivan Vecera <ivecera@redhat.com>
> 
> I'll apply this patch but there is some strangeness with the logic that controls
> these code paths.
> 
> The call to be_insert_vlan_in_pkt() is guarded by:
> 
> 	be_vlan_tag_chk(adapter, skb)
> 
> which evaluates to:
> 
> 	vlan_tx_tag_present(skb) || adapter->pvid
> 
> But the __vlan_put_tag() call is guarded by only one of those two
> conditions:
> 
> 	vlan_tx_tag_present(skb)
> 
> One of these two is wrong and should be corrected.

David, yes the pvid check here is wrong.

The pvid insertion by the driver (to hack around some HW bugs) requires some support from the FW and that
requires some more code/logic. That fix seems to be missing in the netdev tree.

We'll send out a patch-set to handle these issues. Thanks!

-Sathya
