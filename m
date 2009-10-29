From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] udev: create empty regular files to represent net
	interfaces
Date: Thu, 29 Oct 2009 09:52:59 -0700
Message-ID: <20091029165259.GA9692@kroah.com>
References: <20091016214024.GA10091@ldl.fc.hp.com> <20091022063619.GB6321@ldl.fc.hp.com> <20091027205551.GA31963@auslistsprd01.us.dell.com> <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com> <20091029131125.GA13809@auslistsprd01.us.dell.com> <20091029142554.GA16869@kroah.com> <EDA0A4495861324DA2618B4C45DCB3EE589662@blrx3m08.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt_Domsch@Dell.com, kay.sievers@vrfy.org, dannf@hp.com,
	linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	Jordan_Hargrave@Dell.com, Charles_Rose@Dell.com,
	bhutchings@solarflare.com
To: Narendra_K@Dell.com
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <EDA0A4495861324DA2618B4C45DCB3EE589662@blrx3m08.blr.amer.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 29, 2009 at 10:14:08PM +0530, Narendra_K@Dell.com wrote:
> 
> >> Netdev team - are you in agreement that having multiple names to 
> >> address the same netdevice is a worthwhile thing to add, to allow a 
> >> variety of naming schemes to exist simultaneously?  If not, 
> >this whole 
> >> discussion will be moot, and my basic problem, that the ethX naming 
> >> convention is nondeterministic, but we need determinism, remains 
> >> unresolved.
> >
> >I'm still totally confused as to why you think this.  What is 
> >wrong with what we do today, which is name network devices in 
> >a deterministic manner by their MAC in userspace?  That name 
> >goes into the kernel, and everyone uses the same name and is happy.
> 
> The interface name as assigned by the OS is determined by how the
> interface is named first during the OS installation.

That sounds like a distro install issue to me, why not fix it there?

> This name is made persistent by associating the name with it's MAC
> address in userspace, either by udev or ifcfg-eth files. In cases
> where there are one or more add-in cards along with one or more
> integrated cards (Lan on Motherboard), the integrated port 1, which is
> designated as Gb1 on the chassis may or may not get the name "eth0".

Exactly, who cares about "eth0" as a name?

> And that is the customer expectation, most of the times.

Then again, fix the installer to allow you to either pick the name, or
specify some rule in which to use to pick the name.

> Unattended installs and large scale image based installs are the most
> affected scenarios. 

Then fix the installer.

> >If you don't like naming by MAC, then pick some other 
> >deterministic naming scheme that works for your hardware and 
> >write udev rules for it.
> >
> >You could easily name them in a way that could keep the lowest number
> >(eth0) for the lowest PCI id if you so desired and your BIOS 
> >guaranteed it.
> >
> 
> This is how the lspci tree view on a PER710 (PowerEdge R710) server with
> Four BCM5709 integrated NIC ports and One add-in Intel NIC port looks
> like. The integrated ports are always found before the add-in nic (or
> nics) by the BIOS consistently and BIOS guarantees it across every
> reboot.

Great, then you are set to write a udev rule for this, right?

> If the OS also found and named the network ports in the same manner,
> then there is no issue as integrated NIC port 1, designated Gb1 on the
> chassis, is always named as "eth0". But the observation is that, it is
> not the case always.

Sure, it's never guaranteed by the kernel that this will happen,
especially as we speed up the boot process by doing things async.

So again, just fix your installer, or write a new udev rule for your
hardware platforms, or both.  But I still fail to see why multiple names
for network devices _in the kernel_ is a solution for your issue.

> In such cases, pathnames like Embedded_NIC_1 -> eth[01..], point to the
> right interface, and communicate a more meaningful name without any
> state embedded in them.

Yes, pathnames would be nice to work for network devices, but
unfortunatly, that's just not how network devices work :)

thanks,

greg k-h
