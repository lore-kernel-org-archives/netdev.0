From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP Appropriate Byte Counting per default off
Date: Wed, 3 Mar 2010 10:48:29 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1003031035370.10775@melkinpaasi.cs.helsinki.fi>
References: <A7D42088-84DC-4991-A8AD-E4000B2974DA@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"ilpo.jarvinen@helsinki.fi J?rvinen" <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>
To: Alexander Zimmermann <zimmermann@nets.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44471 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754004Ab0CCIsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 03:48:31 -0500
In-Reply-To: <A7D42088-84DC-4991-A8AD-E4000B2974DA@nets.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 3 Mar 2010, Alexander Zimmermann wrote:

> Hi David, hi Ilpo,
> 
> I wonder why ABC is off per default? What are the reasons?
> Should we turn it on per default?
> 
> From algorithmic point of view I see no flaws just
> benefits.
> 
> With RFC5681 ABC is recommended.
> OSX uses ABC per default.

As Alexey once put it, ABC is very BSD specific algorithm.

Out of two goals of ABC, protection against split ACKs is achieved in 
Linux by other means (see tcp_clean_rtx_queue and flags it gives to 
elsewhere). Thus, you can kind of think that we do APC already :-). The 
other part, faster increase during slow start, isn't currently done though 
it would be relatively simple to implement (I think I even have some, 
possibly unfinished, patch to do that lying around somewhere I wrote 
someday). 

ABC is not that necessary when window is counted in packets. And besides 
that, it was found to somewhat hurt small segment flows. There are some 
messages in archives in the timeframe ABC was disabled (plus there might 
have been some even older than that).

-- 
 i.
