From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 8/8] [PATCH v2] [CCID3]: Interface CCID3 code with
	newer Loss Intervals Database
Date: Mon, 10 Dec 2007 19:04:16 -0200
Message-ID: <20071210210416.GB24046@ghostprotocols.net>
References: <11971083882331-git-send-email-gerrit@erg.abdn.ac.uk> <11971083881862-git-send-email-gerrit@erg.abdn.ac.uk> <11971083881667-git-send-email-gerrit@erg.abdn.ac.uk> <11971083883685-git-send-email-gerrit@erg.abdn.ac.uk> <1197108388630-git-send-email-gerrit@erg.abdn.ac.uk> <11971083883727-git-send-email-gerrit@erg.abdn.ac.uk> <11971083882049-git-send-email-gerrit@erg.abdn.ac.uk> <11971083881748-git-send-email-gerrit@erg.abdn.ac.uk> <11971083882534-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43078 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751746AbXLJVEW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2007 16:04:22 -0500
Content-Disposition: inline
In-Reply-To: <11971083882534-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Sat, Dec 08, 2007 at 10:06:28AM +0000, Gerrit Renker escreveu:
> This hooks up the TFRC Loss Interval database with CCID 3 packet reception.
> In addition, it makes the CCID-specific computation of the first loss
> interval (which requires access to all the guts of CCID3) local to ccid3.c.
> 
> The patch also fixes an omission in the DCCP code, that of a default /
> fallback RTT value (defined in section 3.4 of RFC 4340 as 0.2 sec); while
> at it, the  upper bound of 4 seconds for an RTT sample has  been reduced to
> match the initial TCP RTO value of 3 seconds from[RFC 1122, 4.2.3.1].
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

When interfacing we must make sure that ccid3 tfrc_lh_slab is created
and then tfrc_li_cachep is not needed. I'm doing this while keeping
the structure of the patches, i.e. one introducing, the other removing.
But we need to create tfrc_lh_slab if we want the tree to be bisectable.

I'm doing this and keeping your Signed-off-line, please holler if you
disagree for some reason.

- Arnaldo
