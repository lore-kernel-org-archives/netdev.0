From: Julien Vehent <julien@linuxwall.info>
Subject: Re: [WARNING - VERY LONG] A sysadmin's understanding of HFSC and IFB
Date: Tue, 13 Dec 2011 18:10:07 -0500
Message-ID: <5f2da864419b2bd2a28c57128df418a6@njm.linuxwall.info>
References: <1323415051.3159.25.camel@denise.theartistscloset.com>
 <1323417599.2529.18.camel@edumazet-laptop>
 <1323817279.8451.7.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sachiel.linuxwall.info ([88.191.125.180]:60752 "EHLO
	smtp.linuxwall.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753639Ab1LMXUe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 18:20:34 -0500
In-Reply-To: <1323817279.8451.7.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an amazing email and I will definitely sit down and read it=20
carefully.
I've been (silently) following your discussions about HFSC because I've=
 been=20
wanting to add a section on HFSC in the TC doc I wrote here:
http://wiki.linuxwall.info/doku.php/en:ressources:dossiers:networking:t=
raffic_control

The doc I've read so far left me staring at the wall with more question=
s=20
than answers. I'm hoping your text will finally bring a clear view of t=
he=20
problem :)

Cheers,
Julien

On 2011-12-13 18:01, John A. Sullivan III wrote:
> On Fri, 2011-12-09 at 08:59 +0100, Eric Dumazet wrote:
>> Le vendredi 09 d=C3=A9cembre 2011 =C3=A0 02:17 -0500, John A. Sulliv=
an III a
>> =C3=A9crit :
>> > Hello, all.  I've been trying to summarize my last week's worth of
>> > research into HFSC and IFB.  Being neither a developer nor a
>> > mathematician, I found most of the existing documentation daunting=
 and
>> > am truly grateful for the help I received on this list to understa=
nd=20
>> the
>> > technologies.
>> >
>> > I do not currently have a blog to post this research and so was=20
>> thinking
>> > of posting it to this list so that it could be archived and search=
able
>> > for other poor sysadmin types like me to save them the days of
>> > struggling to get their practical heads around the concepts.
>> >
>> > However, since this is probably a 15 page or so document, I realiz=
ed
>> > this could be quite rude to those on dial up or metered connection=
s.
>> > Would it be appropriate to post my summary here? Thanks - John
>> >
>>
>> Please post here, thats definitely a good idea.
>>
>> I am pretty sure your contribution could serve to add a page to
>>
>> http://www.linuxfoundation.org/collaborate/workgroups/networking/gro=
up
>>
>> I believe we lack documentation. A lot.
> <snip>
> OK - it's almost ready.  The only problem I know if is that, when I d=
o
> the math based upon my explanation, I sometimes violate an rt curve w=
hen
> I should not.  I posed that in an email to the list entitled "An erro=
r
> in my HFSC sysadmin documentation".  If anyone can figure out where m=
y
> error is, I will gladly change the documentation.  Here's what I have=
=2E
> The graphics except the ASCII art are obviously missing.  All
> corrections and suggestions very gratefully accepted - John
>
>
> IFB
> The Intermediate Functional Block (IFB) device is a pseudo-interface =
to
> which traffic can be redirected by using a tc filter with the mirred
> (mirror/redirect I assume) action.  The primary documentation appears=
 to
