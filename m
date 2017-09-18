From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip6_gre: skb_push ipv6hdr before packing the
 header in ip6gre_header
Date: Mon, 18 Sep 2017 14:52:04 -0700 (PDT)
Message-ID: <20170918.145204.2146093595696060495.davem@davemloft.net>
References: <4337e23831098961437503efa2c9d7adfce96b81.1505448007.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xeb@mail.ru
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55462 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750998AbdIRVwF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 17:52:05 -0400
In-Reply-To: <4337e23831098961437503efa2c9d7adfce96b81.1505448007.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Fri, 15 Sep 2017 12:00:07 +0800

> Now in ip6gre_header before packing the ipv6 header, it skb_push t->hlen
> which only includes encap_hlen + tun_hlen. It means greh and inner header
> would be over written by ipv6 stuff and ipv6h might have no chance to set
> up.
> 
> Jianlin found this issue when using remote any on ip6_gre, the packets he
> captured on gre dev are truncated:
> 
> 22:50:26.210866 Out ethertype IPv6 (0x86dd), length 120: truncated-ip6 -\
> 8128 bytes missing!(flowlabel 0x92f40, hlim 0, next-header Options (0)  \
> payload length: 8192) ::1:2000:0 > ::1:0:86dd: HBH [trunc] ip-proto-128 \
> 8184
> 
> It should also skb_push ipv6hdr so that ipv6h points to the right position
> to set ipv6 stuff up.
> 
> This patch is to skb_push hlen + sizeof(*ipv6h) and also fix some indents
> in ip6gre_header.
> 
> Fixes: c12b395a4664 ("gre: Support GRE over IPv6")
> Reported-by: Jianlin Shi <jishi@redhat.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Yes, this is consistent with how t->hlen is used in the rest of this
tunnel driver.

Applied and queued up for -stable, thanks!
