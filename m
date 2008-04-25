From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit
 kernels.
Date: Fri, 25 Apr 2008 14:38:45 +0900 (JST)
Message-ID: <20080425.143845.24767700.yoshfuji@linux-ipv6.org>
References: <20080424.170257.87949659.yoshfuji@linux-ipv6.org>
	<OF3A37018B.9EFE360C-ON88257435.00614684-88257435.00622448@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33514 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243AbYDYFir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 01:38:47 -0400
In-Reply-To: <OF3A37018B.9EFE360C-ON88257435.00614684-88257435.00622448@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <OF3A37018B.9EFE360C-ON88257435.00614684-88257435.00622448@us.ibm.com> (at Thu, 24 Apr 2008 11:52:01 -0600), David Stevens <dlstevens@us.ibm.com> says:

>  #ifdef CONFIG_COMPAT
> +
> +struct compat_group_req {
> +       __u32                                   gr_interface;
> +       struct __kernel_sockaddr_storage        gr_group;
> +} __attribute__ ((packed));
> +
:

I prefer __compat_sockaddr_storage{} which has definition closer to
one on 32bit platform.  "packed" seems overkill to me.

>  int compat_ipv6_setsockopt(struct sock *sk, int level, int optname,
>                            char __user *optval, int optlen)
>  {
> @@ -769,6 +791,95 @@ int compat_ipv6_setsockopt(struct sock *
>         if (level != SOL_IPV6)
>                 return -ENOPROTOOPT;
>  
> +                   __put_user(interface, &kgr->gr_interface) ||
> +                   __copy_tofrom_user(&kgr->gr_group, &gr32->gr_group,
> +                               sizeof(kgr->gr_group)))
:

Unfortunately this cannot work.
__copy_tofrom_user is not available on x86_64 etc.

And this will increase copy operation, and I really dislike it, anyway.

--yoshfuji