> be at
> http://www.linuxfoundation.org/collaborate/workgroups/networking/ifb =
but
> I found it less than helpful.  Perhaps the most helpful information w=
as
> found in a discussion on the mirred tc filter action at
> http://www.sephidev.net/external/iproute2/doc/actions/mirred-usage an=
d
> particularly this section:
> Remember that IFB is a very specialized case of packet redirecting
> device. Instead of redirecting it puts packets at the exact spot
> on the stack it found them from.
> In other words, we redirect or mirror traffic from an interface into =
the
> ifb interface and, when ifb is finished with it, it puts it right bac=
k
> onto the interface which was redirected into it.  Why would one want =
to
> do that?
> Diagnostics are one important reason, e.g., to capture dropped packet=
s.
> Packets may be dropped on the interface either because of an iptables
> rule or a traffic limiting rule.  The packets can be mirrored onto an
> ifb interface which will see them before they are dropped allowing
> packet analysis on them.  Another would be in a Linux based switch to
> port mirror traffic from one port to another.
> Another reason is for applying identical traffic shaping rules to
> multiple interfaces.  Let's say one is using complicated traffic shap=
ing
> rules with several qdiscs (queue disciplines), classes, and filters a=
nd
> the same set applies to many interfaces.  Rather than defining and
> maintaining this complex set for multiple interfaces, one could set a
> filter for each of those interfaces to redirect into an ifb interface
> and apply the complex traffic shaping there.
> A final reason is both complex and critically important, especially f=
or
> SimplicITy and Firepipes (or anyone using VDI across the Internet):
> ingress traffic shaping.  Normal Linux ingress traffic shaping can on=
ly
> police.  Policing cannot really shape packets.  It can edit them, dro=
p
> them, pass them, or do nothing.  One of the important goals of either
> policing or shaping ingress traffic is to give us a fighting chance t=
o
> shape inbound traffic from the Internet when we have no control over =
the
> upstream router.
> For example, we may prioritize NX/RDP/Citrix and VoIP traffic outboun=
d
> to the Internet so that it is prioritized over web browsing and sendi=
ng
> huge email attachments or FTP transfers.  But, if someone starts pull=
ing
> down a huge file and consumes all the inbound bandwidth, our desktop
> sessions can slow to a crawl and our VoIP calls become unintelligible=
=2E
> We might face a similar problem if we host our own web servers; our w=
eb
> servers could slow to a crawl in the public perception if their abili=
ty
> to respond to queries is being blocked by monster downloads into our
> network.  How can we keep the bulk traffic internal users are
> downloading from mangling our time critical traffic?
> The basic idea is to use the flow control mechanisms of traffic flow.
> This is built in to any TCP transmission and may or may not be in the
> upper layers of a UDP stream.  If we start dropping inbound packets, =
the
> other side should get the point and start throttling its flow.
> The recommended way to do this is to place an egress filter on the
> internal interface of the firewall, i.e., we only let the firewall pl=
ace
> traffic on the internal network at a particular rate.  Egress traffic
> shaping can be very powerful so we can use something like HTB
> (Hierarchical Token Bucket) to reserve bandwidth for time sensitive
> traffic but allow that bandwidth to be used for bulk traffic it is no=
t
> needed for time sensitive traffic.  We can also distinguish between w=
ell
> behaved traffic (like most TCP traffic) and most poorly behaved traff=
ic
> which won't throttle (like most UDP traffic) and not allow UDP traffi=
c
> to use extra bandwidth if available.
> This is fine if the firewall has only a single internal interface.  T=
he
> bulk traffic can only be output at the traffic shaping speed and, whe=
n
> the inbound buffer overflows, packets will drop and the well behaved
> application on the other end should throttle.  But what if we have a =
DMZ
> or, as we often do with Firepipes, multiple internal interfaces?
> Throttling the egress of the internal interface would also throttle
> traffic flowing to it from the DMZ or other internal interfaces; that
> would be very bad.
> In these cases, it is better to create an ingress filter, i.e., filte=
r
> the traffic coming in off the Internet.  As mentioned, an ingress fil=
ter
> can only police so the only way we can throttle download traffic is t=
o
> drop the packets.  We could create several bands to reserve bandwidth
> for different types of traffic and drop packets which exceed those
> bandwidth limits but we have no ability to do complex traffic shaping
> such as allowing bulk traffic to use available bandwidth from higher
> priority traffic if it is available.
> This is where IFB comes into play.  We can redirect the inbound traff=
ic
> into an IFB interface and then apply an egress filter with full traff=
ic
> shaping to the IFB.  This will shape the traffic before it is placed
> back onto the inbound interface.
> This would allow us to use something like HTB on the inbound traffic =
so
> that we could reserve bandwidth for time sensitive traffic, limit
> bandwidth for bulk traffic, yet allow the bulk traffic to use the tim=
e
> sensitive bandwidth when it is available.  But what happens if the bu=
lk
> traffic is using the bandwidth and a time sensitive packet arrives? I=
t
> is now queued behind the bulk packets and can suffer intolerable dela=
y.
> This is where HFSC steps in.
> HFSC
> HFSC (Hierarchical Fair Service Curve) is an incredibly powerful but,
> again, poorly documented qdisc.  Its outstanding feature over qdiscs
> like HTB is that it separates latency guarantees from bandwidth
> guarantees.  In other queue disciplines, the only way to guarantee lo=
wer
> latency is to allocate more bandwidth.  This is counter productive wi=
th
> technologies such as VoIP which require low latency but send very sma=
ll
> packets and typically require far less bandwidth per flow than bulk
> applications.  HFSC has three goals:
> 1. Decouple latency requirements from bandwidth requirements
> 2. Provide guaranteed bandwidth when specified
> 3. Fairly share available extra bandwidth
> It recognizes it cannot always achieve all three goals and will prese=
rve
> guaranteed bandwidth over fair sharing when there is a conflict.
> The paper describing HFSC is at
> http://www.cs.cmu.edu/~istoica/hfsc_extended.ps.gz (with a note that
> says, "You might need to treat it first with: sed "s|\[FontBBox
> \]|/FontBBox load |" as it was generated with a little bit old (ancie=
nt)
> idraw version." It is highly technical and mathematical but has some
> excellent graphics to illustrate the principles.
> A related site is http://www.cs.cmu.edu/~hzhang/HFSC/main.html
> The latest man pages are a little less mathematical but still pretty
> dense with the references to functions to describe the service curves=
=2E
> I've downloaded the latest man pages
>=20
> (http://git.kernel.org/?p=3Dlinux/kernel/git/shemminger/iproute2.git;=
a=3Dblob_plain;f=3Dman/man7/tc-hfsc.7;hb=3DHEAD
> and
>=20
> http://git.kernel.org/?p=3Dlinux/kernel/git/shemminger/iproute2.git;a=
=3Dblob_plain;f=3Dman/man8/tc-hfsc.8;hb=3DHEAD)
> to Tech/Equipment/Endian; they can be read with:
> nroff -mandoc -rLL=3D<width>n <page> | less
> A commonly reference resource is http://linux-ip.net/articles/hfsc.en=
/
> I also found http://www.sonycsl.co.jp/~kjc/software/TIPS.txt helpful.
> However, many articles attempting to explain HFSC didn't seem to real=
ly
> get it - especially the part about decoupling latency and bandwidth
> requirements.  It is all quite confusing and not well understood.  In
> fact, as I'm thinking about how to record what I have learned, I'm
> really struggling because there is no simple way to describe HFSC!
> Let's break down the terms.  It is hierarchical because bandwidth can=
 be
> allocated and controlled on a hierarchical basis.  For example, the t=
op
> level of the hierarchy might be our overall available bandwidth.  The
> next level of the hierarchy might be gold level customers who get 70%=
 of
> the available bandwidth and regular customers who get 30%.  The next
> level might be individual customers or groups of customers who divide
> the 70% or 30% allocated to their parent.  The final hierarchy might =
be
> groups of traffic like VoIP, interactive, web, or bulk.  These end no=
des
> are called leaf nodes.  There is an important distinction between lea=
f
> nodes and container nodes.  Bandwidth guarantees are only made at the
> leaf node level.  Containers are only used for link sharing, i.e., ho=
w
> excess bandwidth is shared when it is available.  Remember that we sa=
id
> HFSC enforces guarantees even if it means bandwidth is not shared
> evenly.  Bandwidth guarantees are always honored (if physically
> possible) regardless of the bandwidth allocated to the higher layers =
of
> the hierarchy.  Thus one must be careful to not overallocate bandwidt=
h
> at the leaves.
> Moreover, the fair sharing of bandwidth only happens between peers.  =
In
> other words, using our example, only two peers contend for the overal=
l
> bandwidth - Gold and Regular.  If the second level hierarchy of Gold =
has
> clients A, B, and C and the second level of Regular has D and E, D an=
d E
> contend for Regular's share of the bandwidth and A, B, and C contend =
for
> Gold's share of the bandwidth but, for example, D never contends with=
 B
