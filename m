From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v4 0/4] return offloaded stats as default and
 expose original sw stats
Date: Fri, 17 Jun 2016 16:05:13 +0200
Message-ID: <20160617140512.GB1981@nanopsycho.orion>
References: <1466066237-7719-1-git-send-email-jiri@resnulli.us>
 <20160616.172632.1759391103978744570.davem@davemloft.net>
 <20160617082411.GA1981@nanopsycho.orion>
 <f720df39-75c4-9be1-245d-df63bd40d610@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	nogahf@mellanox.com, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
	sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
	ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
	f.fainelli@gmail.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36092 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752094AbcFQOFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 10:05:16 -0400
Received: by mail-wm0-f66.google.com with SMTP id m124so46669wme.3
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 07:05:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <f720df39-75c4-9be1-245d-df63bd40d610@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jun 17, 2016 at 03:48:35PM CEST, dsa@cumulusnetworks.com wrote:
>On 6/17/16 2:24 AM, Jiri Pirko wrote:
>>
>>The problem we try to handle is different, it's about offloaded
>>forwarded packets which are not seen by kernel. Let me try to draw it :)
>>
>>    port1                       port2 (HW stats are counted here)
>>      \                          /
>>       \                        /
>>        \                      /
>>         --(A)---- ASIC --(B)--
>>                    |
>>                   (C)
>>                    |
>>                   CPU (SW stats are counted here)
>>
>>
>>Now we have couple of flows for TX and RX (direction does not matter here):
>>
>>1) port1->A->ASIC->C->CPU
>>
>>   For this flow, HW and SW stats are equal.
>>
>>2) port1->A->ASIC->C->CPU->C->ASIC->B->port2
>>
>>   For this flow, HW and SW stats are equal.
>>
>>3) port1->A->ASIC->B->port2
>>
>>   For this flow, SW stats are 0.
>>
>>The purpose of this patchset is to provide facility for user to
>>find out the difference between flows 1+2 and 3. In other words, user
>>will be able to see the statistics for his slow-path (through kernel).
>>
>>Also, as a default the accumulated stats (HW) will be exposed to user
>>so the userspace apps can react properly.
>>
>
>You no longer agree with this discussion?
>  http://comments.gmane.org/gmane.linux.network/346740
>
>Essentially netdevice stats show counters for packets punted to the cpu and
>ethool -S shows h/w stats. This patch set seems to invert that.

That is problematic. Existing apps depend on rtnetlink stats. But if we
don't count offloaded forwarded packets, the apps don't see anything.
Therefore I believe that this patchset approach is better. The existing
apps continue to work and future apps can use newly introduces sw_stats
to query slowpath traffic. Makes sense to me.
