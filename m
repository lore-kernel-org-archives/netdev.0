From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] net: socket: Fix the wrong returns for recvmsg
 and sendmsg
Date: Mon, 01 Jun 2015 16:54:07 -0700 (PDT)
Message-ID: <20150601.165407.734100251470140931.davem@davemloft.net>
References: <1433150880-9976-1-git-send-email-zhengjunling@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, lizefan@huawei.com,
	viro@zeniv.linux.org.uk, xuhanbing@huawei.com,
	stable@vger.kernel.org, netdev@vger.kernel.org
To: zhengjunling@huawei.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1433150880-9976-1-git-send-email-zhengjunling@huawei.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Junling Zheng <zhengjunling@huawei.com>
Date: Mon, 1 Jun 2015 09:28:00 +0000

> We found that after v3.10.73, recvmsg might return -EFAULT while -EINVAL
> was expected.
> 
> We tested it through the recvmsg01 testcase come from LTP testsuit. It set
> msg->msg_namelen to -1 and the recvmsg syscall returned errno 14, which is
> unexpected (errno 22 is expected):
> 
> recvmsg01    4  TFAIL  :  invalid socket length ; returned -1 (expected -1),
> errno 14 (expected 22)
> 
> Linux mainline has no this bug for commit 08adb7dab fixes it accidentally.
> However, it is too large and complex to be backported to LTS 3.10.
> 
> So, I made the following patch to fix the above problem for LTS 3.10.

Upstream the code doesn't look anything like this, so it's probably
just a missing bug fix for -stable.
