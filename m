From: "John P Poet" <jppoet@gmail.com>
Subject: Re: Realtek 8111C transmit timed out
Date: Wed, 6 Aug 2008 23:51:53 -0600
Message-ID: <2c2a4e250808062251p74f97863l770727843921a5c4@mail.gmail.com>
References: <2c2a4e250808041812j569f6565s9f4ae54f44bbfbb5@mail.gmail.com>
	 <2c2a4e250808041900id64a2b8h1b7cee3b70960ebc@mail.gmail.com>
	 <2c2a4e250808042042j6c448068v98a6b5e428fa1a7@mail.gmail.com>
	 <20080805214250.GA23226@electric-eye.fr.zoreil.com>
	 <2c2a4e250808052221p7d22adf5w7a656e423bff0b26@mail.gmail.com>
	 <20080806190353.GB17174@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:1410 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361AbYHGFvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 01:51:54 -0400
Received: by fg-out-1718.google.com with SMTP id 19so153721fgg.17
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2008 22:51:53 -0700 (PDT)
In-Reply-To: <20080806190353.GB17174@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 6, 2008 at 1:03 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> John P Poet <jppoet@gmail.com> :
> [...]
>> Thank you for the response.  That DOES seem to fix the cold-boot issue.
>>
>> Unfortunately, it does not fix the timeout problem.  I am still
>> experiencing transmittion problems:
>
> Does the patch below (on top of the current pile) make a difference ?
>
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index c421bf6..348846f 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -874,12 +874,9 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
>
>        auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
>
> -       if ((tp->mac_version == RTL_GIGA_MAC_VER_12) ||
> -           (tp->mac_version == RTL_GIGA_MAC_VER_17)) {
> -               /* Vendor specific (0x1f) and reserved (0x0e) MII registers. */
> -               mdio_write(ioaddr, 0x1f, 0x0000);
> -               mdio_write(ioaddr, 0x0e, 0x0000);
> -       }
> +       /* Vendor specific (0x1f) and reserved (0x0e) MII registers. */
> +       mdio_write(ioaddr, 0x1f, 0x0000);
> +       mdio_write(ioaddr, 0x0e, 0x0000);
>
>        tp->phy_auto_nego_reg = auto_nego;
>        tp->phy_1000_ctrl_reg = giga_ctrl;
> --
> Ueimor
>

That does not make any difference.

I will say, that the problem seems to be reduced by this patch (or the
0002-r8169-avoid-thrashing-PCI-conf-space-above-RTL_GIGA.patch).

Before, I was getting failures two or three times an hour.  With
either of these patches applied, the failure rate has dropped to one
every two to four hours.

Thanks for trying.

John
-- 
A: Because it messes up the order in which people normally read text.
Q: Why is top-posting such a bad thing?
