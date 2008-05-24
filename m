From: James Chapman <jchapman@katalix.com>
Subject: Re: network interface *name* alias support?
Date: Sat, 24 May 2008 10:15:16 +0100
Message-ID: <4837DCA4.5070806@katalix.com>
References: <alpine.LNX.1.10.0805231817100.25193@fbirervta.pbzchgretzou.qr> <4836FB73.2010709@intel.com> <4837026A.6000702@hp.com> <1211569604.11907.37.camel@perihelion> <20080523225435.GT20815@postel.suug.ch> <1211603155.11907.79.camel@perihelion> <alpine.LNX.1.10.0805240646380.19084@fbirervta.pbzchgretzou.qr> <20080524051630.GD20890@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Jon Masters <jonathan@jonmasters.org>,
	Thomas Graf <tgraf@suug.ch>, Rick Jones <rick.jones2@hp.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>, johnathan@jonmasters.org,
	netdev@vger.kernel.org, dwmw2@infradead.org
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:33147 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753164AbYEXJPg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 May 2008 05:15:36 -0400
In-Reply-To: <20080524051630.GD20890@auslistsprd01.us.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matt Domsch wrote:
> On Sat, May 24, 2008 at 06:53:17AM +0200, Jan Engelhardt wrote:
>> On Saturday 2008-05-24 06:25, Jon Masters wrote:
>>> I guess that would also work quite nicely for what I want to do, but the
>>> problem is that this will require either:
>>>
>>> *). The kernel decodes the DMI extension directly.
> 
> which is pretty easy to do.
> 
>> *). We can first inform each device which slot it is in (set the slot).
>>> My intention is to implement whatever seems reasonable, and my reason
>>> for asking is that I am not a networking maintainer, so I want to know
>>> what seems reasonable :)
>> Why are we even looking at slot numbers? I do not think there is any
>> guarantee that the order of slots as a human would recognize them on
>> the board must always correspond to a monotonically increasing linear
>> function.
> 
> The guarantee comes from the SMBIOS tables describing the slot
> physically, including the label on the motherboard for it, as well as
> the new SMBIOS table bits in the 2.6 spec that provide the linkage
> between a PCI domain/bus/device/function to slot (or embedded)
> mapping.  New type 41, and extended type 9, can provide this linkage.
> Dell late-model servers implement this in their BIOS.
> 
> Just to throw a wrench in, look at how udev handles disks presently.
> The same physical device is represented in at least 6 different ways:
> /dev/disk/by-{id,label,path,uuid,edd} and /dev/sdX.  There was much
> confusion at first when the /dev/hda IDE driver device names changed
> to /dev/sda with the advent of libata.  People used these alternate
> naming schemes to circumvent the problem.  The by-label and by-uuid
> names didn't change.  Only the tools that hard-coded /dev/hda needed
> to change.
> 
> Conceptually I'm looking for the same thing.  The kernel uses the
> names ethN for most ethernet type devices.  However, there might be
> logical names we would want to assign (public, private, dmz, ...), or
> some form of BIOS-assigned (Gb1, Gb2 to match the label printed on the
> chassis), or some form of physical placement names (eth_embedded1,
> eth_embedded2, eth_slot1_1 and eth_slot1_2 for a multiport card),
> etc.  Right now network devices have essentially one name; yes, you
> can change it, at the peril of breaking all the tools that assume your
> network cards are ethN, just as there was breakage for tools that
> assumed disks were /dev/hda.  But you can't have the multiple names.
> 
> In Fedora 10 rawhide, I'm prepared to change the names of the network
> devices from ethN to eth_s0_1 (first embedded NIC) very early in the
> process and try to find what all breaks.  But it would be really nice
> to be able to assign these other types of names to a device as well,
> ideally without breaking tools that are counting on the ethN names.
> 
> Any options for doing so would be appreciated.

I can see why netdev name aliases might be useful but there are 
potential usability issues. One example is a user who tries to name a 
device eth_s0_1 and gets an error that the device already exists 
(because an alias already exists with that name), yet ifconfig etc 
doesn't list a device with that name. Confusion ensues. Also, kernel 
logs will use the real name in messages, which makes it harder for the 
user to locate messages of her device if she only knows it by its 
aliased name.

Wouldn't it be better to fix any applications that can't handle renamed 
devices?

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

