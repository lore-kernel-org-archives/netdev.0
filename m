From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ethtool: do not vzalloc(0) on registers dump
Date: Fri, 03 Feb 2017 11:11:52 -0500 (EST)
Message-ID: <20170203.111152.2232032272459625954.davem@davemloft.net>
References: <1486038730-9469-1-git-send-email-sgruszka@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@decadent.org.uk
To: sgruszka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38232 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750851AbdBCQLy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 11:11:54 -0500
In-Reply-To: <1486038730-9469-1-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stanislaw Gruszka <sgruszka@redhat.com>
Date: Thu,  2 Feb 2017 13:32:10 +0100

> If ->get_regs_len() callback return 0, we allocate 0 bytes of memory,
> what print ugly warning in dmesg, which can be found further below.
> 
> This happen on mac80211 devices where ieee80211_get_regs_len() just
> return 0 and driver only fills ethtool_regs structure and actually
> do not provide any dump. However I assume this can happen on other
> drivers i.e. when for some devices driver provide regs dump and for
> others do not. Hence preventing to to print warning in ethtool code
> seems to be reasonable.
 ...
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> ---
> v1 -> v2: nullify regbuf to avoid using uninitialized variable in line:
>           if (regbuf && copy_to_user(useraddr, regbuf, regs.len))

Applied, thanks.