> because they are in different parts of the tree.  Only peers contend =
for
> available bandwidth.
> So that explains "hierarchical."  What do we mean by fair? This refer=
s
> to how available extra bandwidth is allocated between those groups wh=
ich
> need it.  Let's say that we have 100Mbps of bandwidth divided into fo=
ur
> groups of traffic - Gold (40%), Silver (30%), Bronze (20%), and Regul=
ar
> (10%).  Let's say that no Gold or Bronze users are active so 60% of o=
ur
> bandwidth is unallocated but both Silver and Regular could use as muc=
h
> bandwidth as we can give them.  How do we fairly share that 60% betwe=
en
> Silver and Regular? HFSC uses a concept called virtual time to which =
we
> will return later.  In effect, it will divide the 60% in proportion t=
o
> the traffic allocated to each group asking for more.  Specifically, i=
n
> this case, three shares of bandwidth will be allocated to Silver for
> every one allocated to Regular (30:10).
> This is another area where HFSC is brilliant over other queue
> disciplines.  For example, what if we have a stream of traffic that
> doesn't require much bandwidth but, when it needs more, we need to
> prioritize it over bulk traffic? If our service guarantees are that V=
oIP
> gets a guaranteed 10% of the bandwidth, web traffic gets 30% and bulk
> gets 60%, when web is inactive and both VoIP and bulk need more, the
> excess would be allocated to bulk in a 6:1 ratio.  That's not good.  =
But
> remember we said that guaranteeing bandwidth and sharing bandwidth ar=
e
> two separate and sometimes conflicting functions in HFSC.  Thus, we c=
an
> say that VoIP is guaranteed 10% but, when it comes to sharing availab=
le
> bandwidth, VoIP should get 70%, web gets 20%, and bulk gets 10%.
> Brilliant! This is done by means of service curves, the last part of
> Hierarchical Fair Service Curve traffic shaping.
> A service curve is a mathematical way of describing how much service =
a
> process is given over time.  The use of the term curve can throw us
> non-mathematicians for a "curve" until we remember that, in strict
> mathematical terms, a straight line is a curve - a curve which
> represents a linear function.  To translate all that: a service curve=
 is
> the allocated bandwidth.  The y axis is the amount of data transferre=
d
> (service given) and the x axis is time.  The greater the bandwidth, t=
he
> steeper the slope of the curve (line).  Another brilliant thing about
> HFSC is that a service curve can have two lines, i.e., for a certain
> period of time one bandwidth can be allocated and after that time
> period, a different bandwidth can be allocated.  I'll refer to this a=
s a
> "di-linear" curve.  This is how HFSC decouples bandwidth from latency
> but we'll come back to that.
> A service curve can be defined using tc with a single parameter if we
> only need one line or with three parameters if we need two lines.  Th=
ere
> are two ways the parameters can be given to tc.  The mathematically
> oriented way is "m1 <value> d <value> m2 <value>" where m1 is the slo=
pe
> of the first curve (line for the non-mathematicians - translate: the
> initial bandwidth), m2 is the slope of the second curve (translate: t=
he
> second bandwidth setting) and d is the intersection of the two curves
> (translate how long we use the first bandwidth before switching to th=
e
> second bandwidth).
> The second, more system administrator oriented syntax is "umax <value=
>
> dmax <value> rate <value>".  This syntax makes it a little easier to =
see
> how HFSC separates guarantees for latency from guarantees for bandwid=
th.
> The rate parameter is the second curve.  In practical terms, this is =
the
> guaranteed bandwidth.  The umax parameter is the size of some unit of
> data.  It will often be the size of a data packet, e.g., 1514 bytes
> (does not need to include CRC, preamble, or inter-frame gap) but it
> could be some other unit.  For example, some have suggested that one
> could use this so that the text portion of web pages are delivered wi=
th
> low latency and the rest of the non-text, typically larger data
> transmissions, will follow at a slower pace.  If the typical text pag=
e
> size is 10KB, we might set umax to 10KB. Of course, this assumes that
> text is always sent first. The dmax parameter is the maximum delay th=
at
> umax can tolerate.  So we might say that the first 1514 byte packet m=
ust
> be delayed no more than 20ms, or the first 10KB of web page transmiss=
ion
> should be delayed no more than 100ms.  This is how bandwidth and late=
ncy
> guarantees are separated.
> Let's illustrate this a little further.  Let's say we have an FTP
> transfer which is running as fast as its guaranteed bandwidth.  We al=
so
> have a VoIP traffic stream also running within its guaranteed bandwid=
th.
> The classic problem is that my VoIP packet which must be delivered on
> time is sitting behind my much larger FTP packet which is allowed to =
be
> sent because it is within the guaranteed bandwidth for FTP.  How do I
> jump the VoIP packet ahead of the FTP packet?
> HFSC will see that both packets are eligible to be sent because both =
are
> within the bandwidth limits set for their kind of traffic.  It then s=
ees
> that the FTP traffic only has a bandwidth guarantee, i.e., it can mee=
t
> its obligations to the FTP traffic as long as the packet is delivered
> within the time frame necessary to meet the bandwidth requirements
> regardless of how much the packet is delayed (as long as the delay is
> not so long as to violate the bandwidth requirements).  It then looks=
 at
> the equally eligible VoIP packet and sees that, not only does it have=
 an
