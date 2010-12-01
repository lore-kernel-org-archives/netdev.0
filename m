From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH] net/r8169: Remove the firmware of RTL8111D
Date: Wed, 1 Dec 2010 17:54:53 +0800
Message-ID: <5CD11B39296347A7AA66F157A5112039@realtek.com.tw>
References: <1291180966-3124-1-git-send-email-hayeswang@realtek.com> <20101201080732.GA3234@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_002E_01CB9180.DB852A90"
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	'Ben Hutchings' <ben@decadent.org.uk>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtitmf2.realsil.com.cn ([60.250.210.236]:3740 "EHLO
	mf2.realtek.com.tw" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752942Ab0LAJyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 04:54:55 -0500
In-Reply-To: <20101201080732.GA3234@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_NextPart_000_002E_01CB9180.DB852A90
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Romieu,

the rtl8168d_3_hw_phy_config is RTL8111DP which is different from RTL8111D(L).
I want to deal with RTL8111D first.

The attatched file is the linux-firmware patch.

I would think the situation for the failure of request_firmware. However, maybe
it is fine to go along.

Thanks for your suggestion and reply.
 
Best Regards,
Hayes


> -----Original Message-----
> From: Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Wednesday, December 01, 2010 4:08 PM
> To: Hayeswang
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Ben 
> Hutchings
> Subject: Re: [PATCH] net/r8169: Remove the firmware of RTL8111D
> 
> Hayes Wang <hayeswang@realtek.com> :
> > Remove the firmware of RTL8111D from the kernel.
> > The binary file of firmware would be moved to 
> linux-firmware repository.
> 
> The driver can not simply go along when request_firmware 
> fails. Though Ben's
> code did not take care of it, the driver should imho 
> propagate some return
> code. Ben ?
> 
> There is no change in rtl8168d_3_hw_phy_config : could you 
> add a comment
> so that people know it is different ?
> 
> Could you Cc: the linux-firmware patch as well ?
> 
> Minor nit: please keep the code free of capitalized hex data.
> 
> > diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> > index 7d33ef4..cad1ba8 100644
> > --- a/drivers/net/r8169.c
> > +++ b/drivers/net/r8169.c
> [...]
> > @@ -1383,6 +1384,28 @@ static void rtl_phy_write(void 
> __iomem *ioaddr, const struct phy_reg *regs, int
> >  	}
> >  }
> >  
> > +static void rtl_phy_write_fw(void __iomem *ioaddr, const 
> struct firmware *fw)
> > +{
> [...]
> > +		default:
> > +			printk(KERN_WARNING "%s: Unknown action\n",
> > +				__FUNCTION__);
> 
> A bit old school. It gives no information about the device.
> Use netif_{err/info} or such ?
> 
> Thanks.
> 
> -- 
> Ueimor
> 
> 
> ------Please consider the environment before printing this e-mail. 
> 
> 
> 

------=_NextPart_000_002E_01CB9180.DB852A90
Content-Type: application/octet-stream;
	name="0001-rtl_nic-Add-firmware-for-RTL8111D-L.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="0001-rtl_nic-Add-firmware-for-RTL8111D-L.patch"

>From 706b34566b9318ae50b9b931178ee6b66b05080a Mon Sep 17 00:00:00 2001=0A=
From: Hayes Wang <hayeswang@realtek.com>=0A=
Date: Wed, 1 Dec 2010 10:21:47 +0800=0A=
Subject: [PATCH] rtl_nic: Add firmware for RTL8111D(L)=0A=
=0A=
Add firmware for r8169 of kernel for RTL8111D=0A=
	rtl_nic/rtl8168d-1.fw=0A=
	rtl_nic/rtl8168d-2.fw=0A=
=0A=
Signed-off-by: Hayes Wang <hayeswang@realtek.com>=0A=
---=0A=
 WHENCE                |   14 ++++++++++++++=0A=
 rtl_nic/rtl8168d-1.fw |  Bin 0 -> 1492 bytes=0A=
 rtl_nic/rtl8168d-2.fw |  Bin 0 -> 1324 bytes=0A=
 3 files changed, 14 insertions(+), 0 deletions(-)=0A=
 create mode 100644 rtl_nic/rtl8168d-1.fw=0A=
 create mode 100644 rtl_nic/rtl8168d-2.fw=0A=
=0A=
diff --git a/WHENCE b/WHENCE=0A=
index 907fe68..e2aca61 100644=0A=
--- a/WHENCE=0A=
+++ b/WHENCE=0A=
@@ -1451,3 +1451,17 @@ Licence: Redistributable. See =
LICENCE.rtlwifi_firmware for details.=0A=
 =0A=
 =
-------------------------------------------------------------------------=
-=0A=
 =0A=
+Driver: r8169 - RealTek 8169/8168/8101 ethernet driver.=0A=
+=0A=
+File: rtl_nic/rtl8168d-1.fw=0A=
+File: rtl_nic/rtl8168d-2.fw=0A=
+=0A=
+Licence:=0A=
+ * Copyright (c) 2010, Realtek Semiconductor Corporation =0A=
+ *=0A=
+ * Permission is hereby granted for the distribution of this firmware=0A=
+ * data in hexadecimal or equivalent format, provided this copyright=0A=
+ * notice is accompanying it.=0A=
+=0A=
+------------------------------------------------------------------------=
--=0A=
+=0A=
diff --git a/rtl_nic/rtl8168d-1.fw b/rtl_nic/rtl8168d-1.fw=0A=
new file mode 100644=0A=
index =
0000000000000000000000000000000000000000..99e002de1fb965d53822bc9ea0f5a8c=
a12d27f62=0A=
GIT binary patch=0A=
literal 1492=0A=
zcmb7^&2LO$6vppN=3DN_%1<0Fx(AYx^uEX1yhrar4ANXv!=3D@gJx}lSjwKS7IZ?qOFKT=0A=
zM$#s%SeTtHN*bc#8Z8OQj1|)lQ@=3DC!PBeBFH_v<C^YK3KbIyIkV55F6gi>G%6l$ho=0A=
zD$klqeWq`$OYDCKBk%%P`DE%FAg0B%D`gr=3Dvo_XQ({Lm4TmQ);rk>YJ-cSdz<mS6f=0A=
zg=3DW)@LDS%bDSg}2Lu}J1cEL1(J%TUg^?OX!o2L2SoFAHIXTTDCza{t`ESf%FFb%+Q=0A=
z<$cqtm8OnyQ>WMNG_9r92zK7>d~COHRwuFU?`EC%HNM@>VT`-1HXY2x8gx6t`#^#{=0A=
z$^PL4_c<<@_Ja|)4a}icZ@X!#YP#auP2;<2+Mf9Oc9@FP^x9jNnSLCH_XgsoOw-p)=0A=
z*U51n5j_07DKvJ>MW+6P=3DuJ<erSV>Ng!AF=3Dd?R#p4Es%YhW^G6W$;nMeGT|p7W>E<=0A=
z4NYV4s9ZE%<lM1)rb*UyE%uP-^RO56dGNbCC&yGTeIKSLFHL%7I<qn92|e=3Dpsc^SV=0A=
zezz~&E!j)Irmv6VxH7#vv7H_&?qLJm7MPdiXt|!+>yFab)6C0VG$YTs<UX6)_L?3Z=0A=
zV@8<0FJNu|t0~KVoks?3ickLLl<^g*<vpv_*iY}h#)`N`ZJ!!N_PsYbI7bKKbwDlG=0A=
z$aV2PWV=3DE7H3|xSeI2o`Yuvn8WBesP_eIS0|IC4(^=3DX@_o!rz}G~=3DA<E2gVxyOVj%=0A=
zmFOumQHx8srrJyy&cB;CJxF3Q9z$%<gKoY@-G0`?4RBi%a~o$4COS+<(0mY{<7=3D@;=0A=
z$axyuRqXn|SaDt_O{d_IuJcOlnr{#Dg0F=3DhroI2pJK6JD@%n`mrbFDTt88kWG`;*l=0A=
zY>Ii{pLKt9&UBI*{`T~qV&-@UYW6fduxHS8jyJ3D+|)r_?iv63A#|cf+Y-}@%ce&D=0A=
z{r9{Rk6M|lIn(bd^~hVyv9ZoS;r9#9i}_~enPGaH4osWT(eWd8iW&WY?KsQ%W$G8s=0A=
z6T`aoEu7z>?<Mw{OwasI{szI--@9Afxk_G0?FDpA!7Bj${%>=3Dk4h!u;e+%D$0d{s%=0A=
VTES$40^aVxniVE*_&j`k?+=3DA!Np1iD=0A=
=0A=
literal 0=0A=
HcmV?d00001=0A=
=0A=
diff --git a/rtl_nic/rtl8168d-2.fw b/rtl_nic/rtl8168d-2.fw=0A=
new file mode 100644=0A=
index =
0000000000000000000000000000000000000000..7022ab0af4753c529a1646bc921d9d1=
889767fde=0A=
GIT binary patch=0A=
literal 1324=0A=
zcmb7^OGs2<6vyv8?#a}eDFQJ=3DC8D+3qOA)l&Bs_&Ot#U5;ihF^kZ^R`qy_DQ7UQ@W=0A=
ziU~%jRV@lyxXlNMk<wL11BJ0w`JR5?eAl#PtMi@r|NPIn*L7<2SHV?vL>+Z?Yg078=0A=
zExKkTwsqtZ@)2@#Su{N$dg_$u^l8!AM$x7w(ZL}41bRv|ld*ahJsq+BEdF%6^_lnh=0A=
zRngCbqKP~`JFJZ0H+rPax5s>W-O9o>U$!DW(ZxE^`h@6y99%ikm0{5lFcy6cqL=3DVR=0A=
z?w~J;mQ%ayf@t+m(Hyv+npsxB@yy3Ty{PF&9S_+-uG24CI%?~su%)BC!51)iiSI`y=0A=
zUE*Kb_%QL&<Pl#8U&Q(X_*{JDS-2Ue?<>(8%wK$u9O0tb_HbHkov4`|OmXCBKy-3V=0A=
zbjlH}QFe0A?#S$<Yn|DcX|>k3G20BbcW}M5Z+F+QA*y%n4wLL~0DOf4wNHrNIw#tD=0A=
zR&<QL&OE0loGpW;1s-l!iI%)UlAl-=3D{o&iE;KSfZf#ZGn-<)0(Yih8wR=3D>u{%#j+t=0A=
z-NdZ2n>Jz$rzzg$j^)LJmv-zq`WP98yBz(@`!D|?I4(QnKWzBViw4=3Dv|J;Gc9n_h+=0A=
zi=3Dut?^nvSP_%t_?1xNm}?cvd{h?Tf1uqKJiFne~4nAbKYj~=3D5|mN`6lGw%@lKVxnQ=0A=
zY%bUur{R1SoHs=3D$2ALcEgVD(``W`!TcgY7sx52Rpt{!j&eH~mLdb96~b1&5q>o3~y=0A=
zPhvCmN{8tCNpz!AbpDFyLM1mmDLO>0V5#Uu{F@%%Q@3aj_4eZE+}w(<hrzME1+E?J=0A=
z)cM#b+R03Tl<2X5=3Do9W^`V0Sw64A<UqC0Q-Cb_Hdp2dHFu@5{sVh->b%(>r(`Yw7q=0A=
z+&Q)I2sY<DI<oK`oj!#H`XhJvH$CLO43;@!zB12aFdrXfCTz3!MIQ`-kKBzIc`rnF=0A=
s;j_ZExGJa-aHx-eF5&XeBL^8HCt4d+XFjA3|3pX1)b;<3yC$CZAI_u&^8f$<=0A=
=0A=
literal 0=0A=
HcmV?d00001=0A=
=0A=
-- =0A=
1.7.3.2=0A=
=0A=

------=_NextPart_000_002E_01CB9180.DB852A90--
