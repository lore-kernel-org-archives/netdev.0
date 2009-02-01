From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Sat, 31 Jan 2009 16:51:19 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0901311639530.3067@localhost.localdomain>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <200901312346.35265.rjw@sisk.pl> <alpine.LFD.2.00.0901311450550.2978@localhost.localdomain> <200902010111.08433.rjw@sisk.pl> <alpine.LFD.2.00.0901311623520.3067@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Parag Warudkar <parag.lkml@gmail.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754349AbZBAAwL@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.0901311623520.3067@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sat, 31 Jan 2009, Linus Torvalds wrote:
> 
> For a USB host controller, for example, it really could make sense to do 
> that - just leave all the core host controller stuff running, and the only 
> thing the "suspend()" callback does is to send the commands to the actual 
> devices, it doesn't necessarily touch the host controller itself at all.

Same is quite likely true of things like video graphics adapters. Again, 
for all the same reasons. Think about all those fbcon drivers. They will 
use DMA for things. And again, there are very compelling debugging reasons 
to not suspend them for real until suspend_late (if even then).

		Linus
