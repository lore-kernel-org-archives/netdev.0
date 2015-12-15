From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH v5 4/4] net: diag: Support destroying TCP socketsr
Date: Wed, 16 Dec 2015 02:17:44 +0900
Message-ID: <1450199868-93712-1-git-send-email-lorenzo@google.com>
References: <20151214.143739.879220917312503422.davem@davemloft.net>
Cc: davem@davemloft.net, hannes@stressinduktion.org,
	eric.dumazet@gmail.com, ek@google.com, tom@herbertland.com,
	zenczykowski@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34635 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965147AbbLORR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 12:17:59 -0500
Received: by mail-pf0-f170.google.com with SMTP id o64so7938822pfb.1
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 09:17:58 -0800 (PST)
In-Reply-To: <20151214.143739.879220917312503422.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the reviews. This version fixes a few issues and
addresses Tom's comments on v5. Specifically:

1. As requested by Tom, tcp_abort is no longer behind a config
   option, and now allows the caller to specify the error with
   which to interrupt blocking operations. (The SOCK_DIAG
   codepath to close TCP sockets from userspace always uses
   ECONNABORTED.)

2. Config symbols are checked with "ifdef" not "if".

3. The boolean Kconfig option no longer depends on
   INET_DIAG && (IPV6 || IPV6=n) but only on INET_DIAG

The name of the operation is still SOCK_DESTROY, and the
functions that implement it still have "destroy" in their
name. I'm leaning towards changing this to SOCK_ABORT instead,
both to reduce confusion with e.g., sock_diag_destroy_group,
and because it seems more correct in general, at least for
TCP. Thoughts on the name?
