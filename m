From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [IGB 2.6.29.3 bug] Re: WARNING at dev_disable_lro when enabling
	ip_forward
Date: Mon, 18 May 2009 16:07:36 -0700
Message-ID: <9929d2390905181607v24a6c7a0t7d74e1388f131ef9@mail.gmail.com>
References: <20090519010147.772f0bff@vingilot.sergknet>
	 <20090518.153531.126023429.davem@davemloft.net>
	 <20090518155714.0f1a3b20@nehalam>
	 <20090518.160029.230477451.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, sergk@sergk.org.ua, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:40946 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754359AbZERXHq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 19:07:46 -0400
Received: by yw-out-2324.google.com with SMTP id 5so2174884ywb.1
        for <netdev@vger.kernel.org>; Mon, 18 May 2009 16:07:47 -0700 (PDT)
In-Reply-To: <20090518.160029.230477451.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 18, 2009 at 4:00 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Mon, 18 May 2009 15:57:14 -0700
>
>> Does this fix it?
>
> It should, but I think the ifdef is probably superfluous.
>

I agree with Dave, the #ifdef is not necessary.  Thanks Stephen for
the quick patch.

>> diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_eth=
tool.c
>> index 4bdfc2e..a425d85 100644
>> --- a/drivers/net/igb/igb_ethtool.c
>> +++ b/drivers/net/igb/igb_ethtool.c
>> @@ -2028,6 +2028,10 @@ static struct ethtool_ops igb_ethtool_ops =3D=
 {
>> =C2=A0 =C2=A0 =C2=A0 .get_ethtool_stats =C2=A0 =C2=A0 =C2=A0=3D igb_=
get_ethtool_stats,
>> =C2=A0 =C2=A0 =C2=A0 .get_coalesce =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =3D igb_get_coalesce,
>> =C2=A0 =C2=A0 =C2=A0 .set_coalesce =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =3D igb_set_coalesce,
>> +#ifdef CONFIG_IGB_LRO
>> + =C2=A0 =C2=A0 .get_flags =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0=3D ethtool_op_get_flags,
>> + =C2=A0 =C2=A0 .set_flags =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0=3D ethtool_op_set_flags,
>> +#endif
>> =C2=A0};
>>
>> =C2=A0void igb_set_ethtool_ops(struct net_device *netdev)

If this resolves Sergey's issue, I will push this to the stable tree
(minus the #ifdef).

--=20
Cheers,
Jeff
