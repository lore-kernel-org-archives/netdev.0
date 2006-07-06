From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH][ebtables][vlan] ebt_vlan_t target
Date: Thu, 6 Jul 2006 13:15:16 +0200
Message-ID: <200607061315.17109.netdev@axxeo.de>
References: <200607052149.16473.dpc@asn.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:35998 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S932309AbWGFLPX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jul 2006 07:15:23 -0400
To: Dawid =?utf-8?q?Ci=C4=99=C5=BCarkiewicz?= <dpc@asn.pl>
In-Reply-To: <200607052149.16473.dpc@asn.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dawid,

Dawid Ci=C4=99=C5=BCarkiewicz schrieb:
>  my name is Dawid Ciezarkiewicz. As a part of my daily job I was to w=
rite=20
> kernel module for ebtables to let linux bridges change vlan ids in fl=
y using=20
> logic provided by ebtables matches. After hours of tries and kernel l=
earning,=20
> reading and googlin' I've finally come to the place where I've got wo=
rking=20
> module that does what I want. I'm looking for comments of more advanc=
ed linux=20
> developers. Please note that this is my first linux patch I've ever m=
ade.=20

=46irst of all:=20
	You should not implemented "--vlan-target".=20
	Always return EBT_CONTINUE. That saves a lot of (duplicated) code
	(you can express the same using some more rules) while keeping=20
	the same flexibility level. Rules for transforming/mangling=20
	and decision rules should be seperate.


> diff -Nur linux-2.6.17.orig/net/bridge/netfilter/Kconfig=20
> linux-2.6.17/net/bridge/netfilter/Kconfig
> --- linux-2.6.17.orig/net/bridge/netfilter/Kconfig	2006-06-18=20
> 03:49:35.000000000 +0200
> +++ linux-2.6.17/net/bridge/netfilter/Kconfig	2006-06-28 20:48:27.000=
000000=20
> +0200
> @@ -165,6 +165,15 @@
>=20
>  	  To compile it as a module, choose M here.  If unsure, say N.
>=20
> +config BRIDGE_EBT_VLAN_T
> +	tristate "ebt: vlan target support"
> +	depends on BRIDGE_NF_EBTABLES
> +	help
> +	  This option adds the vlan target.
> +
> +	  To compile it as a module, choose M here.  If unsure, say N.
> +
> +

Please put your nice explanations "to change vlan ids in fly" from your=
 email here.

And short ebtables example for the common use case might help, too. But=
 only,
if it is not more than two lines or such. Otherwise omit it.

I cannot comment on rest of the patch and hope other people will do :-)


Regards

Ingo Oeser
