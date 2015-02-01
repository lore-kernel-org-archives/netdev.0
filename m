From: dpreed@reed.com
Subject: Re: Fwd: Throughput regression with `tcp: refine
	TSO autosizing`
Date: Sun, 1 Feb 2015 09:43:34 -0500 (EST)
Message-ID: <1422801814.796219699@apps.rackspace.com>
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
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2703217968577306848=="
Cc: dstanley@arubanetworks.com, Andrew McGregor <andrewmcgr@gmail.com>,
	Stig Thormodsrud <stig@ubnt.com>, netdev@vger.kernel.org,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Jesper Dangaard Brouer <jbrouer@redhat.com>,
	cerowrt-devel@lists.bufferbloat.net, Matt Mathis <mattmathis@google.com>,
	Derrick Pallas <pallas@meraki.com>,
	Mahesh Paolini-Subramanya <mahesh@dieswaytoofast.com>,
	Kathy Giori <kgiori@qca.qualcomm.com>, Tim Shepard <shep@alum.mit.edu>,
	Avery Pennarun <apenwarr@google.com>
To: "Jonathan Morton" <chromatix99@gmail.com>
Return-path: <cerowrt-devel-bounces@lists.bufferbloat.net>
In-Reply-To: <CAJq5cE3ETbpEtecFHmhgHQveNRUhVfrzjTOygHm-TRCTwHNyKA@mail.gmail.com>
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

--===============2703217968577306848==
Content-Type: multipart/alternative;boundary="----=_20150201094334000000_85961"

------=_20150201094334000000_85961
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

=0AJust to clarify, managing queueing in a single access point WiFi network=
 is only a small part of the problem of fixing the rapidly degrading perfor=
mance of WiFi based systems.  Similarly, mesh routing is only a small part =
of the problem with the scalability of cooperative meshes based on the WiFi=
 MAC.=0A =0ASo I don't disagree with work on queue management (which is not=
 good in any commercial product).=0A =0ABut Dave T has done some great talk=
s on "fixing WiFi" that don't have to do with queueing very much at all.=0A=
 =0AFor example, rate selection for various packets is terrible.  When you =
have nearly 1000:1 ratios of transmission rates and codes that are not back=
ward compatible, there's a huge opportunity for improvement.  Similarly, ch=
oice of frequency bandwidth and center frequency at each station offers hug=
e opportunities for practical scalability of systems.  Also, as we noted ea=
rlier, "handoff" from one next hop to another is a huge problem with perfor=
mance in practical deployments (a factor of 10x at least, just in that).=0A=
 =0APropagation information is not used at all when 802.11 systems share a =
channel, even in single AP deployments, yet all stations can measure propag=
ation quite accurately in their hardware.=0A =0AFinally, Listen-before-talk=
 is highly wasteful for two reasons: 1) any random radio noise from other s=
ources unnecessarily degrades communications (and in the 5.8 MHz band, the =
rule about "radar avoidance" requires treating very low level noise as a "s=
ignal to shut the net down by law", but there is a loophole if you can tell=
 that it's not actually "radar" (the technique requires two or more station=
s to measure the same noise event, and if the power is significantly differ=
ent - more than a few dB - then it can't possibly be due to a distant trans=
mitter, and therefore can be ignored). 2) the transmitter cannot tell when =
the intended receiver will be perfectly able to decode the signal without i=
nterference with the station it hears (this second point is actually proven=
 in theory in a paper by Jon Peha that argued against trivial "etiquettes" =
as a mechanism for sharing among uncooperative and non-interoperable statio=
ns).=0A =0ADave T has discussed more, as have I in other venues.=0A =0AThe =
reason no one is making progress on any of these particular issues is that =
there is no coordination at the "systems level" around creating rising tide=
s that lift all boats in the WiFi-ish space.  It's all about ripping the co=
mpetition by creating stuff that can sell better than the other guys' stuff=
, and avoiding cooperation at all costs.=0A =0AI agree that, to the extent =
that managing queues in a single box or a single operating system doesn't r=
equire cooperation, it's much easier to get such things into the market.  T=
hat's why CeroWRT has been as effective as it has been.  But has Microsoft =
done anything at all about it?   Do the better ECN signals that can arise f=
rom good queue management get used by the TCP endpoints, or for that matter=
 UDP-based protocol endpoints?=0A =0ABut the big wins in making WiFi better=
 are going begging.  As WiFi becomes more closed, as it will as the major I=
