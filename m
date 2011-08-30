From: Wolfgang Walter <wolfgang.walter@stwm.de>
Subject: Re: linux 2.6.32.46 crashes
Date: Tue, 30 Aug 2011 23:45:11 +0200
Message-ID: <201108302345.12250.wolfgang.walter@stwm.de>
References: <201108302231.47530.wolfgang.walter@stwm.de> <4E5D4E91.3070503@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <greg@kroah.com>, "gregkh@suse.de" <gregkh@suse.de>,
	linux-kernel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tim Gardner <tim.gardner@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:52911 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751520Ab1H3VpO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 17:45:14 -0400
In-Reply-To: <4E5D4E91.3070503@canonical.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, 30. August 2011 schrieb Tim Gardner:
> On 08/30/2011 02:31 PM, Wolfgang Walter wrote:
> > Hello,
> >
> > I upgraded several machines from 2.6.32.43 to 2.6.32.46 and
> > they all crashed when the kernel boots.
> >
> > I bisected it to the following commit:
> >
> >
> > 35ed3d0fb62804090a3f21a7ce84c538a6ff852f is the first bad commit
> > commit 35ed3d0fb62804090a3f21a7ce84c538a6ff852f
> > Author: Alexey Dobriyan<adobriyan@gmail.com>
> > Date:   Tue Feb 16 09:05:04 2010 +0000
> >
> >      tunnels: fix netns vs proto registration ordering
> >
> >      commit d5aa407f59f5b83d2c50ec88f5bf56d40f1f8978 upstream.
> >
> >      Same stuff as in ip_gre patch: receive hook can be called befo=
re
> > netns setup is done, oopsing in net_generic().
> >
> >      Signed-off-by: Alexey Dobriyan<adobriyan@gmail.com>
> >      Signed-off-by: David S. Miller<davem@davemloft.net>
> >      Signed-off-by: Greg Kroah-Hartman<gregkh@suse.de>
> >
> > :040000 040000 6338c45b1372e7e3c5a5ef466dc365cc47a2e152
> > : cde6b92bab403d860cca90e8232cb9c03090fc7e M      net
> >
> > Reverting it on top of 2.6.32.46 fixes the problem for me.
>
> <snip>
>
> Wolfgang - see if this patch fixes your problem.
>

> From e52d45fe5518e8447b54b440f41d318db146a19e Mon Sep 17 00:00:00 200=
1
> From: Andy Whitcroft <apw@canonical.com>
> Date: Tue, 30 Aug 2011 13:44:23 +0100
> Subject: [PATCH] tunnels: fix netns vs proto registration ordering --=
 fix
> stable backport
>
> BugLink: http://bugs.launchpad.net/bugs/837421
>
> As per Stratos Psomadakis the backport of the upstream commit below i=
s
> flawed and introduces crashes when using this ipv6 tunnel type:
>
>   commit a14a3f90745c4831a1437528706b38daa1db4885
>   Author: Alexey Dobriyan <adobriyan@gmail.com>
>   Date:   Tue Feb 16 09:05:04 2010 +0000
>
>     tunnels: fix netns vs proto registration ordering
>
> Signed-off-by: Andy Whitcroft <apw@canonical.com>
> Acked-by: Stefan Bader <stefan.bader@canonical.com>
> Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
> ---
>  net/ipv6/ip6_tunnel.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
> index 7fb3e02..53e0d51 100644
> --- a/net/ipv6/ip6_tunnel.c
> +++ b/net/ipv6/ip6_tunnel.c
> @@ -1466,7 +1466,7 @@ static int __init ip6_tunnel_init(void)
>  {
>  	int  err;
>
> -	err =3D register_pernet_device(&ip6_tnl_net_ops);
> +	err =3D register_pernet_gen_device(&ip6_tnl_net_id, &ip6_tnl_net_op=
s);
>  	if (err < 0)
>  		goto out_pernet;
>
> --
> 1.7.0.4




Yes, it does.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
