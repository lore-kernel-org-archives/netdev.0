From: Wei Shuai <cpuwolf@gmail.com>
Subject: Re: [PATCH 2/2] CDC_NCM: adding support FLAG_NOARP for Infineon modem platform
Date: Mon, 21 Jan 2013 10:20:22 +0800
Message-ID: <CACa7zynymtYN4OtTjVNTNdB23eNU4D-G+JqaTxjaPFekRHkRAg@mail.gmail.com>
References: <1358662329-8294-1-git-send-email-cpuwolf@gmail.com>
	<1358662329-8294-2-git-send-email-cpuwolf@gmail.com>
	<50FC25B7.70708@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: dcbw@redhat.com, davem@davemloft.net, peter@stuge.se,
	oneukum@suse.de, gregkh@linuxfoundation.org,
	alexey.orishko@stericsson.com, bjorn@mork.no,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Sergei Shtylyov <sshtylyov@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:49352 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752528Ab3AUCUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 21:20:23 -0500
In-Reply-To: <50FC25B7.70708@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The main problem is that these devices don't support ethernet.  They
support IP (v4 and _maybe_ v6) with an ethernet header.  Many of them
will do ARP (and IPv6 ND) as well to complete the picture, but some of
them don't and that's what these drivers try to deal with.

Note that most of the devices will run a DHCP server, so there is some
sort of IP broadcast support.  Whether that qualifies as proper ethernet
broadcast support is another question...

These devices are attempting to bridge an IP-only point-to-point
interface and an ethernet over USB interface, with the intention to make
the point-to-point interface look like ethernet to applications and
users. This is of course always going to be imperfect.  But I believe
that we should aim to help the firmware achive this goal when writing
drivers instead of working against it.  Setting IFF_NOARP and not
IFF_POINTTOPOINT is one way to do that. ---- by  Bjorn Mork <bjorn@mork.no>

2013/1/21, Sergei Shtylyov <sshtylyov@mvista.com>:
> Hello.
>
> On 20-01-2013 10:12, Wei Shuai wrote:
>
>> Infineon(now Intel) HSPA Modem platform NCM cannot support ARP. we can
>> define a new common structure wwan_noarp_info.
>
>     Wrap your lines at 76-80 columns maximum please.
>
>> Then more similiar NO ARP devices can be handled easily
>
>
>> Signed-off-by: Wei Shuai <cpuwolf@gmail.com>
>> ---
>>   drivers/net/usb/cdc_ncm.c |   21 +++++++++++++++++++++
>>   1 files changed, 21 insertions(+), 0 deletions(-)
>
>> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
>> index 71b6e92..2d699b6 100644
>> --- a/drivers/net/usb/cdc_ncm.c
>> +++ b/drivers/net/usb/cdc_ncm.c
>> @@ -1155,6 +1155,20 @@ static const struct driver_info wwan_info = {
>>   	.tx_fixup = cdc_ncm_tx_fixup,
>>   };
>>
>> +/* Same as wwan_info, but with IFF_NOARP  */
>
>     FLAG_NOARP, you mean?
>
>> +static const struct driver_info wwan_noarp_info = {
>> +	.description = "Mobile Broadband Network Device (NO ARP)",
>> +	.flags = FLAG_POINTTOPOINT | FLAG_NO_SETINT | FLAG_MULTI_PACKET
>> +			| FLAG_WWAN | FLAG_NOARP,
>
> WBR, Sergei
>
>
