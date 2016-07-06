From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2] netfilter: nf_log: fix error on write NONE to logger
 choice sysctl
Date: Wed, 6 Jul 2016 11:22:10 +0200
Message-ID: <20160706092156.GA950@salvia>
References: <1467378972-16770-1-git-send-email-ptikhomirov@virtuozzo.com>
 <1467381234-20364-1-git-send-email-ptikhomirov@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Leblond <eric@inl.fr>, Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Konstantin Khorenko <khorenko@virtuozzo.com>, devel@openvz.org
To: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37080 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750990AbcGFJWT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jul 2016 05:22:19 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id CF7231B694D
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 11:22:16 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id BE5429EBBA
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 11:22:16 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 55E0B6446A
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 11:22:12 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1467381234-20364-1-git-send-email-ptikhomirov@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 01, 2016 at 04:53:54PM +0300, Pavel Tikhomirov wrote:
> It is hard to unbind nf-logger:
> 
>   echo NONE > /proc/sys/net/netfilter/nf_log/0
>   bash: echo: write error: No such file or directory
> 
>   sysctl -w net.netfilter.nf_log.0=NONE
>   sysctl: setting key "net.netfilter.nf_log.0": No such file or directory
>   net.netfilter.nf_log.0 = NONE
> 
> You need explicitly send '\0', for instance like:
> 
>   echo -e "NONE\0" > /proc/sys/net/netfilter/nf_log/0
> 
> That seem to be strange, so fix it using proc_dostring.
> 
> Now it works fine:
>    modprobe nfnetlink_log
>    echo nfnetlink_log > /proc/sys/net/netfilter/nf_log/0
>    cat /proc/sys/net/netfilter/nf_log/0
>    nfnetlink_log
>    echo NONE > /proc/sys/net/netfilter/nf_log/0
>    cat /proc/sys/net/netfilter/nf_log/0
>    NONE

Applied, thanks.
