From: Philippe Reynes <tremyfr@gmail.com>
Subject: Re: [PATCH] net: usb: asix88179_178a: use new api ethtool_{get|set}_link_ksettings
Date: Mon, 13 Mar 2017 08:34:19 +0100
Message-ID: <CAC=8w93j9rYmqTY5hzCt12tknFwC44QRO6PpNqyNmcoO6-R9Bg@mail.gmail.com>
References: <1489338156-18632-1-git-send-email-tremyfr@gmail.com> <392d4ccd-a335-0078-d95b-2e0d142aa2b9@usask.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, jarod@redhat.com, allan@asix.com.tw,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Chris Roth <chris.roth@usask.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34209 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751545AbdCMHeW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 03:34:22 -0400
In-Reply-To: <392d4ccd-a335-0078-d95b-2e0d142aa2b9@usask.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Chris,

On 3/13/17, Chris Roth <chris.roth@usask.ca> wrote:
> I can test it tomorrow. I'll pull a clean copy of 4.10.2, or do you
> suggest a different version than that?

I think that 4.10.2 is fine, there are no change on this driver
between 4.10 and git (net-next).

Thanks a lot for the test.


> Chris

Philippe


> On 2017-03-12 11:02 AM, Philippe Reynes wrote:
>> The ethtool api {get|set}_settings is deprecated.
>> We move this driver to new api {get|set}_link_ksettings.
>>
>> As I don't have the hardware, I'd be very pleased if
>> someone may test this patch.
>>
>> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
>> ---
>>  drivers/net/usb/ax88179_178a.c |   14 ++++++++------
>>  1 files changed, 8 insertions(+), 6 deletions(-)
>>
>> diff --git a/drivers/net/usb/ax88179_178a.c
>> b/drivers/net/usb/ax88179_178a.c
>> index a3a7db0..4a0ae7c 100644
>> --- a/drivers/net/usb/ax88179_178a.c
>> +++ b/drivers/net/usb/ax88179_178a.c
>> @@ -620,16 +620,18 @@ static int ax88179_get_eeprom_len(struct net_device
>> *net)
>>  	return 0;
>>  }
>>
>> -static int ax88179_get_settings(struct net_device *net, struct
>> ethtool_cmd *cmd)
>> +static int ax88179_get_link_ksettings(struct net_device *net,
>> +				      struct ethtool_link_ksettings *cmd)
>>  {
>>  	struct usbnet *dev = netdev_priv(net);
>> -	return mii_ethtool_gset(&dev->mii, cmd);
>> +	return mii_ethtool_get_link_ksettings(&dev->mii, cmd);
>>  }
>>
>> -static int ax88179_set_settings(struct net_device *net, struct
>> ethtool_cmd *cmd)
>> +static int ax88179_set_link_ksettings(struct net_device *net,
>> +				      const struct ethtool_link_ksettings *cmd)
>>  {
>>  	struct usbnet *dev = netdev_priv(net);
>> -	return mii_ethtool_sset(&dev->mii, cmd);
>> +	return mii_ethtool_set_link_ksettings(&dev->mii, cmd);
>>  }
>>
>>  static int
>> @@ -826,11 +828,11 @@ static int ax88179_ioctl(struct net_device *net,
>> struct ifreq *rq, int cmd)
>>  	.set_wol		= ax88179_set_wol,
>>  	.get_eeprom_len		= ax88179_get_eeprom_len,
>>  	.get_eeprom		= ax88179_get_eeprom,
>> -	.get_settings		= ax88179_get_settings,
>> -	.set_settings		= ax88179_set_settings,
>>  	.get_eee		= ax88179_get_eee,
>>  	.set_eee		= ax88179_set_eee,
>>  	.nway_reset		= usbnet_nway_reset,
>> +	.get_link_ksettings	= ax88179_get_link_ksettings,
>> +	.set_link_ksettings	= ax88179_set_link_ksettings,
>>  };
>>
>>  static void ax88179_set_multicast(struct net_device *net)
>
>
