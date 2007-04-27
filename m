From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [ofa-general] Re: IPoIB forwarding
Date: Fri, 27 Apr 2007 13:32:51 -0700
Message-ID: <46325DF3.2050203@hp.com>
References: <6.1.2.0.2.20070423160212.12db6400@mail.llnl.gov>	<20070425124652.GG1624@mellanox.co.il>	<6.1.2.0.2.20070426083410.1389d9e0@mail.llnl.gov>	<20070426161409.GF15540@mellanox.co.il>	<6.1.2.0.2.20070426095112.138e9a68@mail.llnl.gov>	<20070426180618.GJ15540@mellanox.co.il>
	<6.1.2.0.2.20070427115435.13ea5ec0@mail.llnl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@dev.mellanox.co.il>,
	general@lists.openfabrics.org
To: Bryan Lawver <lawver1@llnl.gov>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <6.1.2.0.2.20070427115435.13ea5ec0@mail.llnl.gov>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Bryan Lawver wrote:
> Your right about the ipoib module not combining packets (I believed you 
> without checking) but I did never the less.  The ipoib_start_xmit 
> routine is definitely handed a "double packet"  which means that the IP 
> NIC driver or the kernel is combining two packets into a single super 
> jumbo packet.  This issue is irrespective of the IP MTU setting because 
> I have set all interfaces to 9000k yet  ipoib accepts and forwards this 
> 17964 packet to the next IB node and onto the TCP stack where it is 
> never acknowledged.  This may not have come up in prior testing because 
> I am using some of the fastest IP NICs which have no trouble keeping up 
> with or exceeding the bandwidth of the IB side.  This issue arises 
> exactly every 8 packets...(ring buffer overrun??)
> 
> I will be at Sonoma for the next few days as many on this list will be.


Some NICs (esp 10G) support large receive offload - they coalesce TCP segments 
from the wire/fiber into larger ones they pass up the stack.  Perhaps that is 
happening here?

I'm going to go out a bit on a limb, cross the streams, and include netdev, 
because I suspect that if a system is acting as an IP router, one doesn't want 
large receive offload enabled.  That may need some discussion in netdev - it may 
then require some changes to default settings or some documentation 
enhancements.  That or I'll learn that the stack is already dealing with the 
issue...

rick jones

> bryan
> 
> 
> 
> At 11:06 AM 4/26/2007, Michael S. Tsirkin wrote:
> 
>> > Quoting Bryan Lawver <lawver1@llnl.gov>:
>> > Subject: Re: IPoIB forwarding
>> >
>> > Here's a tcpdump of the same sequence.  The TCP MSS is 8960 and it 
>> appears
>> > that two payloads are queued at ipoib which combines them into a single
>> > 17920 payload with assumingly correct IP header (40) and IB header
>> > (4).  The application or TCP stack does not acknowledge this double 
>> packet
>> > ie. it does not ACK until each of the 8960 packets are resent
>> > individually.  Being an IB newbie, I am guessing this combining is
>> > allowable but may violate TCP protocol.
>>
>> IPoIB does nothing like this - it's just a network device so
>> it sends all packets out as is.
>>
>> -- 
>> MST
> 
> 
> _______________________________________________
> general mailing list
> general@lists.openfabrics.org
> http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general
> 
> To unsubscribe, please visit 
> http://openib.org/mailman/listinfo/openib-general