nternet Access Providers and Gadget builders (Google, Apple) start excludin=
g innovators in wireless from the market by closed, proprietary solutions, =
the problem WILL get worse.  You won't be able to fix those problems at all=
.  If you have a solution you will have to convince the oligopoly to even b=
other trying it.=0A =0ASo, let me reiterate.  The problem is not just "gett=
ing Minstrel adopted", though I have nothing against that as a subgoal.  Th=
e problem is to find good systems-level answers, and to find a strategy to =
deliver those answers to a WiFi ecology that spans the planet, and where th=
e marketing value-story focuses on things one can measure between two stati=
ons in a Faraday cage, and never on any systems-level issues.=0A =0A =0AI p=
ersonally think that things like promoting semi-closed, essentially proprie=
tary ESSID-based bridged distribution systems as "good ideas" are counterpr=
oductive to this goal.  But that's perhaps too radical for this crowd.  It =
reminds me of Cisco's attempt to create a proprietary Internet technology w=
ith IOS, which fortunately was not the success Cisco hoped for, or Juniper =
would not have existed. Maybe IOS would have been a fine standard, but it w=
ould have killed the evolution of the Internet as we know it.=0A=0AOn Sunda=
y, February 1, 2015 5:47am, "Jonathan Morton" <chromatix99@gmail.com> said:=
=0A=0A=0A=0ASince this is going to be a big job, it's worth prioritising pa=
rts of it appropriately.=0AMinstrel is probably already the single best fea=
ture of the Linux Wi-Fi stack. AFAIK it still outperforms any other rate se=
lector we know about. So I don't consider improving it further to be a high=
 priority, although that trick of using it as a sneaky random packet loss i=
nducer is intriguing.=0AMuch more important and urgent is getting some form=
 of functioning SQM closer to the hardware, where the information is. I don=
't think we need to get super fancy here to do some real good, in the same =
way that PIE is a major improvement over drop-tail. I'd settle for a varian=
t of fq_codel that gets and uses information about whether the current pack=
et request might be aggregated with the previous packet provided, and adjus=
ts its choice of packet accordingly.=0AAt the same time, models would undou=
btedly be useful to help test and repeatably demonstrate the advantages of =
both simple and more sophisticated solutions. Ns3 allows laying out a reaso=
nably complex radio environment, which is great for this. To counter the pr=
evalence of one-station Faraday cage tests in the industry, the simulated e=
nvironments should represent realistic, challenging use cases:=0A1) the fam=
ily home, with half a dozen client devices competing with several interfere=
nce sources (Bluetooth, RC toys, microwave oven, etc). This is a relatively=
 easy environment, representing the expected environment for consumer equip=
ment.=0A2) the apartment block, with fewer clients per AP but lots of APs d=
istributed throughout a large building. Walls and floors may provide valuab=
le attenuation here - unless you're in Japan, where they can be notoriously=
 thin.=0A3) the railway carriage, consisting of eighty passengers in a 20x3=
 m space, and roughly the same number of client devices. The uplink is 3G b=
ased and has some inherent latency. Add some Bluetooth for flavour, stir ge=
ntly. This one is rather challenging, but there is scope to optimise AP ant=
enna placement, and to scale the test down slightly by reducing seat occupa=
ncy.=0A4) the jumbo jet, consisting of several hundred passengers crammed i=
n like sardines. The uplink has satellite latencies built in. Good luck.=0A=
5) the business hotel. Multiple APs will be needed to provide adequate cove=
rage for this environment, which should encompass the rooms as well as loun=
ge, conference and dining areas. Some visitors may bring their own APs, and=
 the system must be able to cope with this without seriously degrading perf=
