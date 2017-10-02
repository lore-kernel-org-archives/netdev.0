From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next v2] net: core: decouple ifalias get/set from
 rtnl lock
Date: Mon, 2 Oct 2017 17:09:36 +0200
Message-ID: <20171002150936.GB30423@breakpoint.cc>
References: <20171002102745.3047-1-fw@strlen.de>
 <1506956029.8061.8.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:54904 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751969AbdJBPNO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 11:13:14 -0400
Content-Disposition: inline
In-Reply-To: <1506956029.8061.8.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Just use RCU : A writer is supposed to work on a private copy, and
> _then_ publish the new pointer, so that a reader can not see mangled
> string.
> 
> We either copy the 'old' name or the 'new' one.
> 
> A seqcount is not needed, and wont prevent you from reading the value
> right before a change anyway.

Would you rather use kfree_rcu or unconditional synchronize_net()
before releasing old memory?
