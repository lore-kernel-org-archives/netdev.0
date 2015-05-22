From: Joao Martins <Joao.Martins@neclab.eu>
Subject: Re: [RFC PATCH 00/13] Persistent grant maps for xen net drivers
Date: Fri, 22 May 2015 10:27:06 +0000
Message-ID: <191EF54A-D8DE-4BAA-B15D-41B2BA35353F@neclab.eu>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <20150519153901.GH26335@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"david.vrabel@citrix.com" <david.vrabel@citrix.com>,
	"boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.neclab.eu ([195.37.70.40]:60499 "EHLO mailer1.neclab.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756032AbbEVK1X convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 06:27:23 -0400
In-Reply-To: <20150519153901.GH26335@zion.uk.xensource.com>
Content-Language: en-US
Content-ID: <F464C0902DC744478A15EEC95DD28FDF@office.hd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 19 May 2015, at 17:39, Wei Liu <wei.liu2@citrix.com> wrote:

> On Tue, May 12, 2015 at 07:18:24PM +0200, Joao Martins wrote:
> 
>> There have been recently[3] some discussions and issues raised on
>> persistent grants for the block layer, though the numbers above
>> show some significant improvements specially on more network intensive
>> workloads and provide a margin for comparison against future map/unmap
>> improvements.
>> 
>> Any comments or suggestions are welcome,
>> Thanks!
> 
> Thanks, the numbers certainly look interesting.
> 
> I'm just a bit concerned about the complexity of netback. I've
> commented on individual patches, we can discuss the issues there.

Thanks a lot for the review! It does add more complexity, mainly for
the TX path, but I also would like to mention that a portion of this
changeset is also the persistent grants ops that could potentially live
outside.

Joao

>> [1] http://article.gmane.org/gmane.linux.network/249383
>> [2] http://bit.ly/1IhJfXD
>> [3] http://lists.xen.org/archives/html/xen-devel/2015-02/msg02292.html
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
