From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [net-next 01/13] e1000e: Fix no connectivity when driver loaded
 with cable out
Date: Tue, 1 Apr 2014 18:07:35 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1404011807080.14882@ionos.tec.linutronix.de>
References: <1396308899-20926-1-git-send-email-jeffrey.t.kirsher@intel.com> <1396308899-20926-2-git-send-email-jeffrey.t.kirsher@intel.com> <CAOMZO5Ar9QrqsnOjb=V_hLB9Rz51jBMByz=jOMH2iAHi+OfbjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	David Ertman <davidx.m.ertman@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	gospo@redhat.com, sassmann@redhat.com
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:46838 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190AbaDAQH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 12:07:28 -0400
In-Reply-To: <CAOMZO5Ar9QrqsnOjb=V_hLB9Rz51jBMByz=jOMH2iAHi+OfbjA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Apr 2014, Fabio Estevam wrote:

> On Mon, Mar 31, 2014 at 8:34 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > From: David Ertman <davidx.m.ertman@intel.com>
> >
> > In commit da1e2046e5, the flow for enabling/disabling an Si errata
> > workaround (e1000_lv_jumbo_workaround_ich8lan) was changed to fix a problem
> > with iAMT connections dropping on interface down with jumbo frames set.
> > Part of this change was to move the function call disabling the workaround
> > to e1000e_down() from the e1000_setup_rctl() function.  The mechanic for
> > disabling of this workaround involves writing several MAC and PHY registers
> > back to hardware defaults.
> >
> > After this commit, when the driver is loaded with the cable out, the PHY
> > registers are not programmed with the correct default values.  This causes
> > the device to be capable of transmitting packets, but is unable to recieve
> > them until this workaround is called.
> >
> > The flow of e1000e's open code relies upon calling the above workaround to
> > expicitly program these registers either with jumbo frame appropriate settings
> > or h/w defaults on 82579 and newer hardware.
> >
> > Fix this issue by adding logic to e1000_setup_rctl() that not only calls
> > e1000_lv_jumbo_workaround_ich8lan() when jumbo frames are set, to enable the
> > workaround, but also calls this function to explicitly disable the workaround
> > in the case that jumbo frames are not set.
> >
> > Signed-off-by: Dave Ertman <davidx.m.ertman@intel.com>
> > Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> Maybe a Reported-by tag from Thomas is missing?

Plus a Tested-by: me :)
