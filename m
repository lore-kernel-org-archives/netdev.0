From: David Miller <davem@davemloft.net>
Subject: Re: Netperf UDP issue with connected sockets
Date: Wed, 30 Nov 2016 13:11:03 -0500 (EST)
Message-ID: <20161130.131103.773051708416646032.davem@davemloft.net>
References: <20730b37-d218-a1bb-d0fb-0f838e2a77b5@hpe.com>
        <20161130114339.78c6d4fa@redhat.com>
        <086ec7ce-ea6a-55bd-cefe-095c2cad9f09@hpe.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: rick.jones2@hpe.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38124 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753106AbcK3SLF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 13:11:05 -0500
In-Reply-To: <086ec7ce-ea6a-55bd-cefe-095c2cad9f09@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hpe.com>
Date: Wed, 30 Nov 2016 09:42:40 -0800

> And indeed, based on a quick check, send() is what is being called,
> though it becomes it seems a sendto() system call - with the
> destination information NJULL:
> 
> write(1, "send\n", 5)                   = 5
> sendto(4, "netperf\0netperf\0netperf\0netperf\0"..., 1024, 0, NULL, 0)
> = 1024
> write(1, "send\n", 5)                   = 5
> sendto(4, "netperf\0netperf\0netperf\0netperf\0"..., 1024, 0, NULL, 0)
> = 1024
> 
> So I'm not sure what might be going-on there.

It's because of glibc's implementation of send() which is:

ssize_t
__libc_send (int sockfd, const void *buffer, size_t len, int flags)
{
  return SYSCALL_CANCEL (sendto, sockfd, buffer, len, flags, NULL, 0);
}
strong_alias (__libc_send, __send)
weak_alias (__libc_send, send)
