From: Bob Liu <lliubbo@gmail.com>
Subject: Re: [PATCH 2/3] drivers: net: ethernet: stmmac: fix failure in module test
Date: Wed, 23 May 2012 13:09:11 +0800
Message-ID: <CAA_GA1fNJCT=qfuHDkNrBdeZd8wiR30MPBdtUVuAv+ZY+zMH_g@mail.gmail.com>
References: <1337672336-7378-1-git-send-email-lliubbo@gmail.com>
	<1337672336-7378-2-git-send-email-lliubbo@gmail.com>
	<4FBB8BBD.8010208@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, francesco.virlinzi@st.com,
	rayagond@vayavyalabs.com, sr@denx.de, netdev@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:50642 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752659Ab2EWFJM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 01:09:12 -0400
Received: by mail-ey0-f174.google.com with SMTP id k11so1881071eaa.19
        for <netdev@vger.kernel.org>; Tue, 22 May 2012 22:09:11 -0700 (PDT)
In-Reply-To: <4FBB8BBD.8010208@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Peppe,

On Tue, May 22, 2012 at 8:51 PM, Giuseppe CAVALLARO
<peppe.cavallaro@st.com> wrote:
> On 5/22/2012 9:38 AM, Bob Liu wrote:
>> Module can't be compiled and installed in current Makefile.
>
> I've just seen that I can generate the stmmac.ko on ARM and also on x=
86
> with my configuration.
>
> Can you post here you build failure?
>
> In the meantime I'll test the module on ARM soon.

Yes, stmmac.ko can be generated, but  stmmac_platform.c won't be built.
which cause net device can't be probed.

>
> peppe
>
>>
>> Signed-off-by: Bob Liu <lliubbo@gmail.com>
>> ---
>> =C2=A0drivers/net/ethernet/stmicro/stmmac/Makefile | =C2=A0 12 +++++=
+------
>> =C2=A01 files changed, 6 insertions(+), 6 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/=
net/ethernet/stmicro/stmmac/Makefile
>> index bc965ac..4b50922 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/Makefile
>> +++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
>> @@ -1,10 +1,10 @@
>> =C2=A0obj-$(CONFIG_STMMAC_ETH) +=3D stmmac.o
>> -stmmac-$(CONFIG_STMMAC_TIMER) +=3D stmmac_timer.o
>> -stmmac-$(CONFIG_STMMAC_RING) +=3D ring_mode.o
>> -stmmac-$(CONFIG_STMMAC_CHAINED) +=3D chain_mode.o
>> -stmmac-$(CONFIG_STMMAC_PLATFORM) +=3D stmmac_platform.o
>> -stmmac-$(CONFIG_STMMAC_PCI) +=3D stmmac_pci.o
>> +stmmac-$(CONFIG_STMMAC_TIMER:m=3Dy) +=3D stmmac_timer.o
>> +stmmac-$(CONFIG_STMMAC_RING:m=3Dy) +=3D ring_mode.o
>> +stmmac-$(CONFIG_STMMAC_CHAINED:m=3Dy) +=3D chain_mode.o
>> +stmmac-$(CONFIG_STMMAC_PLATFORM:m=3Dy) +=3D stmmac_platform.o
>> +stmmac-$(CONFIG_STMMAC_PCI:m=3Dy) +=3D stmmac_pci.o
>> =C2=A0stmmac-objs:=3D stmmac_main.o stmmac_ethtool.o stmmac_mdio.o =C2=
=A0 \
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dwmac_lib.o dwmac1000_core=
=2Eo =C2=A0dwmac1000_dma.o =C2=A0 =C2=A0 \
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dwmac100_core.o dwmac100_d=
ma.o enh_desc.o =C2=A0norm_desc.o \
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mmc_core.o $(stmmac-y)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mmc_core.o
>

--=20
Thanks,
--Bob
