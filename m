From: "=?windows-1252?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: net-next-2.6 phonet causes build error
Date: Mon, 27 Jul 2009 11:06:02 +0300
Message-ID: <200907271106.02456.remi.denis-courmont@nokia.com>
References: <4A6CA3BF.7010709@hartkopp.net> <200907270927.55728.remi.denis-courmont@nokia.com> <4A6D512A.1050504@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: ext Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:45730 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbZG0IDy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 04:03:54 -0400
In-Reply-To: <4A6D512A.1050504@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 27 July 2009 10:03:06 ext Eric Dumazet wrote:
> R=E9mi Denis-Courmont a =E9crit :
> > On Sunday 26 July 2009 21:43:11 ext Oliver Hartkopp wrote:
> >> i got this build error from the latest net-next-2.6:
> >>
> >> net/phonet/pn_dev.c: In function =91phonet_init_net=92:
> >> net/phonet/pn_dev.c:221: error: implicit declaration of function
> >> =91proc_net_fops_create=92
> >> net/phonet/pn_dev.c: In function =91phonet_exit_net=92:
> >> net/phonet/pn_dev.c:242: error: implicit declaration of function
> >> =91proc_net_remove=92
> >
> > Oops. This makes me wonder why I did not get that one here on my te=
st
> > builds???
>
> I also have this warning :
>
> net/phonet/pn_dev.c: In function `phonet_device_get':
> net/phonet/pn_dev.c:99: warning: 'dev' might be used uninitialized in=
 this
> function

Right. This is indeed a bug - thanks. Either my gcc version is bad at t=
hat=20
stuff or I have missing debug options :(

> What about following patch ?
>
> [PATCH] phonet: phonet_device_get() fix
>
> net/phonet/pn_dev.c: In function `phonet_device_get':
> net/phonet/pn_dev.c:99: warning: 'dev' might be used uninitialized in=
 this
> function
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Acked-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

> ---
>
> diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
> index b0d6ddd..c2b77a6 100644
> --- a/net/phonet/pn_dev.c
> +++ b/net/phonet/pn_dev.c
> @@ -96,7 +96,7 @@ struct net_device *phonet_device_get(struct net *ne=
t)
>  {
>  	struct phonet_device_list *pndevs =3D phonet_device_list(net);
>  	struct phonet_device *pnd;
> -	struct net_device *dev;
> +	struct net_device *dev =3D NULL;
>
>  	spin_lock_bh(&pndevs->lock);
>  	list_for_each_entry(pnd, &pndevs->list, list) {



--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

