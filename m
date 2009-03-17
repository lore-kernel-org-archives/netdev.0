From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: socket api problem: can't bind an ipv6 socket to ::ffff:0.0.0.0
Date: Mon, 16 Mar 2009 17:00:40 -0700
Message-ID: <20090316170040.4fa6cff7@nehalam>
References: <20090316233934.GD32111@codeblau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Felix von Leitner <felix-kernel@fefe.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34894 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752669AbZCQAAu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Mar 2009 20:00:50 -0400
In-Reply-To: <20090316233934.GD32111@codeblau.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Mar 2009 00:48:10 +0100
Felix von Leitner <felix-kernel@fefe.de> wrote:

> Here's an strace:
> 
> socket(PF_INET6, SOCK_STREAM, IPPROTO_IP) = 3
> fcntl(3, F_GETFL)                       = 0x2 (flags O_RDWR)
> fcntl(3, F_SETFL, O_RDWR|O_NONBLOCK)    = 0
> setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
> bind(3, {sa_family=AF_INET6, sin6_port=htons(6969), inet_pton(AF_INET6, "::ffff:0.0.0.0", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = -1 EADDRNOTAVAIL (Cannot assign requested address)
> 
> This is supposed to work, and it works on other operating systems, even
> on Mac OS X.
> 
> I think it used to work on Linux, too.
> 
> I'm using 2.6.29-rc7 right now, but others have reported this not
> working on distro kernels, too.
> 
> Felix
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Most likely you already have same port open on IPV4 and unless
you set IPV6 only, the bind bind will fail. The standard way
of doing servers is to bind only for IPV6 and handle IPV4
clients via the 6-4 address mapping.
