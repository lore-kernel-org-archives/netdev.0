From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v2 net] macvlan: Add support for 'always_on' offload features
Date: Tue, 04 Mar 2014 08:44:29 -0500
Message-ID: <5315D8BD.1000001@redhat.com>
References: <1393878833-17667-1-git-send-email-vyasevic@redhat.com> <53151514.4080906@candelatech.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34263 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757193AbaCDNol (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2014 08:44:41 -0500
In-Reply-To: <53151514.4080906@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/03/2014 06:49 PM, Ben Greear wrote:
> On 03/03/2014 12:33 PM, Vlad Yasevich wrote:
>> Macvlan currently inherits all of its features from the lower
>> device.  When lower device disables offload support, this causes
>> macvlan to disable offload support as well.  This causes
>> performance regression when using macvlan/macvtap in bridge
>> mode.
>>
>> It can be easily demonstrated by creating 2 namespaces using
>> macvlan in bridge mode and running netperf between them:
>>
>> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.0.0.1 () port 0 AF_INET
>> Recv   Send    Send
>> Socket Socket  Message  Elapsed
>> Size   Size    Size     Time     Throughput
>> bytes  bytes   bytes    secs.    10^6bits/sec
>>
>>  87380  16384  16384    20.00    1204.61
>>
>> To restore the performance, we add software offload features
>> to the list of "always_on" features for macvlan.  This way
>> when a namespace or a guest using macvtap initially sends a
>> packet, this packet will not be segmented at macvlan level.
>> It will only be segmented when macvlan sends the packet
>> to the lower device.
> 
> If users specifically disable the offload features on the macvlan using ethtool,
> will they be turned off?  If not, then I think that logic should
> be kept somehow?

Just looked and offloads on macvlan are fixed even before this patch,
so a user can't disable them.

Looks like the only way to disable them prior to this patch was to
change the features of the lower device.  However, that introduces
an issue when running in bridged mode that this patch fixes.

-vlad

> 
> Thanks,
> Ben
> 
