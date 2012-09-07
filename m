From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] scm: Don't use struct ucred in NETLINK_CB and
 struct scm_cookie.
Date: Fri, 07 Sep 2012 14:42:50 -0400 (EDT)
Message-ID: <20120907.144250.592587303760599718.davem@davemloft.net>
References: <87haralb0u.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, serge@hallyn.com, eric.dumazet@gmail.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40230 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753540Ab2IGSmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 14:42:52 -0400
In-Reply-To: <87haralb0u.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 06 Sep 2012 21:20:01 -0700

> 
> Passing uids and gids on NETLINK_CB from a process in one user
> namespace to a process in another user namespace can result in the
> wrong uid or gid being presented to userspace.  Avoid that problem by
> passing kuids and kgids instead.
> 
> - define struct scm_creds for use in scm_cookie and netlink_skb_parms
>   that holds uid and gid information in kuid_t and kgid_t.
> 
> - Modify scm_set_cred to fill out scm_creds by heand instead of using
>   cred_to_ucred to fill out struct ucred.  This conversion ensures
>   userspace does not get incorrect uid or gid values to look at.
> 
> - Modify scm_recv to convert from struct scm_creds to struct ucred
>   before copying credential values to userspace.
> 
> - Modify __scm_send to populate struct scm_creds on in the scm_cookie,
>   instead of just copying struct ucred from userspace.
> 
> - Modify netlink_sendmsg to copy scm_creds instead of struct ucred
>   into the NETLINK_CB.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied, thanks Eric.
