From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: ethernet QoS support?
Date: Mon, 12 Jul 2004 21:17:38 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407122117.44069.vkondra@mail.ru>
References: <1C440F3C-D110-11D8-8B61-000393DBC2E8@freescale.com> <1089621532.3063.8.camel@andromache> <1089635216.1054.271.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Glen Turner <glen.turner@aarnet.edu.au>, Sam Leffler <sam@errno.com>,
        Jeff Garzik <jgarzik@pobox.com>, Kumar Gala <kumar.gala@freescale.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, hadi@cyberus.ca
In-Reply-To: <1089635216.1054.271.camel@jzny.localdomain>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Monday 12 July 2004 15:26, jamal wrote:
> On Mon, 2004-07-12 at 04:38, Glen Turner wrote:
> > On Sat, 2004-07-10 at 18:28, Vladimir Kondratiev wrote:
> > > I continue to insist that for true MAC layer QoS, we need several Tx
> > > queues.
> >
> > If you have several MAC-layer queues, then do you have
> > another set of MAC-layer scheduling?  If so, how do you
> > select the algorithm?
>
> A mapping is being suggested. Qdiscs handle the queueing. Send it to
> the driver/MAC layer with instructions of which queue it goes on.
Problem is, I don't know how driver can dictate what qdiscs should be attached 
to it. AFAIK, it is under 'tc' control. What I suggest, is to provide some 
API for driver to configure its qdiscs.
>
> > I suggest this can of worms requires further thought
> > before we end up with two layers of QoS queuing and
> > scheduling.
>
> Refer to the thread earlier; i think the mapping is pretty much
> sufficient.
There is a bit more complex then just diffserv.
Glen touched very good point: it should be no 2 QoS policies. Since in case of 
802.11, policy dictated from link layer, driver should be able to configure 
upper layers accordingly.

And most complex item: I don't know how to support intserv type of streams, 
i.e. streams with admission control. let's say it is like RSVP with support 
on link layer.

Should I try to summarize QoS facilities defined in TGE (new standard for QoS 
in 802.11)? I tried to do it once, but I don't feel I expressed it clearly.
>
> > PS: Can we *please* deprecate use of the ToS bits. We had
> >     almost killed them and Linux is again encouraging their
> >     use, much to the despair of network operators (who want
> >     DiffServ, or at least DiffServ-compatible use of IP
> >     Precedence)
One more reason why I prefer to use skb->priority over TOS: driver should be 
protocol agnostic. It may be non-IP, and TOS may be missing.
>
> I know you are refering to the default linux behavior, but
> do you use any of the diffserv enablers like dsmark to set DSCPs?
> I think 2.6.7+ we should change that default behavior. What exactly
> are the network operators complaining about?
>
> cheers,
> jamal
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFA8tXIqxdj7mhC6o0RAsICAKCBBsGH5fXO3z/muggJ0K/z7o5cMwCcDaFm
qNV8hhHZRpoPHbcSSv1QHac=
=AVLn
-----END PGP SIGNATURE-----
