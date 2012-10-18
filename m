From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sock_getsockopt() not exported
Date: Thu, 18 Oct 2012 11:30:12 +0200
Message-ID: <1350552612.26103.1281.camel@edumazet-glaptop>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B7052@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:37806 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753415Ab2JRJaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 05:30:15 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so4021597bkc.19
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2012 02:30:14 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7052@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-18 at 10:11 +0100, David Laight wrote:
> I've noticed that net/core/sock.c contains an
>     EXPORT_SYMBOL(sock_setsockopt)
> but is missing the corresponding
>     EXPORT_SYMBOL(sock_getsockopt)
> 
> In-kernel users of sockets probably manage without
> needing to read SOL_SOCKET options.
> (They do need to set SO_REUSADDR and SO_KEEPALIVE.)


sock_setsockopt() is exported because sunrpc needs it, and sunrpc can be
a module

sock_getsockopt() is not exported because no module needs it yet.

The day one user needs it, we'll add the EXPORT_SYMBOL()
