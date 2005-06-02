From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: NAPI packet weighting patch
Date: Thu, 02 Jun 2005 08:26:46 -0400
Message-ID: <1117715207.6050.21.camel@localhost.localdomain>
References: <1117241786.6251.7.camel@localhost.localdomain>
	 <200505311707.54487.jdmason@us.ibm.com>
	 <20050531.151443.74564699.davem@davemloft.net>
	 <200505311828.44304.jdmason@us.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, mitch.a.williams@intel.com,
        shemminger@osdl.org, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        john.ronciak@intel.com, ganesh.venkatesan@intel.com,
        jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon Mason <jdmason@us.ibm.com>
In-Reply-To: <200505311828.44304.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-31-05 at 18:28 -0500, Jon Mason wrote:
> On Tuesday 31 May 2005 05:14 pm, David S. Miller wrote:
> > From: Jon Mason <jdmason@us.ibm.com>
> > Date: Tue, 31 May 2005 17:07:54 -0500
> >
> > > Of course some performace analysis would have to be done to determine the
> > > optimal numbers for each speed/duplexity setting per driver.
> >
> > per cpu speed, per memory bus speed, per I/O bus speed, and add in other
> > complications such as NUMA
> >
> > My point is that whatever experimental number you come up with will be
> > good for that driver on your systems, not necessarily for others.
> >
> > Even within a system, whatever number you select will be the wrong
> > thing to use if one starts a continuous I/O stream to the SATA
> > controller in the next PCI slot, for example.
> >
> > We keep getting bitten by this, as the Altix perf data continually shows,
> > and we need to absolutely stop thinking this way.
> >
> > The way to go is to make selections based upon observed events and
> > mesaurements.
> 
> I'm not arguing against a /proc entry to tune dev->weight for those sysadmins 
> advanced enough to do that.  I am arguing that we can make the driver smarter 
> (at little/no cost)  for "out of the box" users.
> 

What is the point of making the driver "smarter"? 
Recall, the algorithm used to schedule the netdevices is based on an
extension of Weighted Round Robin from Varghese et al known as DRR (ask
gooogle for details).
The idea is to provide fairness amongst many drivers. As an example, if
you have a gige driver it shouldnt be taking all the resources at the
expense of starving the fastether driver.
If the admin wants one driver to be more "important" than the other,
s/he will make sure it has a higher weight.

cheers,
jamal
