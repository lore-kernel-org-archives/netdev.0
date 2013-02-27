From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] net: af_packet: Validate parameter size for
 PACKET_HDRLEN control message
Date: Wed, 27 Feb 2013 12:33:27 -0800
Message-ID: <20130227203327.GA6113@roeck-us.net>
References: <1361994418-1403-1-git-send-email-linux@roeck-us.net>
 <512E6AF9.3030901@redhat.com>
 <20130227.152630.35846741651175869.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dborkman@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.active-venture.com ([67.228.131.205]:49554 "EHLO
	mail.active-venture.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752706Ab3B0UdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 15:33:25 -0500
Content-Disposition: inline
In-Reply-To: <20130227.152630.35846741651175869.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 27, 2013 at 03:26:30PM -0500, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Wed, 27 Feb 2013 21:22:17 +0100
>=20
> > On 02/27/2013 08:46 PM, Guenter Roeck wrote:
> >> Building af_packet may fail with
> >>
> >> In function =E2=80=98copy_from_user=E2=80=99,
> >>      inlined from =E2=80=98packet_getsockopt=E2=80=99 at
> >>      net/packet/af_packet.c:3215:21:
> >> arch/x86/include/asm/uaccess_32.h:211:26: error: call to
> >>      =E2=80=98copy_from_user_overflow=E2=80=99 declared with attri=
bute error:
> >>      copy_from_user()
> >>      buffer size is not provably correct
> >>
> >> if built with W=3D1 due to a missing parameter size validation.
> >>
> >> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> >> ---
> >>   net/packet/af_packet.c |    2 ++
> >>   1 file changed, 2 insertions(+)
> >>
> >> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> >> index c7bfeff..1976b23 100644
> >> --- a/net/packet/af_packet.c
> >> +++ b/net/packet/af_packet.c
> >> @@ -3210,6 +3210,8 @@ static int packet_getsockopt(struct socket
> >> *sock, int level, int optname,
> >>   		val =3D po->tp_version;
> >>   		break;
> >>   	case PACKET_HDRLEN:
> >> +		if (len < sizeof(int))
> >> +			return -EINVAL;
> >=20
> > I think this could break some user space applications here, those w=
ho
> > e.g. only pass
> > an uint16_t to packet_getsockopt with PACKET_HDRLEN.
>=20
> Well, their shit is broken on big endian then.

There must be something else going on anyway ... yes, my patch fixes th=
e
warning/error, but copy_from_user should only bail out if the copy size
can be larger than the provided buffer (unless I misunderstand the code
in copy_from_user). And the second check should take care of that.

Anyway, point taken. I'll waste my time elsewhere :).

Thanks,
Guenter
