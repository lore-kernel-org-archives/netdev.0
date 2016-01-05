From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] udp_diag: fix udp_dump_one() vs SO_REUSEPORT
Date: Tue, 05 Jan 2016 14:22:14 -0800
Message-ID: <1452032534.8255.137.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1452024487-2909-1-git-send-email-kraigatgoog@gmail.com>
	 <1452031738.8255.127.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36497 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815AbcAEWWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 17:22:16 -0500
Received: by mail-pa0-f52.google.com with SMTP id yy13so129273941pab.3
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 14:22:15 -0800 (PST)
In-Reply-To: <1452031738.8255.127.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-01-05 at 14:08 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> udp_dump_one() uses __udp4_lib_lookup() & __udp6_lib_lookup()
> which cannot properly handle the provided cookie when SO_REUSEPORT
> is used, as many sockets share the same 4-tuple
> 
> Instead, let's use the provided 64bit cookie to uniquely identify
> the socket.
> 
> This will allow us to remove a check against skb being NULL in
> reuseport_select_sock(), as we no longer share __udp4_lib_lookup() &
> __udp6_lib_lookup() with packet processing path.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---

I'll send a v2, removing the EXPORT_SYMBOL(__udp4_lib_lookup) and add a
static qualifier. (Same for v6)

Also, INET_UDP_DIAG can depends on INET_DIAG instead of "depends on
INET_DIAG && (IPV6 || IPV6=n)"
