From: Malli <mchilakala@gmail.com>
Subject: Re: [net-2.6 PATCH 3/3] Fix 82598 premature copper PHY link
	indicatation
Date: Mon, 14 Dec 2009 10:37:32 -0800
Message-ID: <7991c5480912141037u77cc4988qee734feb555e4ba5@mail.gmail.com>
References: <20091212075120.10952.98484.stgit@localhost.localdomain>
	 <20091212075200.10952.13217.stgit@localhost.localdomain>
	 <20091213.191858.71104129.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, mallikarjuna.chilakala@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.211.182]:40568 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754663AbZLNShe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2009 13:37:34 -0500
Received: by ywh12 with SMTP id 12so3424181ywh.21
        for <netdev@vger.kernel.org>; Mon, 14 Dec 2009 10:37:33 -0800 (PST)
In-Reply-To: <20091213.191858.71104129.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Dave. I'll respin the patch, didn't mean to wait in non-preempti=
ve loop.

On Sun, Dec 13, 2009 at 7:18 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Fri, 11 Dec 2009 23:52:01 -0800
>
>> + =A0 =A0 for (timeout =3D 0;
>> + =A0 =A0 =A0 =A0 =A0timeout < IXGBE_VALIDATE_LINK_READY_TIMEOUT; ti=
meout++) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 hw->phy.ops.read_reg(hw, MDIO_STAT1, MDIO_=
MMD_AN, &an_reg);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if ((an_reg & MDIO_AN_STAT1_COMPLETE) &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (an_reg & MDIO_STAT1_LSTATUS))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 mdelay(100);
>> + =A0 =A0 }
>
> An up to 5000 msec non-preemptable spin loop.
>
> If this used "msleep()" that would make it OK.
>
> But as it is, sorry, no way.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
