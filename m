From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: macvtap performance regression (bisected) between 3.13 and 3.14-rc1
Date: Sat, 01 Mar 2014 14:27:17 -0500
Message-ID: <53123495.7030902@gmail.com>
References: <530FA586.3010400@de.ibm.com> <53110A62.7070109@redhat.com> <5311C142.6040509@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	KVM list <kvm@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>, vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:33492 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753194AbaCAT1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Mar 2014 14:27:21 -0500
In-Reply-To: <5311C142.6040509@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/01/2014 06:15 AM, Christian Borntraeger wrote:
> On 28/02/14 23:14, Vlad Yasevich wrote:
>> On 02/27/2014 03:52 PM, Christian Borntraeger wrote:
>>> Vlad,
>>>
>>> commit 6acf54f1cf0a6747bac9fea26f34cfc5a9029523
>>>     macvtap: Add support of packet capture on macvtap device.
>>>
>>> causes a performance regression for iperf traffic between two KVM guests
>>> on my s390 system. Both guests are connected via two macvtaps on the same OSA
>>> network card.
>>> Before that patch I get ~20 Gbit/sec between two guests, afterwards I get
>>> ~4Gbit/sec
>>>
>>> Latency seems to be unchanges (uperf 1byte ping pong).
>>>
>>> According to ifconfig in the guest, I have ~ 1500 bytes per packet with this
>>> patch and ~  40000 bytes without. So for some reason this patch causes the
>>> network stack to do segmentation. (the guest kernel stays the same, only host 
>>> kernel is changed).
>>>
>>> Any ideas?
>>
>> I am looking.  It shouldn't cause addition segmentations and when I ran
>> netperf on the code I didn't see any difference in the throughput.
> 
> Dont know if the different bytes/packets ratio is really the reason or
> just a side effect. As a hint: the underlying network device does not support
> segmentation, but this should not matter for traffic between to guests.

Could you post 'ethtool -k' output for both lower-level device and the
macvtap device?

Thanks
-vlad

> 
> Maybe you remember, we had a similar situation with commit 3e4f8b787370978733ca6cae452720a4f0c296b8
> (macvtap: Perform GSO on forwarding path), the setup is basically the same.
> 
> 
> Christian
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
