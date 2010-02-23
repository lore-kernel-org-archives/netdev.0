From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: [net-next-2.6 PATCH] e1000: convert to use netdev_for_each_mc_addr
Date: Mon, 22 Feb 2010 16:54:13 -0800
Message-ID: <4807377b1002221654t423023efq9f6ad45492d1374f@mail.gmail.com>
References: <20100222191044.GC4141@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f197.google.com ([209.85.211.197]:56981 "EHLO
	mail-yw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422Ab0BWAyO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 19:54:14 -0500
Received: by ywh35 with SMTP id 35so1599802ywh.4
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2010 16:54:13 -0800 (PST)
In-Reply-To: <20100222191044.GC4141@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 22, 2010 at 11:10 AM, Jiri Pirko <jpirko@redhat.com> wrote:
>
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> ---
> =A0drivers/net/e1000/e1000_main.c | =A0 37 +++++++++++++++++---------=
-----------
> =A01 files changed, 17 insertions(+), 20 deletions(-)
>
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000=
_main.c
> index 3b14dd7..c99f95c 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -2161,29 +2161,26 @@ static void e1000_set_rx_mode(struct net_devi=
ce *netdev)
>
> =A0 =A0 =A0 =A0WARN_ON(i =3D=3D rar_entries);
>
> - =A0 =A0 =A0 mc_ptr =3D netdev->mc_list;
> -
> - =A0 =A0 =A0 for (; i < rar_entries; i++) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mc_ptr) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 e1000_rar_set(hw, mc_pt=
r->da_addr, i);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mc_ptr =3D mc_ptr->next=
;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 E1000_WRITE_REG_ARRAY(h=
w, RA, i << 1, 0);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 E1000_WRITE_FLUSH();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 E1000_WRITE_REG_ARRAY(h=
w, RA, (i << 1) + 1, 0);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 E1000_WRITE_FLUSH();
> + =A0 =A0 =A0 netdev_for_each_mc_addr(mc_ptr, netdev) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (i =3D=3D rar_entries) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* load any remaining a=
ddresses into the hash table */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 hash_reg, hash_bit,=
 mta;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hash_value =3D e1000_ha=
sh_mc_addr(hw, mc_ptr->da_addr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hash_reg =3D (hash_valu=
e >> 5) & 0x7F;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hash_bit =3D hash_value=
 & 0x1F;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mta =3D (1 << hash_bit)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcarray[hash_reg] |=3D =
mta;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else {

nit - else should be in the same line like  "} else {"

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 e1000_rar_set(hw, mc_pt=
r->da_addr, i++);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 /* load any remaining addresses into the hash table */
> -
> - =A0 =A0 =A0 for (; mc_ptr; mc_ptr =3D mc_ptr->next) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 hash_reg, hash_bit, mta;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 hash_value =3D e1000_hash_mc_addr(hw, m=
c_ptr->da_addr);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 hash_reg =3D (hash_value >> 5) & 0x7F;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 hash_bit =3D hash_value & 0x1F;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mta =3D (1 << hash_bit);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcarray[hash_reg] |=3D mta;
> + =A0 =A0 =A0 for (; i < rar_entries; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 E1000_WRITE_REG_ARRAY(hw, RA, i << 1, 0=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 E1000_WRITE_FLUSH();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 E1000_WRITE_REG_ARRAY(hw, RA, (i << 1) =
+ 1, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 E1000_WRITE_FLUSH();
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0/* write the hash table completely, write from bottom =
to avoid

otherwise seems okay.  Thanks for your work on cleaning this stuff,
we'll be testing it as part of the net next testing already going on.
