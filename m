From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] route: fix ICMP redirect validation
Date: Mon, 17 Oct 2011 19:43:44 -0400 (EDT)
Message-ID: <20111017.194344.510280595317217573.davem@davemloft.net>
References: <1317824404-9513-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54779 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473Ab1JQXnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 19:43:47 -0400
In-Reply-To: <1317824404-9513-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Wed,  5 Oct 2011 11:20:04 -0300

> The commit f39925dbde7788cfb96419c0f092b086aa325c0f
> (ipv4: Cache learned redirect information in inetpeer.)
> removed some ICMP packet validations which are required by
> RFC 1122, section 3.2.2.2:
> ...
>   A Redirect message SHOULD be silently discarded if the new
>   gateway address it specifies is not on the same connected
>   (sub-) net through which the Redirect arrived [INTRO:2,
>   Appendix A], or if the source of the Redirect is not the
>   current first-hop gateway for the specified destination (see
>   Section 3.3.1).
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>

The reason for putting this into the inetpeer cache was so that we
didn't need to consult the routing cache at all.  We're working to
remove it at some point, so every dependency matters.

Can you implement this such that only an inetpeer cache probe is
necessary?

Thanks.
