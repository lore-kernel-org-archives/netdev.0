From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC:] struct net_device_ops: Add function pointer to fill device
	specific ndisc information
Date: Mon, 21 Jan 2013 21:04:14 +0900
Message-ID: <50FD2EBE.9050608@linux-ipv6.org>
References: <50FC2EE4.3080705@gmail.com> <50FC3BB1.4070005@linux-ipv6.org>
	<50FC6068.3020302@gmail.com> <20130121090951.103c0680@stein>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev <netdev@vger.kernel.org>, linux1394-devel@lists.sourceforge.net,
	David Miller <davem@davemloft.net>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130121090951.103c0680@stein>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Stefan Richter wrote:
> On Jan 20 Stephan Gatzka wrote:
>> On 01/20/2013 07:47 PM, YOSHIFUJI Hideaki wrote:
>>
>>> My current position is to change "mac address" to
>>>
>>> struct fwnet_hwaddr {
>>> 	u8	guid[8];
>>> 	u8	max_rec;
>>> 	u8	sspd;
>>> 	u8	fifo[6];
>>> };
>>>
>>
>> That is something I'm not really convinced of. As Stefan Richter pointed 
>> out clearly, the fifo address might be different between IPv4 and IPv6 
>> communication.
> 
> If it is of any help, the initial implementation could assume that IPv4
> unicast_FIFO and IPv6 unicast_FIFO are the same.  RFC 3146 is silent on
> this topic (which means it can be one way or the other), but from an
> implementation point of view, using one FIFO offset for both seems quite
> natural.  Currently the only existing RFC 3146 implementation which is
> known to us is Mac OS X, and since your tests with OS X 10.6 went well,
> they obviously use one offset for both protocols.
> 
> But if we actually put this assumption into the implementation now, we
> should make sure that we can easily expand the implementation later in the
> event that a third implementation comes across which uses separate
> unicast_FIFOs.

Well, FIFO for which side?

I do believe sender will not (or say, must not) care if they use
different FIFO for both protocol or not.

Assume that peer has FIFO per protocol, one for IPv4 and another for
IPv6.  ARP advertise FIFO for IPv4 and NDP advertise FIFO for IPv6.
neighbour subsystem has protocol dependent tables, and two different
NCEs (neighbour cache entries) will be created.  So, sender will
correctly get FIFO from NCE for each protocol.


------------------------------------------------------------------------------
Master Visual Studio, SharePoint, SQL, ASP.NET, C# 2012, HTML5, CSS,
MVC, Windows 8 Apps, JavaScript and much more. Keep your skills current
with LearnDevNow - 3,200 step-by-step video tutorials by Microsoft
MVPs and experts. SALE $99.99 this month only -- learn more at:
http://p.sf.net/sfu/learnmore_122412
