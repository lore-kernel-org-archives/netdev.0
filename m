From: Takashi Hibi <hibi665@oki.com>
Subject: Re: MLD problems (again) [PATCH]
Date: Mon, 12 Jan 2004 20:04:48 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040112200448.6e8f22f7%hibi665@oki.com>
References: <OF5F20AEAF.88A82C91-ON88256E19.001F1E69@us.ibm.com>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: (Your message of "Sun, 11 Jan 2004 22:49:08 -0700")
  <OF5F20AEAF.88A82C91-ON88256E19.001F1E69@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David,

Thank you for the patch.
But at least it doesn't solve the problem for 2.4 line kernel.
I will also test with 2.6.1 later.

Regards,
Takashi Hibi

> 
> 
> 
> 
> Takashi,
>       I believe the patch below will fix the problem you
> had with MCAST_JOIN_SOURCE_GROUP not sending a
> report. There was a typo in the source filter switching that did
> two deletes, rather than an delete and an add.
> 
> Dave,
>       Although IGMPv3 didn't have any problems, this patch
> also re-arranges the order of the filter changes. I think it's cleaner
> to add the new one first and then delete the old one, rather than
> having a small window with no filter set. So, this is a bug fix for MLD
> and a code clean-up for IGMPv3.
>       This bug and patch should also apply to the 2.4 line.
> 
>                         +-DLS
> 
> [included in-line for viewing and as an attachment for unmangled
>       whitespace]
> 
> --- linux-2.6.1/net/ipv6/mcast.c    2004-01-08 22:59:56.000000000 -0800
> +++ linux-2.6.1F1/net/ipv6/mcast.c  2004-01-11 21:06:05.000000000 -0800
> @@ -372,9 +372,9 @@
>                   goto done;
>       } else if (pmc->sfmode != omode) {
>             /* allow mode switches for empty-set filters */
> +           ip6_mc_add_src(idev, group, omode, 0, 0, 0);
>             ip6_mc_del_src(idev, group, pmc->sfmode, 0, 0, 0);
>             pmc->sfmode = omode;
> -           ip6_mc_del_src(idev, group, pmc->sfmode, 0, 0, 0);
>       }
> 
>       psl = pmc->sflist;
> --- linux-2.6.1/net/ipv4/igmp.c     2004-01-08 23:00:12.000000000 -0800
> +++ linux-2.6.1F1/net/ipv4/igmp.c   2004-01-11 21:27:41.000000000 -0800
> @@ -1749,11 +1749,10 @@
>                   goto done;
>       } else if (pmc->sfmode != omode) {
>             /* allow mode switches for empty-set filters */
> +           ip_mc_add_src(in_dev, &mreqs->imr_multiaddr, omode, 0, 0, 0);
>             ip_mc_del_src(in_dev, &mreqs->imr_multiaddr, pmc->sfmode, 0,
>                   0, 0);
>             pmc->sfmode = omode;
> -           ip_mc_add_src(in_dev, &mreqs->imr_multiaddr, pmc->sfmode, 0,
> -                 0, 0);
>       }
> 
>       psl = pmc->sflist;
> 
> (See attached file: 2.6.1MLD.patch)
