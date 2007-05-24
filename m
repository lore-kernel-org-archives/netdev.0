From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 1/6] 8139too: force media setting cleanup
Date: Thu, 24 May 2007 17:36:39 -0400
Message-ID: <46560567.5060708@garzik.org>
References: <200705232134.l4NLYcm2000578@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: leewkb@yahoo.com, netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48222 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752745AbXEXVgp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2007 17:36:45 -0400
In-Reply-To: <200705232134.l4NLYcm2000578@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Bernard Lee <leewkb@yahoo.com>
> 
> Setting bit 4 & 5 alone in 8139too module media option does not really
> force 100Mbps full-duplex mode.  When media option bit 0-3 is cleared,
> 8139too module does not force media setting.  Therefore, bit 0-3 requires
> to be set for bit 4 & 5 to take effect.  The hidden bit 0-3 setting is not
> stated in module description.
> 
> It can be fixed by changing rtl8139_private structure default_port bitfield
> from 4-bit to 6-bit.
> 
> Besides, module media bit 9 is a duplicate of bit 4 (full-duplex).  It is
> suggested that bit 9 is freed.  A remark is added to module description
> that bit 0 can be used to force setting.  It helps to clarify 10Mbps
> half-duplex mode.
> 
> Signed-off-by: Bernard Lee <leewkb@yahoo.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/8139too.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)

(re-replying, just to refresh everybody on the status)

The status of this patch is HOLD, and has been for months.

AFAICS this is a behavior change that differs from other Becker-derived 
drivers.  I would suggest looking at other drivers.

Furthermore, people should be using ethtool to set media.  Rather than 
changing the behavior of this module parameter to be non-standard, I 
feel it is better to (a) leave it as is or (b) remove it completely.

	Jeff




