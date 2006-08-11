From: David Miller <davem@davemloft.net>
Subject: Re: the mystery that is sock_fasync
Date: Fri, 11 Aug 2006 04:35:39 -0700 (PDT)
Message-ID: <20060811.043539.50338105.davem@davemloft.net>
References: <20060811.031516.38316536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:47536
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932149AbWHKLf3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 07:35:29 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 88EFCAE43C3
	for <netdev@vger.kernel.org>; Fri, 11 Aug 2006 04:35:39 -0700 (PDT)
To: netdev@vger.kernel.org
In-Reply-To: <20060811.031516.38316536.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Fri, 11 Aug 2006 03:15:16 -0700 (PDT)

> If my analysis is correct we can incredibly simplify sock_fasync().

I've also found more bugs in sock_fasync(), it's a real can of worms
:-)

It deviates from the return value policies used by othe
file_ops->fasync() implementations.  For example, if we look at
fasync_helper() it clearly shows that we should return 1 if a list
manipulation (insert of delete) happened else it should return 0.

Also, my theory about struct file<-->struct socket being a one-to-one
mapping is fully supported by the fact that struct socket has a "file"
member that can only take on one value.
