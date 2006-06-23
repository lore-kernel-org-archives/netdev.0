From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [1/1] Kevent subsystem.
Date: Fri, 23 Jun 2006 15:12:44 +0900 (JST)
Message-ID: <20060623.151244.02594148.yoshfuji@linux-ipv6.org>
References: <20060622171436.GA26161@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:35080 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S932828AbWFWGLx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 02:11:53 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060622171436.GA26161@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20060622171436.GA26161@2ka.mipt.ru> (at Thu, 22 Jun 2006 21:14:37 +0400), Evgeniy Polyakov <johnpol@2ka.mipt.ru> says:

> Patch against linux-2.6.17-git tree attached (gzipped).
> I would like to hear some comments about the overall design,
> implementation and plans about it's usefullness for generic kernel.
> 
> Design notes, patches, userspace application and perfomance tests can be
> found at project's homepages.

| diff --git a/arch/i386/kernel/syscall_table.S b/arch/i386/kernel/syscall_table.S
| index af56987..93e23ff 100644
| --- a/arch/i386/kernel/syscall_table.S
| +++ b/arch/i386/kernel/syscall_table.S
| @@ -316,3 +316,7 @@ ENTRY(sys_call_table)
|  	.long sys_sync_file_range
|  	.long sys_tee			/* 315 */
|  	.long sys_vmsplice
| +	.long sys_aio_recv
| +	.long sys_aio_send
| +	.long sys_aio_sendfile
| +	.long sys_kevent_ctl
:

We do not waste syscall entries; we can probably use socketcall
for sys_aio_recv, sys_aio_send (and maybe, sys_aio_sendfile).


| diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
| index 25ecc6e..05d7086 100644
| --- a/net/ipv4/tcp_ipv4.c
| +++ b/net/ipv4/tcp_ipv4.c
:

Please do for tcp_ipv6.c as well.  Thank you.

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
