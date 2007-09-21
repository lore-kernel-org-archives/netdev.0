From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] Re: [PATCH v2] iw_cxgb3: Support "iwarp-only"
 interfaces to avoid 4-tuple conflicts.
Date: Fri, 21 Sep 2007 10:10:46 -0500
Message-ID: <46F3DEF6.3010404@opengridcomputing.com>
References: <20070913191617.30937.95960.stgit@dell3.ogc.int>
	<20070914130941.GG18517@2ka.mipt.ru>
	<46EC00BE.3020801@opengridcomputing.com>
	<20070916142241.GA26848@2ka.mipt.ru>
	<46EE9C50.7070406@opengridcomputing.com>
	<20070919105612.GA31158@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, general@lists.openfabrics.org,
	linux-kernel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070919105612.GA31158@2ka.mipt.ru>
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



Evgeniy Polyakov wrote:
> Hi Steve.
> 
> On Mon, Sep 17, 2007 at 10:25:04AM -0500, Steve Wise (swise@opengridcomputing.com) wrote:
>>> Does creating the whole new netdevice is a too big overhead, or is it
>>> considered bad idea?
>> I think its too big overhead, and pretty invasive on the low level cxgb3 
>> driver.  I think having a device in the 'ifconfig -a' after iw_cxgb3 is 
>> loaded and devices discovered would be a good thing for the admin.  This 
>> is the angle Roland suggested.  I'm just not sure how to implement it.
>>
>> But if someone could explain how I might create this full netdevice as a 
>> pseudo device on top of the real one, maybe I could implement it.
>>
>> Note that non TCP traffic still needs to utilize this interface for ND 
>> to work properly with the RDMA core.
> 
> Just a though - what about allowing secondary addresses with the same
> address as main one? I.e. change bit of the core code to allow creating
> aliases with the same address as main device, so that you would be able
> to create ':iw' alias during rdma device initialization?
> 

The problem is that on rdma route/address resolution the rdma core CM 
uses the routing table to look up which local device to use.  So what we 
need is separate ip subnets for rdma vs non rdma tcp.

Also, to avoid the original issue of 4-tuple conflicts, the rdma device 
_must_ listen on specific local "rdma-only" ip addresses and thus they 
must be not the same address as that used for native host tcp traffic.

Steve.
