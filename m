From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp_metrics: fix wrong lockdep annotations
Date: Mon, 16 Mar 2015 07:10:54 -0700
Message-ID: <1426515054.11398.206.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150316113542.GA27127@paralelels.com>
	 <1426514329.11398.204.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
To: Andrew Vagin <avagin@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:35028 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754948AbbCPOK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 10:10:56 -0400
Received: by ieclw3 with SMTP id lw3so171815831iec.2
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 07:10:55 -0700 (PDT)
In-Reply-To: <1426514329.11398.204.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-16 at 06:58 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Changes in tcp_metric hash table are protected by tcp_metrics_lock
> only, not by genl_mutex
> 
> Reported-by: Andrew Vagin <avagin@parallels.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 098a697b497e ("tcp_metrics: Use a single hash table for all network namespaces.")
> ---
>  net/ipv4/tcp_metrics.c |   12 ++++--------
>  1 file changed, 4 insertions(+), 8 deletions(-)

I'll send a v2 : We also can use deref_locked() in tcp_new() to avoid
unnecessary barrier (as they are implied in rcu_dereference())
 
