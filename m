From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] remove casts in drivers/net/arm/
Date: Tue, 2 Mar 2004 11:02:37 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040302110237.0f580736.rddunlap@osdl.org>
References: <20040229142516.3d218ed0.rddunlap@osdl.org>
	<20040229143436.4bb884ee.rddunlap@osdl.org>
	<20040302121042.A9931@flint.arm.linux.org.uk>
	<4044D86C.70709@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rmk@arm.linux.org.uk, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4044D86C.70709@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 02 Mar 2004 13:54:36 -0500 Jeff Garzik wrote:

| Russell King wrote:
| > On Sun, Feb 29, 2004 at 02:34:36PM -0800, Randy.Dunlap wrote:
| > 
| >> drivers/net/arm/am79c961a.c |   18 +++++++++---------
| >> drivers/net/arm/ether1.c    |   18 +++++++++---------
| >> drivers/net/arm/ether3.c    |   18 +++++++++---------
| >> drivers/net/arm/etherh.c    |    4 ++--
| >> 4 files changed, 29 insertions(+), 29 deletions(-)
| > 
| > 
| > I think we should really consider using netdev_priv() in all these places
| > so the compiler knows that 'dev' and 'priv' are related.
| 
| 
| Good point.

I respectfully disagree, but if the maintainter won't merge
them as is, so be it.

I have trouble understanding why this:
	return (char *)dev + ((sizeof(struct net_device) + 31) & ~31);
is better than using a structure->field, i.e.,
	dev->priv

Can one of you enlighten me?
Using dev->priv shows that 'dev' and 'priv' are related.

--
~Randy
