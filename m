From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: netlink - notify when the socket gets closed
Date: Fri, 5 Dec 2008 19:56:24 -0800
Message-ID: <20081205195624.95ea1866.akpm@linux-foundation.org>
References: <35476bd20812050017y70c3c729v450cdc3d0c1188de@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: "m m" <olsajiri@gmail.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <35476bd20812050017y70c3c729v450cdc3d0c1188de@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(cc netdev@vger.kernel.org)

On Fri, 5 Dec 2008 09:17:51 +0100 "m m" <olsajiri@gmail.com> wrote:

> Hi,
> 
> I'm using netlink in my module. Based on the communication,
> this module dynamically creates some internal structure, which
> needs to be destroyed when the user level socket is closed (or
> the application dies).
> 
> I found I could use the netlink_register_notifier function to register
> NETLINK_URELEASE callback during the netlink_release function.
> But since my module uses the multicast netlink socket communication,
> it wont be called:
> 
> static int netlink_release(struct socket *sock)
> {
>         ...
> 
>         if (nlk->pid && !nlk->subscriptions) {
>                 struct netlink_notify n = {
>                                                 .net = sock_net(sk),
>                                                 .protocol = sk->sk_protocol,
>                                                 .pid = nlk->pid,
>                                           };
>                 atomic_notifier_call_chain(&netlink_chain,
>                                 NETLINK_URELEASE, &n);
>         }
>         ...
> 
> Whats the reason this callback is not called for multicast sockets?
> 
> To workaround it I created simple misc device which the user application
> opens before creating the netlink socket. This way I get some callbacks
> inside the module when the application dies, at least.. pretty ugly :)
> 
> Is there a netlink mechanism to be notified when the netlink socket is
> closed on the user level side? (when using multicast communication)
> 
> Or is there any other design I could use, since I think I'm not alone in
> using internal module data which needs to be removed once the application dies.

