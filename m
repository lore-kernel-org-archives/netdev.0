From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: ethernet QoS support?
Date: Mon, 12 Jul 2004 21:07:24 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407122107.29389.vkondra@mail.ru>
References: <1C440F3C-D110-11D8-8B61-000393DBC2E8@freescale.com> <200407092126.43021.vkondra@mail.ru> <1089634701.1055.260.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Kumar Gala <kumar.gala@freescale.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, hadi@cyberus.ca
In-Reply-To: <1089634701.1055.260.camel@jzny.localdomain>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Monday 12 July 2004 15:18, jamal wrote:
> On Fri, 2004-07-09 at 14:26, Vladimir Kondratiev wrote:
> > > Who marks the skb->priority? Is that the default mark as per TOS?
> > > I think the VLAN code marks it as well.
> >
> > I don't care. It should not be driver's business. Actually, it is TOS.
> > AFAIK, application supposed to do setsockoption(SO_PRIORITY) on its
> > socket so set priority.
>
> That or if routed from another host, then TOS does get extracted and set
> to skb->priority
this is not very important. From one side, it seems like bug in routing code. 
- From another side, 802.11 was supposed for link ends only. It is not supposed 
to appear in the middle of routers chain.
>
> > Agree about intelligence. Driver should serve link and MAC layer. But
> > exactly because link layer have different priorities, driver need several
> > Tx queues. It is stack's business to route packet to the proper queue.
> > Driver should deliver it using appropriate MAC layer priority.
>
> So far you have said there are two schedulers h/ware understands: strict
> priority(3 band strict priority is the deafult in Linux) and WRR.
> The qdisc level is already taken care of today.
>
> > Waiting. If no support will exist, it simply means we will be unable to
> > use QoS provided by modern 802.11.
>
> I think someone with motivation and hardware (such as you
> Vladimir ;->)should take the lead. I have offered to consult and review
> code.
You know: schedule, plan, other job to do, limited time... And, I don't feel 
myself enough educated in network stack internals. Now I think I can speak 
for the driver. This is what I am trying to do. But I started looking for 
qdiscs and other stuff, so may be eventually I will get there.
>
> > Depending on market development, impact may
> > range from being slightly slower relating to Windows clients, to being
> > almost completely unable to communicate for traffic like VOIP. Later will
> > be the case if most access points will implement QoS as in TGE.
> >
> > I can now deliver packets accordingly to skb->priority, but if stack have
> > different idea for what is proper proportion between different sorts of
> > traffic, driver's Tx path will be flooded with low priority frames.
>
> I dont think so - as long as you map to a specific qdisc things should
> work fine. i.e the scheduling semantics will be taken good care of by
> the qdisc level.
> So lets separate the two levels, driver and qdisc level.
> I dont think they should be synchronized. In my opinion, the
> synchronization point is the configurator/operator/management s/ware of
> the box.
QoS policies are dictated by access point, they are coming to the driver from 
the link side. And I see no way to let upper layers to know these policies.
>
> > Situation is much worser for streams with admission control. I have no
> > mechanism to communicate with stack for such traffic establishment and
> > tear down.
>
> Let me make an interim suggestion:
> To illustrate i will assume 3 priorities with priority 1 higher than
> priority 3. Substitute with whatever driver does. Assuming the
> priorities will be reflected in the skb->priority.
>
> - Shut down device only when highest(1) priority ring is full.
> - if packets received for priority 2 and 3 and their respective rings
> are full, drop the packet in the driver and return a 0 i.e dont shut
> device.
Real situation:
- - highest priority is VOIP (200 bytes each 20ms). With decent link, it will 
always pass.
- - low priority is ftp bulk transfer. stack pushes more then driver can tx. I 
will silently drop 9 out of 10 packets. Not a good behavior.
>
> You can also do the following in the case of strict priority(caveat is
> reordering may happen):
> for each prio X try to stash on DMA ring of prio X. If full, try X+1, if
> full try X+2 etc.
forbidden by spec. I will be disconnected immediately.
>
> Thoughts?
>
> cheers,
> jamal
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD4DBQFA8tNhqxdj7mhC6o0RAsKoAJdfe1cMHghBSDI8Jel9zYsdmP6kAJ0fshJw
M3b1lsvT4zq3oRR5fveylg==
=6FLN
-----END PGP SIGNATURE-----
