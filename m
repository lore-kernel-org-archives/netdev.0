From: Laurent Chavey <chavey@google.com>
Subject: Re: [PATCH 1/1] add ethtool loopback support
Date: Thu, 8 Apr 2010 12:17:47 -0700
Message-ID: <w2i97949e3e1004081217jdeca953dz162c62b61c0e8f72@mail.gmail.com>
References: <pvmbpdtn8yh.fsf@chavey.mtv.corp.google.com> <1270751373.5055.22.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, therbert@google.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:13724 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933150Ab0DHTSQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 15:18:16 -0400
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o38JIEWQ032725
	for <netdev@vger.kernel.org>; Thu, 8 Apr 2010 12:18:15 -0700
Received: from gxk20 (gxk20.prod.google.com [10.202.11.20])
	by kpbe20.cbf.corp.google.com with ESMTP id o38JI7PR023930
	for <netdev@vger.kernel.org>; Thu, 8 Apr 2010 12:18:08 -0700
Received: by gxk20 with SMTP id 20so1365658gxk.12
        for <netdev@vger.kernel.org>; Thu, 08 Apr 2010 12:18:07 -0700 (PDT)
In-Reply-To: <1270751373.5055.22.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 8, 2010 at 11:29 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Thu, 2010-04-08 at 10:35 -0700, chavey@google.com wrote:
>> From: Ranjit Manomohan <ranjitm@google.com>
>> Date: Wed, 7 Apr 2010 15:19:48 -0700
>>
>> Add an ethtool option to use internal loopback mode for testing.
>> This feature is used for component and driver test coverage by putti=
ng
>> the device in hardware loopback mode and sending / receiving network
>> traffic from a user application to test the hardware and driver
>> transmit / receive paths.
>>
>> Signed-off-by: laurent chavey <chavey@google.com>
>> ---
>> =A0include/linux/ethtool.h | =A0 16 ++++++++++++++++
>> =A0net/core/ethtool.c =A0 =A0 =A0| =A0 40 ++++++++++++++++++++++++++=
++++++++++++++
>> =A02 files changed, 56 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
>> index b33f316..df1dcc7 100644
>> --- a/include/linux/ethtool.h
>> +++ b/include/linux/ethtool.h
>> @@ -292,6 +292,18 @@ struct ethtool_stats {
>> =A0 =A0 =A0 __u64 =A0 data[0];
>> =A0};
>>
>> +/* for setting the NIC into loopback mode */
>> +struct ethtool_loopback {
>> + =A0 =A0 u32 cmd; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* ETHTOOL_SLOOPBA=
CK */
>> + =A0 =A0 u32 type; =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* ethtool_loopback_=
type */
>> +};
>> +
>> +enum ethtool_loopback_type {
>> + =A0 =A0 ETH_MAC =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D 0x00000001,
>> + =A0 =A0 ETH_PHY_INT =A0 =A0 =A0 =A0 =A0 =A0 =3D 0x00000002,
>> + =A0 =A0 ETH_PHY_EXT =A0 =A0 =A0 =A0 =A0 =A0 =3D 0x00000004
>> +};
> [...]
>
> There are many different places you can loop back within a MAC or PHY=
,
> not to mention bypassing the MAC altogether. =A0See
> drivers/net/sfc/mcdi_pcol.h, starting from the line
> '#define MC_CMD_LOOPBACK_NONE 0'. =A0I believe we implement all of th=
ose
> loopback modes on at least one board.
>
> Also are these supposed to be an enumeration or flags? =A0In theory y=
ou
those are enums that can be or together.
> could use wire-side and host-side loopback at the same time if they
> don't overlap, but it's probably too much trouble to bother with. =A0=
Any
> other combination is meaningless.

>
> Ben.
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
>
