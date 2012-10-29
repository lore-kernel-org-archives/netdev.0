From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next] ipv6: fix a potential NULL deref
Date: Mon, 29 Oct 2012 09:25:13 +0100
Message-ID: <1351499113.7394.171.camel@edumazet-glaptop>
References: <1351482620-11008-1-git-send-email-amwang@redhat.com>
	 <1351491005.7394.7.camel@edumazet-glaptop>  <1351493366.8221.2.camel@cr0>
	 <1351494334.7394.64.camel@edumazet-glaptop>  <1351495523.8221.8.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:37971 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756401Ab2J2IZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 04:25:27 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so1588803eaa.19
        for <netdev@vger.kernel.org>; Mon, 29 Oct 2012 01:25:26 -0700 (PDT)
In-Reply-To: <1351495523.8221.8.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-29 at 15:25 +0800, Cong Wang wrote:

> Oh, yeah, gcc should be smart enough to do calculation without deref it
> given it has the offset and the address. And dst happens to be first
> field of rt, so offset is 0, &rt->dst should be NULL too if rt is NULL.
> 

There is no dereference, even if gcc was dumb, since dst is an embedded
struct, not a pointer to a struct.

This wont change in a near future.

> But this will be a problem if someone moved dst inside rt, as there is
> no comment saying dst has to be the first one?

I dont think this placement will change in a near future, it would break
lot of things.

I guess we can use a BUILD_BUG_ON() instead of a comment that
could be ignored.

Note we could move dst in rtable, if we change the NULL test in
dst_release with some if ((unsigned long)dst < 4000) condition

I'll send a patch against ip_rt_put()
