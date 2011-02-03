From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Date: Fri, 4 Feb 2011 00:43:05 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1102040027060.25125@melkinpaasi.cs.helsinki.fi>
References: <20110202.170750.229739784.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, therbert@google.com,
	"H.K. Jerry Chu" <hkjerry.chu@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43663 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051Ab1BCWnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 17:43:08 -0500
In-Reply-To: <20110202.170750.229739784.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It would perhaps be useful to change receiver advertized window to include 
some extra segs initially. It should be >= IW + peer's dupThresh-1 as 
otherwise limited transmit won't work for the initial window because we 
won't open more receiver window with dupacks (IIRC, I suppose Jerry might 
be able to correct me right away if I'm wrong and we open window with 
dupacks too?).  I think initial receiver window code used to have some 
surplus but it was broken by the rfc3390-func conversion (against my 
advice on how to do the conversion).

-- 
 i.
