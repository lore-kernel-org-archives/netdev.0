From: Andrew McGregor <andrewmcgr@gmail.com>
Subject: Re: Fwd: Throughput regression with `tcp: refine
	TSO autosizing`
Date: Mon, 2 Feb 2015 10:34:10 +1100
Message-ID: <CAA_e5Z5PfimZeC5cqSk_xFpKOBeZ74htLeEdwtKieAYWJaEX+A@mail.gmail.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
	<1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
	<54CB5D08.2070906@broadcom.com>
	<1422623975.21689.77.camel@edumazet-glaptop2.roam.corp.google.com>
	<54CB8B69.1070807@broadcom.com>
	<CAA93jw5fqhz0Hiw74L2GXgtZ9JsMg+NtYydKxKzGDrvQcZn4hA@mail.gmail.com>
	<CAA93jw7b0E9jjQYXrEPzjLLC9j8xNC0TFYXpWVtgFameJaNBdw@mail.gmail.com>
	<1422741065.199624134@apps.rackspace.com>
	<CAPp0ZBb2nkA6Y0s=W0kw=zvyn0wi0NMBRsBCw_xcD61ScOmgQg@mail.gmail.com>
	<CAA_e5Z46Bu+zZZFzf_ejzA35Gw3g1_OG85yv6yd7MpbwZcE-nw@mail.gmail.com>
	<CAA93jw7=oTex0Mp-0ThvuDRUnfR0N8tzdOQ8DD7QYWphp1b=4w@mail.gmail.com>
	<CAJq5cE3ETbpEtecFHmhgHQveNRUhVfrzjTOygHm-TRCTwHNyKA@mail.gmail.com>
	<1422801814.796219699@apps.rackspace.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1953081499210863844=="
Cc: dstanley@arubanetworks.com, Stig Thormodsrud <stig@ubnt.com>,
	netdev@vger.kernel.org, linux-wireless <linux-wireless@vger.kernel.org>,
	Jesper Dangaard Brouer <jbrouer@redhat.com>,
	cerowrt-devel@lists.bufferbloat.net, Matt Mathis <mattmathis@google.com>,
	Derrick Pallas <pallas@meraki.com>, Kathy Giori <kgiori@qca.qualcomm.com>,
	Mahesh Paolini-Subramanya <mahesh@dieswaytoofast.com>,
	Jonathan Morton <chromatix99@gmail.com>, Tim Shepard <shep@alum.mit.edu>,
	Avery Pennarun <apenwarr@google.com>
To: dpreed@reed.com
Return-path: <cerowrt-devel-bounces@lists.bufferbloat.net>
In-Reply-To: <1422801814.796219699@apps.rackspace.com>
List-Unsubscribe: <https://lists.bufferbloat.net/options/cerowrt-devel>,
	<mailto:cerowrt-devel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/cerowrt-devel>
List-Post: <mailto:cerowrt-devel@lists.bufferbloat.net>
List-Help: <mailto:cerowrt-devel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/cerowrt-devel>,
	<mailto:cerowrt-devel-request@lists.bufferbloat.net?subject=subscribe>
Sender: cerowrt-devel-bounces@lists.bufferbloat.net
Errors-To: cerowrt-devel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

--===============1953081499210863844==
Content-Type: multipart/alternative; boundary=001a113a5fb04f657b050e0f46d0

--001a113a5fb04f657b050e0f46d0
Content-Type: text/plain; charset=UTF-8

So far as I'm concerned, Minstrel is as widely adopted as we could want; it
could go further, but it doesn't need any help with that.  It could be
better, however, and that's a fairly straightforward change.  One of the
problems with rate selection is that the standard itself has a bit to say
on what rates to use for what packets, and what it says is braindead.  So
if you want to be standards compliant you are also leaving quite a bit of
potential performance on the table.

I missed one item in my list of potential improvements: the most braindead
thing 802.11 has to say about rates is that broadcast and multicast packets
should be sent at 'the lowest basic rate in the current supported rate
set', which is really wasteful.  There are a couple of ways of dealing with
this: one, ignore the standard and pick the rate that is most likely to get
the frame to as many neighbours as possible (by a scan of the Minstrel
tables).  Or two, fan it out as unicast, which might well take less airtime
(due to aggregation) as well as being much more likely to be delivered,
since you get ACKs and retries by doing that.

