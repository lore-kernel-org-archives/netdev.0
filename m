From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH V2] New Xen netback implementation
Date: Mon, 30 Jan 2012 18:30:41 +0000
Message-ID: <1327948241.5553.44.camel@leeds.uk.xensource.com>
References: <1326808024-3744-1-git-send-email-wei.liu2@citrix.com>
	 <20120127192214.GA14437@phenom.dumpdata.com>
	 <1327844561.2911.5.camel@leeds.uk.xensource.com>
	 <20120129213746.GA7164@phenom.dumpdata.com>
	 <1327948024.5553.43.camel@leeds.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"David Vrabel" <david.vrabel@citrix.com>,
	Paul Durrant <Paul.Durrant@citrix.com>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:32158 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752001Ab2A3Saa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 13:30:30 -0500
In-Reply-To: <1327948024.5553.43.camel@leeds.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-01-30 at 18:27 +0000, Wei Liu (Intern) wrote:
> On Sun, 2012-01-29 at 21:37 +0000, Konrad Rzeszutek Wilk wrote:
> > 
> > Sure. I also did some testing with limiting the amount of CPUs and found
> > that 'xl vcpu-set 0 N' make netback not work anymore :-( 
> > > 
> > > 
> 
> I just played with vcpu-set a bit, and I can reproduced this problem.
> That's a race condition.
> 
> One possible fix is remove cond_resched() in the kernel thread. After
> removing that, it fixes the problem (at least for me).
> 
> 
> Wei.
> 
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -994,7 +994,7 @@ int xenvif_kthread(void *data)
>                 wait_event_interruptible(vif->wq,
>                                          rx_work_todo(vif) ||
>                                          kthread_should_stop());
> -               cond_resched();
> +               /* cond_resched(); */
>  
>                 if (kthread_should_stop())
>                         break;
> 
> 

Hmm... Here it comes again. Ignore this fix. It's more complicated than
I thought.


Wei.
