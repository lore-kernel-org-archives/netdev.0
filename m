From: "Yuzhou (C)" <vitas.yuzhou@huawei.com>
Subject: RE: [Xen-devel] [RFC PATCH 00/13] Persistent grant maps for xen net
	drivers
Date: Fri, 29 May 2015 06:53:19 +0000
Message-ID: <47498F109986134D9A5B42B82F405EBBA3244CB6@SZXEMA502-MBX.china.huawei.com>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
	<20150519153901.GH26335@zion.uk.xensource.com>
 <191EF54A-D8DE-4BAA-B15D-41B2BA35353F@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"david.vrabel@citrix.com" <david.vrabel@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>,
	"Luohao (brian)" <brian.luohao@huawei.com>,
	"Zhangleiqiang (Trump)" <zhangleiqiang@huawei.com>,
	Zhuangyuxin <zhuangyuxin@huawei.com>,
	"Xiaoding (B)" <xiaoding1@huawei.com>
To: Joao Martins <Joao.Martins@neclab.eu>,
	Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:46097 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbbE2Gxm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 02:53:42 -0400
In-Reply-To: <191EF54A-D8DE-4BAA-B15D-41B2BA35353F@neclab.eu>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

	About rx zerocopy, I have a question:

	If some application make a socket, then listen and accept, the client sends packets to it, but it doesn't recv from this socket right now, all persistent grant page would be in used.
So other application cannot receive any packets.  Is my guess right or wrong?

YuZhou

-----Original Message-----
From: xen-devel-bounces@lists.xen.org [mailto:xen-devel-bounces@lists.xen.org] On Behalf Of Joao Martins
Sent: Friday, May 22, 2015 6:27 PM
To: Wei Liu
Cc: ian.campbell@citrix.com; netdev@vger.kernel.org; david.vrabel@citrix.com; xen-devel@lists.xenproject.org; boris.ostrovsky@oracle.com
Subject: Re: [Xen-devel] [RFC PATCH 00/13] Persistent grant maps for xen net drivers


On 19 May 2015, at 17:39, Wei Liu <wei.liu2@citrix.com> wrote:

> On Tue, May 12, 2015 at 07:18:24PM +0200, Joao Martins wrote:
> 
>> There have been recently[3] some discussions and issues raised on 
>> persistent grants for the block layer, though the numbers above show 
>> some significant improvements specially on more network intensive 
>> workloads and provide a margin for comparison against future 
>> map/unmap improvements.
>> 
>> Any comments or suggestions are welcome, Thanks!
> 
> Thanks, the numbers certainly look interesting.
> 
> I'm just a bit concerned about the complexity of netback. I've 
> commented on individual patches, we can discuss the issues there.

Thanks a lot for the review! It does add more complexity, mainly for the TX path, but I also would like to mention that a portion of this changeset is also the persistent grants ops that could potentially live outside.

Joao

>> [1] http://article.gmane.org/gmane.linux.network/249383
>> [2] http://bit.ly/1IhJfXD
>> [3] 
>> http://lists.xen.org/archives/html/xen-devel/2015-02/msg02292.html
>> 
>> Joao Martins (13):
>>  xen-netback: add persistent grant tree ops
>>  xen-netback: xenbus feature persistent support
>>  xen-netback: implement TX persistent grants
>>  xen-netback: implement RX persistent grants
>>  xen-netback: refactor xenvif_rx_action
>>  xen-netback: copy buffer on xenvif_start_xmit()
>>  xen-netback: add persistent tree counters to debugfs
>>  xen-netback: clone skb if skb->xmit_more is set
>>  xen-netfront: move grant_{ref,page} to struct grant
>>  xen-netfront: refactor claim/release grant
>>  xen-netfront: feature-persistent xenbus support
>>  xen-netfront: implement TX persistent grants
>>  xen-netfront: implement RX persistent grants
>> 
>> drivers/net/xen-netback/common.h    |  79 ++++
>> drivers/net/xen-netback/interface.c |  78 +++-
>> drivers/net/xen-netback/netback.c   | 873 ++++++++++++++++++++++++++++++------
>> drivers/net/xen-netback/xenbus.c    |  24 +
>> drivers/net/xen-netfront.c          | 362 ++++++++++++---
>> 5 files changed, 1216 insertions(+), 200 deletions(-)
>> 
>> --
>> 2.1.3



_______________________________________________
Xen-devel mailing list
Xen-devel@lists.xen.org
http://lists.xen.org/xen-devel
