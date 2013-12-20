From: Joe Perches <joe@perches.com>
Subject: Re: [net-next v2 11/16] i40e: remove chatty log messages
Date: Fri, 20 Dec 2013 10:31:32 -0800
Message-ID: <1387564292.2353.58.camel@joe-AO722>
References: <1387557965-13241-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1387557965-13241-12-git-send-email-jeffrey.t.kirsher@intel.com>
	 <52B489ED.3010704@cogentembedded.com>
	 <AAEA33E297BCAC4B9BB20A7C2DF0AB8D654E34C9@FMSMSX113.amr.corp.intel.com>
	 <1387562360.2353.51.camel@joe-AO722>
	 <AAEA33E297BCAC4B9BB20A7C2DF0AB8D654E35E2@FMSMSX113.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: "Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0242.hostedemail.com ([216.40.44.242]:58239 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751201Ab3LTSbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 13:31:35 -0500
In-Reply-To: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D654E35E2@FMSMSX113.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-20 at 18:04 +0000, Williams, Mitch A wrote:
> > From: Joe Perches [mailto:joe@perches.com]
[]
> > this code is inconsistent and might be
> > nicer using the same form:
> > 
> > 		/* Skip if the queue is already in the requested state */
> > 		if (enable && (tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
> > 			continue;
> > 		if (!enable && !(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
> > 			continue;
> > 
> > [...]
> > 
> > 		/* wait for the change to finish */
> > 		for (j = 0; j < 10; j++) {
> > 			tx_reg = rd32(hw, I40E_QTX_ENA(pf_q));
> > 			if (enable) {
> > 				if ((tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
> > 					break;
> > 			} else {
> > 				if (!(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
> > 					break;
> > 			}
> > 
> > Perhaps the first form should be like the second
> > 
> > 	if (enable) {
> > 		if (tx_reg & I40E_QTX_ENA_QENA_STAT_MASK)
> > 			continue;
> > 	} else {
> > 		if (!(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
> > 			continue;
> > 	}
> > 
> > or maybe both should be
> > 
> > 	bool mask = tx_reg & I40E_QTX_ENA_QENA_STAT_MASK;
> > 	if (enable ^ mask)
[]
> I see what you mean about the inconsistent logic. Since it's not
> crucial, I think I'd prefer to fix this in a separate patch in the
> future. (I'll implement it today, but it takes a while to get through
> our internal validation process.)

Whenever, no worries, it's just a nit.
