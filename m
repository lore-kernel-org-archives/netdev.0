From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] scm: fix possible control message header alignment
 issue
Date: Fri, 30 Dec 2016 15:20:57 -0500 (EST)
Message-ID: <20161230.152057.1192922867281184266.davem@davemloft.net>
References: <1483015172-5017-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linyu.Yuan@alcatel-sbell.com.cn
To: cugyly@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45908 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753755AbcL3UVB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2016 15:21:01 -0500
In-Reply-To: <1483015172-5017-1-git-send-email-cugyly@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <cugyly@163.com>
Date: Thu, 29 Dec 2016 20:39:32 +0800

> From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> 
> 1. put_cmsg{_compat}() may copy data to user when buffer free space less than
>    control message header alignment size.
> 2. scm_detach_fds{_compat}() may calc wrong fdmax if control message header
>    have greater alignment size.
> 
> Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

But can this actually happen, in practice?

Take, for example, COMPAT_CMSG_DATA().

It aligns "struct compat_cmsghdr" to a multiple of a u32.

I cannot think of any possibly way that, on any architecture
whatsoever:

	CMSG_COMPAT_ALIGN(sizeof(struct compat_cmsghdr))

evaludates to any value other than, exactly:

	sizeof(struct compat_cmsghdr)

If you can come up with a case where this does happen in
practice, I will continue to consider this patch.

Otherwise, we should make the assumptions that exist explicit
and get rid of all of the code that does that funny alignment
upon the cmsghdr structure.

Thanks.
