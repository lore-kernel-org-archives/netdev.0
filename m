From: Stas Sergeev <stsp@list.ru>
Subject: Re: [5/6] mvneta: implement SGMII-based in-band link state signaling
Date: Wed, 8 Jul 2015 19:51:44 +0300
Message-ID: <559D5520.3030700@list.ru>
References: <55155D9D.6070800@list.ru>
 <alpine.LNX.2.02.1507081757260.28659@sbrk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Sebastien Rannou <mxs@sbrk.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.02.1507081757260.28659@sbrk.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

08.07.2015 19:30, Sebastien Rannou =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> Hi Stas,
>
> On Fri, 27 Mar 2015, Stas Sergeev wrote:
>
>> When MDIO bus is unavailable (common setup for SGMII), the in-band
>> signaling must be used to correctly track link state.
>> This patch enables the in-band status delivery and interrupts for
>> links state changes, namely:
>> - link up/down
>> - link speed
>> - duplex full/half
>> Upon reciving the appropriate interrupt, the driver updates the
>> fixed_phy status to match the received status.
> I'm seeing a regression with this patch when trying to netboot an Arm=
ada
> XP board (by reverting this commit it is fine), the network
> link stays down:
>
> [    9.274492] mvneta d0070000.ethernet eth0: Link is Down
>
> (I've added an extra call to phy_print_status() in mvneta_adjust_link=
() to
> get this trace).
>
> I've tried to dig a bit in the code, and it seems that the status.lin=
k flag
> never gets set in mvneta_fixed_link_update(). If I try to force the
> use_inband_status to 0 in mvneta_probe(), it boots properly so I'm no=
t
> sure that I need the in-band status/delivery in my case ; I'm using a
> custom DTB with a fixed-link:
>
> eth0: ethernet@70000 {
>           status =3D "okay";
>           fixed-link =3D <1 1 1000 0 0>;
>           phy-mode =3D "sgmii";
> };
>
> Could there be something missing in the condition that initializes
> pp->use_inband_status?
Hi, use_inband_status is set when fixed-link is used, which is
exactly your case. But it seems something on the other end
is not generating the inband status. What is there? A phy chip,
or something else?
Perhaps some DT property should be added to explicitly
enable the use of the inband status... I just thought in sgmii
protocol it is a mandatory.
I'll try to come up with the patch tomorrow that adds such
property.
