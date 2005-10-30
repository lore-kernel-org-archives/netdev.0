From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH][MCAST]IPv6: doubt about ipv6_sk_mc_lock usage.
Date: Sun, 30 Oct 2005 09:32:14 -0800
Message-ID: <OFE9824801.1D574FF8-ON882570AA.005FC39C-882570AA.006050CD@us.ibm.com>
References: <4364EA58.7040707@21cn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751095AbVJ3RcI@vger.kernel.org>
In-Reply-To: <4364EA58.7040707@21cn.com>
To: Yan Zheng <yanzheng@21cn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No, ipv6_sk_mc_lock is required for join and leave to protect 
inet6_mc_check()
calls, and modifications to the filter list only happen via ioctls that 
are protected
by the socket lock.

I don't think any of these changes are correct.

                                                +-DLS


netdev-owner@vger.kernel.org wrote on 10/30/2005 07:44:24 AM:

> Hello.
> 
> I think ipv6_sk_mc_lock should protest both ipv6_mc_list and it's 
sflist. 
> because they can are used by 
> inet6_mc_check(...) in softirq and be modified by ip6_mc_source(...) or 
> ip6_mc_msfilter(...) simultaneity.
> I also remove read_lock when traverse ipv6_mc_list, because it's 
protected by 
> lock_sock(sk).
> 
