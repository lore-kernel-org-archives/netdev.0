From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] net: ipmr, ip6mr: fix vif/tunnel failure race condition
Date: Tue, 24 Nov 2015 10:56:46 -0800
Message-ID: <CAHA+R7N2mWAQhQwb+y8NEDaHW8wHB7D+w883y0zO3YBOeOVegA@mail.gmail.com>
References: <1448381370-32173-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f173.google.com ([209.85.160.173]:33699 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754275AbbKXS4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 13:56:48 -0500
Received: by ykdv3 with SMTP id v3so29857833ykd.0
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 10:56:46 -0800 (PST)
In-Reply-To: <1448381370-32173-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 24, 2015 at 8:09 AM, Nikolay Aleksandrov
<razor@blackwall.org> wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>
> Since (at least) commit b17a7c179dd3 ("[NET]: Do sysfs registration as
> part of register_netdevice."), netdev_run_todo() deals only with
> unregistration, so we don't need to do the rtnl_unlock/lock cycle to
> finish registration when failing pimreg or dvmrp device creation. In
> fact that opens a race condition where someone can delete the device
> while rtnl is unlocked because it's fully registered. The problem gets
> worse when netlink support is introduced as there are more points of entry
> that can cause it and it also makes reusing that code correctly impossible.
>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Makes sense for me, we do have some other cases (e.g. macvlan) where
we call unregister_netdevice() in error path without re-taking RTNL lock.

So,

Reviewed-by: Cong Wang <cwang@twopensource.com>

Thanks.