As for the industry... sure, there are those forces, but then again there's
a non-trivial amount of influence in this audience.

On Mon, Feb 2, 2015 at 1:43 AM, <dpreed@reed.com> wrote:

> Just to clarify, managing queueing in a single access point WiFi network
> is only a small part of the problem of fixing the rapidly degrading
> performance of WiFi based systems.  Similarly, mesh routing is only a small
> part of the problem with the scalability of cooperative meshes based on the
> WiFi MAC.
>
>
>
> So I don't disagree with work on queue management (which is not good in
> any commercial product).
>
>
>
> But Dave T has done some great talks on "fixing WiFi" that don't have to
> do with queueing very much at all.
>
>
>
> For example, rate selection for various packets is terrible.  When you
> have nearly 1000:1 ratios of transmission rates and codes that are not
> backward compatible, there's a huge opportunity for improvement.
> Similarly, choice of frequency bandwidth and center frequency at each
> station offers huge opportunities for practical scalability of systems.
> Also, as we noted earlier, "handoff" from one next hop to another is a huge
> problem with performance in practical deployments (a factor of 10x at
> least, just in that).
>
>
>
> Propagation information is not used at all when 802.11 systems share a
> channel, even in single AP deployments, yet all stations can measure
> propagation quite accurately in their hardware.
>
>
>
> Finally, Listen-before-talk is highly wasteful for two reasons: 1) any
> random radio noise from other sources unnecessarily degrades communications
> (and in the 5.8 MHz band, the rule about "radar avoidance" requires
> treating very low level noise as a "signal to shut the net down by law",
> but there is a loophole if you can tell that it's not actually "radar" (the
> technique requires two or more stations to measure the same noise event,
> and if the power is significantly different - more than a few dB - then it
> can't possibly be due to a distant transmitter, and therefore can be
> ignored). 2) the transmitter cannot tell when the intended receiver will be
> perfectly able to decode the signal without interference with the station
> it hears (this second point is actually proven in theory in a paper by Jon
> Peha that argued against trivial "etiquettes" as a mechanism for sharing
> among uncooperative and non-interoperable stations).
>
>
>
> Dave T has discussed more, as have I in other venues.
>
>
>
> The reason no one is making progress on any of these particular issues is
> that there is no coordination at the "systems level" around creating rising
> tides that lift all boats in the WiFi-ish space.  It's all about ripping
> the competition by creating stuff that can sell better than the other guys'
> stuff, and avoiding cooperation at all costs.
>
>
>
> I agree that, to the extent that managing queues in a single box or a
> single operating system doesn't require cooperation, it's much easier to
> get such things into the market.  That's why CeroWRT has been as effective
> as it has been.  But has Microsoft done anything at all about it?   Do the
> better ECN signals that can arise from good queue management get used by
> the TCP endpoints, or for that matter UDP-based protocol endpoints?
>
>
>
> But the big wins in making WiFi better are going begging.  As WiFi becomes
> more closed, as it will as the major Internet Access Providers and Gadget
> builders (Google, Apple) start excluding innovators in wireless from the
> market by closed, proprietary solutions, the problem WILL get worse.  You
> won't be able to fix those problems at all.  If you have a solution you
> will have to convince the oligopoly to even bother trying it.
>
>
>
> So, let me reiterate.  The problem is not just "getting Minstrel adopted",
> though I have nothing against that as a subgoal.  The problem is to find
> good systems-level answers, and to find a strategy to deliver those answers
> to a WiFi ecology that spans the planet, and where the marketing
> value-story focuses on things one can measure between two stations in a
> Faraday cage, and never on any systems-level issues.
>
>
>
>
>
> I personally think that things like promoting semi-closed, essentially
> proprietary ESSID-based bridged distribution systems as "good ideas" are
> counterproductive to this goal.  But that's perhaps too radical for this
> crowd.  It reminds me of Cisco's attempt to create a proprietary Internet
> technology with IOS, which fortunately was not the success Cisco hoped for,
> or Juniper would not have existed. Maybe IOS would have been a fine
> standard, but it would have killed the evolution of the Internet as we know
> it.
>
>
> On Sunday, February 1, 2015 5:47am, "Jonathan Morton" <
> chromatix99@gmail.com> said:
>
>  Since this is going to be a big job, it's worth prioritising parts of it
> appropriately.
>
> Minstrel is probably already the single best feature of the Linux Wi-Fi
> stack. AFAIK it still outperforms any other rate selector we know about. So
> I don't consider improving it further to be a high priority, although that
> trick of using it as a sneaky random packet loss inducer is intriguing.
>
> Much more important and urgent is getting some form of functioning SQM
> closer to the hardware, where the information is. I don't think we need to
> get super fancy here to do some real good, in the same way that PIE is a
> major improvement over drop-tail. I'd settle for a variant of fq_codel that
> gets and uses information about whether the current packet request might be
> aggregated with the previous packet provided, and adjusts its choice of
> packet accordingly.
>
> At the same time, models would undoubtedly be useful to help test and
> repeatably demonstrate the advantages of both simple and more sophisticated
> solutions. Ns3 allows laying out a reasonably complex radio environment,
> which is great for this. To counter the prevalence of one-station Faraday
> cage tests in the industry, the simulated environments should represent
> realistic, challenging use cases:
>
> 1) the family home, with half a dozen client devices competing with
> several interference sources (Bluetooth, RC toys, microwave oven, etc).
> This is a relatively easy environment, representing the expected
> environment for consumer equipment.
>
> 2) the apartment block, with fewer clients per AP but lots of APs
> distributed throughout a large building. Walls and floors may provide
> valuable attenuation here - unless you're in Japan, where they can be
> notoriously thin.
>
> 3) the railway carriage, consisting of eighty passengers in a 20x3 m
> space, and roughly the same number of client devices. The uplink is 3G
> based and has some inherent latency. Add some Bluetooth for flavour, stir
> gently. This one is rather challenging, but there is scope to optimise AP
> antenna placement, and to scale the test down slightly by reducing seat
> occupancy.
>
> 4) the jumbo jet, consisting of several hundred passengers crammed in like
> sardines. The uplink has satellite latencies built in. Good luck.
>
> 5) the business hotel. Multiple APs will be needed to provide adequate
> coverage for this environment, which should encompass the rooms as well as
> lounge, conference and dining areas. Some visitors may bring their own APs,
> and the system must be able to cope with this without seriously degrading
> performance.
>
> 6) the trade conference. A large arena filled with thousands of people.
> Multiple APs required. Good luck.
>
> I also feel that ultimately we're going to have to get industry on board.
> Not just passively letting us play around as with ath9k, but actively
> taking note of our findings and implementing at least a few of our ideas
> themselves. Of course, tools, models and real-world results are likely to
> make that easier.
>
> - Jonathan Morton
>

