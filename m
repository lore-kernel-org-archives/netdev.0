From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [net-next-2.6 PATCH] bonding: refuse to change bond type if
 it's used
Date: Mon, 8 Mar 2010 10:24:48 -0800
Message-ID: <20100308102448.7acfe7c0@nehalam>
References: <20100308175406.GA2834@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40180 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752418Ab0CHSZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 13:25:51 -0500
In-Reply-To: <20100308175406.GA2834@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 8 Mar 2010 18:54:06 +0100
Jiri Pirko <jpirko@redhat.com> wrote:

> It's not desirable to be able to change the type of net_device in bond device if
> it's in use by bridge, or vlan, or so. At the moment, there is possible for
> example to have INFINIBAND bond type in bridge (by adding bond with eth type to
> a bridge first and then enslave INFINIBAND device).

Rather than building lots of back pointer dependencies, why not
have another netdevice notifier that allows other subsystems to
see the type change and reject it if they care? That way the code
would be more modular and expandable.
