From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [IGB 2.6.29.3 bug] Re: WARNING at dev_disable_lro when enabling
	ip_forward
Date: Tue, 19 May 2009 15:06:57 -0700
Message-ID: <9929d2390905191506t1fc203d3q98a7f89cbcda38ca@mail.gmail.com>
References: <20090519010147.772f0bff@vingilot.sergknet>
	 <20090518.153531.126023429.davem@davemloft.net>
	 <20090518155714.0f1a3b20@nehalam>
	 <20090519234629.2b5f7550@vingilot.sergknet>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Sergey Kononenko <sergk@sergk.org.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:63069 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882AbZESWG4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 18:06:56 -0400
Received: by yx-out-2324.google.com with SMTP id 3so53585yxj.1
        for <netdev@vger.kernel.org>; Tue, 19 May 2009 15:06:57 -0700 (PDT)
In-Reply-To: <20090519234629.2b5f7550@vingilot.sergknet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2009 at 1:46 PM, Sergey Kononenko <sergk@sergk.org.ua> =
wrote:
>> Does this fix it?
>>
>> diff --git a/drivers/net/igb/igb_ethtool.c
>> b/drivers/net/igb/igb_ethtool.c index 4bdfc2e..a425d85 100644
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
> Yes, patch have fixed the problem. Thank you.
>
> With best regards,
> Sergey Kononenko.
> --

Thanks Sergey and Stephen, I will get this queued up for the current
and stable trees.

--=20
Cheers,
Jeff
