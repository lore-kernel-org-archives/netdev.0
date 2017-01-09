From: Florian Westphal <fw@strlen.de>
Subject: [PATCH ipsec-next 0/6] xfrm: remove xfrm_state_get_afinfo conditional rcu locking
Date: Mon,  9 Jan 2017 14:20:44 +0100
Message-ID: <1483968050-788-1-git-send-email-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:48762 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1760625AbdAINUc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 08:20:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xfrm_state_get_afinfo still uses a conditional locking scheme
dating back to when this still used an rwlock:

If return value is NULL, no lock (rcu readlock) was taken,
otherwise, rcu_read_unlock has to be called.

This series moves rcu read lock/unlock responsibility to the callers.

xfrm_state_put_afinfo is removed (it is equivalent
to rcu_read_unlock so thats what will be used instead).

xfrm_state_get_afinfo is renamed to xfrm_state_afinfo_get_rcu()
and is only a rcu dereference wrapper.

In one case, rcu read/unlock can be avoided as we're always
called with rcu read lock held.
