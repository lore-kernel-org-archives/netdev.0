From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [Linux-kernel] [net-next, 2/5] sh_eth: WARN on access to a register
 not implemented in a particular chip
Date: Tue, 10 Mar 2015 23:03:43 +0300
Message-ID: <54FF4E1F.7050508@cogentembedded.com>
References: <1424982854.4444.73.camel@xylophone.i.decadent.org.uk> <alpine.DEB.2.10.1503050958520.8385@ayla.of.borg> <1425561532.4288.34.camel@xylophone.i.decadent.org.uk> <54FD5ED0.6070208@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	netdev@vger.kernel.org,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	"David S. Miller" <davem@davemloft.net>
To: Ben Dooks <ben.dooks@codethink.co.uk>,
	Ben Hutchings <ben.hutchings@codethink.co.uk>,
	Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:37449 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752959AbbCJUDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 16:03:49 -0400
Received: by labgq15 with SMTP id gq15so4280383lab.4
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 13:03:47 -0700 (PDT)
In-Reply-To: <54FD5ED0.6070208@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/09/2015 11:50 AM, Ben Dooks wrote:

>>>> Currently we may silently read/write a register at offset 0.  Change
>>>> this to WARN and then ignore the write or read-back all-ones.

>>>> Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
>>>> Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

>>> While this may be a good idea for debugging...

>>>> --- a/drivers/net/ethernet/renesas/sh_eth.h
>>>> +++ b/drivers/net/ethernet/renesas/sh_eth.h
>>>> @@ -543,19 +543,29 @@ static inline void sh_eth_soft_swap(char *src, int len)
>>>>   #endif
>>>>   }
>>>>
>>>> +#define SH_ETH_OFFSET_INVALID	((u16) ~0)
>>>> +
>>>>   static inline void sh_eth_write(struct net_device *ndev, u32 data,
>>>>   				int enum_index)
>>>>   {
>>>>   	struct sh_eth_private *mdp = netdev_priv(ndev);

> does de-referencing this each time make a difference? Looks like

   It's not a dereference, it's just a pointer addition.

> it would have been easier to pass an "struct sh_eth_private" instead
> of the "struct net_device *ndev"

    Hm, maybe...

>>>> +	u16 offset = mdp->reg_offset[enum_index];
>>>> +
>>>> +	if (WARN_ON(offset == SH_ETH_OFFSET_INVALID))
>>>> +		return;

> You could cange the mdp->reg_offset to an mdp->reg_pointer and make
> any invalid registers a NULL. This would at-least make it fail on an
> invalid access.

    Interesting idea...

WBR, Sergei
