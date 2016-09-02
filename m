From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [Patch net-next 2/2] netns: avoid disabling irq for netns id
Date: Fri, 2 Sep 2016 10:12:21 +0200
Message-ID: <7de98923-0cfb-5937-d32b-bdaee7ec10dc@6wind.com>
References: <1472792025-14702-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472792025-14702-3-git-send-email-xiyou.wangcong@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:35066 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750873AbcIBIMZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 04:12:25 -0400
Received: by mail-wm0-f45.google.com with SMTP id w2so17547267wmd.0
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 01:12:24 -0700 (PDT)
In-Reply-To: <1472792025-14702-3-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/09/2016 à 06:53, Cong Wang a écrit :
> We never read or change netns id in hardirq context,
> the only place we read netns id in softirq context
> is in vxlan_xmit(). So, it should be enough to just
> disable BH.

Are you sure? Did you audit all part of the code?
peernet2id() is called from netlink core system (do_one_broadcast()). Are you
sure that no driver call this function from an hard irq context?

I think that NETLINK_LISTEN_ALL_NSID is largely untested, so it will be hard to
detect a bug introduced in this feature.
