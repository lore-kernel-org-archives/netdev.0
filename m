From: Vladislav Bolkhovitin <vst@vlnb.net>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Wed, 13 Aug 2008 22:35:34 +0400
Message-ID: <48A32976.7060504@vlnb.net>
References: <adad4kfxm9v.fsf@cisco.com> <200808121457.11356.divy@chelsio.com> <20080812.150246.42068558.davem@davemloft.net> <200808121521.10101.divy@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: open-iscsi@googlegroups.com, rdreier@cisco.com, rick.jones2@hp.com,
	jgarzik@pobox.com, Steve Wise <swise@opengridcomputing.com>,
	Karen Xie <kxie@chelsio.com>, netdev@vger.kernel.org,
	michaelc@cs.wisc.edu, daisyc@us.ibm.com, wenxiong@us.ibm.com,
	bhua@us.ibm.com, Dimitrios Michailidis <dm@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <200808121521.10101.divy@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray wrote:
> On Tuesday 12 August 2008 03:02:46 pm David Miller wrote:
>> From: Divy Le Ray <divy@chelsio.com>
>> Date: Tue, 12 Aug 2008 14:57:09 -0700
>>
>>> In any case, such a stateless solution is not yet designed, whereas
>>> accelerated iSCSI is available now, from us and other companies.
>> So, WHAT?!
>>
>> There are TOE pieces of crap out there too.
> 
> Well, there is demand for accerated iscsi out there, which is the driving 
> reason of our driver submission. 

I'm, as an iSCSI target developer, strongly voting for hardware iSCSI 
offload. Having possibility of the direct data placement is a *HUGE* 
performance gain.

For example, according to measurements done by one iSCSI-SCST user in 
system with iSCSI initiator and iSCSI target (with iSCSI-SCST 
(http://scst.sourceforge.net/target_iscsi.html) running), both with 
identical modern high speed hardware and 10GbE cards, the _INITIATOR_ is 
the bottleneck for READs (data transfers from target to initiator). This 
is because the target sends data in a zero-copy manner, so its CPU is 
capable to deal with the load, but on the initiator there are additional 
data copies from skb's to page cache and from page cache to application. 
As the result, in the measurements initiator got near 100% CPU load and 
only ~500MB/s throughput. Target had ~30% CPU load. For the opposite 
direction (WRITEs), where there is no the application data copy on the 
target, throughput was ~800MB/s with also near 100% CPU load, but in 
this case on the target. The initiator ran Linux with open-iscsi. The 
test was with real backstorage: target ran BLOCKIO (direct BIOs to/from 
backstorage) with 3ware card. Locally on the target the backstorage was 
able to provide 900+MB/s for READs and about 1GB/s for WRITEs. The 
commands queue in both cases was sufficiently big to eliminate the link 
and processing latencies (20-30 outstanding commands).

Vlad

