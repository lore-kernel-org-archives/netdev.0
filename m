From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH -next/mmotm] net/can: fix softing build errors
Date: Sun, 13 Feb 2011 08:01:14 -0800
Message-ID: <4D58004A.3060407@oracle.com>
References: <201102110100.p1B10sDx029244@imap1.linux-foundation.org> <20110211223312.be571303.randy.dunlap@oracle.com> <20110212111344.GA328@e-circ.dyndns.org> <4D56AF22.4070803@oracle.com> <20110213133717.GA508@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: Kurt Van Dijck <kurt.van.dijck@eia.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:38421 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752217Ab1BMQCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Feb 2011 11:02:24 -0500
In-Reply-To: <20110213133717.GA508@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/13/11 05:37, Kurt Van Dijck wrote:
> On Sat, Feb 12, 2011 at 08:02:42AM -0800, Randy Dunlap wrote:
>> On 02/12/11 03:15, Kurt Van Dijck wrote:
>>> On Fri, Feb 11, 2011 at 10:33:12PM -0800, Randy Dunlap wrote:
>>>>
>>>> warning: (CAN_SOFTING_CS) selects CAN_SOFTING which has unmet direct dependencies (NET && CAN && CAN_DEV && HAS_IOMEM)
>>>>
>>>> with this partial config:
>>>>
>>>> CONFIG_CAN=m
>>>> # CONFIG_CAN_RAW is not set
>>>> # CONFIG_CAN_BCM is not set
>>>> # CAN Device Drivers
>>>> # CONFIG_CAN_VCAN is not set
>>>> CONFIG_CAN_SLCAN=m
>>>> # CONFIG_CAN_DEV is not set
>>>> CONFIG_CAN_SOFTING=m
>>>> CONFIG_CAN_SOFTING_CS=m
>>>> # CONFIG_CAN_DEBUG_DEVICES is not set
>>> I understand the output, but I don't understand the cause well enough.
>>> CAN_SOFTING=m has a 'depends on CAN_DEV'
>>> Is it then possible to have CAN_SOFTING=m _and not_ CAN_DEV ?
>>
>> Yes.  From Documentation/kbuild/kconfig-language.txt:
>>
> I see.
> The 'select CAN_SOFTING' was introduced because it makes no sense to
> have CAN_SOFTING_CS alone 'for a normal user', although there is no
> real dependency.
> Is a 'select' then still a good option, since it feels like repeating
> all dependencies from CAN_SOFTING in CAN_SOFTING_CS?
> What about this?
> 
> diff --git a/drivers/net/can/softing/Kconfig b/drivers/net/can/softing/Kconfig
> index 92bd6bd..55dd3e4 100644
> --- a/drivers/net/can/softing/Kconfig
> +++ b/drivers/net/can/softing/Kconfig
> @@ -18,7 +18,7 @@ config CAN_SOFTING
>  config CAN_SOFTING_CS
>  	tristate "Softing Gmbh CAN pcmcia cards"
>  	depends on PCMCIA
> -	select CAN_SOFTING
> +	depends on CAN_SOFTING
>  	---help---
>  	  Support for PCMCIA cards from Softing Gmbh & some cards
>  	  from Vector Gmbh.
> ---
> It will present the Softing stuff in Kconfig as if CAN_SOFTING_CS really
> depends on CAN_SOFTING, which is acceptible from a users perspective.

That's fine.
Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

thanks.
-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