> obligation for bandwidth but it also must not delay this packet for m=
ore
> than, say, 20ms.  In effect, it looks at the deadline for delivering =
the
> FTP packet and compares it to the deadline for delivering the VoIP
> packet and if the deadline for the VoIP packet is sooner than the
> deadline for the FTP packet, it will service the VoIP packet first.
> But how, exactly, does it work? It is done by the interplay of servic=
e
> curves and timers.  In fact, we will come to see that eligible and
> deadline are actually technical terms to describe some of the timers =
but
> first, let's step back and explain a little more about service curves=
=2E
> Service curves
> There are actually three service curves used by HFSC.  They are:
> 1. The real-time service curve (rt)
> 2. The link-sharing service curve (ls)
> 3. The upper limit service curve (ul)
> The abbreviations are used to specify which service curve we are
> describing in the tc syntax, e.g.,
> tc add class dev <device> parent parentID classid <ID> hfsc [ [ rt SC=
 ]
> [ ls SC ] | [ sc SC ] ] [ ul SC ]
> SC is the description of the curve as described above using m1 d m2 o=
r
> umax dmax rate, e.g.,
> tc add class dev <device> parent parentID classid <ID> hfsc rt 1514b
> 20ms 200kbits
> If we are not using two curves, we only need the last parameter, e.g.=
,
> tc add class dev <device> parent parentID classid <ID> hfsc ls 500kbi=
ts
> The sc parameter is used when rt and ls are the same, i.e., one can
> specify them both in one definition rather than needing to write two.
> It is not usual to specify all three curves in the same class.  The r=
t
> parameter is only used on leaves.  The ul parameter is usually not us=
ed
> leaves.
> Real-time service curve
> Real-time service curves can only be applied to leaf nodes (remember
> this is Hierarchical Fair Service Curve).  Using our previous example=
,
> rt curve would not be applied to "Gold Clients" but to "Web traffic".
> The rt curves can have either one curve (line) or two.  In fact, it i=
s
> usually only rt curves which have two curves; ls and ul curves genera=
lly
> do not.  If the first curve is steeper than the second curve
> (translated: if the initial bandwidth guarantee is greater than the
> sustained bandwidth guarantee), the curve is called concave in HFSC
> terminology.  If the opposite is true, it is called convex.  This is
> illustrated by the below graphic copied from
> http://www.cs.cmu.edu/~hzhang/HFSC/main.html
> One must be careful when specifying rt curves because they will be
> honored above all other curves (remember we said that, when it is
> impossible to satisfy the requirements for both guaranteed bandwidth =
and
> fair sharing, guaranteed bandwidth wins).  This will be more
> understandable when we discuss the upper limit (ul) curve.  To jump
> ahead a little bit, the ul is typically though not exclusively used t=
o
> describe the maximum bandwidth available, e.g., a T1 circuit or a cab=
le
> connection.  We said that rt is honored above all other curves.  If t=
he
> ul curve says the maximum bandwidth available is 10 Mbps and the sum =
of
> all our rt curves is 20 Mbps, the system will try to guarantee 20 Mbp=
s
> which, of course, means it will fail to meet its guarantees under
> maximum load.
> Jumping ahead once more, rt curves override ls curves, too.  The ls
> curves are used to share extra bandwidth fairly.  So, if the ls curve
> dictates that class A should have 2 Mbps of our 10 Mbps link and clas=
s B
> should have 8 Mbps but the rt curve says that class A is guaranteed 3
> Mbps, class A will get 3 Mbps and class B only 7 Mbps.  The rt curve
> will always be honored whenever it is physically possible.  The botto=
m
> line is that the rt service curve always "wins."
> An important point to remember is that the rt curve determines the
> bandwidth and latency guarantees, is the only curve which determines
> bandwidth and latency guarantees, and has nothing to do with how
> bandwidth is fairly shared (other than to override that sharing if
> necessary!).  To put it another way, the function of the rt service
> curve is independent of the ul and ls service curves.  They handle tw=
o
> completely separate characteristics of HFSC.
> Upper limit service curve
> As mentioned above, the ul curve is often used to describe the maximu=
m
> bandwidth available.  More specifically, it sets an upper boundary to
> the bandwidth which can be allocated by the ls curve.  As we will see=
,
> the ls curve is used to determine how the excess available bandwidth =
is
> fairly shared.  The ul service curve sets limits on that sharing.
> Let's get some vocabulary defined.  Link sharing is the term used by
> HFSC to describe how the bandwidth not actively used by the rt servic=
e
> curve is fairly allocated among the rest of the network sessions whic=
h
> are requesting bandwidth.  Let's connect the dots again as a way of
> review.  Remember, the rt curve defines the guaranteed amounts of
> bandwidth.  Let's go back to our 10 Mbps circuit and say we have VoIP
> with an rt service curve rate of 1 Mbps, interactive traffic with an =
rt
> service curve rate of 5 Mbps, web traffic with an rt service curve ra=
te
> of 2 Mbps, and bulk traffic with an rt service curve rate of 1 Mbps.
> Note that the sum of the rt curves does not need to equal the total
> bandwidth.  Now let's say it's the middle of the night so the phones =
are
> not in use and no one is generating interactive traffic however web
> traffic to our internal web servers is going at full speed as are our
> overnight off site backups and FTP transfers.  Web is guaranteed 2 Mb=
ps,
> bulk is guaranteed 1 Mbps and link sharing will figure out how to div=
ide
> up the remaining 7 Mbps.  However, the ul curve could override the wa=
y
> link sharing divides that 7 Mbps.
> Let's illustrate how and learn more about ul at the same time.  The u=
l
> service curve is normally specified at the top of the hierarchy and i=
s
> set to the maximum bandwidth available.  Think way back to when we sa=
id
> that link sharing only happened between peers.  Classes lower in the
> hierarchy can only contend for the bandwidth allocated to their paren=
t
> and not for bandwidth allocated to classes at the same level but unde=
r a
> different parent.  Once again, I will copy a graphic from
> http://www.cs.cmu.edu/~hzhang/HFSC/main.html to illustrate this:
> Since children can only contend for the bandwidth allocated to their
> parents, the ul limit on bandwidth flows down through the entire tree
> under it.  If the parent with the ul limitation cannot receive the
> bandwidth, its children cannot contend for it.  Thus, by placing the =
ul
> at the top of the hierarchy and setting it to the maximum bandwidth
> available, it flows down through the entire tree and we do not need t=
o
> define it in every descendant class.  That is, unless we want to
> override it further down the tree.
> Let's go back to our illustration.  If we had set ul rate 10240kbits =
(10
> Mbps), the web traffic and the bulk traffic will be sharing the 7 Mbp=
s
> available bandwidth in whatever ratio was specified in their ls servi=
ce
> curves.  If no ls curves were specified, they will divide the bandwid=
th
> according to their rt curves - in this case a 2:1 split.  For now, le=
t's
> assume that the ls curve is the same as the rt curve, that is 2 Mbps =
for
> web and 1 Mbps for bulk.  Remember that the ul curve sets a limit on =
the
> ls curve.  What if, for some reason, we wanted to make sure that bulk
> traffic never exceeds 3 Mbps even if there is more available?  We wou=
ld
> create a  second ul service curve for the bulk traffic on the bulk
> traffic class with ul rate 3072bkits.
> Link sharing will try to allocate an extra 2.33 Mbps to bulk traffic
> (7 / 3).  When this link sharing bandwidth is added to the guaranteed
> bandwidth of 1 Mbps, we come out to 3.33 Mbps.  Since this is exceeds
> the ul service curve set specifically for bulk traffic, link sharing
> will not be able to service bulk traffic at 3.33 Mbps.  It will only =
be
> able to provide service at 3 Mbps.  The rest will go to the web servi=
ce.
> So, to summarize, the ul service curve is not used to guarantee
> bandwidth or latency.  That is the job of the rt service curve.
> Allocated bandwidth can exceed the ul service curve if the sum of the=
 rt
