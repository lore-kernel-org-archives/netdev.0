From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: ethernet QoS support?
Date: Fri, 9 Jul 2004 21:26:37 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407092126.43021.vkondra@mail.ru>
References: <1C440F3C-D110-11D8-8B61-000393DBC2E8@freescale.com> <200407091641.35651.vkondra@mail.ru> <1089383622.1030.21.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Kumar Gala <kumar.gala@freescale.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, hadi@cyberus.ca
In-Reply-To: <1089383622.1030.21.camel@jzny.localdomain>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Friday 09 July 2004 17:33, jamal wrote:
> On Fri, 2004-07-09 at 09:41, Vladimir Kondratiev wrote:
> > So far, I have hardware related parts working. I rely on skb->priority to
> > determine traffic class and select proper queue.
>
> Who marks the skb->priority? Is that the default mark as per TOS?
> I think the VLAN code marks it as well.
I don't care. It should not be driver's business. Actually, it is TOS. AFAIK, 
application supposed to do setsockoption(SO_PRIORITY) on its socket so set 
priority.
>
> > All this worth nothing if one can't do separate queues. qdisc assignment
> > for driver is not in driver's hands, so it can't do any assumptions.
> > Generic
> > in-kernel support needed here. Stack should allow driver to request
> > additional Tx queues, providing some classifiers for each one. I tried to
> > imagine how to work it around, but there is no good solution without
> > those several queues.
>
> I dont think we should put intelligence at the driver level.
> We can have drivers configured via parameter to look at the priority
> field. Only then do they look at it; else use only single ring.
> When multi-ring is on, you intepret the priority.
> priority field is set above driver based on which priority queue the
> packet was grabbed from (before sending to driver).
Agree about intelligence. Driver should serve link and MAC layer. But exactly 
because link layer have different priorities, driver need several Tx queues. 
It is stack's business to route packet to the proper queue. Driver should 
deliver it using appropriate MAC layer priority.
>
> > This mean, I will be able to deliver QoS support when network stack will
> > make it possible.
>
> So what do you do now?
Waiting. If no support will exist, it simply means we will be unable to use 
QoS provided by modern 802.11. Depending on market development, impact may 
range from being slightly slower relating to Windows clients, to being almost 
completely unable to communicate for traffic like VOIP. Later will be the 
case if most access points will implement QoS as in TGE.

I can now deliver packets accordingly to skb->priority, but if stack have 
different idea for what is proper proportion between different sorts of 
traffic, driver's Tx path will be flooded with low priority frames.

Situation is much worser for streams with admission control. I have no 
mechanism to communicate with stack for such traffic establishment and tear 
down.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFA7uNiqxdj7mhC6o0RAoDyAJ9dx9ibVRee1tV5RRZXyK5X+4QjswCeJ5Vj
4nZ3BKNlzLPnoga6oblpGNw=
=n/gU
-----END PGP SIGNATURE-----
