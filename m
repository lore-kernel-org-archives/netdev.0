From: jamal <hadi@cyberus.ca>
Subject: Re: in-driver QoS
Date: 09 Jun 2004 21:59:01 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1086832740.1205.65.camel@jzny.localdomain>
References: <20040608184831.GA18462@bougret.hpl.hp.com>
	 <200406090851.40691.vkondra@mail.ru>
	 <1086780010.1051.106.camel@jzny.localdomain>
	 <200406092127.28477.vkondra@mail.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jt@hpl.hp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200406092127.28477.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-06-09 at 14:27, Vladimir Kondratiev wrote:

> Sure. I know when each DMA queue have space to accept new packets. w.r.t Tx 
> discipline, it is really like 4 (taking into account TSPEC, see my mail about 
> TGe, minimum 5 for STA and 6 (i did not said about power save buffering) for 
> AP) independent devices.

Vladimir - do you have one of these cards? Jean is putting some my
doubts in my mind about their designs. Do they have seperate DMA rings?

> I see you got the idea. Question is, how to implement it.

As suggested earlier:
- introduce id and id_state per ring.
- use a skb tag to select id
- if ring is full, use same id to requeue to qdisc.
- qdiscs above must have semantics that map to the strict priority
scheme (eg you could use CBQ which does both priorities and bandwith
allocation or use simple prio or strict prio qdiscs).
- netif stopping and starting is done per id/ring. 

Did i miss something?

Do you wanna try this? I could give you a hand but dont have much time
to code at the moment. I could point you to the different pieces of code
that need mods and suggest the changes.

cheers,
jamal
