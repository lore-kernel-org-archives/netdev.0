From: Yan Zheng <yanzheng@21cn.com>
Subject: Re: [PATCH][MCAST]IPv6: doubt about ipv6_sk_mc_lock usage.
Date: Mon, 31 Oct 2005 09:46:03 +0800
Message-ID: <4365775B.9080209@21cn.com>
References: <OFE9824801.1D574FF8-ON882570AA.005FC39C-882570AA.006050CD@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751274AbVJaBoa@vger.kernel.org>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OFE9824801.1D574FF8-ON882570AA.005FC39C-882570AA.006050CD@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Stevens wrote:
> No, ipv6_sk_mc_lock is required for join and leave to protect 
> inet6_mc_check()
> calls, and modifications to the filter list only happen via ioctls that 
> are protected
> by the socket lock.
> 
> I don't think any of these changes are correct.
> 
>                                                 +-DLS

Thanks.

I have one more question. 
Why ip6_mc_source() uses read_lock_bh(&ipv6_sk_mc_lock) and ip6_mc_msfilter() doesn't use ipv6_sk_mc_lock at all. 
when ipv6_mc_list's sflist are accessed by inet6_mc_check(), Can it be modified by ip6_mc_source() or ip6_mc_msfilter() ?
(For example ipv6_mc_list's sflist is freed up by sock_kfree_s(), when inet6_mc_check() uses it)


                                                                   Regards
