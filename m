From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tcp_cubic: limit delayed_ack ratio to prevent divide
 error
Date: Fri, 6 May 2011 09:53:59 -0700
Message-ID: <20110506095359.57c4fb38@nehalam>
References: <20110504113351.4643a0c9@nehalam>
	<16668.1304537481@localhost>
	<20110504123738.7bb4d1ee@nehalam>
	<20110504.124053.260068550.davem@davemloft.net>
	<20110504130456.425dee68@nehalam>
	<alpine.WNT.2.00.1105041352020.6048@JBRANDEB-DESK2.amr.corp.intel.com>
	<4DC41EB2.6070404@techboom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	David Miller <davem@davemloft.net>,
	Sangtae Ha <sangtae.ha@gmail.com>,
	Injong Rhee <injongrhee@gmail.com>,
	"Valdis.Kletnieks@vt.edu" <Valdis.Kletnieks@vt.edu>,
	"rdunlap@xenotime.net" <rdunlap@xenotime.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: TB <lkml@techboom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DC41EB2.6070404@techboom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 06 May 2011 12:15:46 -0400
TB <lkml@techboom.com> wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> On 11-05-04 04:53 PM, Brandeburg, Jesse wrote:
> > 
> > 
> > On Wed, 4 May 2011, Stephen Hemminger wrote:
> > 
> >> TCP Cubic keeps a metric that estimates the amount of delayed
> >> acknowledgements to use in adjusting the window. If an abnormally
> >> large number of packets are acknowledged at once, then the update
> >> could wrap and reach zero. This kind of ACK could only
> >> happen when there was a large window and huge number of
> >> ACK's were lost.
> >>
> >> This patch limits the value of delayed ack ratio. The choice of 32
> >> is just a conservative value since normally it should be range of 
> >> 1 to 4 packets.
> >>
> >> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > patch seems fine, but please credit the reporter (lkml@techboom.com) with 
> > reporting the issue with logs, maybe even with Reported-by: and some kind 
> > of reference to the panic message or the email thread in the text or 
> > header?
> 
> We're currently testing the patch on 6 production servers

Thank you, is there some regularity to the failures previously?
