From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 5/9] net: network drivers no longer need to
 implement ndo_busy_poll()
Date: Tue, 17 Nov 2015 07:33:41 -0800
Message-ID: <1447774421.22599.109.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447768624-14962-1-git-send-email-edumazet@google.com>
	 <1447768624-14962-6-git-send-email-edumazet@google.com>
	 <564B4443.90108@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Eli Cohen <eli@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>,
	Rida Assaf <rida@google.com>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:33002 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753818AbbKQPdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 10:33:46 -0500
Received: by padfb7 with SMTP id fb7so1776350pad.0
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 07:33:45 -0800 (PST)
In-Reply-To: <564B4443.90108@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-17 at 17:14 +0200, Eliezer Tamir wrote:
> On 17/11/2015 15:57, Eric Dumazet wrote:
> > Instead of having to implement complex ndo_busy_poll() method,
> > drivers can simply rely on NAPI poll logic.
> 
> I really like where you are going with this series.
> 
> ...
> 
> > We could go one step further, and make busy polling
> > available for all NAPI drivers, but this would require
> > that all netif_napi_del() calls are done in process context
> > so that we can call synchronize_rcu().
> > Full audit would be required.
> > 
> > Before this is done, a driver still needs to call :
> > 
> > - skb_mark_napi_id() for each skb provided to the stack, although we can
> >   easily do this directly in core networking stack in a future patch.
> > 
> > - napi_hash_add() and napi_hash_del() to allocate/free a napi_id per napi.
> > 
> > - Make sure RCU grace period is respected after napi_hash_del() before
> >   memory containing napi structure is freed.
> 
> Can we move all of these into the NAPI infrastructure?
> Maybe hash add/del can be inside netif_napi_add/del.
> Some way to force the right RCU behavior, and busy polling is
> completely driver-agnostic, which IMHO outweighs the small gains
> you can have by micro-optimizing ndo_busy_poll.

This is exactly what I suggested in the changelog ;)
