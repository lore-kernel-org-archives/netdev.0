From: Jisheng Zhang <jszhang@marvell.com>
Subject: Re: [RFC] net: mvneta: 64bit platform support
Date: Wed, 30 Mar 2016 21:45:35 +0800
Message-ID: <20160330214535.4139ebe5@xhacker>
References: <20160330213700.41876e09@xhacker>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
To: <thomas.petazzoni@free-electrons.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<gregory.clement@free-electrons.com>, <mw@semihalf.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016f401.pphosted.com ([67.231.148.174]:52015 "EHLO
	mx0a-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753729AbcC3Ntp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 09:49:45 -0400
In-Reply-To: <20160330213700.41876e09@xhacker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Mar 2016 21:37:00 +0800 Jisheng Zhang wrote:

> Hi all,
> 
> Obviously, current mvneta driver can't work on 64bit platforms. For one thing
> the BM feature should be explicitly disabled, I just sent out one patch for
> this purpose. 
> 
> What's more, the buf_cookie in mvneta_rx_desc need to be carefully considered.
> The driver use the buf_cookie(u32 type) to store the buffer virtual address,
> obviously it can't store the virtual address on 64bit platforms. I have two
> solutions:
> 
> solution A: let one reserved type in current mvneta_rx_desc, e.g reserved5
> to store the high 32bit virt address, and hack code as the following:
> #ifdef CONFIG_64BIT
> rx_desc->reserved5 = high32(data);
> #endif

oh, missing some code:
#ifdef CONFIG_64BIT
data = ((u64)rx_desc->reserved5 << 32) | rx_desc->buf_cookie;
#else
data = (void*)rx_desc->buf_cookie;
#endif

> 
> solution B: add one member void **buf_virt_ptrs in mvneta_rx_queue, and point
> all buf_cookie usage to the according buf_virt_ptrs[i]
> 
> 
> Is there any elegant solutions?
> 
> Thanks,
> Jisheng
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
