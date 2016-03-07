From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [patch net 2/2] mlxsw: pci: Correctly determine if descriptor
 queue is full
Date: Mon, 7 Mar 2016 16:12:34 +0200
Message-ID: <20160307141234.GA15734@colbert.mtl.com>
References: <1457339092-2878-1-git-send-email-jiri@resnulli.us>
 <1457339092-2878-3-git-send-email-jiri@resnulli.us>
 <56DD8A8B.8000705@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jiri Pirko <jiri@resnulli.us>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <eladr@mellanox.com>, <yotamg@mellanox.com>,
	<ogerlitz@mellanox.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0055.outbound.protection.outlook.com ([157.55.234.55]:22881
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752634AbcCGO3m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2016 09:29:42 -0500
Content-Disposition: inline
In-Reply-To: <56DD8A8B.8000705@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 07, 2016 at 04:04:59PM IST, sergei.shtylyov@cogentembedded.com wrote:
>Hello.
>
>On 3/7/2016 11:24 AM, Jiri Pirko wrote:
>
>> From: Ido Schimmel <idosch@mellanox.com>
>>
>> The descriptor queues for sending (SDQs) and receiving (RDQs) packets
>> are managed by two counters - producer and consumer - which are both
>> 16-bit in size. A queue is considered full when the difference between
>> the two equals the queue's maximum number of descriptors.
>>
>> However, if the producer counter overflows, then it's possible for the
>> full queue check to fail, as it doesn't take the overflow into account.
>> In such a case, descriptors already passed to the device - but for which
>> a completion has yet to be posted - will be overwritten, thereby causing
>> undefined behavior. The above can be achieved under heavy load (~30
>> netperf instances).
>>
>> Fix that by casting the substraction result to u16, preventing it from
>
>    Subtraction.

Will fix that in v2.

Thanks!

>
>> being treated as a signed integer.
>>
>> Fixes: eda6500a987a ("mlxsw: Add PCI bus implementation")
>> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>
>[...]
>
>MBR, Sergei
>
