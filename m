From: Andreas Schwab <schwab@suse.de>
Subject: Re: [PATCH] remove net driver ugliness that sparse complains about
Date: Sat, 29 May 2004 20:31:17 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <jeaczraxvu.fsf@sykes.suse.de>
References: <40B8D2F8.6090905@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@oss.sgi.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@redhat.com>,
	Al Viro <viro@parcelfarce.linux.theplanet.co.uk>,
	Arjan van de Ven <arjanv@redhat.com>,
	Linus Torvalds <torvalds@osdl.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S264652AbUE2Sfj@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <40B8D2F8.6090905@pobox.com> (Jeff Garzik's message of "Sat, 29
 May 2004 14:14:16 -0400")
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> writes:

> @@ -3680,7 +3680,7 @@
>  	case SIOCETHTOOL:
>  		return bond_ethtool_ioctl(bond_dev, ifr);
>  	case SIOCGMIIPHY:
> -		mii =3D (struct mii_ioctl_data *)&ifr->ifr_data;
> +		mii =3D if_mii(&ifr);
>  		if (!mii) {
>  			return -EINVAL;
>  		}
> @@ -3691,7 +3691,7 @@
>  		 * We do this again just in case we were called by SIOCGMIIREG
>  		 * instead of SIOCGMIIPHY.
>  		 */
> -		mii =3D (struct mii_ioctl_data *)&ifr->ifr_data;
> +		mii =3D if_mii(&ifr);

These two look wrong, too many &.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
