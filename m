From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
 gc_elasticity is exceeded
Date: Thu, 16 Oct 2008 22:03:07 -0700
Message-ID: <20081016220307.5456ac55@extreme>
References: <20081006225210.GA29794@hmsreliant.think-freely.org>
	<48EAEFF9.1000606@cosmosbay.com>
	<20081013182655.GA9505@hmsreliant.think-freely.org>
	<20081015.235556.61915120.davem@davemloft.net>
	<20081016114155.GA15877@hmsreliant.think-freely.org>
	<48F732CB.8030704@cosmosbay.com>
	<20081016163644.GA2933@localhost.localdomain>
	<20081016233517.GA21243@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, billfink@mindspring.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	johnpol@2ka.mipt.ru
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34582 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751152AbYJQFDL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 01:03:11 -0400
In-Reply-To: <20081016233517.GA21243@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Oct 2008 19:35:17 -0400
Neil Horman <nhorman@tuxdriver.com> wrote:

> On Thu, Oct 16, 2008 at 12:36:44PM -0400, Neil Horman wrote:
> > On Thu, Oct 16, 2008 at 02:25:47PM +0200, Eric Dumazet wrote:
> > > Neil Horman a =C3=A9crit :
> > Yeah, that was quite stupid of me.  I rescind this, and I'll post a=
 patch with the=20
> > missing chunk later tonight after I spin/test it.
> >=20
>=20
>=20
> Ok, heres a new patch, same as before, but added in proper initalizat=
ion for
> stack variables, as well as the missing chunk that actually computed =
the
> standard deviation and maximum chain length.  Built/tested by me succ=
essfully.
> Sorry for the prior noise.  Please review/ack.
>=20
> Regards
> Neil
>=20
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>=20
>=20
>  include/linux/sysctl.h     |    1=20
>  include/net/netns/ipv4.h   |    2=20
>  kernel/sysctl_check.c      |    1=20
>  net/ipv4/route.c           |  130 ++++++++++++++++++++++++++++++++++=
++++++++++-
>  net/ipv4/sysctl_net_ipv4.c |   12 ++++
>  5 files changed, 144 insertions(+), 2 deletions(-)
>=20
>=20
> diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
> index d0437f3..481aa44 100644
> --- a/include/linux/sysctl.h
> +++ b/include/linux/sysctl.h
> @@ -435,6 +435,7 @@ enum
>  	NET_TCP_ALLOWED_CONG_CONTROL=3D123,
>  	NET_TCP_MAX_SSTHRESH=3D124,
>  	NET_TCP_FRTO_RESPONSE=3D125,
> +	NET_IPV4_RT_CACHE_REBUILD_COUNT=3D126,
>  };
> =20

Don't add new sysctl numbers use CTL_UNNUMBERED
