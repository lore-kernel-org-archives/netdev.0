From: Jeff Garzik <jeff@garzik.org>
Subject: Re: the future of ethtool
Date: Mon, 15 Nov 2010 17:49:33 -0500
Message-ID: <4CE1B8FD.3000007@garzik.org>
References: <4CE18CEA.5080502@garzik.org> <1289852326.2586.32.camel@bwh-desktop> <20101115124428.7b857ccb@nehalam> <1289855642.2586.38.camel@bwh-desktop>  <20101115131453.16958d68@nehalam> <1289857936.2586.51.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:60988 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757915Ab0KOWtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 17:49:36 -0500
Received: by vws13 with SMTP id 13so6299vws.19
        for <netdev@vger.kernel.org>; Mon, 15 Nov 2010 14:49:35 -0800 (PST)
In-Reply-To: <1289857936.2586.51.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/15/2010 04:52 PM, Ben Hutchings wrote:
> On Mon, 2010-11-15 at 13:14 -0800, Stephen Hemminger wrote:
>> On Mon, 15 Nov 2010 21:14:02 +0000
>> Ben Hutchings<bhutchings@solarflare.com>  wrote:
>>
>>> On Mon, 2010-11-15 at 12:44 -0800, Stephen Hemminger wrote:
>>> [...]
>>>> My views are simple:
>>>>
>>>> Ethtool needs to be an extension of existing netlink API for interfaces.
>>>>    - handles multiple values per transaction
>>>>    - extensible
>>> [...]
>>>
>>> Are you suggesting to send and receive the existing ethtool command and
>>> result structures (with some wrapping) through netlink?  Or some larger
>>> change to the API?
>>
>> The existing ioctl base API should be kept as legacy and something
>> better developed.
>
> So you're saying: expose all new operations through netlink (and only
> netlink) while keeping the old operations exposed only through ioctl?
> That's hardly an improvement as it means ethtool or any other
> configuration utility will have to support both APIs indefinitely.

s/only//   I don't think Stephen is suggesting sending _some_ ops 
through netlink and others through old-ioctl.  That's just silly.  Any 
new netlink interface should transit all existing ETHTOOL_xxx 
commands/structures.

But presumably, one would have the ability to send multiple ETHTOOL_xxx 
bundled together into a single netlink transaction, facilitating the 
kernel's calling of struct ethtool_ops'
	->begin()
	... first operation specified by userspace via netlink ...
	... second operation specified by userspace via netlink ...
	... etc.
	->end()

The underlying struct ethtool_ops remains unchanged; you're only 
changing the transit method.

Thus, the ethtool userspace utility would switch entirely to netlink, 
while the ioctl processing code remains for binary compatibility.

Or... ethtool userspace utility could remain unchanged, and a new 
'nictool' utility provides the same features but with (a) a new CLI and 
(b) exclusively uses netlink rather than ioctl.

	Jeff