> service curves is greater than the ul service curve and the circuit c=
an
> support the higher rt bandwidth allocation.  This is another way of
> saying the rt guaranteed bandwidth always takes precedence.  The ul
> service curve is used to determine the link sharing bandwidth, i.e., =
the
> bandwidth allocated to classes of traffic from the unused portion of =
the
> available bandwidth.  It is specifically used to limit how much
> bandwidth can be allocated through link sharing, is typically set to =
the
> maximum bandwidth of the circuit, and is normally set at the top of t=
h
> hierarchy because its affect is to flow down to all classes underneat=
h
> it.
> Link-sharing service curve
> The ls service curve is not used to guarantee bandwidth or latency.  =
Its
> sole purpose is to determine the proportions in which unused bandwidt=
h
> is allocated to classes which are requesting more than their guarante=
ed
> bandwidth, that is link sharing.  Although it is good practice to use
> service curves with numbers that are realistic for the available
> bandwidth, technically, only the ratio is important.
> Let's illustrate by returning to our previous example.  The ul is set=
 to
> a rate of 10 Mbps.  We would expect the web ls service curve to use a
> rate of 2 Mbps and the bulk ls service curve to use a rate of 1 Mbps.
> However, we could say the web ls sc is 200 Mbps and the bulk ls sc is
> 100 Mbps and it would not break and not be illegal - just confusing.
> The ratios are the same (2:1) and it is only the ratios which are
> important.
> The discussion about ul service curves has "stolen the thunder" from =
the
> ls service curve discussion, i.e., there is not much left to say.  Th=
e
> ls service curves determine how link sharing works, i.e., how the
> bandwidth with is not being used to satisfy the guarantees of the rt
> service curves is fairly allocated among all the other network traffi=
c
> flows who would like more bandwidth than they are guaranteed.
> The Linux and BSD implementation of HFSC go beyond the original
> specification by allowing us to specify the ls service curve separate=
ly
> from the rt service curve.  This gives us some powerful flexibility a=
s
> we are about to illustrate.
> Let's extend our previous example.  Remember we have a 10 Mbps circui=
t
> and thus have set the ul service curve rate at the top of the hierarc=
hy
> to 10 Mbps.  We have four classes of traffic, VoIP, interactive, web,
> and bulk.  The rt rate for VoIP is 1 Mbps, for interactive 5 Mbps, fo=
r
> web 2 Mbps, and for bulk 1 Mbps.  That accurately reflects our desire
> for guaranteed bandwidth but those proportions may not accurately
> reflect how we want any available excess bandwidth distributed.
> For our purposes, link sharing should have the following
> characteristics.  Bulk should be able to use all the bandwidth if it =
is
> available and uncontended.  However, if the VoIP traffic needs extra
> bandwidth and there is available bandwidth, it should be granted that
> extra bandwidth with priority since we do not want to starve our voic=
e
> traffic.  Furthermore, we want visitors to our web site to have a
> positive experience and not one with substantial delays so, if there =
is
> contention between bulk and web traffic, we want web traffic to take
> more than a 2:1 ration of available bandwidth.  Thus, we might setup =
our
> tc classes as follows:
> VoIP:
> tc add class dev eth0 parent 1:1 classid 1:10 hfsc rt rate1024kbits l=
s
> rate 7168kbits
> We first thought this should be rt umax 222b dmax 5ms rate 1024kbits
> because the maximum sized VoIP packet is typically 222 bytes (ulaw/al=
aw
> at 64Kbps =3D 8KB/s * 0.020s (20 ms per packet) =3D 160 Bytes + 8 (UD=
P
> header) + 40 (IP header) + 14 (Ethernet header) =3D 222 Bytes) and we=
 want
> it delayed in the router for no more than 5ms.  However, to guarantee=
 1
> Mbps bandwidth, a 222 byte packet needs to be sent within roughly 1.7=
ms
> (222 * 8 =3D 1776 bits / (1024 * 1024)bits/s =3D 0.0017s).  Thus, our=
 rate
> is sufficient and we do not need to jump the delivery of VoIP packets=
 by
> specifying a larger initial bandwidth.
> Interactive
> tc add class dev eth0 parent 1:1 classid 1:11 hfsc sc rate5120kbits
> We use sc since we want rt and ls to be the same
> Web:
> tc add class dev eth0 parent 1:1 classid 1:12 hfsc rt rate 2048kbits =
ls
> rate 3072kbits
> Bulk:
> tc add class dev eth0 parent 1:1 classid 1:12 hfsc sc rate 1024kbits
> Note that the sum of our ls service curves exceeds the ul service cur=
ve.
> This is not a problem.  Remember it is only the ls service curve rati=
os
> which are meaningful.  So what have we done? Even though our guarante=
es
> can be met with a proportion of 1:5:2:1, we have specified that, if
> there is extra bandwidth available and, if there is contention for it=
,
> distribute it in the ratio of 7:5:3:1.  In other words, if interactiv=
e
> and web are idle and VoIP and bulk can use more bandwidth than their
> guarantees (backlogged in HFSC terminology), the bandwidth will be
> allocated between VoIP and bulk at a 7:1 ration and not a 1:1 ratio.
> Likewise, if VoIP and interactive are idle and web and bulk are
> backlogged, the extra bandwidth will be allocated at a 3:1 ratio rath=
er
> than a 2:1 ratio.  Can we see the value of having separate rt and ls
> service curves?
> Timers
> However, service curves are not the whole story.  In fact, it is not
> really the service curves which determine which packet is sent when.
> The service curves are used to set the timers and it is the timers wh=
ich
> determine which packet is sent when.
> While service curves are quite understandable to system administrator
> types once we translate the vocabulary (curves =3D bandwidth, umax an=
d
> dmax =3D latency (technically bandwidth I suppose but, latency in
> practicality)), timers are they mysterious art of programmers and
> mathematicians - an impenetrable black box.  Let's see if we can pry
> open that black box and make it at least a little understandable to u=
s
> sysadmin types.
> HFSC uses four separate timers to work its wonders:
> 1. Fit time
> 2. Virtual time
> 3. Eligible time
> 4. Deadline time
> Virtual time
> Let's start with virtual time.  Virtual time is used by link sharing =
to
> determine which queue should be serviced to keep things fair, that is=
 to
