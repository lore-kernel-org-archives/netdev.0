From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] Use firmware provided index to register a network
	interface
Date: Thu, 7 Oct 2010 07:31:58 -0700
Message-ID: <20101007143158.GA14913@kroah.com>
References: <20100922183137.GA7607@auslistsprd01.us.dell.com> <20100922192228.GB29899@kroah.com> <EDA0A4495861324DA2618B4C45DCB3EE6A0AF8@blrx3m08.blr.amer.dell.com> <20100923152730.GA1261@kroah.com> <EDA0A4495861324DA2618B4C45DCB3EE6A0AFD@blrx3m08.blr.amer.dell.com> <20100923163336.GA15603@kroah.com> <20101007141433.GA2641@libnet-test.oslab.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org, Matt_Domsch@Dell.com,
	Charles_Rose@Dell.com, Jordan_Hargrave@Dell.com,
	Vijay_Nijhawan@Dell.com
To: Narendra_K@Dell.com
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101007141433.GA2641@libnet-test.oslab.blr.amer.dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 07, 2010 at 07:44:57PM +0530, Narendra_K@Dell.com wrote:
> On Thu, Sep 23, 2010 at 10:03:36PM +0530, Greg KH wrote:
> >    On Thu, Sep 23, 2010 at 09:20:57PM +0530, Narendra_K@Dell.com wrote:
> >    > > Now trying to change the kernel namespace itself seems like a bad hack
> >    > > around this fact.
> >    > >
> >    >
> >    > The patch does not change the existing kernel name space.
> > 
> >    You are "reordering it", right?
> > 
> >    > It adheres to the existing ethN name space with IFNAMSIZ length
> >    > requirements. The patch only makes sure that eth0 always corresponds
> >    > to what is labeled as 'Gb1' on server chassis, on systems where SMBIOS
> >    > type 41 record is available. And removes the need for any renames for
> >    > the interfaces which have a firmware index assigned by system
> >    > firmware, as the very first name assigned by the kernel will be as
> >    > expected and deterministic.
> > 
> >    And on systems with buggy firmware, what is going to happen here?  And
> >    yes, there will be buggy BIOS tables, we can guarantee that, as this is
> >    not something that Windows supports, right?
> > 
> 
> It took some time to find out the details asked above. Right, windows
> does not use SMBIOS type 41 record to derive names. But as a datapoint,
> windows also has the same problem.

If windows does not use this field, then you can guarantee it will show
up incorrectly in BIOSes and never be tested by manufacturers before
they ship their machines.

> Yes, firmware and BIOS tables can be buggy. How about a command line
> parameter 'no_netfwindex', passing which firmware index will not be
> used to derive ethN names ? That would handle the scenario of buggy
> firmware and names will be derived in the now existing way.

I'd prefer the option never be added in the first place as you are
placing a big burden on people whose machines were working properly on
old kernels, to suddenly have to add a command line option to get their
box to now work again.

And again, as this is a "simple" rename type operation, I still don't
see why you can't just do this from a udev rule, especially if the
firmware information is exported to userspace.  That is where such
"policy" should be added, not within the kernel itself.

thanks,

greg k-h
