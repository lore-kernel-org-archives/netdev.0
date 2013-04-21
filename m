From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [Patch net-next v4 4/5] vxlan: add scope_id support for ll addr
Date: Sun, 21 Apr 2013 17:10:21 +0200
Message-ID: <87y5cbor6q.fsf@nemi.mork.no>
References: <1366175423-27310-1-git-send-email-amwang@redhat.com>
	<1366175423-27310-5-git-send-email-amwang@redhat.com>
	<OFA1761298.DF396ECD-ON85257B52.003AE2CA-85257B52.003DBDAB@us.ibm.com>
	<1366552033.23100.16.camel@cr0> <8738ukosar.fsf@nemi.mork.no>
	<1366556238.23100.19.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Stevens <dlstevens@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:53523 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753543Ab3DUPKf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Apr 2013 11:10:35 -0400
In-Reply-To: <1366556238.23100.19.camel@cr0> (Cong Wang's message of "Sun, 21
	Apr 2013 22:57:18 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <amwang@redhat.com> writes:

> On Sun, 2013-04-21 at 16:46 +0200, Bj=C3=B8rn Mork wrote:
>> struct vxlan_addr *rip =3D &vxlan->default_dst.remote_ip;
>>=20
>> rip->va_sin.sin_addr.s_addr
>> rip->va_sin6.sin6_addr=20
>
> I don't see any difference between this with:
>
> vxlan->default_dst.remote_ip.va_sin.sin_addr.s_addr
> vxlan->default_dst.remote_ip.va_sin6.sin6_addr
>
> except making two lines shorter... People still have to go into 5 lev=
els
> to get the final field.

Yes, of course.  That's how many levels there is in this data structure=
=2E

They still have to go into 5 levels when you define away some of those
levels.  Only difference is that they then have to _remember_ that one
of the labels actually is a macro hiding 3 levels...

You are obscuring the levels, not removing them.  That's the problem.

Noone objects to removing levels if you can do that by moving fields
around.  But if you can't, then don't try to hide it.


Bj=C3=B8rn
