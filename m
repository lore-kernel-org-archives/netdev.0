From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Use NLMSG_DEFAULT_SIZE in combination with
 nlmsg_new()
Date: Thu, 28 Jun 2012 16:55:49 +0200
Message-ID: <1340895349.13187.105.camel@edumazet-glaptop>
References: <caecbaa2f181c17908fbd61264e1acb9c5cb1fe1.1340891841.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Sergey Lapin <slapin@ossfans.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:55448 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752950Ab2F1Ozy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 10:55:54 -0400
Received: by eaak11 with SMTP id k11so840917eaa.19
        for <netdev@vger.kernel.org>; Thu, 28 Jun 2012 07:55:53 -0700 (PDT)
In-Reply-To: <caecbaa2f181c17908fbd61264e1acb9c5cb1fe1.1340891841.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-28 at 15:57 +0200, Thomas Graf wrote:
> Using NLMSG_GOODSIZE results in multiple pages being used as
> nlmsg_new() will automatically add the size of the netlink
> header to the payload thus exceeding the page limit.

On the other hand, this limits to 3776 bytes for each recvmsg() call.

Maybe this can add a regression if one of the file needed to store more
than 3776 bytes in the answer ?

For GFP_KERNEL allocations, I am not sure we really need to limit to
order-0 pages...

Unless you can point a real bug, this patch is not for net tree, but
net-next.