> keep the bandwidth in proportion to the ls service curve ratios.
> Virtual time appears to be a very complicated topic addressing
> mind-bending issues like how to preserve fairness among several
> backlogged queues when a new queue becomes backlogged as well and to
> preserve this fairness without starving one of the queues while the
> others catch up. Thus my explanation will be a dramatic
> oversimplification but hopefully enough to give fellow sysadmins a
> toehold to ascend this seemingly sheer rock face.
> Virtual time is a measure of how much time has been spent servicing t=
he
> queue and how much it will take to service the next packet.  Here is =
a
> very good ascii art representation copied from
> http://www.sonycsl.co.jp/~kjc/software/TIPS.txt :
>                     bytes
>                          |                   /
>                          |                  /service curve
>                          |                 /
>            next   -->+   +----------------+
>            packet    |   |               /|
>            length    |   |              / |
>                      |   |             /  |
>            total --> +   +------------+   |
>            bytes         |           /|   |
>            already       |          / |   |
>            sent          |         /  |   |
>                                   /   |   |
>                                       |   |
>                                       |   |
>                               --------+---+--------------> time
>                                           vt for next packet
>                                       vt for previous packet
>
> Not surprisingly, this makes a great deal of sense when we digest it.
> Remember, the service curve we are using is the ls service curve, i.e=
=2E,
> the one for link sharing.  The more the bandwidth allocated to the ls
> service curve, the steeper the slope of the line.  The steeper the sl=
ope
> of the line, the shorter the time to transmit the packet =3D the more
> bandwidth, the shorter the time to transmit the packet.  Thus, the
> change in virtual time for the same sized packet is less for a faster
> queue than for a slower queue.  We'll see why that is important in a
> second.
> Remember that link sharing is used only among peers.  Only peers can
> contend for available extra bandwidth.  Fairness is achieved in HFSC =
by
> trying to keep the virtual time of all peers equal.  When a queue
> becomes backlogged, i.e., needing more than its guaranteed bandwidth,=
 it
> starts accumulating virtual time.  The more it has been serviced whil=
e
> backlogged, the more virtual time it accumulates.
> When HFSC looks at the various backlogged queues, how does it determi=
ne
> which one to service? Look again at the above diagram.  Each queue wi=
ll
> have its current virtual time and the virtual time that it will have
> after it sends its next packet.  HFSC will choose the next packet whi=
ch
> will have the lowest virtual time.  Let's make this more understandab=
le
> with some real illustrations.  Let's say we have two backlogged queue=
s
> with identical ls service curves and each has a full sized Ethernet
> packet pending.  Queue A has accumulated virtual time of 1000ms and
> Queue B has accumulated virtual time of 999ms.  Let's say that sendin=
g
> the full sized Ethernet packet will take 2ms.  The virtual time after
> Queue A sends its packet would be 1002 whereas Queue B would be 1001m=
s
> so HFSC sends Queue B's packet.  Now Queue B has VT (virtual time) of
> 1001ms and the next packet would bring it to 1003ms.  Queue A has VT =
of
> 1000ms and sending the next packet would bring it to 1002ms.  HFSC
> chooses the packet which will result in the lowest VT thus it sends t=
he
> packet in Queue A.  See how it tries to keep the virtual times equal =
and
> thus produces fairness.
> Now let's alter the scenario.  Let's keep the virtual time the same,
> 1000ms for Queue A and 999ms for Queue B but Queue A is handling smal=
l
> packets which only take 0.5ms to send.  Queue A has one of these pack=
ets
> ready to send while Queue B has one of its full sized packets to send=
=2E
> VT for Queue A after sending its packet would be 1000.5ms and for Que=
ue
> B would be 1001ms so, even though Queue A has already received more
> service, it is services again because its final virtual time would be
> smaller.
> More importantly, let's go back to the idea that both Queue A and Que=
ue
> B use full sized packets but this time the ls service curves are not
> equal.  Let's say the ls service curve rate for Queue A is 5120kbits =
and
> for Queue B is 1024kbits.  Thus, a packet that would take Queue B 2ms=
 to
