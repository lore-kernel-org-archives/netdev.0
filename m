From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [Fwd: [E1000] NAPI re-insertion w/ changes]
Date: Tue, 1 Apr 2003 16:16:51 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030401211651.GA23739@gtf.org>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010107D30D@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, Jason Lunz <lunz@falooley.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
Content-Disposition: inline
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E010107D30D@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Apr 01, 2003 at 09:47:55AM -0800, Feldman, Scott wrote:
> > A better approximation I think but probably not the last...
> 
> Thanks for you help guys!  I broke NAPI (don't hate me) and then went on
> vacation, so I apologize for not responding sooner.  I like what you've
> come up with here, so I'll turn the patch around for Jeff to update 2.5
> e1000.
> 
> > +       e1000_clean_tx_irq(adapter);
> > +       e1000_clean_rx_irq(adapter, &work_done, work_to_do);
> 
> Just curious, why give priority to Tx over Rx?

TX frees skbs, RX allocates skbs.

You lessen the chance of allocation failure or "additional work" being
performed by the allocator when you do it in this order.

	Jeff
