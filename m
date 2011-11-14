From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: net: Add network priority cgroup
Date: Mon, 14 Nov 2011 15:56:27 -0500
Message-ID: <20111114205627.GE27284@hmsreliant.think-freely.org>
References: <1320868655-32592-1-git-send-email-nhorman@tuxdriver.com>
 <20111114114700.GA27284@hmsreliant.think-freely.org>
 <CAA93jw7tQtBGFMuDiK_pRUqAdfBVqrwbMegR8gh-8KgVb19PWg@mail.gmail.com>
 <20111114144358.GB27284@hmsreliant.think-freely.org>
 <DBFB1B45AF80394ABD1C807E9F28D157077D7D8D5F@BLRX7MCDC203.AMER.DELL.COM>
 <20111114172404.GC27284@hmsreliant.think-freely.org>
 <DBFB1B45AF80394ABD1C807E9F28D157077D7D8E83@BLRX7MCDC203.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dave.taht@gmail.com, netdev@vger.kernel.org,
	john.r.fastabend@intel.com, robert.w.love@intel.com,
	davem@davemloft.net
To: Shyam_Iyer@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44839 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346Ab1KNU4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 15:56:40 -0500
Content-Disposition: inline
In-Reply-To: <DBFB1B45AF80394ABD1C807E9F28D157077D7D8E83@BLRX7MCDC203.AMER.DELL.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2011 at 12:02:59PM -0800, Shyam_Iyer@Dell.com wrote:
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-
> > owner@vger.kernel.org] On Behalf Of Neil Horman
> > Sent: Monday, November 14, 2011 12:24 PM
> > Subject: Re: net: Add network priority cgroup
> > > >
> > > > On Mon, Nov 14, 2011 at 01:32:04PM +0100, Dave Taht wrote:
> > > > > On Mon, Nov 14, 2011 at 12:47 PM, Neil Horman
> > <nhorman@tuxdriver.com>
> > > > wrote:
> > > > > > On Wed, Nov 09, 2011 at 02:57:33PM -0500, Neil Horman wrote=
:
> > > > > >> Data Center Bridging environments are currently somewhat
> > limited
> > > > in their
> > > > > >> ability to provide a general mechanism for controlling tra=
ffic
> > > > priority.
> > > > > >> Specifically they are unable to administratively control t=
he
> > > > priority at which
> > > > > >> various types of network traffic are sent.
> > > > > >>
> > > > > >> Currently, the only ways to set the priority of a network
> > buffer
> > > > are:
> > > > > >>
> > > > > >> 1) Through the use of the SO_PRIORITY socket option
> > > > > >> 2) By using low level hooks, like a tc action
> > > > > >>
> > > > > >> (1) is difficult from an administrative perspective becaus=
e it
> > > > requires that the
> > > > > >> application to be coded to not just assume the default
> > priority is
> > > > sufficient,
> > > > > >> and must expose an administrative interface to allow prior=
ity
> > > > adjustment. =A0Such
> > > > > >> a solution is not scalable in a DCB environment
> > > > > >>
> > > > > >> (2) is also difficult, as it requires constant administrat=
ive
> > > > oversight of
> > > > > >> applications so as to build appropriate rules to match tra=
ffic
> > > > belonging to
> > > > > >> various classes, so that priority can be appropriately set=
=2E It
> > is
> > > > further
> > > > > >> limiting when DCB enabled hardware is in use, due to the f=
act
> > that
> > > > tc rules are
> > > > > >> only run after a root qdisc has been selected (DCB enabled
> > > > hardware may reserve
> > > > > >> hw queues for various traffic classes and needs the priori=
ty
> > to be
> > > > set prior to
> > > > > >> selecting the root qdisc)
> > > > > >>
> > > > > >>
> > > > > >> I've discussed various solutions with John Fastabend, and =
we
> > saw a
> > > > cgroup as
> > > > > >> being a good general solution to this problem. =A0The netw=
ork
> > > > priority cgroup
> > > > > >> allows for a per-interface priority map to be built per
> > cgroup.
> > > > =A0Any traffic
> > > > > >> originating from an application in a cgroup, that does not
> > > > explicitly set its
> > > > > >> priority with SO_PRIORITY will have its priority assigned =
to
> > the
> > > > value
> > > > > >> designated for that group on that interface. =A0This allow=
s a
> > user
> > > > space daemon,
> > > > > >> when conducting LLDP negotiation with a DCB enabled peer t=
o
> > create
> > > > a cgroup
> > > > > >> based on the APP_TLV value received and administratively
> > assign
> > > > applications to
> > > > > >> that priority using the existing cgroup utility
> > infrastructure.
> > > > > >>
> > > > > >> Tested by John and myself, with good results
> > > > > >>
> > > > > >> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > > > > >> CC: John Fastabend <john.r.fastabend@intel.com>
> > > > > >> CC: Robert Love <robert.w.love@intel.com>
> > > > > >> CC: "David S. Miller" <davem@davemloft.net>
> > > > > >> --
> > > > > >> To unsubscribe from this list: send the line "unsubscribe
> > netdev"
> > > > in
> > > > > >> the body of a message to majordomo@vger.kernel.org
> > > > > >> More majordomo info at =A0http://vger.kernel.org/majordomo=
-
> > info.html
> > > > > >>
> > > > > >
> > > > > > Bump, any other thoughts here? =A0Dave T. has some reasonab=
le
> > > > thoughts regarding
> > > > > > the use of skb->priority, but IMO they really seem orthogon=
al
> > to
> > > > the purpose of
> > > > > > this change. =A0Any other reviews would be welcome.
> > > > >
> > > > > Well, in part I've been playing catchup in the hope that lldp=
 and
