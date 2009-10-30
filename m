From: Hannes Reinecke <hare@suse.de>
Subject: Re: [PATCH] udev: create empty regular files to represent net 	interfaces
Date: Fri, 30 Oct 2009 08:45:01 +0100
Message-ID: <4AEA997D.7070205@suse.de>
References: <20091016214024.GA10091@ldl.fc.hp.com> <20091022063619.GB6321@ldl.fc.hp.com> 	<20091027205551.GA31963@auslistsprd01.us.dell.com> <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Domsch <Matt_Domsch@dell.com>, dann frazier <dannf@hp.com>,
	linux-hotplug@vger.kernel.org, Narendra_K@dell.com,
	netdev@vger.kernel.org, Jordan_Hargrave@dell.com,
	Charles_Rose@dell.com, Ben Hutchings <bhutchings@solarflare.com>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kay Sievers wrote:
> On Tue, Oct 27, 2009 at 21:55, Matt Domsch <Matt_Domsch@dell.com> wro=
te:
>> On Thu, Oct 22, 2009 at 12:36:20AM -0600, dann frazier wrote:
>>> Here's a proof of concept to further the discussion..
>>>
>>> The default filename uses the format:
>>>   /dev/netdev/by-ifindex/$ifindex
>>>
>>> This provides the infrastructure to permit udev rules to create ali=
ases for
>>> network devices using symlinks, for example:
>>>
>>>   /dev/netdev/by-name/eth0 -> ../by-ifindex/1
>>>   /dev/netdev/by-biosname/LOM0 -> ../by-ifindex/3
>>>
>>> A library (such as the proposed libnetdevname) could use this infor=
mation
>>> to provide an alias->realname mapping for network utilities.
>> yes, this could work, as IFINDEX is already exported in the uevents,
>> and that's the primary value udev needs to set up the mapping.
>>
>> While I like the little ifindex2name script you've got, I think udev
>> could simply call if_indextoname() to get this, and not call an
>> external program?  I suppose it could be a really really simple
>> external program too.
>=20
> What's the point of all this? Why would udev ever need to find the
> name of a device by the ifindex? The device name is the primary value
> for the kernel events udev acts on.
>=20
>> I'd be fine with this approach.  It has the advantages of not
>> requiring a kernel change at all, and not creating a whole character
>> device which would be useless.  And it doesn't preclude someone in t=
he
>> future from creating a char device for network devices should they s=
o
>> choose.
>>
>> Kay, what say you as udev owner?
>=20
> That all sounds very much like something which will hit us back some
> day. I'm not sure, if udev should publish such dead text files in
> /dev, it does not seem to fit the usual APIs/assumptions where /sys
> and /dev match, and libudev provides access to both. It all sounds
> more like a database for a possible netdevname library, which does no=
t
> need to be public in /dev, right?
>=20
And to throw in some bit of useless information;

I've pondered the idea of persistent device names for network interface=
s
a while back when designing the original layout of the persistent
device naming scheme.

The one reason I didn't to this was that a network interface is
_not_ a file, but rather an abstract type which is known only internall=
y
in the kernel (ie the one exemption from the 'everything is a file'
UNIX rule).
And as udev is primarily concerned with the _files_, using it for
network interfaces would be a workaround at best.

When I were to design this, I would be implementing network interface
_aliases_, so that a network interface could be accessed either by
name or by alias. This mechanism can then be managed by udev, much
like we (ie SUSE) is using it nowadays to assign the network interface
numbers.

But the mechanism for the aliases has to live in the same instance whic=
h
also handles the network interface nowadays, ie the net subsystem of
the kernel. Implementing this in udev is _not_ the way to go.

Cheers,

Hannes

--=20
Dr. Hannes Reinecke		      zSeries & Storage
hare@suse.de			      +49 911 74053 688
SUSE LINUX Products GmbH, Maxfeldstr. 5, 90409 N=C3=BCrnberg
GF: Markus Rex, HRB 16746 (AG N=C3=BCrnberg)
--
To unsubscribe from this list: send the line "unsubscribe linux-hotplug=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
