From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: fix -ENOMEM result with invalid user space
 pointer in sendto() syscall
Date: Wed, 28 Nov 2012 11:12:14 -0500 (EST)
Message-ID: <20121128.111214.940932171814395302.davem@davemloft.net>
References: <1353590596-12216-1-git-send-email-tt.rantala@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	nhorman@tuxdriver.com, vyasevich@gmail.com, sri@us.ibm.com,
	davej@redhat.com
To: tt.rantala@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49948 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553Ab2K1QMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 11:12:19 -0500
In-Reply-To: <1353590596-12216-1-git-send-email-tt.rantala@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tommi Rantala <tt.rantala@gmail.com>
Date: Thu, 22 Nov 2012 15:23:16 +0200

> Consider the following program, that sets the second argument to the
> sendto() syscall incorrectly:
 ...
> We get -ENOMEM:
> 
>  $ strace -e sendto ./demo
>  sendto(3, NULL, 1, 0, {sa_family=AF_INET, sin_port=htons(11111), sin_addr=inet_addr("127.0.0.1")}, 16) = -1 ENOMEM (Cannot allocate memory)
> 
> Propagate the error code from sctp_user_addto_chunk(), so that we will
> tell user space what actually went wrong:
> 
>  $ strace -e sendto ./demo
>  sendto(3, NULL, 1, 0, {sa_family=AF_INET, sin_port=htons(11111), sin_addr=inet_addr("127.0.0.1")}, 16) = -1 EFAULT (Bad address)
> 
> Noticed while running Trinity (the syscall fuzzer).
> 
> Signed-off-by: Tommi Rantala <tt.rantala@gmail.com>

Applied.
