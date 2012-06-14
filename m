From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: am3359 (cpsw): unable to get gigabit link working (PHY: ICPlus IP1001)
Date: Thu, 14 Jun 2012 10:28:03 +0200
Message-ID: <CAGm1_ksx7cZaUPOLq3bQcwEchaZY6xM7svb0i+6KGtJYvwU_Gw@mail.gmail.com>
References: <CAGm1_kurEedQc=5dR-mWPingRZcG9s0y9VDY=UijQC1X9RhJCw@mail.gmail.com>
 <EB1619762EAF8B4E97A227FB77B7E0293E9B6D3B@DBDE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"Chemparathy, Cyril" <cyril@ti.com>,
	"Govindarajan, Sriramakrishnan" <srk@ti.com>
To: "N, Mugunthan V" <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:41438 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582Ab2FNI2Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 04:28:24 -0400
Received: by obbtb18 with SMTP id tb18so2102838obb.19
        for <netdev@vger.kernel.org>; Thu, 14 Jun 2012 01:28:24 -0700 (PDT)
In-Reply-To: <EB1619762EAF8B4E97A227FB77B7E0293E9B6D3B@DBDE01.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 14, 2012 at 10:16 AM, N, Mugunthan V <mugunthanvnm@ti.com> =
wrote:
>> -----Original Message-----
>> From: Yegor Yefremov [mailto:yegorslists@googlemail.com]
>> Sent: Wednesday, June 13, 2012 5:59 PM
>> To: netdev
>> Cc: Chemparathy, Cyril; Govindarajan, Sriramakrishnan; N, Mugunthan =
V
>> Subject: am3359 (cpsw): unable to get gigabit link working (PHY: ICP=
lus
>> IP1001)
>>
>> I'm using a custom am3359 based board. The first CPSW ports is
>> connected to ICPlus IP1001 phy via RGMII interface. I have no proble=
m
>> with 100mbit link, but as soon as I connect my board to a 1Gbit swit=
ch
>> the communication fails. I can see that some data goes on wire, but
>> switch refuses to forward it. I can't receive anything either. Phy
>>. detects 1Gbit link correctly
>>
>> My kernel: https://github.com/koenkooi/linux
>>
>> I also define phy interface as RGMII:
>>
>> static struct cpsw_slave_data am33xx_cpsw_slaves[] =3D {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .slave_reg_o=
fs =C2=A0=3D 0x208,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .sliver_reg_=
ofs =3D 0xd80,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .phy_id =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =3D "0:02",
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .phy_if =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D PHY_INTERFACE_MODE_RGMII=
,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 },
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .slave_reg_o=
fs =C2=A0=3D 0x308,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .sliver_reg_=
ofs =3D 0xdc0,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .phy_id =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =3D "0:01",
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 },
>> };
>>
>> As far as I can see in the mainline cpsw driver
>> PHY_INTERFACE_MODE_RGMII will be ignored. Why? In the current driver
>> it sets two bits in mac_control register:
>>
>> if (phy->interface =3D=3D PHY_INTERFACE_MODE_RGMII) /* RGMII */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 mac_control |=3D (BIT(15)|BIT(16));
>>
>> Any idea where should I look to solve the problem?
>
> Phy interface in cpsw is always MII, there is an external gasket to c=
onvert from MII/GMII to RMII/RGMII. So this is a dead code resides in c=
urrent driver and will be removed, that's why this part of code is not =
up streamed.
>
> Can you verify the design/board layout with hardware engineer; also l=
ook for cpsw statistics counters for errors.

Thanks for the quick reply.

I have just fixed the problem. In this thread
http://e2e.ti.com/support/dsp/sitara_arm174_microprocessors/f/791/p/172=
049/685105.aspx#685105
Paul suggests to disable internal delay. I followed his suggestion and
now it works.

#define RGMII_MODE_ENABLE       0x3A

 __raw_writel(RGMII_MODE_ENABLE,
                        AM33XX_CTRL_REGADDR(MAC_MII_SEL));

Yegor
