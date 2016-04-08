From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mpls: find_outdev: check for err ptr in addition
 to NULL check
Date: Fri, 08 Apr 2016 12:43:53 -0400 (EDT)
Message-ID: <20160408.124353.1354015446819079138.davem@davemloft.net>
References: <1460089718-25788-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34855 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754126AbcDHQnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 12:43:55 -0400
In-Reply-To: <1460089718-25788-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Thu,  7 Apr 2016 21:28:38 -0700

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> find_outdev calls inet{,6}_fib_lookup_dev() or dev_get_by_index() to
> find the output device. In case of an error, inet{,6}_fib_lookup_dev()
> returns error pointer and dev_get_by_index() returns NULL. But the function
> only checks for NULL and thus can end up calling dev_put on an ERR_PTR.
> This patch adds an additional check for err ptr after the NULL check.
> 
> Before: Trying to add an mpls route with no oif from user, no available
> path to 10.1.1.8 and no default route:
> $ip -f mpls route add 100 as 200 via inet 10.1.1.8
> [  822.337195] BUG: unable to handle kernel NULL pointer dereference at
> 00000000000003a3
 ...
> After patch:
> $ip -f mpls route add 100 as 200 via inet 10.1.1.8
> RTNETLINK answers: Network is unreachable
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Reported-by: David Miller <davem@davemloft.net>

Applied, thanks.
