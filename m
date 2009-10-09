From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: behaviour question for igb on nehalem box
Date: Fri, 09 Oct 2009 16:31:59 -0600
Message-ID: <4ACFB9DF.9080909@nortel.com>
References: <4ACF8466.5030309@nortel.com>
	<alpine.WNT.2.00.0910091250440.5328@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-list <e1000-devel@lists.sourceforge.net>,
	Linux Network Development list <netdev@vger.kernel.org>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>, "Ronciak,
	John" <john.ronciak@intel.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.WNT.2.00.0910091250440.5328@jbrandeb-desk1.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 10/09/2009 02:22 PM, Brandeburg, Jesse wrote:
> On Fri, 9 Oct 2009, Chris Friesen wrote:
>> I've got some general questions around the expected behaviour of the
>> 82576 igb net device.  (On a dual quad-core Nehalem box, if it matters.)

> the hardware you have only supports 8 
> queues (rx and tx) and the driver is configured to only set up 4 max.

The datasheet for the 82576 says 16 tx queues and 16 rx queues.  Is that
a typo or do we have the economy version?

>> My second question is around how the rx queues are mapped to interrupts.
>>  According to /proc/interrupts there appears to be a 1:1 mapping between
>> queues and interrupts.  However, I've set up at test with a given amount
>> of traffic coming in to the device (from 4 different IP addresses and 4
>> ports).  Under this scenario, "ethtool -S" shows the number of packets
>> increasing for only rx queue 0, but I see the interrupt count going up
>> for two interrupts.
> 
> one transmit interrupt and one receive interrupt?

No, two rx interrupts.  (Can't remember if the tx interrupt was going up
as well or no...was only looking at rx.)

> RSS will spread the 
> receive work out in a flow based way, based on ip/xDP header.  Your test 
> as described should be using more than one flow (and therefore more than 
> one rx queue) unless you got caught out by the default arp_filter 
> behavior (check arp -an).

I was surprised as well since it didn't match what I expected.  What's
the story around the arp_filter?  I just logged onto the test box and
"arp -an" gives:

? (47.135.251.129) at 00:00:5E:00:01:08 [ether] on eth0

but I'm not sure that's worth anything since someone is running a test
and it's currently using all four rx queues and all four rx interrupt
counts are increasing.  I'll have to see if they changed anything.


> Hope this helps,

That's great, thanks.

Chris

------------------------------------------------------------------------------
Come build with us! The BlackBerry(R) Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9 - 12, 2009. Register now!
http://p.sf.net/sfu/devconference
