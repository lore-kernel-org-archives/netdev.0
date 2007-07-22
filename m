From: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Subject: Re: [PATCH 11/12 -Rev2] IPoIB xmit API addition
Date: Sun, 22 Jul 2007 12:41:36 +0300
Message-ID: <20070722094136.GD7800@mellanox.co.il>
References: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070722090649.7787.47960.sendpatchset@K50wks273871wss.in.ibm.com>
Reply-To: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, rdreier@cisco.com, johnpol@2ka.mipt.ru,
	Robert.Olsson@data.slu.se, peter.p.waskiewicz.jr@intel.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	kumarkr@linux.ibm.com, mcarlson@broadcom.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, netdev@vger.kernel.org,
	tgraf@suug.ch, jeff@garzik.org, hadi@cyberus.ca, kaber@trash.net,
	mchan@broadcom.com, sri@us.ibm.com
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:49009 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753389AbXGVJlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2007 05:41:35 -0400
Received: by ug-out-1314.google.com with SMTP id j3so929529ugf
        for <netdev@vger.kernel.org>; Sun, 22 Jul 2007 02:41:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070722090649.7787.47960.sendpatchset@K50wks273871wss.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +	/*
> +	 * Handle skbs completion from tx_tail to wr_id. It is possible to
> +	 * handle WC's from earlier post_sends (possible multiple) in this
> +	 * iteration as we move from tx_tail to wr_id, since if the last
> +	 * WR (which is the one which had a completion request) failed to be
> +	 * sent for any of those earlier request(s), no completion
> +	 * notification is generated for successful WR's of those earlier
> +	 * request(s).
> +	 */

AFAIK a signalled WR will always generate a completion.
What am I missing?

> 
> +			/*
> +			 * Better error handling can be done here, like free
> +			 * all untried skbs if err == -ENOMEM. However at this
> +			 * time, we re-try all the skbs, all of which will
> +			 * likely fail anyway (unless device finished sending
> +			 * some out in the meantime). This is not a regression
> +			 * since the earlier code is not doing this either.
> +			 */

Are you retrying posting skbs? Why is this a good idea?
AFAIK, earlier code did not retry posting WRs at all.
The comment seems to imply that post send fails as a result of SQ overflow -
do you see SQ overflow errors in your testing?
AFAIK, IPoIB should never overflow the SQ.

-- 
MST
