From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: ethernet QoS support?
Date: Sat, 10 Jul 2004 11:58:41 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407101158.58089.vkondra@mail.ru>
References: <1C440F3C-D110-11D8-8B61-000393DBC2E8@freescale.com> <200407092126.43021.vkondra@mail.ru> <200407091534.53166.sam@errno.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Sam Leffler <sam@errno.com>, hadi@cyberus.ca,
        Jeff Garzik <jgarzik@pobox.com>, Kumar Gala <kumar.gala@freescale.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <200407091534.53166.sam@errno.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Saturday 10 July 2004 01:34, Sam Leffler wrote:
> On Friday 09 July 2004 11:26 am, Vladimir Kondratiev wrote:
> > > So what do you do now?
> >
> > Waiting. If no support will exist, it simply means we will be unable to
> > use QoS provided by modern 802.11. Depending on market development,
> > impact may range from being slightly slower relating to Windows clients,
> > to being almost completely unable to communicate for traffic like VOIP.
> > Later will be the case if most access points will implement QoS as in
> > TGE.
> >
> > I can now deliver packets accordingly to skb->priority, but if stack have
> > different idea for what is proper proportion between different sorts of
> > traffic, driver's Tx path will be flooded with low priority frames.
> >
> > Situation is much worser for streams with admission control. I have no
> > mechanism to communicate with stack for such traffic establishment and
> > tear down.
>
> FWIW the madwifi net80211 layer parses TOS to calculate priority and sticks
> it in the skb.  It also calculates the WME AC to form the QoS frame matter.
Sam,
I think, to use skb->priority is more proper then parse TOS. Several points 
for this:
1. by default, IP code do it for you - it sets skb->priority equal to TOS;
2. stack may have better idea of what priority should be assigned. For this, 
it have all queuing/classifiers stuff with qdiscs.
3. it is layer violation to use information above MAC. It may be non-IP stack 
above you.
> This is then handed to drivers below.  The Atheros driver supports multiple
> tx queues in h/w with appropriate scheduling (for 5212 MACs); it uses the
> AC to set packets on the appropriate queue.
>
> Clearly it'd be better if upper layers did the TOS stuff.  Whatever is done
> however should consider the case where the driver (nee h/w) has it's own
> queueing/scheduling facilities.
>
I also do something similar. But, to be honest, this is not working. If stack 
feeds you with different mixture of high and low priority streams, you can do 
nothing. All you can do by doing additional in-driver queuing is to smooth 
short spikes.

What will you do for TGE? HCCA TSPECS and EDCA categories with admission 
control?

I continue to insist that for true MAC layer QoS, we need several Tx queues.

Anyway, I see we are on the same page with you, as we are facing same 
problems.

Vladimir
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFA76/Rqxdj7mhC6o0RAvyMAJ0UafCsb2P94oo5FVbNoIZ3+qVXEACfTI3D
l9a0YAXR9xPvlpz0wZMlWdQ=
=BrFw
-----END PGP SIGNATURE-----
