From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sctp: rfc4443: do not report ICMP redirects
 to user space
Date: Mon, 16 Sep 2013 21:40:54 -0400 (EDT)
Message-ID: <20130916.214054.1994711412361848197.davem@davemloft.net>
References: <1379327762-4638-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	hannes@stressinduktion.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43851 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437Ab3IQBk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 21:40:56 -0400
In-Reply-To: <1379327762-4638-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 16 Sep 2013 12:36:02 +0200

> Adapt the same behaviour for SCTP as present in TCP for ICMP redirect
> messages. For IPv6, RFC4443, section 2.4. says:
> 
>   ...
>   (e) An ICMPv6 error message MUST NOT be originated as a result of
>       receiving the following:
>   ...
>        (e.2) An ICMPv6 redirect message [IPv6-DISC].
>   ...
> 
> Therefore, do not report an error to user space, just invoke dst's redirect
> callback and leave, same for IPv4 as done in TCP as well. The implication
> w/o having this patch could be that the reception of such packets would
> generate a poll notification and in worst case it could even tear down the
> whole connection. Therefore, stop updating sk_err on redirects.
> 
> Reported-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Suggested-by: Vlad Yasevich <vyasevich@gmail.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied and queued up for -stable, thanks Daniel.
