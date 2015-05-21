From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH net-next 2/2] tcp: improve REUSEADDR/NOREUSEADDR
 cohabitation
Date: Thu, 21 May 2015 17:37:36 -0300
Message-ID: <20150521203736.GI2379@x240.home>
References: <1432144742-17786-1-git-send-email-edumazet@google.com>
 <1432144742-17786-3-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38133 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755429AbbEUUhl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 16:37:41 -0400
Content-Disposition: inline
In-Reply-To: <1432144742-17786-3-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 20, 2015 at 10:59:02AM -0700, Eric Dumazet wrote:
> inet_csk_get_port() randomization effort tends to spread
> sockets on all the available range (ip_local_port_range)
> 
> This is unfortunate because SO_REUSEADDR sockets have
> less requirements than non SO_REUSEADDR ones.
> 
> If an application uses SO_REUSEADDR hint, it is to try to
> allow source ports being shared.
> 
> So instead of picking a random port number in ip_local_port_range,
> lets try first in first half of the range.
> 
> This gives more chances to use upper half of the range for the
> sockets with strong requirements (not using SO_REUSEADDR)
> 
> Note this patch does not add a new sysctl, and only changes
> the way we try to pick port number.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>
> Cc: Flavio Leitner <fbl@redhat.com>
> ---

The only downside I can see is that after the patch the applications
using the SO_REUSEADDR will reuse ports more often and that could
potentially trigger some bug.

Looks like a good change to me.

Acked-by: Flavio Leitner <fbl@redhat.com>
