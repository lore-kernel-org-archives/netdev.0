From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] igmp: Fix regression caused by igmp sysctl namespace
 code.
Date: Wed, 09 Aug 2017 22:47:52 -0700 (PDT)
Message-ID: <20170809.224752.1096296661923743221.davem@davemloft.net>
References: <1502262369.4936.1.camel@edumazet-glaptop3.roam.corp.google.com>
        <1502278684-11151-1-git-send-email-nborisov@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, eric.dumazet@gmail.com,
        stable@vger.kernel.org
To: nborisov@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51980 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751373AbdHJFrx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 01:47:53 -0400
In-Reply-To: <1502278684-11151-1-git-send-email-nborisov@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Borisov <nborisov@suse.com>
Date: Wed,  9 Aug 2017 14:38:04 +0300

> Commit dcd87999d415 ("igmp: net: Move igmp namespace init to correct file")
> moved the igmp sysctls initialization from tcp_sk_init to igmp_net_init. This
> function is only called as part of per-namespace initialization, only if
> CONFIG_IP_MULTICAST is defined, otherwise igmp_mc_init() call in ip_init is
> compiled out, casuing the igmp pernet ops to not be registerd and those sysctl
> being left initialized with 0. However, there are certain functions, such as
> ip_mc_join_group which are always compiled and make use of some of those
> sysctls. Let's do a partial revert of the aforementioned commit and move the
> sysctl initialization into inet_init_net, that way they will always have
> sane values.
> 
> Fixes: dcd87999d415 ("igmp: net: Move igmp namespace init to correct file")
> Link: https://bugzilla.kernel.org/show_bug.cgi?id=196595
> Reported-by: Gerardo Exequiel Pozzi <vmlinuz386@gmail.com>
> Cc: <stable@vger.kernel.org> # 4.6
> Signed-off-by: Nikolay Borisov <nborisov@suse.com>

Please do not use "CC: stable.." for networking patches, I take care of
-stable submissions by hand for those.

Applied and queued up for -stable, thanks.
