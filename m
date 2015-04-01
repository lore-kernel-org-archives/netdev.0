From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: relax BR_GROUPFWD_RESTRICTED to
 forward LLDP frames
Date: Wed, 01 Apr 2015 15:28:45 -0400 (EDT)
Message-ID: <20150401.152845.1522826021699870645.davem@davemloft.net>
References: <1427063051-1236-1-git-send-email-bernhard.thaler@wvnet.at>
	<1427666762-23683-1-git-send-email-bernhard.thaler@wvnet.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: bernhard.thaler@wvnet.at
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1427666762-23683-1-git-send-email-bernhard.thaler@wvnet.at>
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

From: Bernhard Thaler <bernhard.thaler@wvnet.at>
Date: Mon, 30 Mar 2015 00:06:02 +0200

> BR_GROUPFWD_RESTRICTED bitmask restricts users from setting values to
> /sys/class/net/brX/bridge/group_fwd_mask that allow forwarding of
> some IEEE 802.1D Table 7-10 Reserved addresses:
> 
> 	(MAC Control) 802.3		01-80-C2-00-00-01
> 	(Link Aggregation) 802.3	01-80-C2-00-00-02
> 	802.1AB LLDP			01-80-C2-00-00-0E
> 
> Relax BR_GROUPFWD_RESTRICTED to at least forward LLDP frames and document
> group_fwd_mask.
> 
> e.g.
>    echo 16384 > /sys/class/net/brX/bridge/group_fwd_mask
> allows to forward LLDP frames.
> 
> Tested on a simple bridge setup with two interfaces. Setting group_fwd_mask
> as described above lets crafted LLDP frames traverse bridge.
> 
> Signed-off-by: Bernhard Thaler <bernhard.thaler@wvnet.at>

I don't understand why we want to allow forwarding LLDP by default, it
specifically is the case that an 802.1D bridge is only compliant if it
does not forward LLDP packets.

We've blocked forwarding of LLDP by default for such a long time, so I
argue against this change from the perspective of users expecting LLDP
to be not forwarded by the Linux bridge by default.
