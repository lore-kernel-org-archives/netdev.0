From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next] bridge: multicast to unicast
Date: Mon, 09 Jan 2017 13:15:59 +0100
Message-ID: <1483964159.17582.34.camel@sipsolutions.net>
References: <20170102193214.31723-1-linus.luessing@c0d3.blue>
	<1483706872.4089.8.camel@sipsolutions.net>
	<8836daaa-9638-4502-d079-fd428595f822@nbd.name>
	<1483710841.12677.1.camel@sipsolutions.net>
	<22fad045-57c6-7789-d19f-f47bd0faf441@fami-braun.de>
	<20170107145516.GE3134@otheros>
	<1483949336.17582.3.camel@sipsolutions.net>
	<6f5ec9f1-800a-2bc4-2f41-9d803343bb22@fami-braun.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>, Felix Fietkau <nbd@nbd.name>
To: "M. Braun" <michael-dev@fami-braun.de>, Linus =?ISO-8859-1?Q?L=FCssing?=
	<linus.luessing@c0d3.blue>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <6f5ec9f1-800a-2bc4-2f41-9d803343bb22@fami-braun.de>
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

On Mon, 2017-01-09 at 12:44 +0100, M. Braun wrote:
> Am 09.01.2017 um 09:08 schrieb Johannes Berg:
> > Does it make sense to implement the two in separate layers though?
> > 
> > Clearly, this part needs to be implemented in the bridge layer due
> > to
> > the snooping knowledge, but the code is very similar to what
> > mac80211
> > has now.
> 
> Does the bridge always know about all stations connected?
> 
> That is bridge fdb entries (need to) expire so the bridge might
> "forget" a still-connected station not sending but only consuming
> broadcast traffic.
> 
> E.g. there is a television broadcast station here that receives a
> video stream (via wifi, udp packets) and then airs it (dvb-t) but (on
> its own) would not send any data packet on wifi (static ip, etc.).

Ok, that I don't know. Somehow if you address a unicast packet there
the bridge has to make a decision - so it really should know? Would it
query the port somehow to see if the device is behind it, if getting a
packet for a station it forgot about?

> An other reason to implement this in mac80211 initially was that
> mac80211 could encapsulate broacast/multicast ethernet packtes in
> unicast A-MSDU packets in a way, so that the receiver would still see
> process ethernet packets (after conversion) but have unicast wifi
> frames. This cannot be done in bridge easily but one might want to
> add this later to mac80211.

Yes, DMG would have to be done in mac80211, but that's a lot clearer
case too since it requires negotiation functionality etc.

johannes
