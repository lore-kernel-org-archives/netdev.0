From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 0/4] inet: add second hash table
Date: Wed, 30 May 2012 09:57:20 +0200
Message-ID: <1338364640.2760.96.camel@edumazet-glaptop>
References: <1338363410-6562-1-git-send-email-alex.mihai.c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, gerrit@erg.abdn.ac.uk, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, Daniel Baluta <dbaluta@ixiacom.com>,
	Lucian Grijincu <lucian.grijincu@gmail.com>
To: Alexandru Copot <alex.mihai.c@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:43724 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334Ab2E3H50 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 03:57:26 -0400
Received: by bkcji2 with SMTP id ji2so3828299bkc.19
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 00:57:24 -0700 (PDT)
In-Reply-To: <1338363410-6562-1-git-send-email-alex.mihai.c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-30 at 10:36 +0300, Alexandru Copot wrote:
> This patchset implements all the operations needed to use a second
> (port,address) bind hash table for inet. It uses a similar approach
> as the UDP implementation.
> 
> The performance improvements for port allocation are very good and
> detailed in the last message.
> 
> This is based on a series of patches written by Lucian Grijincu at Ixia.
> 
> Signed-off-by: Alexandru Copot <alex.mihai.c@gmail.com>
> Cc: Daniel Baluta <dbaluta@ixiacom.com>
> Cc: Lucian Grijincu <lucian.grijincu@gmail.com>
> ---
> Alexandru Copot (4):
>       inet: add counter to inet_bind_hashbucket
>       inet: add a second bind hash
>       inet: add/remove inet buckets in the second bind hash
>       inet: use second hash in inet_csk_get_port
> 
>  include/net/inet_hashtables.h    |  140 +++++++++++++++++++++++++++++++--
>  include/net/inet_timewait_sock.h |    5 +-
>  net/dccp/proto.c                 |   37 ++++++++-
>  net/ipv4/inet_connection_sock.c  |   66 ++++++++--------
>  net/ipv4/inet_hashtables.c       |  158 ++++++++++++++++++++++++++++++++++++--
>  net/ipv4/inet_timewait_sock.c    |   16 ++--
>  net/ipv4/tcp.c                   |   17 ++++
>  net/ipv6/inet6_hashtables.c      |   95 +++++++++++++++++++++++
>  8 files changed, 477 insertions(+), 57 deletions(-)


Its a huge change (with many details to look at), for a yet to be
understood need.

What sensible workload needs this at all ?
