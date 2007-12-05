From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH v2 0/3][BUG-FIX]: Test tree updates and bug fixes
Date: Wed, 5 Dec 2007 12:11:22 -0200
Message-ID: <20071205141122.GE4653@ghostprotocols.net>
References: <11968535863312-git-send-email-gerrit@erg.abdn.ac.uk> <11968535864083-git-send-email-gerrit@erg.abdn.ac.uk> <11968535861091-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56918 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752034AbXLEOLZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 09:11:25 -0500
Content-Disposition: inline
In-Reply-To: <11968535861091-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Dec 05, 2007 at 11:19:45AM +0000, Gerrit Renker escreveu:
> This fixes a problem in the initial revision of the patch: The loss interval
> history was not de-allocated when the initialisation of the packet history
> failed.  The identification of this problem is also thanks due to Arnaldo.
> 
> The interdiff to the previous revision is:
> 
> 	--- b/net/dccp/ccids/lib/tfrc_module.c
> 	+++ b/net/dccp/ccids/lib/tfrc_module.c
> 	@@ -26,7 +26,12 @@
> 	 
> 		if (rc == 0)
> 			rc = packet_history_init();
> 	+	if (rc == 0)
> 	+		goto out;
> 	 
> 	+out_free_loss_intervals:
> 	+	dccp_li_exit();
> 	+out:
> 		return rc;
> 	 }
> 

Ok, this one is kept on the series I have pending submission.

- Arnaldo
