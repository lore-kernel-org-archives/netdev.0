From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: Use correct sideffect command in duplicate
 cookie handling
Date: Wed, 13 Mar 2013 10:04:31 -0400 (EDT)
Message-ID: <20130313.100431.523451251434580538.davem@davemloft.net>
References: <1363139603-14042-1-git-send-email-vyasevich@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	nhorman@tuxdriver.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43757 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932339Ab3CMOEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 10:04:22 -0400
In-Reply-To: <1363139603-14042-1-git-send-email-vyasevich@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Tue, 12 Mar 2013 21:53:23 -0400

> When SCTP is done processing a duplicate cookie chunk, it tries
> to delete a newly created association.  For that, it has to set
> the right association for the side-effect processing to work.
> However, when it uses the SCTP_CMD_NEW_ASOC command, that performs
> more work then really needed (like hashing the associationa and
> assigning it an id) and there is no point to do that only to
> delete the association as a next step.  In fact, it also creates
> an impossible condition where an association may be found by
> the getsockopt() call, and that association is empty.  This
> causes a crash in some sctp getsockopts.
> 
> The solution is rather simple.  We simply use SCTP_CMD_SET_ASOC
> command that doesn't have all the overhead and does exactly
> what we need.
> 
> Reported-by: Karl Heiss <kheiss@gmail.com>
> Tested-by: Karl Heiss <kheiss@gmail.com>
> CC: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>

Applied.
