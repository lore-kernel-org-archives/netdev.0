From: Nj A <nj_a83@yahoo.fr>
Subject: Re : Re : Re : Bug in using inet_lookup ()
Date: Thu, 15 Nov 2007 17:29:52 +0100 (CET)
Message-ID: <910163.76878.qm@web26108.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web26108.mail.ukl.yahoo.com ([217.146.182.149]:20675 "HELO
	web26108.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756365AbXKOQ3y convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 11:29:54 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello all,
No bugs are due to the inet_lookup call now using the following:
      if ((s_skb =3D alloc_skb (MAX_TCP_HEADER + 15, GFP_ATOMIC)) =3D=3D=
 NULL)
      {
         printk ("%s: Unable to allocate memory \n", __FUNCTION__);
         err =3D -ENOMEM;
      }
      dev =3D s_skb->dev;

      if (!dev)
         printk ("%s: no device attached to s_skb\n", __FUNCTION__);
         goto process_dev;

      sk =3D inet_lookup (&tcp_hashinfo, src, p_src, dst, p_dst, inet_i=
if (s_skb));

      bh_lock_sock (sk);
    process_dev:
      spin_lock (&tmp_lock);
      new_dev =3D list_entry (&tmp, struct net_device, todo_list);
      spin_unlock (&tmp_lock);
      if (!new_dev)
         printk ("%s: no device attached to new_dev \n", __FUNCTION__);
      s_skb->dev =3D new_dev;

  ...
  bh_unlock_sock (sk);
  ...

However, I am not having the right results. I checked with an establish=
ed socket and expected to see that the socket is established (which is =
the case) but got the wrong state when testing on (sk->sk_state) and th=
e socket seems in the TIME_WAIT / CLOSE state.

May be I am corrupting the search by manually attaching a device to the=
 skb?
Any idea please?

Cheers,

----- Message d'origine ----
> De : Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> =C0 : Nj A <nj_a83@yahoo.fr>
> Cc : netdev@vger.kernel.org
> Envoy=E9 le : Jeudi, 15 Novembre 2007, 11h12mn 28s
> Objet : Re: Re : Re : Bug in using inet_lookup ()
>=20
> On Wed, Nov 14, 2007 at 04:47:22PM +0000, Nj A (nj_a83@yahoo.fr) wrot=
e:
> > By setting the ID of the ingress device to the inet_lookup() to 0, =
the machine
> reboots automatically.
> > Setting proc/sys/kernel/panic* to non zero values dosn't help more.=
=2E
>=20
> Sorry, I did not understand?
> You mean after you provide zero to inet_lookup() instead of device id=
 it
> strted to reboot?
>=20
> --=20
> Evgeniy Polyakov
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at=20
> http://vger.kernel.org/majordomo-info.html
>


      _________________________________________________________________=
____________=20
Ne gardez plus qu'une seule adresse mail ! Copiez vos mails vers Yahoo!=
 Mail=20
