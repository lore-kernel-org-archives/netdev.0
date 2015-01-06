From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/1] bridge: remove BR_GROUPFWD_RESTRICTED for
 arbitrary forwarding of reserved addresses
Date: Mon, 5 Jan 2015 22:10:34 -0800
Message-ID: <20150105221034.0f69d6fd@urahara>
References: <1420505776-26827-1-git-send-email-bernhard.thaler@wvnet.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net
To: Bernhard Thaler <bernhard.thaler@wvnet.at>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1420505776-26827-1-git-send-email-bernhard.thaler@wvnet.at>
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

On Tue,  6 Jan 2015 01:56:15 +0100
Bernhard Thaler <bernhard.thaler@wvnet.at> wrote:

> BR_GROUPFWD_RESTRICTED bitmask restricts users from setting values to
> /sys/class/net/brX/bridge/group_fwd_mask that allow forwarding of
> some IEEE 802.1D Table 7-10 Reserved addresses:
> 	(MAC Control) 802.3		01-80-C2-00-00-01
> 	(Link Aggregation) 802.3	01-80-C2-00-00-02
> 	802.1AB LLDP			01-80-C2-00-00-0E
> BR_GROUPFWD_RESTRICTED may have been set as an extra protection against
> forwarding these control frames as forwarding 802.1X PAE (01-80-C2-00-00-03)
> in 802.1X setups satisfies most common use-cases.
> Other situations, such as placing a software based bridge as a "TAP" between two
> devices may require to forward e.g. LLDP frames while debugging network problems
> or actively changing/filtering traffic with ebtables.
> 
> This patch allows to set e.g.:
> 	echo 65535 > /sys/class/net/brX/bridge/group_fwd_mask
> which sets no restrictions on the forwardable reserved addresses.
> 
> - the default value 0 will still comply with 802.1D and not forward any
>   reserved addresses
> - values such as 8 for forwarding 802.1X related frames will behave the
>   same way as with BR_GROUPFWD_RESTRICTED currently in place, so backward
>   compatibility to current scripts using group_fwd_masks shoudl be possible
> 
> Administrators and network engineers however will be able to arbitrarily
> forward any reserved addresses without BR_GROUPFWD_RESTRICTED. This will
> be non-standard compliant behavior, but forwarding of any reserved address
> right from the beginning is. Users should be aware of this anyway and
> know what/why they are doing when setting values such as 65535, 32768, 16384,
> 4, 2 for group_fwd_mask
> 
> This patch was tested on a bridge with two interfaces created with bridge-utils.
> 
> Signed-off-by: Bernhard Thaler <bernhard.thaler@wvnet.at>

I am ok with forwarding LLDP because some people need it.
But allowing forwarding STP or PAUSE frames is bad.

We don't let people do things that break networks. Other examples
already exist like set all 0 ethernet addresses, or the restrictions
on allowing net 127 in IP addresses.
