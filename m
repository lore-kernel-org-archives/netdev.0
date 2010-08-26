From: Matt Domsch <Matt_Domsch@Dell.com>
Subject: Re: [PATCH] Add firmware label support to iproute2
Date: Thu, 26 Aug 2010 09:10:45 -0500
Message-ID: <20100826141045.GA21770@auslistsprd01.us.dell.com>
References: <20100812173537.GA29784@auslistsprd01.us.dell.com> <20100812141240.417949e2@s6510> <EDA0A4495861324DA2618B4C45DCB3EE612E34@blrx3m08.blr.amer.dell.com> <20100818144124.33a72453@nehalam> <20100819213314.GA26135@auslistsprd01.us.dell.com> <20100819145308.0fa08522@nehalam> <20100825220323.GA12671@auslistsprd01.us.dell.com> <20100825221628.GA24502@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, Narendra_K@Dell.com,
	netdev@vger.kernel.org, Charles_Rose@Dell.com,
	Jordan_Hargrave@Dell.com, linux-pci@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100825221628.GA24502@kroah.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 25, 2010 at 03:16:28PM -0700, Greg KH wrote:
> On Wed, Aug 25, 2010 at 05:03:23PM -0500, Matt Domsch wrote:
> > libnetdevname needs to be able to look up a (PCI) device by label.  It
> > currently does this by glob()ing /sys/class/net/*/device/label to find
> > all network interfaces that have a PCI device label exposed.  There can
> > be arbitrarily many network interfaces, making this a very expensive
> > operation.
> 
> So you want to add code to the kernel to make userspace have an easier
> 'find' path?  I'm all for making stuff easier, but just how "expensive"
> is such an operation today?

it's one newfstatat and one stat for each network interface,
including interfaces for each vlan, which as Stephen had noted,
could be tens of thousands.  Just to test, on a system with ~20k vlans
configured across 5 physical interfaces, the glob() took just over 4
minutes.  Now, that may not be the typical case, but it does show the
scalability problem Stephen is concerned about.

Thanks also for the patch review.  Yes, we'll clean up the items
noted, if we (collectively) come to agreement that this approach to
solve device naming is valid and warranted.  From Stephen's other
comments, we're not quite there yet. :-)

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
