From: "Alexey Klimov" <klimov.linux@gmail.com>
Subject: Re: [patch v2] net/usb: remove err() messages in few drivers
Date: Tue, 13 Jan 2009 11:57:12 +0300
Message-ID: <208cbae30901130057r2b3396f4gb5abdedd5647739c@mail.gmail.com>
References: <1231805322.12962.4.camel@tux.localhost>
	 <200901130940.28478.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dbrownell@users.sourceforge.net, davem@davemloft.net,
	"Greg KH" <greg@kroah.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: "Oliver Neukum" <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:55494 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752476AbZAMI5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 03:57:14 -0500
In-Reply-To: <200901130940.28478.oliver@neukum.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 13, 2009 at 11:40 AM, Oliver Neukum <oliver@neukum.org> wrote:
> Am Tuesday 13 January 2009 01:08:42 schrieb Alexey Klimov:
>> @@ -675,7 +677,7 @@ static int kaweth_open(struct net_device *net)
>>
>>         res = usb_autopm_get_interface(kaweth->intf);
>>         if (res) {
>> -               err("Interface cannot be resumed.");
>> +               dev_err(&net->dev, "Interface cannot be resumed.\n");
>>                 return -EIO;
>>         }
>>         res = kaweth_resubmit_rx_urb(kaweth, GFP_KERNEL);
>> @@ -902,7 +904,7 @@ static void kaweth_async_set_rx_mode(struct kaweth_device *kaweth)
>>                                 KAWETH_CONTROL_TIMEOUT);
>>
>>         if(result < 0) {
>> -               err("Failed to set Rx mode: %d", result);
>> +               dev_err(&kaweth->dev->dev, "Failed to set Rx mode: %d\n", result);
>>         }
>>         else {
>>                 dbg("Set Rx mode to %d", packet_filter_bitmap);
>> @@ -1038,7 +1040,7 @@ static int kaweth_probe(
>>                                                       "kaweth/new_code.bin",
>>                                                       100,
>>                                                       2)) < 0) {
>> -                       err("Error downloading firmware (%d)", result);
>> +                       dev_err(&intf->dev, "Error downloading firmware (%d)\n", result);
>
> I have to veto this. You are using three different device structures
> to refer to the same device. That will make it next to impossible to
> find out which device originated a message.
>
>        Regards
>                Oliver

Ok, i'll reformat patch. Is it okay if i use kaweth->dev->dev,
kaweth->net->dev and intf->dev ? Or switch to kaweth->net->dev
(instead of dev->dev)?

-- 
Best regards, Klimov Alexey