ormance.=0A6) the trade conference. A large arena filled with thousands of =
people. Multiple APs required. Good luck.=0AI also feel that ultimately we'=
re going to have to get industry on board. Not just passively letting us pl=
ay around as with ath9k, but actively taking note of our findings and imple=
menting at least a few of our ideas themselves. Of course, tools, models an=
d real-world results are likely to make that easier.=0A- Jonathan Morton
------=_20150201094334000000_85961
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<font face=3D"tahoma" size=3D"2"><p style=3D"margin:0;padding:0;font-family=
: tahoma; font-size: 10pt; word-wrap: break-word;">Just to clarify, managin=
g queueing in a single access point WiFi network is only a small part of th=
e problem of fixing the rapidly degrading performance of WiFi based systems=
. &nbsp;Similarly, mesh routing is only a small part of the problem with th=
e scalability of cooperative meshes based on the WiFi MAC.</p>=0A<p style=
=3D"margin:0;padding:0;font-family: tahoma; font-size: 10pt; word-wrap: bre=
ak-word;">&nbsp;</p>=0A<p style=3D"margin:0;padding:0;font-family: tahoma; =
font-size: 10pt; word-wrap: break-word;">So I don't disagree with work on q=
ueue management (which is not good in any commercial product).</p>=0A<p sty=
le=3D"margin:0;padding:0;font-family: tahoma; font-size: 10pt; word-wrap: b=
reak-word;">&nbsp;</p>=0A<p style=3D"margin:0;padding:0;font-family: tahoma=
; font-size: 10pt; word-wrap: break-word;">But Dave T has done some great t=
alks on "fixing WiFi" that don't have to do with queueing very much at all.=
</p>=0A<p style=3D"margin:0;padding:0;font-family: tahoma; font-size: 10pt;=
 word-wrap: break-word;">&nbsp;</p>=0A<p style=3D"margin:0;padding:0;font-f=
amily: tahoma; font-size: 10pt; word-wrap: break-word;">For example, rate s=
election for various packets is terrible. &nbsp;When you have nearly 1000:1=
 ratios of transmission rates and codes that are not backward compatible, t=
here's a huge opportunity for improvement. &nbsp;Similarly, choice of frequ=
ency bandwidth and center frequency at each station offers huge opportuniti=
es for practical scalability of systems. &nbsp;Also, as we noted earlier, "=
handoff" from one next hop to another is a huge problem with performance in=
 practical deployments (a factor of 10x at least, just in that).</p>=0A<p s=
tyle=3D"margin:0;padding:0;font-family: tahoma; font-size: 10pt; word-wrap:=
 break-word;">&nbsp;</p>=0A<p style=3D"margin:0;padding:0;font-family: taho=
ma; font-size: 10pt; word-wrap: break-word;">Propagation information is not=
 used at all when 802.11 systems share a channel, even in single AP deploym=
ents, yet all stations can measure propagation quite accurately in their ha=
rdware.</p>=0A<p style=3D"margin:0;padding:0;font-family: tahoma; font-size=
: 10pt; word-wrap: break-word;">&nbsp;</p>=0A<p style=3D"margin:0;padding:0=
;font-family: tahoma; font-size: 10pt; word-wrap: break-word;">Finally, Lis=
ten-before-talk is highly wasteful for two reasons: 1) any random radio noi=
se from other sources unnecessarily degrades communications (and in the 5.8=
 MHz band, the rule about "radar avoidance" requires treating very low leve=
l noise as a "signal to shut the net down by law", but there is a loophole =
if you can tell that it's not actually "radar" (the technique requires two =
or more stations to measure the same noise event, and if the power is signi=
ficantly different - more than a few dB - then it can't possibly be due to =
a distant transmitter, and therefore can be ignored). 2) the transmitter ca=
nnot tell when the intended receiver will be perfectly able to decode the s=
ignal without interference with the station it hears (this second point is =
actually proven in theory in a paper by Jon Peha that argued against trivia=
l "etiquettes" as a mechanism for sharing among uncooperative and non-inter=
operable stations).</p>=0A<p style=3D"margin:0;padding:0;font-family: tahom=
a; font-size: 10pt; word-wrap: break-word;">&nbsp;</p>=0A<p style=3D"margin=
:0;padding:0;font-family: tahoma; font-size: 10pt; word-wrap: break-word;">=
Dave T has discussed more, as have I in other venues.</p>=0A<p style=3D"mar=
gin:0;padding:0;font-family: tahoma; font-size: 10pt; word-wrap: break-word=
;">&nbsp;</p>=0A<p style=3D"margin:0;padding:0;font-family: tahoma; font-si=
ze: 10pt; word-wrap: break-word;">The reason no one is making progress on a=
ny of these particular issues is that there is no coordination at the "syst=
ems level" around creating rising tides that lift all boats in the WiFi-ish=
 space. &nbsp;It's all about ripping the competition by creating stuff that=
 can sell better than the other guys' stuff, and avoiding cooperation at al=
