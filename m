From: kuznet@ms2.inr.ac.ru
Subject: Re: Patch: minor nit in ip_options_compile()
Date: Mon, 24 Mar 2003 03:02:13 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200303240002.DAA25577@sex.inr.ac.ru>
References: <200303211956.50921.niv@us.ibm.com>
Mime-Version: 1.0
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: niv@us.ibm.com (Nivedita Singhvi)
In-Reply-To: <200303211956.50921.niv@us.ibm.com> from "Nivedita Singhvi" at Mar 21, 3 07:56:50 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> In the following else clause, we check for opt->is_data, which=20
> should always be set for this case, and if not, current code will
> lead to a null ptr dereference because skb is always null in=20
> this case..

You misunderstood tha code. If opt->is_data is clear skb may be not NULL.
The option is not used at the moment, but it it pretty silly to lose this.

> Look reasonable?=20

No:

> +=09=09if ((optptr =3D opt->__data) =3D=3D 0)
> +=09=09=09goto error;=20

is identical FALSE. [Sent quatable-printable attachment? Get it
back quoted. :-)]


> Figured its better to fall down to returning EINVAL..

if (skb == NULL)
   BUG();

Listen, I love to add BUG()s when it is not mathematically
clear that something is invariant. Not in this trivial case.

Alexey
