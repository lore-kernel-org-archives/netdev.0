From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Tue, 24 May 2011 01:19:42 -0400 (EDT)
Message-ID: <20110524.011942.393855175233217324.davem@davemloft.net>
References: <20110523140048.777fb378@nehalam>
	<20110523.172047.1438754754048434316.davem@davemloft.net>
	<m1y61x2htp.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, greearb@candelatech.com,
	nicolas.2p.debian@gmail.com, jpirko@redhat.com, xiaosuo@gmail.com,
	netdev@vger.kernel.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, jesse@nicira.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43271 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751283Ab1EXFVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 01:21:15 -0400
In-Reply-To: <m1y61x2htp.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 23 May 2011 15:05:54 -0700

> 3) What do we do with pf_packet and vlan hardware acceleration when
>    dumping not the vlan interface but the interface below the vlan
>    interface?
> 
>    Do we provide an option to keep the vlan header?  Should that option
>    be on by default?
> 

The vlan_tci in the V2 pf_packet auxdata was intended for this
purpose.

So no matter what variant of behavior is occurring, apps can properly
reconstitute the VLAN header if they inspect the vlan_tci in the
auxdata.

The only thing that seems to be missing is an indication that a VLAN
tag was present at all, ie. vlan_tx_tag_present(), in this manner an
application could then differentiate between no VLAN header and a VLAN
tag of zero.
