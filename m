From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v1 1/2] TCPCT API sysctl update to draft -03
Date: Wed, 12 Jan 2011 19:05:25 +0100
Message-ID: <1294855525.3981.119.camel@edumazet-laptop>
References: <4D2DE824.10205@gmail.com>  <4D2DEA73.4000708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D2DEA73.4000708@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 12 janvier 2011 =C3=A0 12:52 -0500, William Allen Simpson a
=C3=A9crit :
> Use most recently specified symbols of RFC-to-be-6013.
>=20
> Allows different global s_data limits for SYN and SYN_ACK.
>=20
> CC: "Eric W. Biederman" <ebiederm@xmission.com>
> CC: Stephen Hemminger <shemminger@vyatta.com>
> CC: Andi Kleen <andi@firstfloor.org>


> Signed-off-by: William.Allen.Simpson@gmail.com

Should be :

Signed-off-by: William Allen Simpson <William.Allen.Simpson@gmail.com>

> ---
>   Documentation/networking/ip-sysctl.txt |   10 ++++++++++
>   include/net/tcp.h                      |    2 ++
>   net/ipv4/sysctl_net_ipv4.c             |   25 +++++++++++++++++++++=
+++-
>   net/ipv4/tcp_output.c                  |   19 +++++++++++++++++--
>   4 files changed, 53 insertions(+), 3 deletions(-)

Hmm, patch is not inlined, so I have to copy/paste

+static int tcp_cookie_max =3D TCP_COOKIE_MAX;

=2E..
=20
 /* Update system visible IP port range */
 static void set_local_port_range(int range[2])
@@ -588,7 +591,27 @@ static struct ctl_table ipv4_table[] =3D {
                .data           =3D &sysctl_tcp_cookie_size,
                .maxlen         =3D sizeof(int),
                .mode           =3D 0644,
-               .proc_handler   =3D proc_dointvec
+               .proc_handler   =3D proc_dointvec_minmax,
+               .extra1         =3D &zero,
+               .extra2         =3D &tcp_cookie_max,
+       },


Now sysctl_tcp_cookie_size has a max limit of TCP_COOKIE_MAX, you can
remove the now uneeded check in :

static u8 tcp_cookie_size_check(u8 desired)
=2E..
if (cookie_size >=3D TCP_COOKIE_MAX)
	/* value too large, specify maximum */
	return TCP_COOKIE_MAX;
