From: "Ronciak, John" <john.ronciak@intel.com>
Subject: RE: RFC: NAPI packet weighting patch
Date: Thu, 2 Jun 2005 17:11:20 -0700
Message-ID: <468F3FDA28AA87429AD807992E22D07E0450BFDB@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <shemminger@osdl.org>, <hadi@cyberus.ca>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>, <netdev@oss.sgi.com>,
        <Robert.Olsson@data.slu.se>,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Jon Mason" <jdmason@us.ibm.com>, "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I like this idea as well but I do an issue with it.  How would this
stack code find out that the weight is too high and pacekts are being
dropped (not being polled fast enough)?  It would have to check the
controller stats to see the error count increasing for some period.  I'm
not sure this is workable unless we have some sort of feedback which the
driver could send up (or set) saying that this is happening and the
dynamic weight code could take into acount.

Comments?

Cheers,
John


> -----Original Message-----
> From: Jon Mason [mailto:jdmason@us.ibm.com] 
> Sent: Thursday, June 02, 2005 3:20 PM
> To: David S. Miller
> Cc: shemminger@osdl.org; Ronciak, John; hadi@cyberus.ca; 
> Williams, Mitch A; netdev@oss.sgi.com; 
> Robert.Olsson@data.slu.se; Venkatesan, Ganesh; Brandeburg, Jesse
> Subject: Re: RFC: NAPI packet weighting patch
> 
> 
> On Thursday 02 June 2005 05:12 pm, David S. Miller wrote:
> > From: Jon Mason <jdmason@us.ibm.com>
> > Date: Thu, 2 Jun 2005 16:51:48 -0500
> >
> > > Why not have the driver set the weight to 16/32 
> respectively for the
> > > weight (or better yet, have someone run numbers to find 
> weight that
> > > are closer to what the adapter can actually use)?  While these
> > > numbers may not be optimal for every system, this is much better
> > > that the current system, and would only require 5 or so 
> extra lines
> > > of code per NAPI enabled driver.
> >
> > Why do this when we can adjust the weight in one spot,
> > namely the upper level NAPI ->poll() running loop?
> >
> > It can measure the overhead, how many packets processed, etc.
> > and make intelligent decisions based upon that.  This is a CPU
> > speed, memory speed, I/O bus speed, and link speed agnostic
> > solution.
> >
> > The driver need not take any part in this, and the scheme will
> > dynamically adjust to resource usage changes in the system.
> 
> Yes, a much better idea to do this generically.  I 100% agree 
> with you.
> 
