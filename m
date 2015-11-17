From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH net-next 5/9] net: network drivers no longer need to
 implement ndo_busy_poll()
Date: Tue, 17 Nov 2015 17:14:11 +0200
Message-ID: <564B4443.90108@linux.intel.com>
References: <1447768624-14962-1-git-send-email-edumazet@google.com>
 <1447768624-14962-6-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Eli Cohen <eli@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>,
	Rida Assaf <rida@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:14150 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750867AbbKQPOR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2015 10:14:17 -0500
In-Reply-To: <1447768624-14962-6-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/11/2015 15:57, Eric Dumazet wrote:
> Instead of having to implement complex ndo_busy_poll() method,
> drivers can simply rely on NAPI poll logic.

I really like where you are going with this series.

...

> We could go one step further, and make busy polling
> available for all NAPI drivers, but this would require
> that all netif_napi_del() calls are done in process context
> so that we can call synchronize_rcu().
> Full audit would be required.
> 
> Before this is done, a driver still needs to call :
> 
> - skb_mark_napi_id() for each skb provided to the stack, although we can
>   easily do this directly in core networking stack in a future patch.
> 
> - napi_hash_add() and napi_hash_del() to allocate/free a napi_id per napi.
> 
> - Make sure RCU grace period is respected after napi_hash_del() before
>   memory containing napi structure is freed.

Can we move all of these into the NAPI infrastructure?
Maybe hash add/del can be inside netif_napi_add/del.
Some way to force the right RCU behavior, and busy polling is
completely driver-agnostic, which IMHO outweighs the small gains
you can have by micro-optimizing ndo_busy_poll.

On another note, any thoughts about unifying poll_controller with
regular poll?

cheers,
Eliezer
