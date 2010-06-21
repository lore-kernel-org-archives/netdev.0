From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH net-next-2.6] sfc: Implement ethtool register dump operation
Date: Mon, 21 Jun 2010 14:08:51 -0400
Message-ID: <4C1FAAB3.8000403@garzik.org>
References: <1277125613.2100.9.camel@achroite.uk.solarflarecom.com> <4C1FA3C1.4020006@garzik.org> <1277142725.2100.36.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:64610 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753365Ab0FUSIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 14:08:54 -0400
Received: by gxk26 with SMTP id 26so1027788gxk.19
        for <netdev@vger.kernel.org>; Mon, 21 Jun 2010 11:08:53 -0700 (PDT)
In-Reply-To: <1277142725.2100.36.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/21/2010 01:52 PM, Ben Hutchings wrote:
> On Mon, 2010-06-21 at 13:39 -0400, Jeff Garzik wrote:
>> On 06/21/2010 09:06 AM, Ben Hutchings wrote:
>>> Signed-off-by: Ben Hutchings<bhutchings@solarflare.com>
>>> ---
>>>    drivers/net/sfc/ethtool.c |   16 +++
>>>    drivers/net/sfc/io.h      |    7 +
>>>    drivers/net/sfc/nic.c     |  266 +++++++++++++++++++++++++++++++++++++++++++++
>>>    drivers/net/sfc/nic.h     |    3 +
>>>    4 files changed, 292 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
>>> index 22026bf..81b7f39 100644
>>> --- a/drivers/net/sfc/ethtool.c
>>> +++ b/drivers/net/sfc/ethtool.c
>>> @@ -242,6 +242,20 @@ static void efx_ethtool_get_drvinfo(struct net_device *net_dev,
>>>    	strlcpy(info->bus_info, pci_name(efx->pci_dev), sizeof(info->bus_info));
>>>    }
>>>
>>> +static int efx_ethtool_get_regs_len(struct net_device *net_dev)
>>> +{
>>> +	return efx_nic_get_regs_len(netdev_priv(net_dev));
>>> +}
>>> +
>>> +static void efx_ethtool_get_regs(struct net_device *net_dev,
>>> +				 struct ethtool_regs *regs, void *buf)
>>> +{
>>> +	struct efx_nic *efx = netdev_priv(net_dev);
>>> +
>>> +	regs->version = efx->type->revision;
>>> +	efx_nic_get_regs(efx, buf);
>>
>> regs->version is really the version of hardware register dump exported
>> to userspace.  You might want to hardcode this in the driver, to be
>> changed when efx_nic_regs[] array changes, rather than tying
>> regs->version directly to the SFC hardware architecture revision.
>>
>> However, if that limitation is OK with you, ie. ethtool register dump
>> code will change when h/w arch rev changes, then
>
> This is exactly what we want, as the set of defined registers (and
> fields within each register) will change in each architecture revision.
> (It may not change in each chip revision, but efx_nic_type::revision is
> supposed to reflect the architecture revision.)
>
> Although this code doesn't include an explicit format version, we can
> consider the current format to be version 0 and increment it if we ever
> want to make changes to the format for existing NIC revisions.

Yep -- that's the intented purpose.  If you ever want to dump additional 
registers or information, it might be useful to avoid a hard coupling 
with the hardware arch revision.

Either way is fine, of course.

	Jeff




