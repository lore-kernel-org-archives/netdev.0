From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH V2 3/8] netback: switch to NAPI + kthread model
Date: Tue, 17 Jan 2012 17:11:57 +0000
Message-ID: <1326820317.5285.13.camel@liuw-desktop>
References: <1326808024-3744-1-git-send-email-wei.liu2@citrix.com>
	 <1326808024-3744-4-git-send-email-wei.liu2@citrix.com>
	 <20120117090730.13ae3c6e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Paul Durrant <Paul.Durrant@citrix.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:11260 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755120Ab2AQRMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 12:12:47 -0500
In-Reply-To: <20120117090730.13ae3c6e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-01-17 at 17:07 +0000, Stephen Hemminger wrote:
> On Tue, 17 Jan 2012 13:46:59 +0000
> Wei Liu <wei.liu2@citrix.com> wrote:
> 
> > This patch implements 1:1 model netback. We utilizes NAPI and kthread
> > to do the weight-lifting job:
> > 
> >   - NAPI is used for guest side TX (host side RX)
> >   - kthread is used for guest side RX (host side TX)
> > 
> > This model provides better scheduling fairness among vifs. It also
> > lays the foundation for future work.
> > 
> > The major defect for the current implementation is that in the NAPI
> > poll handler we don't actually disable interrupt. Xen stuff is
> > different from real hardware, it requires some other tuning of ring
> > macros.
> > 
> > Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> 
> The network receive processing is sensitive to the context it is run in.
> Normally it is run in softirq with interrupts enabled. With your code,
> the poll routine disables IRQ's which shouldn't be necessary.
> 

Misunderstanding here. I should rewrite my commit message.

By "disabling interrupt" I mean stop the other end from generating
events, not system wide disabling interrupt.

> Why does xenvif_receive_skb() need to still exist? Couldn't it
> just be replaced with call to netif_receive_skb() in one place it is called.

Sure.


Wei.
