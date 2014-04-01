From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH v4 net] xen-netback: disable rogue vif in kthread context
Date: Tue, 1 Apr 2014 13:19:18 +0100
Message-ID: <1396354758.8667.141.camel@kazak.uk.xensource.com>
References: <1396352772-7884-1-git-send-email-wei.liu2@citrix.com>
	 <533AACC6.3050200@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>, <zoltan.kiss@citrix.com>,
	<edwin@etorok.net>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:16148 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751889AbaDAMTn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2014 08:19:43 -0400
In-Reply-To: <533AACC6.3050200@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-04-01 at 13:10 +0100, David Vrabel wrote:
> On 01/04/14 12:46, Wei Liu wrote:
> > When netback discovers frontend is sending malformed packet it will
> > disables the interface which serves that frontend.
> > 
> > However disabling a network interface involving taking a mutex which
> > cannot be done in softirq context, so we need to defer this process to
> > kthread context.
> > 
> > This patch does the following:
> > 1. introduce a flag to indicate the interface is disabled.
> > 2. check that flag in TX path, don't do any work if it's true.
> > 3. check that flag in RX path, turn off that interface if it's true.
> > 
> > The reason to disable it in RX path is because RX uses kthread. After
> > this change the behavior of netback is still consistent -- it won't do
> > any TX work for a rogue frontend, and the interface will be eventually
> > turned off.
> > 
> > Also change a "continue" to "break" after xenvif_fatal_tx_err, as it
> > doesn't make sense to continue processing packets if frontend is rogue.
> > 
> > This is a fix for XSA-90.
> 
> Reviewed-by: David Vrabel <david.vrabel@citrix.com>

Acked-by: Ian Campbell <ian.campbell@citrix.com>

Ian.
