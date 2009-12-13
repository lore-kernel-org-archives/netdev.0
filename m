From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] net: restore ip source validation WAS(Re: [tproxy,regression]
 tproxy broken in 2.6.32
Date: Sun, 13 Dec 2009 20:12:39 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0912132009410.12698@u.domain.uli>
References: <1259585129.3992.13.camel@nienna.balabit>  <1259589577.873.30.camel@bigi>
 <1259674488.3168.45.camel@bigi>  <20091202.223117.228943068.davem@davemloft.net>
  <1259848398.3766.43.camel@bigi>  <4B17C346.3000906@trash.net>
 <1259849264.13245.3.camel@nienna.balabit>  <1259850594.3766.46.camel@bigi>
 <1260723147.6167.20.camel@bigi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	KOVACS Krisztian <hidden@balabit.hu>,
	Patrick McHardy <kaber@trash.net>, hidden@sch.bme.hu,
	aschultz@warp10.net, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org, Rick Jones <rick.jones2@hp.com>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:53350 "HELO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751180AbZLMSUc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2009 13:20:32 -0500
In-Reply-To: <1260723147.6167.20.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sun, 13 Dec 2009, jamal wrote:

> Ok, I am gonna pull a Rick-Jones;-> and ASS-U-ME the attached patch is
> fine.
> 
> cheers,
> jamal

> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -252,6 +252,8 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
>                 no_addr = in_dev->ifa_list == NULL;
>                 rpf = IN_DEV_RPFILTER(in_dev);
>                 accept_local = IN_DEV_ACCEPT_LOCAL(in_dev);
> +               if (mark && !IN_DEV_SRC_VMARK(in_dev))

	May be "fl.mark = 0;" ?:

> +                       mark = 0;
>         }
>         rcu_read_unlock();

Regards

--
Julian Anastasov <ja@ssi.bg>