--001a113a5fb04f657b050e0f46d0
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">So far as I&#39;m concerned, Minstrel is as widely adopted=
 as we could want; it could go further, but it doesn&#39;t need any help wi=
th that.=C2=A0 It could be better, however, and that&#39;s a fairly straigh=
tforward change.=C2=A0 One of the problems with rate selection is that the =
standard itself has a bit to say on what rates to use for what packets, and=
 what it says is braindead.=C2=A0 So if you want to be standards compliant =
you are also leaving quite a bit of potential performance on the table.<div=
><br></div><div>I missed one item in my list of potential improvements: the=
 most braindead thing 802.11 has to say about rates is that broadcast and m=
ulticast packets should be sent at &#39;the lowest basic rate in the curren=
t supported rate set&#39;, which is really wasteful.=C2=A0 There are a coup=
le of ways of dealing with this: one, ignore the standard and pick the rate=
 that is most likely to get the frame to as many neighbours as possible (by=
 a scan of the Minstrel tables).=C2=A0 Or two, fan it out as unicast, which=
 might well take less airtime (due to aggregation) as well as being much mo=
re likely to be delivered, since you get ACKs and retries by doing that.</d=
iv><div><br></div><div>As for the industry... sure, there are those forces,=
 but then again there&#39;s a non-trivial amount of influence in this audie=
