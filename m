From: William Manley <william.manley@youview.com>
Subject: Re: [PATCH] net: igmp: Reduce Unsolicited report interval to 1s when
 using IGMPv3
Date: Wed, 24 Jul 2013 14:45:08 +0100
Message-ID: <51EFDA64.4020409@youview.com>
References: <1374527349.1635.55.camel@bwh-desktop.uk.level5networks.com> <1374673098-10295-1-git-send-email-william.manley@youview.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: William Manley <william.manley@youview.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe003.messaging.microsoft.com ([216.32.180.13]:48567
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751243Ab3GXNpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 09:45:35 -0400
Received: from mail26-va3 (localhost [127.0.0.1])	by mail26-va3-R.bigfish.com
 (Postfix) with ESMTP id 32B7D200BC	for <netdev@vger.kernel.org>; Wed, 24 Jul
 2013 13:45:34 +0000 (UTC)
Received: from VA3EHSMHS017.bigfish.com (unknown [10.7.14.237])	by
 mail26-va3.bigfish.com (Postfix) with ESMTP id D59453E016A	for
 <netdev@vger.kernel.org>; Wed, 24 Jul 2013 13:45:32 +0000 (UTC)
In-Reply-To: <1374673098-10295-1-git-send-email-william.manley@youview.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/07/13 14:38, William Manley wrote:
> If an IGMP join packet is lost you will not receive data sent to the
> multicast group so if no data arrives from that multicast group in a
> period of time after the IGMP join a second IGMP join will be sent.  The
> delay between joins is the "IGMP Unsolicited Report Interval".
>
> Previously this value was hard coded to be chosen randomly between 0-10s.
> This can be too long for some use-cases, such as IPTV as it can cause
> channel change to be slow in the presence of packet loss.
>
> The value 10s has come from IGMPv2 RFC2236, which was reduced to 1s in
> IGMPv3 RFC3376.  This patch makes the kernel use the 1s value from the
> later RFC if we are operating in IGMPv3 mode.  IGMPv2 behaviour is
> unaffected.
>
> Tested with Wireshark and a simple program to join a (non-existant)
> multicast group.  The distribution of timings for the second join differ
> based upon setting /proc/sys/net/ipv4/conf/eth0/force_igmp_version.
> ---
>   net/ipv4/igmp.c |   17 ++++++++++++++---
>   1 file changed, 14 insertions(+), 3 deletions(-)

I'm also working on a patch which builds on this adding a procfs knob 
similar to force_igmp_version but called 
"force_igmp_unsolicited_report_interval".  This will allow the interval 
to be overridden from user-space independent of the version of IGMP in 
use as for our use-case we want the interval to be short even for IGMPv2.

Thanks

Will
