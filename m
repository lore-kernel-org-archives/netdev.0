From: Hin-Tak Leung <htl10@users.sourceforge.net>
Subject: Re: [PATCH] drivers: rtl818x: request DMA-able memory
Date: Mon, 25 Oct 2010 15:11:22 +0100
Message-ID: <4CC5900A.2050209@users.sourceforge.net>
References: <1287952327-9924-1-git-send-email-sez@debian.org> <4CC5851D.1040204@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Serafeim Zanikolas <sez@debian.org>, herton@mandriva.com.br,
	linville@tuxdriver.com, joe@perches.com, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm16-vm0.bullet.mail.ukl.yahoo.com ([217.146.183.254]:21412
	"HELO nm16-vm0.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753974Ab0JYOL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 10:11:26 -0400
In-Reply-To: <4CC5851D.1040204@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Larry Finger wrote:
> On 10/24/2010 03:32 PM, Serafeim Zanikolas wrote:
>> Despite the indicated intention in comment, the kmalloc() call was not
>> explicitly requesting memory from ZONE_DMA.
>>
>> Signed-off-by: Serafeim Zanikolas <sez@debian.org>
>> ---
>>  drivers/net/wireless/rtl818x/rtl8187_dev.c |    3 ++-
>>  1 files changed, 2 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/wireless/rtl818x/rtl8187_dev.c b/drivers/net/wireless/rtl818x/rtl8187_dev.c
>> index 38fa824..771794d 100644
>> --- a/drivers/net/wireless/rtl818x/rtl8187_dev.c
>> +++ b/drivers/net/wireless/rtl818x/rtl8187_dev.c
>> @@ -1343,7 +1343,8 @@ static int __devinit rtl8187_probe(struct usb_interface *intf,
>>  	priv->is_rtl8187b = (id->driver_info == DEVICE_RTL8187B);
>>  
>>  	/* allocate "DMA aware" buffer for register accesses */
>> -	priv->io_dmabuf = kmalloc(sizeof(*priv->io_dmabuf), GFP_KERNEL);
>> +	priv->io_dmabuf = kmalloc(sizeof(*priv->io_dmabuf),
>> +				  GFP_DMA | GFP_KERNEL);
>>  	if (!priv->io_dmabuf) {
>>  		err = -ENOMEM;
>>  		goto err_free_dev;
> 
> ACK.
> 
> Larry

Acked-by: Hin-Tak Leung <htl10@users.sourceforge.net>

I had a quick look for similiar constructs and AFAIK only the b43/b43legacy 
drivers uses DMA buffers. Seems to be a rare practice. Is that something we 
should or should not do?

Hin-Tak
