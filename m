From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: latest net-next: iwlwifi: reproducible SOFTIRQ-unsafe lock order
 detected
Date: Tue, 27 May 2014 15:09:22 -0400
Message-ID: <20140527190922.GA8378@tuxdriver.com>
References: <538232C5.7000306@hartkopp.net>
 <1401213672.5367.260.camel@edumazet-glaptop2.roam.corp.google.com>
 <1DC40B07CD6EC041A66726C271A73AE61B79892E@IRSMSX102.ger.corp.intel.com>
 <5384DB94.9050303@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Berg, Johannes" <johannes.berg@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	"'johannes@sipsolutions.net'" <johannes@sipsolutions.net>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43444 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752078AbaE0TPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 15:15:12 -0400
Content-Disposition: inline
In-Reply-To: <5384DB94.9050303@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have that commit in wireless-next, included in the pull request
sent today.

John

On Tue, May 27, 2014 at 08:38:12PM +0200, Oliver Hartkopp wrote:
> Yep! That fixed it.
> 
> Tested-by: Oliver Hartkopp <socketcan@hartkopp.net>
> 
> Btw. this issue is in net-next.
> 
> Regards,
> Oliver
> 
> 
> On 27.05.2014 20:03, Berg, Johannes wrote:
> >> Bug added in commit ea68f46070c7bae608c619ae048f0ad995db74c3
> >> ("iwlwifi: pcie: clarify TX queue need_update handling")
> >>
> >> Please try :
> >>
> >> diff --git a/drivers/net/wireless/iwlwifi/pcie/tx.c
> >> b/drivers/net/wireless/iwlwifi/pcie/tx.c
> >> index dde6031f4257..309a13caddcd 100644
> >> --- a/drivers/net/wireless/iwlwifi/pcie/tx.c
> >> +++ b/drivers/net/wireless/iwlwifi/pcie/tx.c
> >> @@ -338,12 +338,12 @@ void iwl_pcie_txq_check_wrptrs(struct iwl_trans
> >> *trans)
> >>  	for (i = 0; i < trans->cfg->base_params->num_of_queues; i++) {
> >>  		struct iwl_txq *txq = &trans_pcie->txq[i];
> >>
> >> -		spin_lock(&txq->lock);
> >> +		spin_lock_bh(&txq->lock);
> > 
> > Yeah, we have the same commit in the tree:
> > 
> > commit d090f878b0084344812dc7bb086e98cd24572e58
> > Author: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
> > Date:   Tue May 13 08:10:51 2014 +0300
> > 
> >     iwlwifi: pcie: disable BHs in iwl_pcie_txq_check_wrptrs
> > 
> > I'm not sure why it hasn't hit net.git, I no longer maintain iwlwifi.git.
> > 
> > johannes
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
