From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [Patch net-next v4 4/5] vxlan: add scope_id support for ll addr
Date: Sun, 21 Apr 2013 16:46:20 +0200
Message-ID: <8738ukosar.fsf@nemi.mork.no>
References: <1366175423-27310-1-git-send-email-amwang@redhat.com>
	<1366175423-27310-5-git-send-email-amwang@redhat.com>
	<OFA1761298.DF396ECD-ON85257B52.003AE2CA-85257B52.003DBDAB@us.ibm.com>
	<1366552033.23100.16.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Stevens <dlstevens@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:53273 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753538Ab3DUOqh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Apr 2013 10:46:37 -0400
In-Reply-To: <1366552033.23100.16.camel@cr0> (Cong Wang's message of "Sun, 21
	Apr 2013 21:47:13 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <amwang@redhat.com> writes:
> On Fri, 2013-04-19 at 07:14 -0400, David Stevens wrote:
>>=20
>>         As I commented before, you're obscuring the types here,
>> which makes it less readable. "va_sin6" ought to be a sockaddr_in6,
>> not a sin6_addr, and the scope id ought to then be=20
>> "va_sin6.sin6_scope_id",
>> without any other #define necessary for it.
>
> So finally you want something like:
>
> vxlan->default_dst.remote_ip.va_sin.sin_addr.s_addr
>
> and
>
> vxlan->default_dst.remote_ip.va_sin6.sin6_addr
>
> Enjoy the readable code! :)

There's nothing preventing you from using local variables and/or
functions to shorten those, without obscuring things on the way.
Readability depends on more than just "short".  Obviously correct type
is more important. But you can do both.  Most kernel code does. It's no=
t
hard.



struct vxlan_addr {
	union {
		struct sockaddr_in	sin;
		struct sockaddr_in6	sin6;
		struct sockaddr		sa;
	} u;
#define va_sin  u.sin
#define va_sin6 u.sin6
#define va_sa   u.sa
};
=20
struct vxlan_addr *rip =3D &vxlan->default_dst.remote_ip;

rip->va_sin.sin_addr.s_addr
rip->va_sin6.sin6_addr

etc.


Bj=C3=B8rn
