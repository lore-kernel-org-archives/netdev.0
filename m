From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: sky2 bonding problem, 802.3ad
Date: Thu, 15 Feb 2007 16:31:36 -0500
Message-ID: <20070215213135.GC30353@gospo.rdu.redhat.com>
References: <871wkruu6p.fsf@kruemel.my-eitzenberger.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org,
	sk-drivers@lists.linux-foundation.org, netdev@vger.kernel.org
To: Holger Eitzenberger <holger@my-eitzenberger.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36632 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161395AbXBOVbt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 16:31:49 -0500
Content-Disposition: inline
In-Reply-To: <871wkruu6p.fsf@kruemel.my-eitzenberger.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 15, 2007 at 07:55:42PM +0100, Holger Eitzenberger wrote:
> Hi Steven,
> 
> I have problems using sky2 v1.10 with with bonding driver (802.3ad),
> on 'Marvell 88E8053 PCI-E Gigabit Ethernet Controller'.  I have attached
> the full lspci output.
> 
> My test was to setup a bond of two physical links (both links same
> hardware) and ping 192.168.11.10, which is the address of the switch
> itself.
> 
> I have tested v1.10 with kernel 2.6.19 and 2.6.16.36 (own backport),
> which despite the bonding problem runs fine.  Both, kernel 2.6.19 and
> 2.6.16.36 show the same behaviour.  The 802.3ad aware switch is a Dell
> PowerConnect 5324.  VLAN is not configured on all switch ports.  Another
> test on a host running kernel 2.6.18.2 with two e1000's bonded runs
> fine.  Using sk98lin (v8.41 & v10.0.4) worked also.


I get the impression that sky2 has never worked for you.  Is that
correct?  There was an skge problem I noticed a while ago where on reset
the multicast membership list was cleared.  

commit 758140900a82e3ed3bb2be1d4705dd352fe44825
Author: Stephen Hemminger <shemminger@osdl.org>
Date:   Fri Dec 1 11:41:08 2006 -0800

    [PATCH] skge: don't clear MC state on link down

    I would rather fix Andy's problem by not clearing
    multicast information on link down.

    Also, add code to restore multicast state after ethtool phy reset.

    Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>



A patch Having this list cleared could stop you from receiving 802.3ad
PDUs.  I'll check skge and see if it has the same problem (I'm betting
on it).