> > > > > openlldp and/or this dcb netlink layer that I don't know anyt=
hing
> > > > > about (pointers please?) could help somehow to resolve the
> > semantic
> > > > > mess skb->priority has become in the first place.
> > > > >
> > > > > I liked what was described here.
> > > > >
> > > > > "What if we did at least carve out the DCB functionality away
> > from
> > > > > skb->priority?  Since, AIUI, we're only concerning ourselves =
with
> > > > > locally generated traffic here, we're talking
> > > > > about skbs that have a socket attached to them.  We could,
> > instead of
> > > > indexing
> > > > > the prio_tc_map with skb->priority, we could index it with
> > > > > skb->dev->priomap[skb->sk->prioidx] (as provided by this patc=
h).
> > The
> > > > cgroup
> > > > > then could be, instead of a strict priority cgroup, a
> > queue_selector
> > > > cgroup (or
> > > > > something more appropriately named), and we don't have to tou=
ch
> > skb-
> > > > >priority at
> > > > > all.  I'd really rather not start down that road until I got =
more
> > > > opinions and
> > > > > consensus on that, but it seems like a pretty good solution, =
one
> > that
> > > > would
> > > > > allow hardware queue selection in systems that use things lik=
e
> > DCB to
> > > > co-exist
> > > > > with software queueing features."
> > > > >
> > > > I was initially ok with this, but the more I think about it, th=
e
> > more I
> > > > think
> > > > its just not needed (see further down in this email for my
> > reasoning).
> > > > John,
> > > > Rob, do you have any thoughts here?
> > > >
> > > > > The piece that still kind of bothered me about the original
> > proposal
> > > > > (and perhaps this one) was that setting SO_PRIORITY in an app
> > means
> > > > > 'give my packets more mojo'.
> > > > >
> > > > > Taking something that took unprioritized packets and assigned
> > them
> > > > and
> > > > > *them only* to a hardware queue struck me as possibly
> > deprioritizing
> > > > > the 'more mojo wanted' packets in the app(s), as they would e=
nd
> > up in
> > > > > some other, possibly overloaded, hardware queue.
> > > > >
> > > > I don't really see what you mean by this at all.  Taking packet=
s
> > with
> > > > no
> > > > priority and assigning them a priority doesn't really have an
> > effect on
> > > > pre-prioritized packets.  Or rather it shouldn't.  You can
> > certainly
> > > > create a
> > > > problem by having apps prioritized according to conflicting
> > semantic
> > > > rules, but
> > > > that strikes me as administrative error.  Garbage in...Garbage =
out.
> > > >
> > > > > So a cgroup that moves all of the packets from an application
> > into a
> > > > > given hardware queue, and then gets scheduled normally accord=
ing
> > to
> > > > > skb->priority and friends (software queue, default of pfifo_f=
ast,
> > > > > etc), seems to make some sense to me. (I wouldn't mind if we =
had
> > > > > abstractions for software queues, too, like, I need a softwar=
e
> > queue
> > > > > with these properties, find me a place for it on the hardware=
 -
> > but
> > > > > I'm dreaming)
> > > > >
> > > > > One open question is where do packets generated from other
> > subsystems
> > > > > end up, if you are using a cgroup for the app? arp, dns, etc?
> > > > >
> > > > The overriding rule is the association of an skb to a socket.  =
If a
> > > > transmitted
> > > > frame has skb->sk set in dev_queue_xmit, then we interrogate it=
s
> > > > priority index
> > > > as set when we passed through the sendmsg code at the top of th=
e
> > stack.
> > > > Otherwise its behavior is unchanged from its current standpoint=
=2E
> > > >
> > > > > So to rephrase your original description from this:
> > > > >
> > > > > >> Any traffic originating from an application in a cgroup, t=
hat
> > does
> > > > not explicitly set its
> > > > > >> priority with SO_PRIORITY will have its priority assigned =
to
> > the
> > > > value
> > > > > >> designated for that group on that interface.  This allows =
a
> > user
> > > > space daemon,
> > > > > >> when conducting LLDP negotiation with a DCB enabled peer t=
o
> > create
> > > > a cgroup
> > > > > >> based on the APP_TLV value received and administratively
> > assign
> > > > applications to
> > > > > >> that priority using the existing cgroup utility
> > infrastructure.
> > > > > > John, Robert, if you're supportive of these changes, some A=
cks
> > > > would be
> > > > > > appreciated.
> > > > >
> > > > > To this:
> > > > >
> > > > > "Any traffic originating from an application in a cgroup,  wi=
ll
> > have
> > > > > its hardware queue  assigned to the value designated for that
> > group
> > > > on
> > > > > that interface.  This allows a user space daemon, when conduc=
ting
> > > > LLDP
> > > > > negotiation with a DCB enabled peer to create a cgroup based =
on
> > the
> > > > > APP_TLV value received and administratively assign applicatio=
ns
> > to
> > > > > that hardware queue using the existing cgroup utility
> > > > infrastructure."
> > > > >
> > > > As above, I'm split brained about this.  I'm ok with the idea o=
f
> > making
> > > > this a
> > > > queue selection cgroup, and separating it from priority, but at=
 the
> > > > same time,
> > > > in the context of DCB, we really are assigning priority here, s=
o it
> > > > seems a bit
> > > > false to do something that is not priority.  I also like the fa=
ct
> > that
> > > > it
> > > > provides administrative control in a way that netfilter and tc
> > don't
> > > > really
> > > > enable.
> > > >
> > > > > Assuming we're on the same page here, what the heck is APP_TL=
V?
> > > > >
> > > > LLDP does layer 2 discovery with peer networking devices. It do=
es
> > so
> > > > using sets
> > > > of Type/length/value tuples.  The types carry various bits of
> > > > information, such
> > > > as which priority groups are available on the network.  The APP=
 tlv
> > > > conveys
> > > > application or feature specific information.  for instance, The=
re
> > is an
> > > > ISCSI
> > > > app tlv that tells the host that  "on the interface you receive=
d
> > this
> > > > tlv, iscsi
> > > > traffic must be sent at priority X".  The idea being that, on
> > receipt
> > > > of this
> > > > tlv, the DCB daemon can create an ISCSI network priority cgroup
> > > > instance, and
> > > > augment the cgroup rules file such that, when the user space is=
csi
> > > > daemon is
> > > > started, its traffic automatically transmits at the appropriate
> > > > priority.
> > >
> > > Love this !
> > >
> > > I guess if this is integrated to libvirt via libcgroups VMs could=
 be
> > assigned a network priority..
> > >
> > As the patch stand currently, absolutely.  Just drop a qemu process
> > into the
> > approriate cgroup, and (assuming you're using a tun/tap type device=
),
> > all the
> > traffic from that vm will get assigned the corresponding priority. =
 You
> > can do
> > the same thing with classification using net_cls already.  I did a
> > video of it
> > here:
> > http://www.youtube.com/watch?v=3DKX5QV4LId_c
>=20
> Yes.. But I guess the present implementation allows iSCSI daemon to b=
e grouped in an iSCSI network priority cgroup.
> This is nicer since then we don't have to deal with a network cgroup =
+ disk cgroup for the iSCSI use case.
>=20
Thats my understanding, yes.

> Now.. since this is on the skb->priority I suspect this could become =
 a per-session priority cgroup.
>=20
Correct.

> Is that the case or does the iscsid form just one cgroup?
>=20
The cgroups are actually formed by administrative tools like dcbx/lldap=
d/etc.
Placement into appropriate cgroups is then handled by appropriate confi=
guration
of cgroups.conf (which may be done administratively by hand, or by the
aforementinoed utilities).  So iscsid, when started, would be assigned =
the
appropriate cgroup by virtue of said configuration file.
Neil

> > Neil
> > > http://linuxplumbersconf.org/2010/ocw/proposals/843
> > >
> > >
> > >
> >=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
