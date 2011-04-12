From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: Re: [PATCH v2] net: bnx2x: convert to hw_features
Date: Tue, 12 Apr 2011 10:46:19 +0300
Message-ID: <1302594379.32697.33.camel@lb-tlvb-vladz>
References: <20110410152336.GA14182@rere.qmqm.pl>
 <20110410144746.679DD13A65@rere.qmqm.pl>
 <1302448214.2242.6.camel@lb-tlvb-vladz>
 <20110410153506.86FA613909@rere.qmqm.pl>
 <1302531021.21065.79.camel@lb-tlvb-vladz>
 <20110411201225.GA9249@rere.qmqm.pl>
 <1302593208.32697.18.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3861 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755069Ab1DLHqc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 03:46:32 -0400
In-Reply-To: <1302593208.32697.18.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > In all those cases, bnx2x_reload_if_running() will be called only when
> > LRO state is changed while there's a recovery in progress.
> 
> Hmmm... And what about all other features from hw_features? What if they
> have changed (in wanted_features) while recovery was in progress?
> According to the __netdev_update_features() code it will invoke
> ndo_set_features() in these cases either. Do I miss something here?

I think I understood what u meant. So, yes, if the bnx2x_nic_load()
called only if TPA_ENABLED_FLAG in bp->flags has changed. And this can
happen if either NETIF_F_LRO has changed while NETIF_F_RXCSUM was set or
if NETIF_F_LRO was set and NETIF_F_RXCSUM is being cleared.

thanks,
vlad


