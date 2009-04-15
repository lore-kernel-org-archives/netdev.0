From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH 0/3] bonding: allow bond in mode balance-alb to work
	properly in bridge -try6
Date: Wed, 15 Apr 2009 10:17:21 +0200
Message-ID: <20090415081720.GA21342@psychotron.englab.brq.redhat.com>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, davem@davemloft.net,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	kaber@trash.net, mschmidt@redhat.com, dada1@cosmosbay.com,
	ivecera@redhat.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35304 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750839AbZDOIS4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2009 04:18:56 -0400
Content-Disposition: inline
In-Reply-To: <20090313183303.GF3436@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(resend, rcu list locking, cometics)

Hi all.

The problem is described in following bugzilla:
https://bugzilla.redhat.com/show_bug.cgi?id=487763

Basically here's what's going on. In every mode, bonding interface uses the same
mac address for all enslaved devices (except fail_over_mac). Only balance-alb
will simultaneously use multiple MAC addresses across different slaves. When you
put this kind of bond device into a bridge it will only add one of mac adresses
into a hash list of mac addresses, say X. This mac address is marked as local.
But this bonding interface also has mac address Y. Now then packet arrives with
destination address Y, this address is not marked as local and the packed looks
like it needs to be forwarded. This packet is then lost which is wrong.

Notice that interfaces can be added and removed from bond while it is in bridge.

This patchset solves this issue in the best way it can be possibly solved. By
adding all mac addresses of all slave devices to the bridge hash list. To carry
these addresses the new list has to be introduced in struct net_device.

Jirka

