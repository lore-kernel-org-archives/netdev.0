From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] net: core: decouple ifalias get/set from
 rtnl lock
Date: Mon, 02 Oct 2017 08:19:03 -0700
Message-ID: <1506957543.8061.14.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171002102745.3047-1-fw@strlen.de>
         <1506956029.8061.8.camel@edumazet-glaptop3.roam.corp.google.com>
         <20171002150936.GB30423@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35609 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751199AbdJBPTF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 11:19:05 -0400
Received: by mail-pg0-f68.google.com with SMTP id p5so4078215pgn.2
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 08:19:05 -0700 (PDT)
In-Reply-To: <20171002150936.GB30423@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-10-02 at 17:09 +0200, Florian Westphal wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Just use RCU : A writer is supposed to work on a private copy, and
> > _then_ publish the new pointer, so that a reader can not see mangled
> > string.
> > 
> > We either copy the 'old' name or the 'new' one.
> > 
> > A seqcount is not needed, and wont prevent you from reading the value
> > right before a change anyway.
> 
> Would you rather use kfree_rcu or unconditional synchronize_net()
> before releasing old memory?

kfree_rcu() please ;)

Adding 16 bytes for the rcu_head is acceptable I think.
