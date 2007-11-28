From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 1/3] Remove trailing NULs from network bonding sysfs
 interface.
Date: Tue, 27 Nov 2007 19:49:29 -0800
Message-ID: <20071127194929.757e4ebe.randy.dunlap@oracle.com>
References: <871wabkxcd.fsf@szonett.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: =?utf-8?q?Ferenc_W=C3=A1gner?= <wferi@niif.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:57687 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbXK1DuK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 22:50:10 -0500
In-Reply-To: <871wabkxcd.fsf@szonett.ki.iif.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 28 Nov 2007 01:49:54 +0100 =3D?utf-8?q?Ferenc_W=3DC3=3DA1gner?=3D=
 wrote:

> Also remove trailing spaces from multivalued files.
>=20
> This fixes output like for example:
>=20
> $ od -c /sys/class/net/bond0/bonding/slaves
> 0000000   e   t   h   -   l   e   f   t       e   t   h   -   r   i  =
 g
> 0000020   h   t      \n  \0
> 0000025
>=20
> It mostly entails deleting '+1'-s after sprintf() calls: the return v=
alue
> of sprintf is the number of characters printed, without the closing N=
UL,
> ie. exactly what the sysfs interface requires.  The three multivalue
> cases are different, because they also have to swallow back a trailin=
g
> space.
>=20
> Signed-off-by: Ferenc W=E1gner <wferi@niif.hu>
> ---
>  drivers/net/bonding/bond_sysfs.c |   66 +++++++++++++++++-----------=
---------
>  1 files changed, 30 insertions(+), 36 deletions(-)
>=20
> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/b=
ond_sysfs.c
> index b29330d..a3f1b4a 100644
> --- a/drivers/net/bonding/bond_sysfs.c
> +++ b/drivers/net/bonding/bond_sysfs.c
> @@ -86,14 +86,13 @@ static ssize_t bonding_show_bonds(struct class *c=
ls, char *buffer)
>  			/* not enough space for another interface name */
>  			if ((PAGE_SIZE - res) > 10)
>  				res =3D PAGE_SIZE - 10;
> -			res +=3D sprintf(buffer + res, "++more++");
> +			res +=3D sprintf(buffer + res, "++more++ ");
>  			break;
>  		}
>  		res +=3D sprintf(buffer + res, "%s ",
>  			       bond->dev->name);
>  	}
> -	res +=3D sprintf(buffer + res, "\n");
> -	res++;
> +	if (res) buffer[res-1] =3D '\n'; /* eat the leftover space */
>  	up_read(&(bonding_rwsem));
>  	return res;
>  }
> @@ -235,14 +234,13 @@ static ssize_t bonding_show_slaves(struct devic=
e *d,
>  			/* not enough space for another interface name */
>  			if ((PAGE_SIZE - res) > 10)
>  				res =3D PAGE_SIZE - 10;
> -			res +=3D sprintf(buf + res, "++more++");
> +			res +=3D sprintf(buf + res, "++more++ ");
>  			break;
>  		}
>  		res +=3D sprintf(buf + res, "%s ", slave->dev->name);
>  	}
>  	read_unlock(&bond->lock);
> -	res +=3D sprintf(buf + res, "\n");
> -	res++;
> +	if (res) buf[res-1] =3D '\n'; /* eat the leftover space */
>  	return res;
>  }
> =20
> @@ -711,10 +709,7 @@ static ssize_t bonding_show_arp_targets(struct d=
evice *d,
>  			res +=3D sprintf(buf + res, "%u.%u.%u.%u ",
>  			       NIPQUAD(bond->params.arp_targets[i]));
>  	}
> -	if (res)
> -		res--;  /* eat the leftover space */
> -	res +=3D sprintf(buf + res, "\n");
> -	res++;
> +	if (res) buf[res-1] =3D '\n'; /* eat the leftover space */
>  	return res;
>  }

Hi,

Patches 1 & 3 use

	if (res) statement;

but the preferred form is

	if (res)
		statement;

Even if this style was already used in the source file, it should
be cleaned up.

Thanks,
---
~Randy
