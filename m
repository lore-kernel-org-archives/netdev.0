From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next] bridge: multicast to unicast
Date: Fri, 06 Jan 2017 13:47:52 +0100
Message-ID: <1483706872.4089.8.camel@sipsolutions.net>
References: <20170102193214.31723-1-linus.luessing@c0d3.blue>
	(sfid-20170102_204412_831542_1DC6188A)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: bridge@lists.linux-foundation.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, Michael Braun <michael-dev@fami-braun.de>,
	"David S . Miller" <davem@davemloft.net>, Felix Fietkau <nbd@nbd.name>
To: Linus =?ISO-8859-1?Q?L=FCssing?= <linus.luessing@c0d3.blue>,
	netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170102193214.31723-1-linus.luessing@c0d3.blue>
	(sfid-20170102_204412_831542_1DC6188A)
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

On Mon, 2017-01-02 at 20:32 +0100, Linus Lüssing wrote:
> Implements an optional, per bridge port flag and feature to deliver
> multicast packets to any host on the according port via unicast
> individually. This is done by copying the packet per host and
> changing the multicast destination MAC to a unicast one accordingly.

How does this compare and/or relate to the multicast-to-unicast feature
we were going to add to the wifi stack, particularly mac80211? Do we
perhaps not need that feature at all, if bridging will have it?

I suppose that the feature there could apply also to locally generated
traffic when the AP interface isn't in a bridge, but I think I could
live with requiring the AP to be put into a bridge to achieve a similar
configuration?

Additionally, on an unrelated note, this seems to apply generically to
all kinds of frames, losing information by replacing the address.
Shouldn't it have similar limitations as the wifi stack feature has
then, like only applying to ARP, IPv4, IPv6 and not general protocols?

Also, it should probably come with the same caveat as we documented for
the wifi feature:

    Note that this may break certain expectations of the receiver,
    such as the ability to drop unicast IP packets received within
    multicast L2 frames, or the ability to not send ICMP destination
    unreachable messages for packets received in L2 multicast (which
    is required, but the receiver can't tell the difference if this
    new option is enabled.)


I'll hold off sending my tree in until we see that we really need both
features, or decide that we want the wifi feature *instead* of the
bridge feature.

johannes
