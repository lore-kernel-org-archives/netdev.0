From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 1/3] net: add ndo to get id of physical port
 of the device
Date: Sun, 21 Jul 2013 23:02:30 +0200
Message-ID: <20130721210230.GA1558@minipsycho.orion>
References: <1374342834-10814-1-git-send-email-jiri@resnulli.us>
 <1374342834-10814-2-git-send-email-jiri@resnulli.us>
 <CAJZOPZJiL4hJV4eKKsZrLseJF_sSRjYVsstgT+NLsoeCXWKh_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, Narendra_K@dell.com,
	bhutchings@solarflare.com, john.r.fastabend@intel.com
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:49659 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756064Ab3GUVCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 17:02:35 -0400
Received: by mail-ee0-f51.google.com with SMTP id e52so3473923eek.10
        for <netdev@vger.kernel.org>; Sun, 21 Jul 2013 14:02:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJZOPZJiL4hJV4eKKsZrLseJF_sSRjYVsstgT+NLsoeCXWKh_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Jul 21, 2013 at 10:26:32PM CEST, or.gerlitz@gmail.com wrote:
>On Sat, Jul 20, 2013 at 8:53 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>
>> This patch adds a ndo for getting physical port of the device. Driver
>> which is aware of being virtual function of some physical port should
>> implement this ndo.
>
>
>Do you mean virtual function literally?  that is in the PCI IOV aspect?

This is applicable not only for IOV, nbut for other solutions (NPAR,
multichannel) as well. Basically if there is possible to have multiple
netdevs on the single hw port.

>
>
>>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  include/linux/netdevice.h | 20 ++++++++++++++++++++
>>  net/core/dev.c            | 18 ++++++++++++++++++
>>  2 files changed, 38 insertions(+)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 0741a1e..726dec2 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -728,6 +728,16 @@ struct netdev_fcoe_hbainfo {
>>  };
>>  #endif
>>
>> +#define MAX_PHYS_PORT_ID_LEN 32
>> +
>> +/* This structure holds a unique identifier to identify the
>> + * physical port used by a netdevice.
>> + */
>> +struct netdev_phys_port_id {
>> +       unsigned char id[MAX_PHYS_PORT_ID_LEN];
>> +       unsigned char id_len;
>> +};
>> +
>>  /*
>>   * This structure defines the management hooks for network devices.
>>   * The following hooks can be defined; unless noted otherwise, they are
>> @@ -932,6 +942,12 @@ struct netdev_fcoe_hbainfo {
>>   *     that determine carrier state from physical hardware properties (eg
>>   *     network cables) or protocol-dependent mechanisms (eg
>>   *     USB_CDC_NOTIFY_NETWORK_CONNECTION) should NOT implement this function.
>> + *
>> + * int (*ndo_get_phys_port_id)(struct net_device *dev,
>> + *                            struct netdev_phys_port_id *ppid);
>> + *     Called to get ID of physical port of this device. If driver does
>> + *     not implement this, it is assumed that the hw is not able to have
>> + *     multiple net devices on single physical port.
>>   */
>
>I am not sure to understand what is assumed here and why it it mandated.

It is not mandated. The key is to provide clear info to user that couple of
netdevs share the same port. The goal is to have this implemented for
all drivers which are able to have more netdevs on single hw port.

Jiri
