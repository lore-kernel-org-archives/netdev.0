From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: Adding Support for SG,GSO,GRO
Date: Thu, 9 Dec 2010 19:47:57 +0100
Message-ID: <AANLkTi=8zWMYWG0DU147B08nN7xcvwaB9Bpq9fE8_fBe@mail.gmail.com>
References: <FCCFB4CDC6E5564B9182F639FC356087035F21D9F9@dbde02.ent.ti.com>
	<1291906948.19763.16.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Govindarajan, Sriramakrishnan" <srk@ti.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:46913 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513Ab0LISr6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 13:47:58 -0500
Received: by qyj19 with SMTP id 19so74958qyj.19
        for <netdev@vger.kernel.org>; Thu, 09 Dec 2010 10:47:58 -0800 (PST)
In-Reply-To: <1291906948.19763.16.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/12/9 Ben Hutchings <bhutchings@solarflare.com>:
> On Thu, 2010-12-09 at 16:03 +0530, Govindarajan, Sriramakrishnan wrot=
e:
>> Hi
>> We have a NAPI compliant driver(net/drivers/davinci_emac.c), that do=
es
>> well at 10/100Mbps loads. Now the same controller/driver is used for
>> 1000Mbps
>> mode as well, where the CPU gets saturated easily
>>
>> Internally the module supports scatter gather DMA(which is currently=
 not
>> exercised) but there is no HW checksum support.
>>
>> To specifically implement GRO, GSO support would it be sufficient to=
 add
>> SG support to the driver? Are there other means of increasing the th=
roughput
>> and decreasing the CPU loading?
[...]
> On the TX side, NETIF_F_SG means that the stack may include data in t=
he
> skb by reference to arbitrary pages *even if their contents are still
> being changed* (think sendfile()), which means it depends on hardware
> checksum generation.

Isn't that condition too broad? If the data could change after packet
is submitted to the driver then results would be unpredictable and
allow sending wrong data with correct (because hw-calculated)
checksum.

Right now NETIF_F_SG is removed from dev->features by
netdev_fix_features() if no checksum offloads are enabled.

Just an idea: would driver with NETIF_F_SG|NETIF_F_HW_CSUM using
skb_checksum_help() in xmit path work? This would allow to use DMA
scatter-gather without hardware checksumming (and avoid copying the
packet's data before sending).

Best Regards,
Micha=B3 Miros=B3aw
