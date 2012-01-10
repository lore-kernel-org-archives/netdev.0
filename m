From: Andy Gospodarek <gospo@redhat.com>
Subject: Re: [PATCHv2] bond_alb: don't disable softirq under bond_alb_xmit
Date: Tue, 10 Jan 2012 12:52:59 -0500
Message-ID: <20120110175259.GD32485@quad.redhat.com>
References: <1326146497-27711-1-git-send-email-maxim.uvarov@oracle.com>
 <20120109222046.GC32485@quad.redhat.com>
 <4F0BABEC.2050200@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <gospo@redhat.com>, netdev@vger.kernel.org,
	fubar@us.ibm.com, andy@greyhouse.net, davem@davemloft.net,
	Cong Wang <amwang@redhat.com>
To: Maxim Uvarov <maxim.uvarov@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57847 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754357Ab2AJSKM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jan 2012 13:10:12 -0500
Content-Disposition: inline
In-Reply-To: <4F0BABEC.2050200@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 09, 2012 at 07:09:32PM -0800, Maxim Uvarov wrote:
> On 01/09/2012 02:20 PM, Andy Gospodarek wrote:
> >On Mon, Jan 09, 2012 at 02:01:37PM -0800, Maxim Uvarov wrote:
> >>No need to lock soft irqs under bond_alb_xmit()
> >>which already has softirq disabled.
> >>
> >>Changes:
> >>1. add non-bh/bh version to tlb_clear_slave()
> >>
> >>2. represent BH and non BH hash table locks
> >>_lock_rx_hashtbl_bh/_unlock_rx_hashtbl_bh
> >>_lock_rx_hashtbl/_unlock_rx_hashtbl
> >>_lock_tx_hashtbl_bh/_unlock_tx_hashtbl_bh
> >>_lock_tx_hashtbl/_unlock_tx_hashtbl
> >>
> >>Signed-off-by: Maxim Uvarov<maxim.uvarov@oracle.com>
> >>Signed-off-by: Cong Wang<amwang@redhat.com>
> >>---
> >>  drivers/net/bonding/bond_alb.c |  112 +++++++++++++++++++++++++++-------------
> >>  1 files changed, 76 insertions(+), 36 deletions(-)
> >>
> >
> >Did you test this with CONFIG_DEBUG_LOCKDEP=y at all?
> >
> 
> Just did some simple tests on bond0 with LOCKDEP. Do not see any warnings.
> 

OK, I will test it today and let you know how it looks.
