From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCH] [TCP]: Move clearing of the prior_ssthresh due to
 ECE earlier
Date: Thu, 1 Mar 2007 22:26:57 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0703012220300.25330@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0703011948330.19465@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-723928699-1172780817=:25330"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58535 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965564AbXCAU06 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2007 15:26:58 -0500
In-Reply-To: <Pine.LNX.4.64.0703011948330.19465@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-723928699-1172780817=:25330
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 1 Mar 2007, Ilpo Järvinen wrote:

> Previously the prior_ssthresh was only used in the undo functions
> that were called by fastretrans_alert. FRTO processing, however,
> happens before that and one of the responses is doing undo too.
> 
> I think that after this patch, FRTO should be ECN-safe; only the
> undo_cwr response is a suspect anyway. The possible cases:
> 
[...snip...]
> 
> This problem could be solved locally in the undo_cwr response of
> FRTO by falling back to ratehalving response when FLAG_ECE is
> enabled.

I think that doing it in the response is better that this approach,
since it knows that the ssthresh has been halved already within that
round-trip, so there is no need to do that again... I'll submit the
patch tomorrow... With this prior_ssthresh clearing move alone, the 
ssthresh ends up being halved twice if I tought it right (first in 
tcp_enter_frto and then again in tcp_enter_cwr that is called from 
fastretrans_alert)... So please, drop this patch.

-- 
 i.
---696243703-723928699-1172780817=:25330--