nce.</div></div><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">O=
n Mon, Feb 2, 2015 at 1:43 AM,  <span dir=3D"ltr">&lt;<a href=3D"mailto:dpr=
eed@reed.com" target=3D"_blank">dpreed@reed.com</a>&gt;</span> wrote:<br><b=
lockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px =
#ccc solid;padding-left:1ex"><font face=3D"tahoma"><p style=3D"margin:0;pad=
ding:0;font-family:tahoma;font-size:10pt;word-wrap:break-word">Just to clar=
ify, managing queueing in a single access point WiFi network is only a smal=
l part of the problem of fixing the rapidly degrading performance of WiFi b=
ased systems.=C2=A0 Similarly, mesh routing is only a small part of the pro=
blem with the scalability of cooperative meshes based on the WiFi MAC.</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word">=C2=A0</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word">So I don&#39;t disagree with work on queue management (which is=
 not good in any commercial product).</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word">=C2=A0</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word">But Dave T has done some great talks on &quot;fixing WiFi&quot;=
 that don&#39;t have to do with queueing very much at all.</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word">=C2=A0</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word">For example, rate selection for various packets is terrible.=C2=
=A0 When you have nearly 1000:1 ratios of transmission rates and codes that=
 are not backward compatible, there&#39;s a huge opportunity for improvemen=
t.=C2=A0 Similarly, choice of frequency bandwidth and center frequency at e=
ach station offers huge opportunities for practical scalability of systems.=
=C2=A0 Also, as we noted earlier, &quot;handoff&quot; from one next hop to =
another is a huge problem with performance in practical deployments (a fact=
or of 10x at least, just in that).</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word">=C2=A0</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word">Propagation information is not used at all when 802.11 systems =
share a channel, even in single AP deployments, yet all stations can measur=
e propagation quite accurately in their hardware.</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word">=C2=A0</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word">Finally, Listen-before-talk is highly wasteful for two reasons:=
 1) any random radio noise from other sources unnecessarily degrades commun=
ications (and in the 5.8 MHz band, the rule about &quot;radar avoidance&quo=
t; requires treating very low level noise as a &quot;signal to shut the net=
 down by law&quot;, but there is a loophole if you can tell that it&#39;s n=
ot actually &quot;radar&quot; (the technique requires two or more stations =
to measure the same noise event, and if the power is significantly differen=
t - more than a few dB - then it can&#39;t possibly be due to a distant tra=
nsmitter, and therefore can be ignored). 2) the transmitter cannot tell whe=
n the intended receiver will be perfectly able to decode the signal without=
 interference with the station it hears (this second point is actually prov=
en in theory in a paper by Jon Peha that argued against trivial &quot;etiqu=
ettes&quot; as a mechanism for sharing among uncooperative and non-interope=
rable stations).</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word">=C2=A0</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word">Dave T has discussed more, as have I in other venues.</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word">=C2=A0</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word">The reason no one is making progress on any of these particular=
 issues is that there is no coordination at the &quot;systems level&quot; a=
round creating rising tides that lift all boats in the WiFi-ish space.=C2=
=A0 It&#39;s all about ripping the competition by creating stuff that can s=
ell better than the other guys&#39; stuff, and avoiding cooperation at all =
costs.</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word">=C2=A0</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word">I agree that, to the extent that managing queues in a single bo=
x or a single operating system doesn&#39;t require cooperation, it&#39;s mu=
ch easier to get such things into the market.=C2=A0 That&#39;s why CeroWRT =
has been as effective as it has been.=C2=A0 But has Microsoft done anything=
 at all about it? =C2=A0 Do the better ECN signals that can arise from good=
 queue management get used by the TCP endpoints, or for that matter UDP-bas=
ed protocol endpoints?</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word">=C2=A0</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word">But the big wins in making WiFi better are going begging.=C2=A0=
 As WiFi becomes more closed, as it will as the major Internet Access Provi=
ders and Gadget builders (Google, Apple) start excluding innovators in wire=
less from the market by closed, proprietary solutions, the problem WILL get=
 worse.=C2=A0 You won&#39;t be able to fix those problems at all.=C2=A0 If =
you have a solution you will have to convince the oligopoly to even bother =
trying it.</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word">=C2=A0</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word">So, let me reiterate.=C2=A0 The problem is not just &quot;getti=
ng Minstrel adopted&quot;, though I have nothing against that as a subgoal.=
=C2=A0 The problem is to find good systems-level answers, and to find a str=
ategy to deliver those answers to a WiFi ecology that spans the planet, and=
 where the marketing value-story focuses on things one can measure between =
two stations in a Faraday cage, and never on any systems-level issues.</p>

