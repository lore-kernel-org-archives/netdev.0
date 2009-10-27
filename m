From: Matt Domsch <Matt_Domsch@Dell.com>
Subject: Re: [PATCH] udev: create empty regular files to represent net interfaces
Date: Tue, 27 Oct 2009 15:55:51 -0500
Message-ID: <20091027205551.GA31963@auslistsprd01.us.dell.com>
References: <20091016214024.GA10091@ldl.fc.hp.com> <20091022063619.GB6321@ldl.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hotplug@vger.kernel.org, Narendra_K@Dell.com,
	netdev@vger.kernel.org, Jordan_Hargrave@Dell.com,
	Charles_Rose@Dell.com, Ben Hutchings <bhutchings@solarflare.com>
To: dann frazier <dannf@hp.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091022063619.GB6321@ldl.fc.hp.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 22, 2009 at 12:36:20AM -0600, dann frazier wrote:
> Here's a proof of concept to further the discussion..
> 
> The default filename uses the format:
>   /dev/netdev/by-ifindex/$ifindex
> 
> This provides the infrastructure to permit udev rules to create aliases for
> network devices using symlinks, for example:
> 
>   /dev/netdev/by-name/eth0 -> ../by-ifindex/1
>   /dev/netdev/by-biosname/LOM0 -> ../by-ifindex/3
> 
> A library (such as the proposed libnetdevname) could use this information
> to provide an alias->realname mapping for network utilities.

yes, this could work, as IFINDEX is already exported in the uevents,
and that's the primary value udev needs to set up the mapping.

While I like the little ifindex2name script you've got, I think udev
could simply call if_indextoname() to get this, and not call an
external program?  I suppose it could be a really really simple
external program too.

I'd be fine with this approach.  It has the advantages of not
requiring a kernel change at all, and not creating a whole character
device which would be useless.  And it doesn't preclude someone in the
future from creating a char device for network devices should they so
choose.

Kay, what say you as udev owner?

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist, Dell Office of the CTO
linux.dell.com & www.dell.com/linux
