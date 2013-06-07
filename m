From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: Generic interface to make physical port number used by a netdevice
 available to user space
Date: Fri, 07 Jun 2013 07:59:57 -0700
Message-ID: <51B1F56D.5000007@intel.com>
References: <20130522075331.GA1363@fedora-17-guest.blr.amer.dell.com> <20130523093421.3b20a0bd@nehalam.linuxnetplumber.net> <E31FB011129F30488D5861F383904915210B96144A@BLRX7MCDC201.AMER.DELL.COM> <20130531121201.GA1311@fedora-17-guest.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Narendra_K@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:20871 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752432Ab3FGPAJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jun 2013 11:00:09 -0400
In-Reply-To: <20130531121201.GA1311@fedora-17-guest.blr.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/31/2013 5:13 AM, Narendra_K@Dell.com wrote:
> On Mon, May 27, 2013 at 06:39:00PM +0530, Narendra_K@Dell.com wrote:
>>
>>> -----Original Message-----
>>> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
>>> Sent: Thursday, May 23, 2013 10:04 PM
>>> To: K, Narendra
>>> Cc: netdev@vger.kernel.org
>>> One idea would be to reuse the mostly outdated if_port field.
>>> As far as I can see only drivers using it are legacy drivers which support
>> AUI vs.
>>> TP back in the old bad days of BNC Ethernet.
>>
>> Hi Stephen, thank you.
>>
>> I think if_port or dev_id would be fine. The difference seems to be  that
>> dev_id is already exported to sysfs.
>>
>
> I think the following options could be explored -
>
> 1. dev_id:
> Do not initialize it to -1, but use it to indicate physical port number
> used by netdevice.
>
> It is currently being used for indicating physical port number and
> is also being used to differentiate OS instances as noted here.
> http://marc.info/?l=linux-netdev&m=136992115300526&w=2
>

My opinion would be to use dev_id as the comment in netdevice.h suggests
it can be used for this. I'm not sure the addrconf.c bits are still
valid.

If need be you could fix the check in addrconf to check for not -1.

> 2. if_port:
>
> Reuse if_port to indicate physical port number used by a netdevice as
> suggested.
>

Sure you could use this as well but I got more hits with drivers using
this to indicate the media type. I'm guessing this would break KABI for
someone somewhere, but maybe there is a way to work around it. dev_id
seems like an easier problem to me.

> A quick look at the sources seems to indicate that it is also
> being used to indicate the physical port number and data transfer mode.
>
> Used to indicate physical port number by
> 	-drivers/net/ethernet/chelsio/cxgb/cxgb2.c
> 	-drivers/net/ethernet/tehuti/tehuti.c
>
> Used to indicate data transfer mode by
> 	-drivers/net/ethernet/realtek/atp.c
>
> Also, 'if_port' seems to be available to userspace via
> 	-netlink (by rtnl_dump_ifinfo in net/core/rtnetlink.c)
> 	-SIOCGIFMAP ioctl
>
> 3. Add a new field 'physport' to 'struct net_device' and export it to sysfs.

Probably not we already have two fields that seem ill-defined no reason
to add another to the confusion. If you absolutely can't make dev_id or
if_port coherent then maybe but I really think one of the above two will
work.

>
> It would be great to know your thoughts on which of the above would be
> preferable.
>
