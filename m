From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] selinux: add a skb_owned_by() hook
Date: Tue, 09 Apr 2013 13:23:50 -0400 (EDT)
Message-ID: <20130409.132350.1681660673457923647.davem@davemloft.net>
References: <1365454501.3887.45.camel@edumazet-glaptop>
	<6182509.cOVcY8B4g7@sifl>
	<1365479891.3887.99.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pmoore@redhat.com, netdev@vger.kernel.org, mvadkert@redhat.com,
	linux-security-module@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1365479891.3887.99.camel@edumazet-glaptop>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 08 Apr 2013 20:58:11 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit 90ba9b1986b5ac (tcp: tcp_make_synack() can use alloc_skb())
> broke certain SELinux/NetLabel configurations by no longer correctly
> assigning the sock to the outgoing SYNACK packet.
> 
> Cost of atomic operations on the LISTEN socket is quite big,
> and we would like it to happen only if really needed.
> 
> This patch introduces a new security_ops->skb_owned_by() method,
> that is a void operation unless selinux is active.
> 
> Reported-by: Miroslav Vadkerti <mvadkert@redhat.com>
> Diagnosed-by: Paul Moore <pmoore@redhat.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Since this fixes a regression that got added by the networking
tree, I'll push this to Linus, applied, thanks.
