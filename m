From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] selinux: add a skb_owned_by() hook
Date: Tue, 09 Apr 2013 08:06:50 -0400
Message-ID: <1486478.7dQNuVSTsL@sifl>
References: <20130408154519.18177.57709.stgit@localhost> <6182509.cOVcY8B4g7@sifl> <1365479891.3887.99.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mvadkert@redhat.com, linux-security-module@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1365479891.3887.99.camel@edumazet-glaptop>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, April 08, 2013 08:58:11 PM Eric Dumazet wrote:
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
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: linux-security-module@vger.kernel.org
> ---
>  include/linux/security.h |    8 ++++++++
>  net/ipv4/tcp_output.c    |    1 +
>  security/capability.c    |    6 ++++++
>  security/security.c      |    5 +++++
>  security/selinux/hooks.c |    7 +++++++
>  5 files changed, 27 insertions(+)

I've already voiced my objections to this approach, but I've just tested it 
and it does resolve the regression in the network stack.

Tested-by: Paul Moore <pmoore@redhat.com>
Acked-by: Paul Moore <pmoore@redhat.com>

-- 
paul moore
security and virtualization @ redhat

