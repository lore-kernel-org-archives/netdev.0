From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: CPU: 0 PID: 0 at net/ipv4/af_inet.c:155
 inet_sock_destruct+0x1c4/0x1dc
Date: Tue, 12 Jul 2016 16:25:13 +0200
Message-ID: <1468333513.30694.74.camel@edumazet-glaptop3.roam.corp.google.com>
References: <577BB72E.3020904@free.fr> <577BC94A.4060204@free.fr>
	 <577BD201.2040202@gmail.com> <5784BE36.8060200@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Sebastian Frias <sf84@laposte.net>
To: Mason <slash.tmp@free.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5784BE36.8060200@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-07-12 at 11:53 +0200, Mason wrote:
> On 05/07/2016 17:28, Florian Fainelli wrote:
> 
> > Le 05/07/2016 07:50, Mason wrote:
> > 
> >> On 05/07/2016 15:33, Mason wrote:
> >> 
> >>> I was testing suspend/resume sequences where the suspend operation
> >>> fails and returns without having suspended the platform.
> 
> Please forget I ever mentioned suspend, that was a red herring.
> The warning is displayed even if I never suspend.
> (Dropping linux-pm from this discussion.)
> 
> >> I rebooted, tried the same operation, and hit the same warning
> >> still 310 seconds later:
> 
> However, the 310 seconds time span still seems to be relevant.
> 
> Steps to reproduce: I booted the system, logged in as root,
> mounted an NFS file system, then left the system idling at
> the prompt.
> 
> (I don't remember seeing this warning in v4.1 and v4.4)
> 
> What's going wrong here? Is it related to NFS?
> 
> Here is the defconfig I'm using
> http://pastebin.ubuntu.com/19160299/
> 
> Regards.
> 

Could you try this debug patch ?

diff --git a/net/core/sock.c b/net/core/sock.c
index b7f12639c26a..7fb1aeadbda7 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1465,6 +1465,7 @@ static void __sk_destruct(struct rcu_head *head)
 
 void sk_destruct(struct sock *sk)
 {
+	WARN_ON_ONCE(sk->sk_forward_alloc);
 	if (sock_flag(sk, SOCK_RCU_FREE))
 		call_rcu(&sk->sk_rcu, __sk_destruct);
 	else
