From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH net] ipv6: no need to return rt->dst.error if it is not
 null entry.
Date: Mon, 24 Jul 2017 10:28:27 +0800
Message-ID: <20170724022827.GB2938@leo.usersys.redhat.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
 <CAJieiUiZRkd81BVAkDdENu9T0uBZ31OQDUAFZ+jzNnBJaHx-+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        WANG Cong <xiyou.wangcong@gmail.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36876 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752452AbdGXC2j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Jul 2017 22:28:39 -0400
Received: by mail-pg0-f66.google.com with SMTP id g14so5735520pgu.4
        for <netdev@vger.kernel.org>; Sun, 23 Jul 2017 19:28:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJieiUiZRkd81BVAkDdENu9T0uBZ31OQDUAFZ+jzNnBJaHx-+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Roopa,
On Sat, Jul 22, 2017 at 09:55:51PM -0700, Roopa Prabhu wrote:
> On Thu, Jul 20, 2017 at 7:51 AM, Hangbin Liu <liuhangbin@gmail.com> wrote:
> > After commit 18c3a61c4264 ("net: ipv6: RTM_GETROUTE: return matched fib
> > result when requested"). When we get a prohibit ertry, we will return
> > -EACCES directly.
> >
> > Before:
> > + ip netns exec client ip -6 route get 2003::1
> > prohibit 2003::1 dev lo table unspec proto kernel src 2001::1 metric
> > 4294967295 error -13
> >
> > After:
> > + ip netns exec server ip -6 route get 2002::1
> > RTNETLINK answers: Network is unreachable

Sorry, I have a copy/paste error here, the return error should be

+ ip netns exec server ip -6 route get 2002::1
RTNETLINK answers: Permission denied

I fixed it in v2 patch, but forgot to add
#ifdef CONFIG_IPV6_MULTIPLE_TABLES before net->ipv6.ip6_prohibit_entry.

Since you acked this patch. I will post a v3 patch with fixed comment.

> >
> > Since we will check the ip6_null_entry later. There is not sense
> > to check the dst.error after get rt.
> >
> > Fixes: 18c3a61c4264 ("net: ipv6: RTM_GETROUTE: return matched fib...")
> > Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> > ---
> 
> Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Thanks
Hangbin
