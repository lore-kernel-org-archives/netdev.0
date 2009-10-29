From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] udev: create empty regular files to represent net
	interfaces
Date: Thu, 29 Oct 2009 16:49:35 +0000
Message-ID: <1256834975.2827.63.camel@achroite>
References: <20091016214024.GA10091@ldl.fc.hp.com>
	 <20091022063619.GB6321@ldl.fc.hp.com>
	 <20091027205551.GA31963@auslistsprd01.us.dell.com>
	 <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com>
	 <20091029131125.GA13809@auslistsprd01.us.dell.com>
	 <20091029142554.GA16869@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Domsch <Matt_Domsch@dell.com>,
	Kay Sievers <kay.sievers@vrfy.org>,
	dann frazier <dannf@hp.com>, linux-hotplug@vger.kernel.org,
	Narendra_K@dell.com, netdev@vger.kernel.org,
	Jordan_Hargrave@dell.com, Charles_Rose@dell.com
To: Greg KH <greg@kroah.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20091029142554.GA16869@kroah.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2009-10-29 at 07:25 -0700, Greg KH wrote:
> On Thu, Oct 29, 2009 at 08:11:25AM -0500, Matt Domsch wrote:
> > Netdev team - are you in agreement that having multiple names to
> > address the same netdevice is a worthwhile thing to add, to allow a
> > variety of naming schemes to exist simultaneously?  If not, this wh=
ole
> > discussion will be moot, and my basic problem, that the ethX naming
> > convention is nondeterministic, but we need determinism, remains
> > unresolved.
>=20
> I'm still totally confused as to why you think this.  What is wrong w=
ith
> what we do today, which is name network devices in a deterministic
> manner by their MAC in userspace?  That name goes into the kernel, an=
d
> everyone uses the same name and is happy.
>=20
> If you don't like naming by MAC, then pick some other deterministic
> naming scheme that works for your hardware and write udev rules for i=
t.
>=20
> You could easily name them in a way that could keep the lowest number
> (eth0) for the lowest PCI id if you so desired and your BIOS guarante=
ed
> it.
>=20
> This way the kernel has only one name, and so does userspace, and
> everyone is happy.

=EF=BB=BFI thought there was a general trend in udev development to pro=
vide
default rules that work for almost everyone, so few users/administrator=
s
need to override or add to them.  Compare disks and net devices:

1. Stable kernel device id
Disks: block device number
=EF=BB=BFNet devices: ifindex

2. Unique identifier (across reboot)
Disks: label or UUID (each with limitations)
Net devices: (MAC address, subtype)
=EF=BB=BF
3. Name assignment mechanism
Disks: kernel suggests a name; udev can assign any number
=EF=BB=BFNet devices: kernel assigns a single name; udev can override i=
t

4. Default name assignment policy
Disks: names disk by device path (id), label and UUID
=EF=BB=BFNet devices: assigns arbitrary stable names per (MAC address, =
subtype)

5. Naming by users
Disks: user can identify by any method without having to choose on a
system-wide basis
Net devices: user must identify by single name; policy can be overridde=
n
on a system-wide basis

I fully understand the technical reasons for differences 3-5, but why
should users have to put up with it?

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-hotplug=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
