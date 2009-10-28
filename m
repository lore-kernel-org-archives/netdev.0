From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [PATCH] udev: create empty regular files to represent net
	interfaces
Date: Wed, 28 Oct 2009 09:23:57 +0100
Message-ID: <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com>
References: <20091016214024.GA10091@ldl.fc.hp.com> <20091022063619.GB6321@ldl.fc.hp.com>
	<20091027205551.GA31963@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dann frazier <dannf@hp.com>, linux-hotplug@vger.kernel.org,
	Narendra_K@dell.com, netdev@vger.kernel.org,
	Jordan_Hargrave@dell.com, Charles_Rose@dell.com,
	Ben Hutchings <bhutchings@solarflare.com>
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20091027205551.GA31963@auslistsprd01.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 27, 2009 at 21:55, Matt Domsch <Matt_Domsch@dell.com> wrote=
:
> On Thu, Oct 22, 2009 at 12:36:20AM -0600, dann frazier wrote:
>> Here's a proof of concept to further the discussion..
>>
>> The default filename uses the format:
>> =C2=A0 /dev/netdev/by-ifindex/$ifindex
>>
>> This provides the infrastructure to permit udev rules to create alia=
ses for
>> network devices using symlinks, for example:
>>
>> =C2=A0 /dev/netdev/by-name/eth0 -> ../by-ifindex/1
>> =C2=A0 /dev/netdev/by-biosname/LOM0 -> ../by-ifindex/3
>>
>> A library (such as the proposed libnetdevname) could use this inform=
ation
>> to provide an alias->realname mapping for network utilities.
>
> yes, this could work, as IFINDEX is already exported in the uevents,
> and that's the primary value udev needs to set up the mapping.
>
> While I like the little ifindex2name script you've got, I think udev
> could simply call if_indextoname() to get this, and not call an
> external program? =C2=A0I suppose it could be a really really simple
> external program too.

What's the point of all this? Why would udev ever need to find the
name of a device by the ifindex? The device name is the primary value
for the kernel events udev acts on.

> I'd be fine with this approach. =C2=A0It has the advantages of not
> requiring a kernel change at all, and not creating a whole character
> device which would be useless. =C2=A0And it doesn't preclude someone =
in the
> future from creating a char device for network devices should they so
> choose.
>
> Kay, what say you as udev owner?

That all sounds very much like something which will hit us back some
day. I'm not sure, if udev should publish such dead text files in
/dev, it does not seem to fit the usual APIs/assumptions where /sys
and /dev match, and libudev provides access to both. It all sounds
more like a database for a possible netdevname library, which does not
need to be public in /dev, right?

Thanks,
Kay
--
To unsubscribe from this list: send the line "unsubscribe linux-hotplug=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
