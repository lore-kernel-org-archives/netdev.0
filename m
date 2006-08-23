From: Stefan Rompf <stefan@loplof.de>
Subject: Re: [PATCH wireless-dev 4/6] d80211: Send Layer 2 Update frames in kernel
Date: Wed, 23 Aug 2006 23:50:41 +0200
Message-ID: <200608232350.41963.stefan@loplof.de>
References: <20060807231608.888744720@localhost> <20060807231938.455373487@localhost> <20060823192256.3e8df7f9@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from natblert.rzone.de ([81.169.145.181]:44729 "EHLO
	natblert.rzone.de") by vger.kernel.org with ESMTP id S965223AbWHWVvs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 17:51:48 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060823192256.3e8df7f9@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 23. August 2006 19:22 schrieb Jiri Benc:

> > Send Layer 2 Update frame from the 802.11 code in kernel to the netdev
> > that the STA is bound to. If the STA is bound to another VLAN netdev,
> > send another update frame. This fixes an issue in which a local bridge
> > table was not updated when hostapd sent this frame.
>
> I hope someone is going to describe why is this necessary and why it
> cannot be done in a less hackish way. Otherwise, I'd probably tend to
> ask for reverting this patch.

Imagine an ESS consisting of several APs in a switched wired network. Client 
roams from one AP to another. In order to update the FDB of the switches, a 
packet with the client MAC address needs to be originated from the ethernet 
interface of the AP the client has associated to, even if the client does not 
create traffic at the moment.

It's part of 802.11F.

Stefan
