From: Prashant Sreedharan <prashant@broadcom.com>
Subject: Re: Question regarding {G,S}CHANNELS API
Date: Fri, 8 Jan 2016 10:17:13 -0800
Message-ID: <1452277033.13470.43.camel@prashant>
References: <20160107154324.4081743c@jkicinski-Precision-T1700>
	 <1452201864.13470.27.camel@prashant>
	 <20160108114139.74a35521@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <ben@decadent.org.uk>, <siva.kallam@broadcom.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:54122 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754891AbcAHSk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 13:40:27 -0500
In-Reply-To: <20160108114139.74a35521@jkicinski-Precision-T1700>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-01-08 at 11:41 +0000, Jakub Kicinski wrote:

> The point of my email was that it's a bit cumbersome to express such
> configuration with the current ethtool API.  Therefore I'm asking if
> it's preferred to use:
>   ethtool ethX -L rx N tx M
For tg3 driver this is the preferred way

> in this case, or:
>   ethtool ethX -L combined N tx/rx abs(M-N)
tg3 will ignore the combined option and only consider separate tx / rx
values here. Combined will always be displayed as 0 to the user.

We understand your concern, and agree that the internal implementation
does not assign separate irq's to each tx, rx rings when tx/rx option is
used by user. With limited number of status blocks (max 4) and a HW bug
due to which not more than 1 TX ring is recommended to be enabled, it
was implemented in this manner.