l costs.</p>=0A<p style=3D"margin:0;padding:0;font-family: tahoma; font-siz=
e: 10pt; word-wrap: break-word;">&nbsp;</p>=0A<p style=3D"margin:0;padding:=
0;font-family: tahoma; font-size: 10pt; word-wrap: break-word;">I agree tha=
t, to the extent that managing queues in a single box or a single operating=
 system doesn't require cooperation, it's much easier to get such things in=
to the market. &nbsp;That's why CeroWRT has been as effective as it has bee=
n. &nbsp;But has Microsoft done anything at all about it? &nbsp; Do the bet=
ter ECN signals that can arise from good queue management get used by the T=
CP endpoints, or for that matter UDP-based protocol endpoints?</p>=0A<p sty=
le=3D"margin:0;padding:0;font-family: tahoma; font-size: 10pt; word-wrap: b=
reak-word;">&nbsp;</p>=0A<p style=3D"margin:0;padding:0;font-family: tahoma=
; font-size: 10pt; word-wrap: break-word;">But the big wins in making WiFi =
better are going begging. &nbsp;As WiFi becomes more closed, as it will as =
the major Internet Access Providers and Gadget builders (Google, Apple) sta=
rt excluding innovators in wireless from the market by closed, proprietary =
solutions, the problem WILL get worse. &nbsp;You won't be able to fix those=
 problems at all. &nbsp;If you have a solution you will have to convince th=
e oligopoly to even bother trying it.</p>=0A<p style=3D"margin:0;padding:0;=
font-family: tahoma; font-size: 10pt; word-wrap: break-word;">&nbsp;</p>=0A=
<p style=3D"margin:0;padding:0;font-family: tahoma; font-size: 10pt; word-w=
rap: break-word;">So, let me reiterate. &nbsp;The problem is not just "gett=
ing Minstrel adopted", though I have nothing against that as a subgoal. &nb=
sp;The problem is to find good systems-level answers, and to find a strateg=
y to deliver those answers to a WiFi ecology that spans the planet, and whe=
re the marketing value-story focuses on things one can measure between two =
stations in a Faraday cage, and never on any systems-level issues.</p>=0A<!=
--WM_COMPOSE_SIGNATURE_START--><!--WM_COMPOSE_SIGNATURE_END-->=0A<p style=
=3D"margin:0;padding:0;font-family: tahoma; font-size: 10pt; word-wrap: bre=
ak-word;">&nbsp;</p>=0A<p style=3D"margin:0;padding:0;font-family: tahoma; =
font-size: 10pt; word-wrap: break-word;">&nbsp;</p>=0A<p style=3D"margin:0;=
padding:0;font-family: tahoma; font-size: 10pt; word-wrap: break-word;">I p=
ersonally think that things like promoting semi-closed, essentially proprie=
tary ESSID-based bridged distribution systems as "good ideas" are counterpr=
oductive to this goal. &nbsp;But that's perhaps too radical for this crowd.=
 &nbsp;It reminds me of Cisco's attempt to create a proprietary Internet te=
chnology with IOS, which fortunately was not the success Cisco hoped for, o=
r Juniper would not have existed. Maybe IOS would have been a fine standard=
, but it would have killed the evolution of the Internet as we know it.</p>=
=0A<p style=3D"margin:0;padding:0;font-family: tahoma; font-size: 10pt; wor=
d-wrap: break-word;"><br />On Sunday, February 1, 2015 5:47am, "Jonathan Mo=
rton" &lt;chromatix99@gmail.com&gt; said:<br /><br /></p>=0A<div id=3D"Safe=
Styles1422800133">=0A<p style=3D"margin:0;padding:0;font-family: tahoma; fo=
nt-size: 10pt; word-wrap: break-word;" dir=3D"ltr">Since this is going to b=
e a big job, it's worth prioritising parts of it appropriately.</p>=0A<p st=
yle=3D"margin:0;padding:0;font-family: tahoma; font-size: 10pt; word-wrap: =
break-word;" dir=3D"ltr">Minstrel is probably already the single best featu=
re of the Linux Wi-Fi stack. AFAIK it still outperforms any other rate sele=
ctor we know about. So I don't consider improving it further to be a high p=
riority, although that trick of using it as a sneaky random packet loss ind=
ucer is intriguing.</p>=0A<p style=3D"margin:0;padding:0;font-family: tahom=
a; font-size: 10pt; word-wrap: break-word;" dir=3D"ltr">Much more important=
 and urgent is getting some form of functioning SQM closer to the hardware,=
 where the information is. I don't think we need to get super fancy here to=
 do some real good, in the same way that PIE is a major improvement over dr=
