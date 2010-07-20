From: Stefan Assmann <sassmann@redhat.com>
Subject: Re: [PATCH net-next] sysfs: add entry to indicate network interfaces
 with random MAC address
Date: Tue, 20 Jul 2010 13:47:03 +0200
Message-ID: <4C458CB7.3030508@redhat.com>
References: <4C457F72.8090708@redhat.com> <1279624844.2110.3.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	davem@davemloft.net, Andy Gospodarek <gospo@redhat.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Casey Leedom <leedom@chelsio.com>,
	Harald Hoyer <harald@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32022 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758282Ab0GTLrO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jul 2010 07:47:14 -0400
In-Reply-To: <1279624844.2110.3.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20.07.2010 13:20, Ben Hutchings wrote:
> On Tue, 2010-07-20 at 12:50 +0200, Stefan Assmann wrote:
>> From: Stefan Assmann <sassmann@redhat.com>
>>
>> Reserve a bit in struct net_device to indicate whether an interface
>> generates its MAC address randomly, and expose the information via
>> sysfs.
>> May look like this:
>> /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/net/eth0/ifrndmac
>>
>> By default the value of ifrndmac is 0. Any driver that generates the MAC
>> address randomly should return a value to 1.
> 
> The name should incorporate 'address', not 'mac', for consistency with
> the generic 'address' attribute.

We can call it "ifrndhwaddr" if that's more consistent.

> 
> What about devices that 'steal' MAC addresses from slave devices?
> Currently I believe udev has special cases for them but ideally these
> drivers would indicate explicitly that their addresses are not stable
> identifiers (even though they aren't random).

It's really up to the driver to decide whether it makes sense to set the
flag or not. The question is what should udev do with these MAC address
stealing devices apart from ignoring them? Sorry I have no higher
insight into it.
This flag has the purpose to allow udev to explicitly handle devices
that generate their MAC address randomly and generate a persistent
rule based on the device path instead of the MAC address.
I'm open for suggestions but I'm not sure we can handle both cases with
a single flag.

JFYI this is an alternative approach to changing the kernel name of VFs
to vfeth. The advantage of this way should be that we don't break any
user-space applications that rely on network interfaces being names
"ethX". Actually this goes in the direction of "fixing udev" which was
what you asked for in your comment on my first patch concering vfeth. :)

> 
> [...]
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index b626289..2ea0298 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -845,6 +845,7 @@ struct net_device {
>>  #define NETIF_F_FCOE_MTU	(1 << 26) /* Supports max FCoE MTU, 2158 bytes*/
>>  #define NETIF_F_NTUPLE		(1 << 27) /* N-tuple filters supported */
>>  #define NETIF_F_RXHASH		(1 << 28) /* Receive hashing offload */
>> +#define NETIF_F_RNDMAC		(1 << 29) /* Interface with random MAC address */
> [...]
> 
> This is not really a feature, and we are running out of real feature
> bits.  Can you find somewhere else to put this flag?

Actually Dave Miller suggested to put it there. What other place is
there to put it?

  Stefan
--
Stefan Assmann         | Red Hat GmbH
Software Engineer      | Otto-Hahn-Strasse 20, 85609 Dornach
                       | HR: Amtsgericht Muenchen HRB 153243
                       | GF: Brendan Lane, Charlie Peters,
sassmann at redhat.com |     Michael Cunningham, Charles Cachera
