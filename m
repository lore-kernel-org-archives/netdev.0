From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip6tnl: fix use after free of fb_tnl_dev
Date: Thu, 14 Nov 2013 17:05:29 -0500 (EST)
Message-ID: <20131114.170529.1627250972818871118.davem@davemloft.net>
References: <20131113211430.1ad3bb7d@gandalf.local.home>
	<1384440423-4275-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org, gregkh@linuxfoundation.org,
	williams@redhat.com, linux-rt-users@vger.kernel.org,
	lclaudio@uudg.org, netdev@vger.kernel.org, willemb@google.com
To: nicolas.dichtel@6wind.com
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <1384440423-4275-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 14 Nov 2013 15:47:03 +0100

> Bug has been introduced by commit bb8140947a24 ("ip6tnl: allow to use rtnl ops
> on fb tunnel").
> 
> When ip6_tunnel.ko is unloaded, FB device is delete by rtnl_link_unregister()
> and then we try to use the pointer in ip6_tnl_destroy_tunnels().
> 
> Let's add an handler for dellink, which will never remove the FB tunnel. With
> this patch it will no more be possible to remove it via 'ip link del ip6tnl0',
> but it's safer.
> 
> The same fix was already proposed by Willem de Bruijn <willemb@google.com> for
> sit interfaces.
> 
> CC: Willem de Bruijn <willemb@google.com>
> Reported-by: Steven Rostedt <rostedt@goodmis.org>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied and queued up for -stable, thanks for being so proactive about this
Nicolas.
