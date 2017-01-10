From: Felix Fietkau <nbd@nbd.name>
Subject: Re: [PATCH net-next] bridge: multicast to unicast
Date: Tue, 10 Jan 2017 18:23:29 +0100
Message-ID: <99c01ce6-d80c-790e-25e5-157be31aee9a@nbd.name>
References: <20170102193214.31723-1-linus.luessing@c0d3.blue>
	<1483706872.4089.8.camel@sipsolutions.net>
	<8836daaa-9638-4502-d079-fd428595f822@nbd.name>
	<1483710841.12677.1.camel@sipsolutions.net>
	<22fad045-57c6-7789-d19f-f47bd0faf441@fami-braun.de>
	<20170107145516.GE3134@otheros>
	<1483949336.17582.3.camel@sipsolutions.net>
	<6f5ec9f1-800a-2bc4-2f41-9d803343bb22@fami-braun.de>
	<20170109212345.GA5513@otheros> <20170109133032.221f8669@xeon-e3>
	<20170110041816.GJ5513@otheros>
	<1484045763.1014.0.camel@sipsolutions.net>
	<CAA93jw6+P8um7TxDCYgJ=SJfFzpskboR7njgudMb3NR4JZ34BA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"M. Braun" <michael-dev@fami-braun.de>,
	"David S . Miller" <davem@davemloft.net>
To: Dave Taht <dave.taht@gmail.com>, Johannes Berg <johannes@sipsolutions.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CAA93jw6+P8um7TxDCYgJ=SJfFzpskboR7njgudMb3NR4JZ34BA@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 2017-01-10 18:17, Dave Taht wrote:
> In the case of wifi I have 3 issues with this line of thought.
> 
> multicast in wifi has generally supposed to be unreliable. This makes
> it reliable. reliability comes at a cost -
> 
> multicast is typically set at a fixed low rate today. unicast is
> retried at different rates until it succeeds - for every station
> listening. If one station is already at the lowest rate, the total
> cost of the transmit increases, rather than decreases.
> 
> unicast gets block acks until it succeeds. Again, more delay.
> 
> I think there is something like 31 soft-retries in the ath9k driver....
If I remember correctly, hardware retries are counted here as well.

> what happens to diffserv markings here? for unicast CS1 goes into the
> BE queue, CS6, the VO queue. Do we go from one flat queue for all of
> multicast to punching it through one of the hardware queues based on
> the diffserv mark now with this patch?
> 
> I would like it if there was a way to preserve the unreliability
> (which multiple mesh protocols depend on), send stuff with QoSNoack,
> etc - or dynamically choose (based on the rates of the stations)
> between conventional multicast and unicast.
> 
> Or - better, IMHO, keep sending multicast as is but pick the best of
> the rates available to all the listening stations for it.
The advantage of the multicast-to-unicast conversion goes beyond simply
selecting a better rate - aggregation matters a lot as well, and that is
simply incompatible with normal multicast.

Some multicast streams use lots of small-ish packets, the airtime impact
of those is vastly reduced, even if the transmission has to be
duplicated for a few stations.

- Felix
