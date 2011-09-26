From: Ben Greear <greearb@candelatech.com>
Subject: Re: intel 82599 multi-port performance
Date: Mon, 26 Sep 2011 10:57:52 -0700
Message-ID: <4E80BD20.2040301@candelatech.com>
References: <4E805359.2080600@gmail.com> <4E808A41.8040902@genband.com>
	<4E809D59.10103@gmail.com> <4E80A2AB.2040206@intel.com>
	<4E80AAF8.1000806@genband.com> <4E80B551.1040609@candelatech.com>
	<4E80BA91.2040803@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>,
	"J.Hwan.Kim" <j.hwan.kim99@gmail.com>, frog1120@gmail.com
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4E80BA91.2040803@genband.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 09/26/2011 10:46 AM, Chris Friesen wrote:
> On 09/26/2011 11:24 AM, Ben Greear wrote:
>> On 09/26/2011 09:40 AM, Chris Friesen wrote:
>
>>> To any of the Intel guys out there...any ideas? Can an 82599 on an 8x
>>> bus handle max line rate with minimum size packets?
>>
>> Rick Jones sent me an interesting link related to this. Short answer seems
>> to be 'yes', but it seems not for any normal off-the-shelf software stack.
>>
>> > This: http://comments.gmane.org/gmane.linux.network/203602 should
>> lead you to some slide.
>
> Interesting. I wonder if Intel's DPDK will be the only way to handle those sorts of packet rates.

Pktgen is probably still the fastest general code that I know of,
but we had some interesting results setting the TCP_MAXSEGS to
88, which creates around 150 byte packets, and let the NICs offload
chop up large TCP writes into small packets on the wire.

Using core-I7 980x CPU, and dual-port 82599, we could send
around 4Mpps and receive around 2Mpps between two machines.
We were using a single port on each NIC/machine for this test.  Connection
was a bit asymmetric, seems one side would over-power the other...so if
we twiddled a bit, we could get around 3Mpps in each direction.

Our user-space app has some over-head as well, but we can send
at least 5Gbps full duplex on two ports using normal sized frames, so I
think the bottleneck in this case is the TCP offload in the NIC.

Still, pretty impressive for stateful TCP packets per second :)

Top-of-tree netperf just learned to do the TCP_MAXSEG trick as well,
so it might be fun to play with that.  It probably has less overhead
than our tool, so might run even faster.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


------------------------------------------------------------------------------
All the data continuously generated in your IT infrastructure contains a
definitive record of customers, application performance, security
threats, fraudulent activity and more. Splunk takes this data and makes
sense of it. Business sense. IT sense. Common sense.
http://p.sf.net/sfu/splunk-d2dcopy1
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
