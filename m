From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next v2 2/6] gtp: merge gtp_get_net and
 gtp_genl_find_dev
Date: Mon, 13 Feb 2017 15:51:14 +0100
Message-ID: <20170213145114.GA4368@salvia>
References: <20170130163713.17524-1-aschultz@tpip.net>
 <20170130163713.17524-3-aschultz@tpip.net>
 <20170206135512.sbxvkbe3hzgnwwjt@nataraja>
 <2072664575.96405.1486995217363.JavaMail.zimbra@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harald Welte <laforge@netfilter.org>,
        netdev <netdev@vger.kernel.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc <openbsc@lists.osmocom.org>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35750 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752476AbdBMOvU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Feb 2017 09:51:20 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 7D5D21B7FB8
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 15:51:17 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 6452FDA807
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 15:51:17 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 2F649DA807
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 15:51:15 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <2072664575.96405.1486995217363.JavaMail.zimbra@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 13, 2017 at 03:13:37PM +0100, Andreas Schultz wrote:
> 
> 
> ----- On Feb 6, 2017, at 2:55 PM, Harald Welte laforge@netfilter.org wrote:
> 
> > Hi Andreas,
> > 
> > On Mon, Jan 30, 2017 at 05:37:09PM +0100, Andreas Schultz wrote:
> >> Both function are always used together with the final goal to
> >> get the gtp_dev. This simplifies the code by merging them together.
> > 
> > Ok, some code restructuring / unification, seems useful.
> > 
> > However:
> > 
> >> -			netdev_dbg(dev, "GTPv0-U: update tunnel id = %llx (pdp %p)\n",
> >> -				   pctx->u.v0.tid, pctx);
> >> +			pr_debug("GTPv0-U: update tunnel id = %llx (pdp %p)\n",
> >> +				 pctx->u.v0.tid, pctx);
> > 
> > (and other related changes) appear to be purely cosmetic and should thus
> > be unrelated to the function merging described in the change log
> > message.
> 
> The dev argument has been removed from the surrounding function.
> However, for those debug message having the network device information
> is use full. I've modified the code in v3 a bit to keep the debug message.

There is no reason to replace netdev_dbg() by pr_debug(). With several
gtp devices in place, this debugging will render completely useless
since you cannot know what device has triggered the debugging mesage.

A better solution would be to simply remove this debugging thing. This
actually is only useful at early development stage IMO.