> transmit would take Queue A 0.4ms to transmit.  Both queues are
> continually backlogged so they always have packets to send.  HFSC tak=
es
> a look and calculates the next VT for Queue A as 1000.4 and Queue B a=
s
> 1001 so it sends Queue A.  It calculates again and A is 1000.8 and B
> 1001 so it sends A again.  The next calculation of VT puts A at 1001.=
2
> and B at 1001 so it sends B.  The next calculation puts A at 1001.2 a=
nd
> B at 1003 so A is sent.  Then 1001.6 versus 1003, then 1002 vs. 1003,
> then 1002.4 vs. 1003, then 1002.8 vs. 1003, then 1003.2 vs. 1003.  Ca=
n
> you see how the virtual time calculation is allocating service to Que=
ue
> A at a 5:1 ratio with Queue B - just the fairness we requested via th=
e
> ls service curves.
> So, in summary, virtual time used to produce fairness when distributi=
ng
> available excess bandwidth to backlogged queues in the ratio of the l=
s
> service curves.  It does this by trying to keep virtual times for all
> peers in the hierarchy equal and it does this by always choosing the
> packet to send which will result in the smallest virtual time.
> Fit time
> Fit time is pretty simple to understand.  Recall that we said the ls
> service curve was bounded by the ul service curve, i.e., even if a qu=
eue
> should get say 10 Mbps according to link sharing, if the ul (Upper
> Limit) service curve says we can use 8 Mpbs maximum, we are only goin=
g
> to get 8 Mbps.  Fit time takes into account the ul service curve.
> In effect, fit time looks at what the clock time would be to send the
> packet based upon the ul service curve rate, i.e., what the time woul=
d
> be to send the pending packet at the maximum transmission rate.  If t=
hat
> time is later than the current clock time, the packet will not be sen=
t
> not matter what virtual time says.  If the current clock time is late=
r
> than fit time, i.e., we would not have exceeded out bandwidth
> limitation, then the decision is made based upon virtual time.
> As a reminder, this is all for traffic over and above the guaranteed
> rate, i.e., the rt service curve rate.  Packets are always sent to
> preserve the rt service curve rate as long as it is physically possib=
le
> regardless of fit time or virtual time.  This is the same as saying t=
hat
> the rt service curve always wins or, to phrase it yet another way, to
> meet the HFSC design criterion that, if there is a conflict between l=
ink
> sharing and guaranteed bandwidth, choose guaranteed bandwidth.
> Eligible time
> The rt service curve uses two timers: eligible time and deadline time=
=2E
> Recall, we used referred to eligible and deadline time toward the
> beginning of this discussion when observed how HFSC provides decouple=
d
> guarantees for both bandwidth and latency.  Like fit time, eligible t=
ime
> is relative to clock time.  In other words, HFSC calculates what the
> clock time would be to send the queued packet at the guaranteed rate,
> i.e., the rt service curve rate.  If that time is later than the curr=
ent
> clock time, that packet's time has not come yet and it cannot be sent
> based upon its real time guarantee.  I do believe it can be sent base=
d
> upon virtual time assuming that fit time allows it.  After all, that =
is
> what link sharing is about - being able to exceed the guaranteed
> bandwidth if there is extra bandwidth available.  On the other hand, =
if
> current clock time is later than eligible time, then this packet had
> better get moving because it is potentially running behind schedule.
> So, eligible time is just as then name implies; it is the time the
> packet becomes eligible for sending based upon the real-time service
> curve, i.e., the guaranteed bandwidth/latency.
> An important point to understand the difference between eligible time
> and deadline time is that eligible time is measured from the beginnin=
g
> or head of the packet, i.e., is HFSC ready to begin sending this pack=
et.
> But what happens when more than one queue has packets whose eligible
> time has come? That's where deadline time comes into play.
> Deadline time
> Deadline time is closely related to eligible time and is likewise
> measured against clock time.  However, deadline time is measured agai=
nst
> the end or tail of the packet, i.e., by when must we have finished
> sending this packet at the specified bandwidth in order to meet our
> packet delivery guarantees for bandwidth and latency.  Once again,
> http://www.sonycsl.co.jp/~kjc/software/TIPS.txt has an excellent ASCI=
I
> graphic for illustrating the relationship between eligible time measu=
red
> at the beginning of the packet and deadline time measured from the en=
d:
>                     bytes
>                          |                   /
>                          |                  /service curve
>                          |                 /
>            next   -->+   +----------------+
>            packet    |   |               /|
>            length    |   |              / |
>                      |   |             /  |
>       cumulative --> +   +------------+   |
>            bytes         |           /|   |
>            already       |          / |   |
>            sent          |         /  |   |
>                                   /   |   |
>                                       |   |
>                                       |   |
>                               --------+---+--------------> time
>                                 eligible  deadline
>                                 time
>
> This time, the slope is the rt service curve.  The way in which HFSC
> chooses from among several different queues all with packets whose
> eligible time is greater than current clock time is almost identical =
to
> the way it chooses among backlogged queues with virtual time, viz., i=
t
> chooses the packet with the lowest deadline time.  Remember that the
> steeper the curve, the greater the bandwidth and the shorter the
> distance between eligible time and deadline time for the same sized
> packet.
> Let's walk through a real example.  We have Queue A with VoIP traffic=
 -
> small, 222 byte packets and an rt service curve bandwidth such that i=
t
> takes 0.2ms to send its packets; that equates to roughly 8.88 Mbps ((=
222
> * 8)bits/0.0002s).  Let's also assume that we have so much VoIP traff=
ic
> that the queue is filled so we always have a VoIP packet asking to be
> dequeued.  Queue B is sending FTP with large packets and an rt servic=
e
> curve rate such that each packet takes 2ms to send; this equates to
> 6.056 Mbps ((1514 * 8)bits/0.002s).  Queue B is also completely full.
> Let's assume that the maximum bandwidth available is the sum of the
> guaranteed bandwidths, viz., 14.936 Mbps.  This will allow us to
> calculated the progress of clock time, i.e., how long it actually tak=
es
> to send each packet.  Also remember that each packet has a 4 byte CRC=
,
> and 8 byte preamble, and a 12 byte interframe gap time at least in
> traditional Ethernet.  Thus to transmit a packet in Queue A, we reall=
y
> need to transmit 246 bytes and, to transmit one in Queue B, we need t=
o
> transmit 1538 bytes.  Thus, the elapsed time to send a Queue A packet=
 is
> (246 * 8)bits / 14,936,000(b/s) =3D 0.132ms and the time to transmit =
a
> Queue B packet is (1538 * 8)bits / 14,936,000(b/s) =3D 0.824ms.  Sorr=
y for
> all the math but this is what is inside the black box (and a very
> simplified version!).
> Let's assume that clock time (CT - the actual time) is 1000ms (not
> realistic but it makes the explanation easier!).  The next packet que=
ued
> in Queue A has an ET (eligible time) of 1000ms and the next packet in
> Queue B has an ET of 999ms, i.e., both are eligible to be sent.  A le=
ss
> sophisticated traffic shaping algorithm would send the FTP packet fir=
st.
> However, HFSC calculates the deadline time (DT) for the packet in Que=
ue
> A at 1000.2 (1000 + 0.2) and the deadline time for the packet in Queu=
e B
> at 1001ms (999 + 2) so it sends A instead since it has the smaller DT=
=2E
> 0.132ms has elapsed in real time so CT is now 1000.132.  The
> eligible/deadline times (ET/DT) for A and B respectively are
> 1000.2/1000.4 and 999/1001.  Notice that A is no longer eligible to s=
end
> because its ET > CT so B is serviced.  0.824ms has elapsed to send B'=
s
> packet so CT is now 1000.956.  ET/DT for A is still 1000.2/1000.4 but=
 B
> has changed to 1001/1003.  B just misses being eligible to send but A=
 is
