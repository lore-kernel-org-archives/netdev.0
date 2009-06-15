From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: rfkill regression in net-next-2.6
Date: Mon, 15 Jun 2009 15:20:59 +0200
Message-ID: <4A364ABB.6040704@hartkopp.net>
References: <20090604152011.GC2839@tuxdriver.com>	 <20090607.033751.191866033.davem@davemloft.net>	 <4A2BCC41.1060508@hartkopp.net> <20090607145830.GA2736@tuxdriver.com>	 <4A2BD8A5.4040302@hartkopp.net>	 <1244388583.23850.87.camel@localhost.localdomain>	 <4A34BAB9.9000104@hartkopp.net>  <20090615120422.GA2729@tuxdriver.com> <1245068686.23912.0.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	David Miller <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:36618 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751689AbZFONVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 09:21:01 -0400
In-Reply-To: <1245068686.23912.0.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg wrote:
> On Mon, 2009-06-15 at 08:04 -0400, John W. Linville wrote:
>> On Sun, Jun 14, 2009 at 10:54:17AM +0200, Oliver Hartkopp wrote:
>>
>>> Any idea what changed in net-next-2.6 that could produce this behaviour?
>> The rfkill subsystem rewrite would seem suspect... :-)
> 
> Maybe this fixes it?

Yes, that made it!

I booted with the RFKILL switch ON and OFF and the system and the LEDs are
working as one would expect it.

Thanks Johannes.

Tested-by: Oliver Hartkopp <oliver@hartkopp.net>


> 
> johannes
> 
> --- wireless-testing.orig/drivers/platform/x86/dell-laptop.c	2009-06-15 14:23:25.000000000 +0200
> +++ wireless-testing/drivers/platform/x86/dell-laptop.c	2009-06-15 14:23:35.000000000 +0200
> @@ -177,7 +177,7 @@ dell_send_request(struct calling_interfa
>  static int dell_rfkill_set(void *data, bool blocked)
>  {
>  	struct calling_interface_buffer buffer;
> -	int disable = blocked ? 0 : 1;
> +	int disable = blocked ? 1 : 0;
>  	unsigned long radio = (unsigned long)data;
>  
>  	memset(&buffer, 0, sizeof(struct calling_interface_buffer));
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

