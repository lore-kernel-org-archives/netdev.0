From: "Jeremy M. Guthrie" <jeremy.guthrie@berbee.com>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Wed, 12 Jan 2005 16:47:28 -0600
Message-ID: <200501121647.30934.jeremy.guthrie@berbee.com>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain> <200501121621.24259.jeremy.guthrie@berbee.com> <16869.42247.126428.508479@robur.slu.se>
Reply-To: jeremy.guthrie@berbee.com
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1205900.ElXUU3VXJm";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <16869.42247.126428.508479@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1205900.ElXUU3VXJm
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Here is what it looked like I was getting before from the old driver... tha=
t=20
took me down to 8mbps.

"printk: 4624 messages suppressed.
dst cache overflow
printk: 4630 messages suppressed.
dst cache overflow
printk: 4631 messages suppressed.
dst cache overflow
printk: 4646 messages suppressed.
dst cache overflow
printk: 4645 messages suppressed.
dst cache overflow"

On Wednesday 12 January 2005 04:30 pm, Robert Olsson wrote:
> Can you give this a last try. It's from an older driver
>
>
> e1000_clean(struct net_device *netdev, int *budget)
> {
>         struct e1000_adapter *adapter =3D netdev->priv;
>         int work_to_do =3D min(*budget, netdev->quota);
>         int work_done =3D 0;
>
>         e1000_clean_tx_irq(adapter);
>         e1000_clean_rx_irq(adapter, &work_done, work_to_do);
>
>         *budget -=3D work_done;
>         netdev->quota -=3D work_done;
>
>         if(work_done < work_to_do) {
>                 netif_rx_complete(netdev);
>                 e1000_irq_enable(adapter);
>         }
>
>         return (work_done >=3D work_to_do);
> }

=2D-=20

=2D-------------------------------------------------
Jeremy M. Guthrie        jeremy.guthrie@berbee.com
Senior Network Engineer        Phone: 608-298-1061
Berbee                           Fax: 608-288-3007
5520 Research Park Drive         NOC: 608-298-1102
Madison, WI 53711

--nextPart1205900.ElXUU3VXJm
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB5akCqtjaBHGZBeURAq5TAJ9iGI8IEFZa1JRlQvXywW4mgYlBbgCfSQJ8
e36cZNT6ZrUUymU4X0FkPkY=
=Xf+f
-----END PGP SIGNATURE-----

--nextPart1205900.ElXUU3VXJm--