> eligible so A is sent.  Elapsed time is 0.132, CT is now 1001.088, ET=
/DT
> for A is 1000.4/1000.6.  Both A and B are eligible at the same time
> again as both their ETs <=3D CT.  A's DT is less than B's DT so A is
> serviced.
> In fact, A will send 11 packets.  Let's see the result after A sends =
11
> packets.  Elapsed time is 11* 0.132 =3D 1.452ms so clock time is 1002=
=2E54.
> A's ET/DT have incremented by 11 * 0.2 so they are 1002.6/1002.8.  B'=
s
> ET/DT have remained at 1001/1003.  A is no longer eligible so the fac=
t
> that its DT is less than B's DT is irrelevant.  B is serviced.
> Pulling it all together
> To this point, almost all of our discussion have involved rt service
> curves based solely upon rate and we have been using some fairly larg=
e
> circuits to illustrate.  What happens when our bandwidth really is
> constrained such as a T1 circuit or the upload bandwidth of an
> asymmetric DSL or cable connection and we need to balance time sensit=
ive
> traffic with bulk traffic? This is where di-linear curves save the da=
y.
> The best illustration I have found is from the SIGCOM97 paper on HFSC=
:
>
> The results might not be obvious at first.  The packets arriving, e.g=
=2E,
> coming from the internal network and heading toward the constricted T=
1
> circuit  (well, in this specific example, it is a 10 Mbps circuit) ar=
e
> shown in the second level of graphics from the top.  The resulting
> output of those packets is shown in the very bottom set of graphics.
> The illustrations on the left show a mono-linear curve, i.e., just ba=
sed
> upon bandwidth.  The video and FTP packets are flooding in, are being
> lined up and scheduled for dequeueing based upon the bandwidth only.
> Thus, the initial video packet sits in queue behind the FTP packets a=
s
> there is no need to rush to meet its bandwidth requirements.  Here is
> how the authors describe what is happening:
> "To illustrate the advantage of decoupling delay and bandwidth
> allocation with non-linear service curves, consider the example in
> Figure 2, where a video and a FTP session share a 10 Mbps link . . . =
=2E
> Let the video source sends 30 8KB frames per second, which correspond=
s
> to a required bandwidth of 2 Mbps. The remaining 8 Mbps is reserved b=
y a
> continuously backlogged FTP session. For simplicity, let all packets =
be
> of size 8 KB. Thus, it takes roughly 6.5 ms to transmit a packet."
> "As can be seen, the deadlines of the video packets occur every 33 ms=
,
> while the deadlines of the FTP packets occur every 8.2 ms. This resul=
ts
> in a delay of approximately 26 ms for a video packet."
> Let's work through the math to make that more understandable.  HFSC i=
s
> committed to deliver 2 Mbps to video and each packet is 8KB long.  Th=
us,
> HFSC's commitment to deliver that packet is within (8000 * 8)bits /
> 2,000,000(b/s) =3D 32ms.  I'm not quite sure why I come up with 32 an=
d
> they say 33 but we'll use 33.  In other words, to meet the deadline
> based solely upon the rate, the bandwidth part of the rt service curv=
e,
> the packet needs to be finished dequeueing at 33ms.  Since it only ta=
kes
> 6.5ms to send the packet, HFSC can sit on the packet it received for =
33
> - 6.5 =3D 26.5ms if it needs to in order to meet the guarantees for o=
ther
> traffic.  This adds unnecessary latency to the video stream.
> In the second scenario, we introduce an initial, elevated bandwidth
> guarantee for the first 10ms.  The bandwidth for the first 10ms is no=
w
> 6.6 Mbps instead of 2 Mbps.  We do the math again and HFSC's commitme=
nt
> to video to maintain 6.6 Mbps is to finish dequeueing the packet with=
in
> (8000 * 8)bits / 6,600,000(b/s) =3D 10ms.  Since it takes 6.5 ms to s=
end
> the packet, HFSC can sit on the packet for no more than 10 - 6.5 =3D =
3.5
> ms.  Quite a difference!
> I assume for simplicity's sake, the graphic leaves out an important
> point.  The rt service curve either fully or partially resets when th=
e
> queue has been drained.  Fully or partially depends on how much time =
has
> elapsed since the last service rendered and the new service requested
> when the queue becomes active again.  Thanks for Michal Soltys on the
> netdev kernel mail list for clarifying this for me.
> Without this reset, the first part of the service curve (the m1 porti=
on
> if you recall the earlier discussion about how service curves can be
> defined) would not have much practical value because once traffic
> activates the queue, only the first packet or first few packets would=
 be
> guaranteed the latency of the first, accelerated part of the curve.
> Everything else would use the second part of the curve (the m2 portio=
n -
> we'll use the terms m1 and m2 for the rest of the discussion).
> So let's re-examine the above example in more detail.  The video pack=
et
> arrives, uses the m1 curve, is jumped ahead of the FTP packets becaus=
e
> of the low latency guarantee of the m1 curve, is dequeued, and now th=
e
> queue is empty for 33.33ms (remember the video is playing at 30 frame=
s
> per second, well, 32.69ms when you account for transmission time on a
> 100 Mbps circuit) which allows the curve to reset.  The next video
> packet comes in and it is treated according to m1 and not m2 because =
we
> have reset the curve.  Thus, each video packet is jumped in front of =
any
> queued FTP packets.
> We can even multiplex several video streams.  As long as the queue is
> allowed to go idle long enough, each of those streams will be treated
> with very low latency and jumped in front of the FTP packets, i.e.,
> until we have so many video streams that the queue starts to backlog.
> Then they will use the m2 curve.
> This is not a bad thing; it is a good thing and allows us a new
> perspective on the m1 and m2 curves.  Hopefully, we have allocated
> enough bandwidth in our m2 curve to properly service our video or Voi=
P
> or whatever we are pushing through this queue.  Thus, even if we are =
not
> receiving the accelerated treatment, we are still experiencing
> sufficient service.  If our queue is badly backlogged and overflowing=
,
> then we have a different problem and need more raw bandwidth!
> In this way, we can think of the m2 curve, the second level of servic=
e
> in a concave service curve (remember a concave service curve is where=
 we
> start out with a higher bandwidth and then change to a lower bandwidt=
h),
> as a circuit breaker preventing overload.  In other words, we are say=
ing
> to this prioritized traffic that we will deliver it with a lower than
> normal latency (and thus higher short term bandwidth) while we can bu=
t,
> if it becomes too much (as determined by the system administrator who
> defined the HFSC qdisc), we will drop it down to a more sustainable r=
ate
> that will not exceed the physical capabilities of the circuit.  This
> assumes we have designed our traffic shaping so that the sum of all t=
he
> m2 portions of all the rt service curves do not exceed the capabiliti=
es
> of the circuit.
> Another way of saying this with familiar terminology is that we can
> burst at the m1 rate as long as the queue doesn't backlog but, when i=
t
> does, we drop to our sustainable rate.  Thus, concave rt service curv=
es
> are very well suited to periodic traffic, i.e., traffic which sends
> packets on a recurring interval with space in between like VoIP or
> video.  It may be less effective on burstable traffic such as the
> example of using it to accelerate the delivery of text on a web site
> unless the traffic is low enough that the queue has a chance to drain
> regularly.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
