From: Jonathan Morton <chromatix99@gmail.com>
Subject: Re: Fwd: Throughput regression with `tcp: refine
	TSO autosizing`
Date: Sun, 1 Feb 2015 12:47:23 +0200
Message-ID: <CAJq5cE3ETbpEtecFHmhgHQveNRUhVfrzjTOygHm-TRCTwHNyKA@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1192999118683223606=="
Cc: dstanley@arubanetworks.com, Andrew McGregor <andrewmcgr@gmail.com>,
	Stig Thormodsrud <stig@ubnt.com>, netdev@vger.kernel.org,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Jesper Dangaard Brouer <jbrouer@redhat.com>,
	cerowrt-devel@lists.bufferbloat.net, Matt Mathis <mattmathis@google.com>,
	Derrick Pallas <pallas@meraki.com>,
	Mahesh Paolini-Subramanya <mahesh@dieswaytoofast.com>,
	Kathy Giori <kgiori@qca.qualcomm.com>, Tim Shepard <shep@alum.mit.edu>,
	Avery Pennarun <apenwarr@google.com>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <cerowrt-devel-bounces@lists.bufferbloat.net>
In-Reply-To: <CAA93jw7=oTex0Mp-0ThvuDRUnfR0N8tzdOQ8DD7QYWphp1b=4w@mail.gmail.com>
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

--===============1192999118683223606==
Content-Type: multipart/alternative; boundary=001a11335bfc143769050e049085

--001a11335bfc143769050e049085
Content-Type: text/plain; charset=UTF-8

Since this is going to be a big job, it's worth prioritising parts of it
appropriately.

Minstrel is probably already the single best feature of the Linux Wi-Fi
stack. AFAIK it still outperforms any other rate selector we know about. So
I don't consider improving it further to be a high priority, although that
trick of using it as a sneaky random packet loss inducer is intriguing.

Much more important and urgent is getting some form of functioning SQM
closer to the hardware, where the information is. I don't think we need to
get super fancy here to do some real good, in the same way that PIE is a
major improvement over drop-tail. I'd settle for a variant of fq_codel that
gets and uses information about whether the current packet request might be
aggregated with the previous packet provided, and adjusts its choice of
packet accordingly.

At the same time, models would undoubtedly be useful to help test and
repeatably demonstrate the advantages of both simple and more sophisticated
solutions. Ns3 allows laying out a reasonably complex radio environment,
which is great for this. To counter the prevalence of one-station Faraday
cage tests in the industry, the simulated environments should represent
realistic, challenging use cases:

1) the family home, with half a dozen client devices competing with several
interference sources (Bluetooth, RC toys, microwave oven, etc). This is a
relatively easy environment, representing the expected environment for
consumer equipment.

2) the apartment block, with fewer clients per AP but lots of APs
distributed throughout a large building. Walls and floors may provide
valuable attenuation here - unless you're in Japan, where they can be
notoriously thin.

3) the railway carriage, consisting of eighty passengers in a 20x3 m space,
and roughly the same number of client devices. The uplink is 3G based and
has some inherent latency. Add some Bluetooth for flavour, stir gently.
This one is rather challenging, but there is scope to optimise AP antenna
placement, and to scale the test down slightly by reducing seat occupancy.

4) the jumbo jet, consisting of several hundred passengers crammed in like
sardines. The uplink has satellite latencies built in. Good luck.

5) the business hotel. Multiple APs will be needed to provide adequate
coverage for this environment, which should encompass the rooms as well as
lounge, conference and dining areas. Some visitors may bring their own APs,
and the system must be able to cope with this without seriously degrading
performance.

6) the trade conference. A large arena filled with thousands of people.
Multiple APs required. Good luck.

I also feel that ultimately we're going to have to get industry on board.
Not just passively letting us play around as with ath9k, but actively
taking note of our findings and implementing at least a few of our ideas
themselves. Of course, tools, models and real-world results are likely to
make that easier.

- Jonathan Morton

--001a11335bfc143769050e049085
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr">Since this is going to be a big job, it&#39;s worth prioriti=
sing parts of it appropriately.</p>
<p dir=3D"ltr">Minstrel is probably already the single best feature of the =
Linux Wi-Fi stack. AFAIK it still outperforms any other rate selector we kn=
ow about. So I don&#39;t consider improving it further to be a high priorit=
y, although that trick of using it as a sneaky random packet loss inducer i=
s intriguing.</p>
<p dir=3D"ltr">Much more important and urgent is getting some form of funct=
ioning SQM closer to the hardware, where the information is. I don&#39;t th=
ink we need to get super fancy here to do some real good, in the same way t=
hat PIE is a major improvement over drop-tail. I&#39;d settle for a variant=
 of fq_codel that gets and uses information about whether the current packe=
t request might be aggregated with the previous packet provided, and adjust=
s its choice of packet accordingly.</p>
<p dir=3D"ltr">At the same time, models would undoubtedly be useful to help=
 test and repeatably demonstrate the advantages of both simple and more sop=
histicated solutions. Ns3 allows laying out a reasonably complex radio envi=
ronment, which is great for this. To counter the prevalence of one-station =
Faraday cage tests in the industry, the simulated environments should repre=
sent realistic, challenging use cases:</p>
<p dir=3D"ltr">1) the family home, with half a dozen client devices competi=
ng with several interference sources (Bluetooth, RC toys, microwave oven, e=
tc). This is a relatively easy environment, representing the expected envir=
onment for consumer equipment.</p>
<p dir=3D"ltr">2) the apartment block, with fewer clients per AP but lots o=
f APs distributed throughout a large building. Walls and floors may provide=
 valuable attenuation here - unless you&#39;re in Japan, where they can be =
notoriously thin.</p>
<p dir=3D"ltr">3) the railway carriage, consisting of eighty passengers in =
a 20x3 m space, and roughly the same number of client devices. The uplink i=
s 3G based and has some inherent latency. Add some Bluetooth for flavour, s=
tir gently. This one is rather challenging, but there is scope to optimise =
AP antenna placement, and to scale the test down slightly by reducing seat =
occupancy.</p>
<p dir=3D"ltr">4) the jumbo jet, consisting of several hundred passengers c=
rammed in like sardines. The uplink has satellite latencies built in. Good =
luck.</p>
<p dir=3D"ltr">5) the business hotel. Multiple APs will be needed to provid=
e adequate coverage for this environment, which should encompass the rooms =
as well as lounge, conference and dining areas. Some visitors may bring the=
ir own APs, and the system must be able to cope with this without seriously=
 degrading performance.</p>
<p dir=3D"ltr">6) the trade conference. A large arena filled with thousands=
 of people. Multiple APs required. Good luck.</p>
<p dir=3D"ltr">I also feel that ultimately we&#39;re going to have to get i=
ndustry on board. Not just passively letting us play around as with ath9k, =
but actively taking note of our findings and implementing at least a few of=
 our ideas themselves. Of course, tools, models and real-world results are =
likely to make that easier.</p>
<p dir=3D"ltr"> - Jonathan Morton<br>
</p>

--001a11335bfc143769050e049085--

--===============1192999118683223606==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1192999118683223606==--
