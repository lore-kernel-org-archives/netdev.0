From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [Patch net v3] ipv6: check for ip6_null_entry in
 __ip6_del_rt_siblings()
Date: Wed, 1 Mar 2017 16:42:15 -0800
Message-ID: <20170302004215.3ohf6smlrxodd3mn@kafai-mba.local>
References: <1488240463-12000-1-git-send-email-xiyou.wangcong@gmail.com>
 <6d332a15-d86c-0b02-61e5-38d208f2caf7@cumulusnetworks.com>
 <20170301231648.2bpr7doxcipj5gi4@android-1601923ecb7aeff9.dhcp.thefacebook.com>
 <5ab5897d-bafe-d297-91da-07bc32ce6d6e@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Cong Wang <xiyou.wangcong@gmail.com>, <netdev@vger.kernel.org>,
        <andreyknvl@google.com>, Eric Dumazet <eric.dumazet@gmail.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:37918 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753424AbdCBDJB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 22:09:01 -0500
Content-Disposition: inline
In-Reply-To: <5ab5897d-bafe-d297-91da-07bc32ce6d6e@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 01, 2017 at 04:07:38PM -0800, David Ahern wrote:
> On 3/1/17 3:16 PM, Martin KaFai Lau wrote:
> > [ An unrelated topic.  I wonder ip -6 r del xyz::/0 would delete
> >   the gateway route...]
>
> a very related question ...
>
> ip -6 r del x::/0 comes down to the kernel as delete '::/0' (plen is 0,
> so cfg->fc_dst is 0). It ends up on the null_entry from fib6_locate b/c
> of the 0 prefix length, so it is another variant of 'ip -6 ro del ::/0'
Agree on the plen == 0 part.

I actually meant if 'ip -6 r del xyz::/0' would delete any _default_
_gateway_ also.  By looking at ip6_route_del() alone, it seems it only
checks ipv6_addr_equal(&cfg->fc_gateway, &rt->rt6i_gateway) if
(cfg->fc_flags & RTF_GATEWAY) is true.  Your test case makes
me think about this possibility but it is not related
to what this patch is trying to fix.  I should have started
another thread for this :p
