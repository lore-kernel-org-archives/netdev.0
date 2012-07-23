From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rds: set correct msg_namelen
Date: Mon, 23 Jul 2012 01:02:09 -0700 (PDT)
Message-ID: <20120723.010209.288436778718842333.davem@davemloft.net>
References: <5181687def9991f9878460d932bd31c64f9ad0cb.1343010976.git.wpan@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: wpan@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5181687def9991f9878460d932bd31c64f9ad0cb.1343010976.git.wpan@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Weiping Pan <wpan@redhat.com>
Date: Mon, 23 Jul 2012 10:37:48 +0800

> Jay Fenlason (fenlason@redhat.com) found a bug,
> that recvfrom() on an RDS socket can return the contents of random kernel
> memory to userspace if it was called with a address length larger than
> sizeof(struct sockaddr_in).
> rds_recvmsg() also fails to set the addr_len paramater properly before
> returning, but that's just a bug.
> There are also a number of cases wher recvfrom() can return an entirely bogus
> address. Anything in rds_recvmsg() that returns a non-negative value but does
> not go through the "sin = (struct sockaddr_in *)msg->msg_name;" code path
> at the end of the while(1) loop will return up to 128 bytes of kernel memory
> to userspace.
> 
> And I write two test programs to reproduce this bug, you will see that in
> rds_server, fromAddr will be overwritten and the following sock_fd will be
> destroyed.
> Yes, it is the programmer's fault to set msg_namelen incorrectly, but it is
> better to make the kernel copy the real length of address to user space in
> such case.
> 
> How to run the test programs ?
> I test them on 32bit x86 system, 3.5.0-rc7.
 ...
> Signed-off-by: Weiping Pan <wpan@redhat.com>

Applied, thanks.
