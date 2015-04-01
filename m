From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] bridge: relax BR_GROUPFWD_RESTRICTED to
 forward LLDP frames
Date: Wed, 1 Apr 2015 15:50:01 -0700
Message-ID: <20150401155001.40d58a37@urahara>
References: <1427063051-1236-1-git-send-email-bernhard.thaler@wvnet.at>
	<1427666762-23683-1-git-send-email-bernhard.thaler@wvnet.at>
	<20150401.152845.1522826021699870645.davem@davemloft.net>
	<551C5D06.2050407@wvnet.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>
To: Bernhard Thaler <bernhard.thaler@wvnet.at>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <551C5D06.2050407@wvnet.at>
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

On Wed, 01 Apr 2015 23:03:02 +0200
Bernhard Thaler <bernhard.thaler@wvnet.at> wrote:

> 
> 
> On 01.04.2015 21:28, David Miller wrote:
> > From: Bernhard Thaler <bernhard.thaler@wvnet.at>
> > Date: Mon, 30 Mar 2015 00:06:02 +0200
> > 
> >> BR_GROUPFWD_RESTRICTED bitmask restricts users from setting values to
> >> /sys/class/net/brX/bridge/group_fwd_mask that allow forwarding of
> >> some IEEE 802.1D Table 7-10 Reserved addresses:
> >>
> >> 	(MAC Control) 802.3		01-80-C2-00-00-01
> >> 	(Link Aggregation) 802.3	01-80-C2-00-00-02
> >> 	802.1AB LLDP			01-80-C2-00-00-0E
> >>
> >> Relax BR_GROUPFWD_RESTRICTED to at least forward LLDP frames and document
> >> group_fwd_mask.
> >>
> >> e.g.
> >>    echo 16384 > /sys/class/net/brX/bridge/group_fwd_mask
> >> allows to forward LLDP frames.
> >>
> >> Tested on a simple bridge setup with two interfaces. Setting group_fwd_mask
> >> as described above lets crafted LLDP frames traverse bridge.
> >>
> >> Signed-off-by: Bernhard Thaler <bernhard.thaler@wvnet.at>
> > 
> > I don't understand why we want to allow forwarding LLDP by default, it
> > specifically is the case that an 802.1D bridge is only compliant if it
> > does not forward LLDP packets.
> > 
> > We've blocked forwarding of LLDP by default for such a long time, so I
> > argue against this change from the perspective of users expecting LLDP
> > to be not forwarded by the Linux bridge by default.
> > 
> BR_GROUPFWD_DEFAULT is unchanged. By default none of the IEEE 802.1D
> Table 7-10 Reserved addresses are forwarded by the bridge (except for
> STP BPDUs if STP is turned off on the bridge device).
> For users not changing /sys/class/net/brX/bridge/group_fwd_mask there
> should be no difference to current default bridge behavior.
> 
> Only if users deliberately set group_fwd_mask to a value such as 16384
> the bridge will start to forward LLDP frames. Current
> BR_GROUPFWD_RESTRICTED value though restricts users from setting such
> values to group_fwd_mask.

If user wants to violate standards, it is probably best to let them.
Unfortunately, there is no way to put a nastygram message up in response.
There is no network version of TAINT on the kernel.

I have heard that there are people that do weird things with bridges and Openstack
that want this.
