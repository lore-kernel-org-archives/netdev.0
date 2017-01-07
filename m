From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: Re: [PATCH net-next] bridge: multicast to unicast
Date: Sat, 7 Jan 2017 16:06:34 +0100
Message-ID: <20170107150634.GF3134@otheros>
References: <20170102193214.31723-1-linus.luessing@c0d3.blue>
	<20170106191356.43740a26@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>, Felix Fietkau <nbd@nbd.name>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20170106191356.43740a26@xeon-e3>
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

On Fri, Jan 06, 2017 at 07:13:56PM -0800, Stephen Hemminger wrote:
> On Mon,  2 Jan 2017 20:32:14 +0100
> Linus Lüssing <linus.luessing@c0d3.blue> wrote:
> 
> > This feature is intended for interface types which have a more reliable
> > and/or efficient way to deliver unicast packets than broadcast ones
> > (e.g. wifi).
> 
> 
> Why is this not done in MAC80211 rather than  bridge?

Because mac80211 does not have the IGMP/MLD snooping code as
the bridge has?

Reimplementing the snooping in mac80211 does not make sense
because of duplicating code. Moving the snooping code from the
bridge to mac80211 does not make sense either, because we want
multicast snooping, software based, (virtually) wired switches,
too.

The "best way" (TM) would probably be to migrate the IGMP/MLD
snooping from the bridge code to the net device code on the long
run to make such a database usable for any kind of device, without
needing this bridge hack.

But such a migration would also need a way more invasive patchset.

While Felix's idea might look a little "ugly" due it's hacky
nature, I think it is also quite beautiful thanks to it's
simplicity.
