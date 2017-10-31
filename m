From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/1] Change ping_group_range default to what Android's init script sets.
Date: Tue, 31 Oct 2017 13:44:59 -0500
Message-ID: <8760avupg4.fsf@xmission.com>
References: <29f9ee1d-7ad4-b4df-7202-35c66893cc16@landley.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        davem@davemloft.net, kuznet@ms2.inr.ac.ru,
        xiyou.wangcong@gmail.com, yoshfuji@linux-ipv6.org,
        segoon@openwall.com, <netdev@vger.kernel.org>
To: Rob Landley <rob@landley.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <29f9ee1d-7ad4-b4df-7202-35c66893cc16@landley.net> (Rob Landley's
        message of "Mon, 30 Oct 2017 22:39:25 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rob Landley <rob@landley.net> writes:

> From: Rob Landley <rob@landley.net>
>
> See message from the Android "native tools and libraries team" lead
> (I.E. the maintainer of bionic, adb, toolbox, etc) at
> http://lists.landley.net/pipermail/toybox-landley.net/2017-July/009103.html

Sigh.  The list has no https access so it is unreachable here, and even
if it were I would not be able to verify that was not some spoofed
or someone was not hacking the contents of the list archive in flight.

As for the patch itself going from no group is allowed to reate ping sockets by
default to everyone may create ping sockets by default seems potentially
dangerous.

Why in the world would this be safe?
Why would this be wise?

Eric


> Signed-off-by: Rob Landley <rob@landley.net>
> ---
>
>  net/ipv4/af_inet.c |    8 ++------
>  1 file changed, 2 insertions(+), 6 deletions(-)
>
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index e31108e..5b39a96 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1712,12 +1712,8 @@ static __net_init int inet_init_net(struct net *net)
>  	net->ipv4.ip_local_ports.range[1] =  60999;
>  
>  	seqlock_init(&net->ipv4.ping_group_range.lock);
> -	/*
> -	 * Sane defaults - nobody may create ping sockets.
> -	 * Boot scripts should set this to distro-specific group.
> -	 */
> -	net->ipv4.ping_group_range.range[0] = make_kgid(&init_user_ns, 1);
> -	net->ipv4.ping_group_range.range[1] = make_kgid(&init_user_ns, 0);
> +	net->ipv4.ping_group_range.range[0] = make_kgid(&init_user_ns, 0);
> +	net->ipv4.ping_group_range.range[1] = make_kgid(&init_user_ns, 2147483647);
>  
>  	/* Default values for sysctl-controlled parameters.
>  	 * We set them here, in case sysctl is not compiled.
