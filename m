From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC net] neigh: do not modify unlinked entries
Date: Thu, 18 Jun 2015 23:40:10 -0700
Message-ID: <1434696010.31511.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1434484599-5875-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ying Xue <ying.xue@windriver.com>,
	alexei@purestorage.com, joern@purestorage.com
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:36709 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021AbbFSGkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 02:40:15 -0400
Received: by wicnd19 with SMTP id nd19so9380785wic.1
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2015 23:40:13 -0700 (PDT)
In-Reply-To: <1434484599-5875-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-06-16 at 22:56 +0300, Julian Anastasov wrote:
> The lockless lookups can return entry that is unlinked.
> Sometimes they get reference before last neigh_cleanup_and_release,
> sometimes they do not need reference. Later, any
> modification attempts may result in the following problems:
> 
> 1. entry is not destroyed immediately because neigh_update
> can start the timer for dead entry, eg. on change to NUD_REACHABLE
> state. As result, entry lives for some time but is invisible
> and out of control.
> 
> 2. __neigh_event_send can run in parallel with neigh_destroy
> while refcnt=0 but if timer is started and expired refcnt can
> reach 0 for second time leading to second neigh_destroy and
> possible crash.
> 
> Thanks to Eric Dumazet and Ying Xue for their work and analyze
> on the __neigh_event_send change.
> 
> Fixes: 767e97e1e0db ("neigh: RCU conversion of struct neighbour")
> Fixes: a263b3093641 ("ipv4: Make neigh lookups directly in output packet path.")
> Fixes: 6fd6ce2056de ("ipv6: Do not depend on rt->n in ip6_finish_output2().")
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---

Seems good to me Julian !

Acked-by: Eric Dumazet <edumazet@google.com>
