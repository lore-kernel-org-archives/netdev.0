From: Christopher White <chris@logicalelegance.com>
Subject: Re: [PATCH V3 net-next] LISP: Locator/Identifier Separation Protocol
Date: Thu, 19 Jun 2014 09:31:27 -0700
Message-ID: <6A1822EF-41D2-49AC-AA94-227458773FF8@logicalelegance.com>
References: <86BFD474-6614-418E-B4B3-C725848FE196@logicalelegance.com> <CA+mtBx-aNF9-H+N_VmHqFGdVgGAdR5xer8F19wAvSKmUZpGy4Q@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"Vina Ermagan (vermagan)" <vermagan@cisco.com>,
	"Lorand Jakab -X (lojakab - M SQUARED CONSULTING INC. at Cisco)"
	<lojakab@cisco.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.webfaction.com ([74.55.86.74]:43314 "EHLO
	smtp.webfaction.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932456AbaFSQbi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2014 12:31:38 -0400
In-Reply-To: <CA+mtBx-aNF9-H+N_VmHqFGdVgGAdR5xer8F19wAvSKmUZpGy4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,=20

Thanks again for the quick turnaround. Some responses and questions bel=
ow=85

On Jun 18, 2014, at 5:08 PM, Tom Herbert <therbert@google.com> wrote:
>>=20
>> +       hash =3D skb_get_hash(skb);
>> +       if (!hash)
>> +               hash =3D jhash(skb->data, 2 * ETH_ALEN,
>> +                            (__force u32) skb->protocol);
>> +
>=20
> This is probably okay for now, but we should really be smarter here.
> Looks like another consumer of a TX hash in skbuf (Eric was looking t=
o
> add that I believe).

Ok.

> >check =3D CSUM_MANGLED_0;
>> +               }
>> +
>> +               skb->protocol =3D protocol;
>> +       } while ((skb =3D skb->next));
>> +out:
>> +       return segs;
>> +}
>> +
> Please split out generic changes into their own patches.
>=20

Will do.

>> +int udpv4_create_encap_sock(struct net *net, __be16 port, struct so=
cket **psock,
>> +                           bool csum)
>> +{
>> +       struct sock *sk;
>> +       struct socket *sock;
>> +       struct sockaddr_in lisp_addr =3D {
>> +               .sin_family             =3D AF_INET,
>> +               .sin_addr.s_addr        =3D htonl(INADDR_ANY),
>> +               .sin_port               =3D port,
>> +       };
>> +       int rc;
>> +
> Still some lisp artifacts.

Sorry, that got past me, will fix.

>>=20
>> +       }
>> +
>> +       *psock =3D sock;
>> +       /* Disable multicast loopback */
>> +       inet_sk(sk)->mc_loop =3D 0;
>> +
>> +       if (!csum)
>> +               sock->sk->sk_no_check_tx =3D 1;
>> +       return 0;
>> +}
>> +EXPORT_SYMBOL(udpv4_create_encap_sock)
>=20
> I was actually thinking this function could be even more general. The
> L2TP_ENCAPTYPE_UDP case in l2tp_tunnel_sock_create looks like
> something we might be able to abstract out into a separate function--
> it would include IPv6 support and the possibility of binding to other
> than INADDR_ANY and connected sockets. l2tp_tunnel_cfg could be the
> basis of udp_port_cfg which contains addresses, ports, and sockopts
> like sk_no_check_tx=85
>=20

So I=92m happy to do this, but I would like to do it in a separate subm=
ission.=20
=46or one thing, I am not super familiar with that code and I=92m a bit=
 nervous=20
about making substantive changes, thus it may take me some time.=20
As it is orthogonal to the LISP submission, would it be possible to do =
this=20
separately and have LISP move forward?

Thanks!
-Chris
