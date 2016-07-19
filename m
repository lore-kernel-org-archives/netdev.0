From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: [PATCH net-next v2] cdc_ether: Improve ZTE MF823/831/910 handling
Date: Tue, 19 Jul 2016 14:43:04 +0200
Message-ID: <CAKfDRXg6aU3Ht=50b6HMJixycXv98cLOaz1Ty8oyr-Nktc6BBg@mail.gmail.com>
References: <1468928961-26495-1-git-send-email-kristian.evensen@gmail.com> <1468931616.2429.3.camel@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-usb@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468931616.2429.3.camel@neukum.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 19, 2016 at 2:33 PM, Oliver Neukum <oliver@neukum.org> wrote:
> On Tue, 2016-07-19 at 13:49 +0200, Kristian Evensen wrote:
>> @@ -428,10 +434,47 @@ int usbnet_cdc_bind(struct usbnet *dev, struct
>> usb_interface *intf)
>>                 return status;
>>         }
>>
>> +       if (dev->net->dev_addr[0] & 0x02)
>> +               eth_hw_addr_random(dev->net);
>> +
>>         return 0;
>>  }
>>  EXPORT_SYMBOL_GPL(usbnet_cdc_bind);
>>
>> +static int usbnet_cdc_zte_bind(struct usbnet *dev, struct
>> usb_interface *intf)
>> +{
>> +       int status = usbnet_cdc_bind(dev, intf);
>> +
>> +       if (status)
>> +               return status;
>> +
>> +       if (dev->net->dev_addr[0] & 0x02)
>> +               eth_hw_addr_random(dev->net);
>> +
>> +       return 0;
>> +}
>
> That really makes no sense.

Ops, my bad. Thanks for catching it. The check for random hw_addr
should only be in the zte_bind() function.

-Kristian