<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word">=C2=A0</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word">=C2=A0</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word">I personally think that things like promoting semi-closed, esse=
ntially proprietary ESSID-based bridged distribution systems as &quot;good =
ideas&quot; are counterproductive to this goal.=C2=A0 But that&#39;s perhap=
s too radical for this crowd.=C2=A0 It reminds me of Cisco&#39;s attempt to=
 create a proprietary Internet technology with IOS, which fortunately was n=
ot the success Cisco hoped for, or Juniper would not have existed. Maybe IO=
S would have been a fine standard, but it would have killed the evolution o=
f the Internet as we know it.</p><div><div class=3D"h5">
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word"><br>On Sunday, February 1, 2015 5:47am, &quot;Jonathan Morton&q=
uot; &lt;<a href=3D"mailto:chromatix99@gmail.com" target=3D"_blank">chromat=
ix99@gmail.com</a>&gt; said:<br><br></p>
<div>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word" dir=3D"ltr">Since this is going to be a big job, it&#39;s worth=
 prioritising parts of it appropriately.</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word" dir=3D"ltr">Minstrel is probably already the single best featur=
e of the Linux Wi-Fi stack. AFAIK it still outperforms any other rate selec=
tor we know about. So I don&#39;t consider improving it further to be a hig=
h priority, although that trick of using it as a sneaky random packet loss =
inducer is intriguing.</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word" dir=3D"ltr">Much more important and urgent is getting some form=
 of functioning SQM closer to the hardware, where the information is. I don=
&#39;t think we need to get super fancy here to do some real good, in the s=
ame way that PIE is a major improvement over drop-tail. I&#39;d settle for =
a variant of fq_codel that gets and uses information about whether the curr=
ent packet request might be aggregated with the previous packet provided, a=
nd adjusts its choice of packet accordingly.</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word" dir=3D"ltr">At the same time, models would undoubtedly be usefu=
l to help test and repeatably demonstrate the advantages of both simple and=
 more sophisticated solutions. Ns3 allows laying out a reasonably complex r=
adio environment, which is great for this. To counter the prevalence of one=
-station Faraday cage tests in the industry, the simulated environments sho=
uld represent realistic, challenging use cases:</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word" dir=3D"ltr">1) the family home, with half a dozen client device=
s competing with several interference sources (Bluetooth, RC toys, microwav=
e oven, etc). This is a relatively easy environment, representing the expec=
ted environment for consumer equipment.</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word" dir=3D"ltr">2) the apartment block, with fewer clients per AP b=
ut lots of APs distributed throughout a large building. Walls and floors ma=
y provide valuable attenuation here - unless you&#39;re in Japan, where the=
y can be notoriously thin.</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word" dir=3D"ltr">3) the railway carriage, consisting of eighty passe=
ngers in a 20x3 m space, and roughly the same number of client devices. The=
 uplink is 3G based and has some inherent latency. Add some Bluetooth for f=
lavour, stir gently. This one is rather challenging, but there is scope to =
optimise AP antenna placement, and to scale the test down slightly by reduc=
ing seat occupancy.</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word" dir=3D"ltr">4) the jumbo jet, consisting of several hundred pas=
sengers crammed in like sardines. The uplink has satellite latencies built =
in. Good luck.</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word" dir=3D"ltr">5) the business hotel. Multiple APs will be needed =
to provide adequate coverage for this environment, which should encompass t=
he rooms as well as lounge, conference and dining areas. Some visitors may =
bring their own APs, and the system must be able to cope with this without =
seriously degrading performance.</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word" dir=3D"ltr">6) the trade conference. A large arena filled with =
thousands of people. Multiple APs required. Good luck.</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word" dir=3D"ltr">I also feel that ultimately we&#39;re going to have=
 to get industry on board. Not just passively letting us play around as wit=
h ath9k, but actively taking note of our findings and implementing at least=
 a few of our ideas themselves. Of course, tools, models and real-world res=
ults are likely to make that easier.</p>
<p style=3D"margin:0;padding:0;font-family:tahoma;font-size:10pt;word-wrap:=
break-word" dir=3D"ltr">- Jonathan Morton</p>
</div></div></div></font></blockquote></div><br></div>

--001a113a5fb04f657b050e0f46d0--

--===============1953081499210863844==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1953081499210863844==--
