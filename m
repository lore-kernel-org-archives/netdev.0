From: Masashi Honma <masashi.honma@gmail.com>
Subject: Re: [RFC 5/7] net: Add allocation flag to rtnl_unicast()
Date: Fri, 8 Jul 2016 12:15:35 +0900
Message-ID: <577F1AD7.8040800@gmail.com>
References: <1467764916-4983-1-git-send-email-masashi.honma@gmail.com>
 <1467764916-4983-6-git-send-email-masashi.honma@gmail.com>
 <1467946591.1273.45.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-audit@redhat.com, cluster-devel@redhat.com,
	davem@davemloft.net, johannes@sipsolutions.net,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, paul@paul-moore.com, eparis@redhat.com,
	zbr@ioremap.net, pshelar@nicira.com, ccaulfie@redhat.com,
	teigland@redhat.com, bsingharora@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35069 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932077AbcGHDPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 23:15:42 -0400
In-Reply-To: <1467946591.1273.45.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016=E5=B9=B407=E6=9C=8808=E6=97=A5 11:56, Eric Dumazet wrote:
>
> Managing to mix GFP_ATOMIC and GFP_KERNEL almost randomly as you did =
in
> this patch is definitely not good.
>
> Further more, RTNL is a mutex, held in control path, designed to allo=
w
> schedules and waiting for memory under pressure.
>
> We do not want to encourage GFP_ATOMIC usage in control path.
>
> Your patch series gives the wrong signal to developers.
>
>
>

Thanks for comment.

I have selected GFP flags based on existing code.

I have selected GFP_ATOMIC in inet6_netconf_get_devconf() because
skb was allocated with GFP_ATOMIC.

I have used GFP_KERNEL in inet6_rtm_getaddr() by same reason.

 > I will send a patch against net/ipv4/devinet.c so that we remove
 > GFP_ATOMIC usage there.

Thanks. I will modify my patch based on your new code.
