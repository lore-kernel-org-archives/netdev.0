From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] Re: [PATCH 00/10] Implement batching skb API
Date: Sun, 22 Jul 2007 08:51:09 -0400
Message-ID: <1185108670.5192.122.camel@localhost>
References: <OF0F9581FE.472D94A6-ON65257320.001FC787-65257320.00238386@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, gaagaan@gmail.com, jeff@garzik.org,
	Robert.Olsson@data.slu.se, kumarkr@linux.ibm.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	mcarlson@broadcom.com, kaber@trash.net, netdev@vger.kernel.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	sri@us.ibm.com, davem@davemloft.net, herbert@gondor.apana.org.au
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <OF0F9581FE.472D94A6-ON65257320.001FC787-65257320.00238386@in.ibm.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

KK,

On Sun, 2007-22-07 at 11:57 +0530, Krishna Kumar2 wrote:

> Batching need not be useful for every hardware. 

My concern is there is no consistency in results. I see improvements on
something which you say dont. You see improvement in something that
Evgeniy doesnt etc. 
There are many knobs and we need in the minimal to find out how those
play.

> I don't quite agree with that approach, eg, if the blist is empty and the
> driver tells there is space for one packet, you will add one packet and
> the driver sends it out and the device is stopped (with potentially lot of
> skbs on dev->q). Then no packets are added till the queue is enabled, at
> which time a flood of skbs will be processed increasing latency and holding
> lock for a single longer duration. My approach will mitigate holding lock
> for longer times and instead send skbs to the device as long as we are
> within the limits.

Just as a side note _I do have this feature_ in the pktgen piece.
Infact, You can tell pktgen what that bound is as opposed to the hard
coding(look at the pktgen "batchl" parameter). I have not found it to be
useful experimentally; actually, i should say i could not "zone" on a
useful value by experimenting and it was better to turn it off.
I never tried adding it to the qdisc path - but this is something i
could try and as i said it may prove useful.

> Since E1000 doesn't seem to use the TX lock on RX (atleast I couldn't find
> it),
> I feel having prep will not help as no other cpu can execute the queue/xmit
> code anyway (E1000 is also a LLTX driver).

My experiments show it is useful (in a very visible way using pktgen)
for e1000 to have the prep() interface.

>  Other driver that hold tx lock could get improvement however.

So you do see the value then with non LLTX drivers, right? ;-> 
The value is also there in LLTX drivers even if in just formating a skb
ready for transmit. If this is not clear i could do a much longer
writeup on my thought evolution towards adding prep().

> I wonder if you tried enabling/disabling 'prep' on E1000 to see how the
> performance is affected. 

Absolutely. And regardless of whether its beneficial or not for e1000,
theres clear benefit in the tg3 for example.

> If it helps, I guess you could send me a patch to
> add that and I can also test it to see what the effect is. I didn't add it
> since IPoIB wouldn't be able to exploit it (unless someone is kind enough
> to show me how to).

Such core code should not just be focussed on IPOIB.

> I think the code I have is ready and stable, 

I am not sure how to intepret that - are you saying all-is-good and we
should just push your code in? It sounds disingenuous but i may have
misread you. 

cheers,
jamal
