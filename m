From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next 2/2] bonding: options handling cleanup
Date: Wed, 05 Mar 2014 12:39:09 +0100
Message-ID: <53170CDD.4040202@redhat.com>
References: <20140304163425.44995c59@nehalam.linuxnetplumber.net> <20140304163644.432f60d0@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53274 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754806AbaCELnp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2014 06:43:45 -0500
In-Reply-To: <20140304163644.432f60d0@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/05/2014 01:36 AM, Stephen Hemminger wrote:
> Make local functions static (ie. only used in bond_options.c)
> Make bond options parsing tables constant.
>=20
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>=20
>=20
> ---
>  drivers/net/bonding/bond_main.c    |    3=20
>  drivers/net/bonding/bond_options.c |  190 ++++++++++++++++++++++++--=
-----------
>  drivers/net/bonding/bond_options.h |   57 +----------
>  drivers/net/bonding/bond_sysfs.c   |   16 +--
>  drivers/net/bonding/bonding.h      |    2=20
>  5 files changed, 141 insertions(+), 127 deletions(-)
>=20

Hi Stephen,
Thanks for doing this, it was one of the items on my todo list for a lo=
ng time.
However there're a few more places that need cleaning up after the patc=
h is applied:
drivers/net/bonding//bond_options.c: In function =91bond_opt_dep_print=92=
:
drivers/net/bonding//bond_options.c:511:10: warning: assignment discard=
s =91const=92
qualifier from pointer target type [enabled by default]
  modeval =3D bond_opt_get_val(BOND_OPT_MODE, params->mode);
          ^
drivers/net/bonding//bond_options.c: In function =91bond_opt_error_inte=
rpret=92:
drivers/net/bonding//bond_options.c:540:10: warning: assignment discard=
s =91const=92
qualifier from pointer target type [enabled by default]
   minval =3D bond_opt_get_flags(opt, BOND_VALFLAG_MIN);
          ^
drivers/net/bonding//bond_options.c:541:10: warning: assignment discard=
s =91const=92
qualifier from pointer target type [enabled by default]
   maxval =3D bond_opt_get_flags(opt, BOND_VALFLAG_MAX);
          ^
drivers/net/bonding//bond_options.c: In function =91__bond_opt_set=92:
drivers/net/bonding//bond_options.c:589:9: warning: assignment discards=
 =91const=92
qualifier from pointer target type [enabled by default]
  retval =3D bond_opt_parse(opt, val);
         ^
drivers/net/bonding//bond_procfs.c: In function =91bond_info_show_maste=
r=92:
drivers/net/bonding//bond_procfs.c:79:10: warning: assignment discards =
=91const=92
qualifier from pointer target type [enabled by default]
   optval =3D bond_opt_get_val(BOND_OPT_FAIL_OVER_MAC,
          ^
drivers/net/bonding//bond_procfs.c:88:10: warning: assignment discards =
=91const=92
qualifier from pointer target type [enabled by default]
   optval =3D bond_opt_get_val(BOND_OPT_XMIT_HASH,
          ^
drivers/net/bonding//bond_procfs.c:99:11: warning: assignment discards =
=91const=92
qualifier from pointer target type [enabled by default]
    optval =3D bond_opt_get_val(BOND_OPT_PRIMARY_RESELECT,
           ^
drivers/net/bonding//bond_procfs.c:144:10: warning: assignment discards=
 =91const=92
qualifier from pointer target type [enabled by default]
   optval =3D bond_opt_get_val(BOND_OPT_AD_SELECT,
