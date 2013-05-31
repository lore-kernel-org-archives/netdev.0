From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rtnetlink: ndo_dflt_fdb_del() never works
Date: Fri, 31 May 2013 01:46:07 -0700 (PDT)
Message-ID: <20130531.014607.358769391044586124.davem@davemloft.net>
References: <1369951315-14742-1-git-send-email-alanr@unix.sh>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@gavemloft.net, kuznet@ms2.inr.ac.ru,
	vyasevic@redhat.com
To: alanr@unix.sh
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34751 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478Ab3EaIqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 04:46:08 -0400
In-Reply-To: <1369951315-14742-1-git-send-email-alanr@unix.sh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Robertson <alanr@unix.sh>
Date: Thu, 30 May 2013 16:01:55 -0600

> ndo_dflt_fdb_del is checking for a condition which is opposite that
> which ndo_dflt_fdb_add enforces.  ndo_dflt_fdb_add declares an error
> if (ndm->ndm_state && !(ndm->ndm_state) & NUD_PERMANENT)) - that is, if the
> entry is static.  This is consistent with the failure error message.
> 
> On the other hand, ndo_dflt_del() declares an error
> if (ndm_state & NUD_PERMANENT) - which is inconsistent with the add
> precondition, and inconsistent with its failure message text.
> As it is now, you can't delete any entry which add allows to be added -
> so entry deletion always fails.
> 
> Signed-off-by: Alan Robertson <alanr@unix.sh>

What about the ->ndm_state part of the add() test?  Why not include
that in the del() check?
