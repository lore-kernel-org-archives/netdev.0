From: Chuck Ebbert <cebbert.lkml@gmail.com>
Subject: Re: 319554f284dd ("inet: don't use sk_v6_rcv_saddr directly")
 causes bind port regression
Date: Wed, 13 Sep 2017 15:47:50 -0400
Message-ID: <20170913154750.100881c0@gmail.com>
References: <1a8ef376-387e-e0fc-7362-e1fd2c2c45d3@redhat.com>
        <AF16C126-99CA-401A-B803-AA05CDFBFF93@fb.com>
        <588f3795-931e-7779-4ec7-5fe7d4437927@redhat.com>
        <EF55EF02-AD40-4F06-8C07-4F9F4221BFE6@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Laura Abbott <labbott@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        "Hideaki YOSHIFUJI" <yoshfuji@linux-ipv6.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Cole Robinson <crobinso@redhat.com>
To: Josef Bacik <jbacik@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <EF55EF02-AD40-4F06-8C07-4F9F4221BFE6@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 13 Sep 2017 17:28:25 +0000
Josef Bacik <jbacik@fb.com> wrote:

> Sorry I thought I had made this other fix, can you apply this on top
> of the other one and try that?  I have more things to try if this
> doesn=E2=80=99t work, sorry you are playing go between, but I want to make
> sure I know _which_ fix actually fixes the problem, and then clean up
> in followup patches.  Thanks,
>=20
> Josef
>=20
> On 9/13/17, 8:45 AM, "Laura Abbott" <labbott@redhat.com> wrote:
>=20
> On 09/12/2017 04:12 PM, Josef Bacik wrote:
> > First I=E2=80=99m super sorry for the top post, I=E2=80=99m at plumbers=
 and I
> > forgot to upload my muttrc to my new cloud instance, so I=E2=80=99m scr=
ewed
> > using outlook.
> >=20
> > I have a completely untested, uncompiled patch that I think will
> > fix the problem, would you mind giving it a go?  Thanks,
> >=20
> > Josef =20
>=20
> Thanks for the quick turnaround. Unfortunately, the problem is still
> reproducible according to the reporter.
>=20
> Thanks,
> Laura

I am confused by the patch that originally caused this:

        if (sk->sk_family =3D=3D AF_INET6)
                return ipv6_rcv_saddr_equal(&sk->sk_v6_rcv_saddr,
-                                           &sk2->sk_v6_rcv_saddr,
+                                           inet6_rcv_saddr(sk2),
                                            sk->sk_rcv_saddr,
                                            sk2->sk_rcv_saddr,

Shouldn't the first argument also be changed to use inet6_rcv_saddr()?