op-tail. I'd settle for a variant of fq_codel that gets and uses informatio=
n about whether the current packet request might be aggregated with the pre=
vious packet provided, and adjusts its choice of packet accordingly.</p>=0A=
<p style=3D"margin:0;padding:0;font-family: tahoma; font-size: 10pt; word-w=
rap: break-word;" dir=3D"ltr">At the same time, models would undoubtedly be=
 useful to help test and repeatably demonstrate the advantages of both simp=
le and more sophisticated solutions. Ns3 allows laying out a reasonably com=
plex radio environment, which is great for this. To counter the prevalence =
of one-station Faraday cage tests in the industry, the simulated environmen=
ts should represent realistic, challenging use cases:</p>=0A<p style=3D"mar=
gin:0;padding:0;font-family: tahoma; font-size: 10pt; word-wrap: break-word=
;" dir=3D"ltr">1) the family home, with half a dozen client devices competi=
ng with several interference sources (Bluetooth, RC toys, microwave oven, e=
tc). This is a relatively easy environment, representing the expected envir=
onment for consumer equipment.</p>=0A<p style=3D"margin:0;padding:0;font-fa=
mily: tahoma; font-size: 10pt; word-wrap: break-word;" dir=3D"ltr">2) the a=
partment block, with fewer clients per AP but lots of APs distributed throu=
ghout a large building. Walls and floors may provide valuable attenuation h=
ere - unless you're in Japan, where they can be notoriously thin.</p>=0A<p =
style=3D"margin:0;padding:0;font-family: tahoma; font-size: 10pt; word-wrap=
: break-word;" dir=3D"ltr">3) the railway carriage, consisting of eighty pa=
ssengers in a 20x3 m space, and roughly the same number of client devices. =
The uplink is 3G based and has some inherent latency. Add some Bluetooth fo=
r flavour, stir gently. This one is rather challenging, but there is scope =
to optimise AP antenna placement, and to scale the test down slightly by re=
ducing seat occupancy.</p>=0A<p style=3D"margin:0;padding:0;font-family: ta=
homa; font-size: 10pt; word-wrap: break-word;" dir=3D"ltr">4) the jumbo jet=
, consisting of several hundred passengers crammed in like sardines. The up=
link has satellite latencies built in. Good luck.</p>=0A<p style=3D"margin:=
0;padding:0;font-family: tahoma; font-size: 10pt; word-wrap: break-word;" d=
ir=3D"ltr">5) the business hotel. Multiple APs will be needed to provide ad=
equate coverage for this environment, which should encompass the rooms as w=
ell as lounge, conference and dining areas. Some visitors may bring their o=
wn APs, and the system must be able to cope with this without seriously deg=
rading performance.</p>=0A<p style=3D"margin:0;padding:0;font-family: tahom=
a; font-size: 10pt; word-wrap: break-word;" dir=3D"ltr">6) the trade confer=
ence. A large arena filled with thousands of people. Multiple APs required.=
 Good luck.</p>=0A<p style=3D"margin:0;padding:0;font-family: tahoma; font-=
size: 10pt; word-wrap: break-word;" dir=3D"ltr">I also feel that ultimately=
 we're going to have to get industry on board. Not just passively letting u=
s play around as with ath9k, but actively taking note of our findings and i=
mplementing at least a few of our ideas themselves. Of course, tools, model=
s and real-world results are likely to make that easier.</p>=0A<p style=3D"=
margin:0;padding:0;font-family: tahoma; font-size: 10pt; word-wrap: break-w=
ord;" dir=3D"ltr">- Jonathan Morton</p>=0A</div></font>
------=_20150201094334000000_85961--


--===============2703217968577306848==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============2703217968577306848==--
