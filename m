From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 2/2] [e1000 VLAN] Disable vlan hw accel
	when promiscuous mode
Date: Tue, 13 Nov 2007 00:15:16 +0100
Message-ID: <20071112231516.GA15227@1wt.eu>
References: <47388B9F.7050308@trash.net>
	<20071112.143342.10809862.davem@davemloft.net>
	<4738D70C.4060404@nortel.com>
	<20071112.145716.06352378.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, djohnson+linux-kernel@sw.starentnetworks.com,
	linux-kernel@vger.kernel.org, joonwpark81@gmail.com,
	cfriesen@nortel.com, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20071112.145716.06352378.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, Nov 12, 2007 at 02:57:16PM -0800, David Miller wrote:
> From: "Chris Friesen" <cfriesen@nortel.com>
> Date: Mon, 12 Nov 2007 16:43:24 -0600
> 
> > David Miller wrote:
> > 
> > > When you select VLAN, you by definition are asking for non-VLAN
> > > traffic to be elided.  It is like plugging the ethernet cable
> > > into one switch or another.
> > 
> > For max functionality it seems like the raw eth device should show 
> > everything on the wire in promiscuous mode.
> > 
> > If we want to sniff only the traffic for a specific vlan, we can sniff 
> > the vlan device.
> 
> VLAN settings are a filter of sorts, much like plugging into
> one switch or another filters traffic physically.
> 
> If you don't want that filter, turn the VLAN settings off.

I don't really agree with that view. Having spent a lot of time with
tcpdump on production systems, I can say that sometimes you'd like to
be aware that one of your VLANs is wrong and you'd simply like to
sniff the wire to guess the correct tag. And on production, you simply
cannot remove other VLANs, otherwise you disrupt the service.

Basically, what generally happens is that the guy responsible for the
switch tells you "it's OK now", but for you it isn't and you cannot
access the switch.

If the solution is to disable VLAN hardware acceleration, I agree that
it is very risky to do that without the user being aware of it. But at
least we should be able to do this by any means (eg: ethtool) without
disabling what's running.

And since you made the parallel with a switch, when you receive tagged
traffic on a switch port, you generally can mirror that port to another
one and catch all VLANs at once. A new feature that is starting to appear
is the ability to mirror tagged traffic to a VLAN on another port (which
means you get a double 802.1q tag). This is useful for inter-site links
between data-centers for instance.

Regards,
Willy


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
