From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next v4 0/4] return offloaded stats as default and
 expose original sw stats
Date: Fri, 17 Jun 2016 07:48:35 -0600
Message-ID: <f720df39-75c4-9be1-245d-df63bd40d610@cumulusnetworks.com>
References: <1466066237-7719-1-git-send-email-jiri@resnulli.us>
 <20160616.172632.1759391103978744570.davem@davemloft.net>
 <20160617082411.GA1981@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nogahf@mellanox.com, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
	sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
	ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
	f.fainelli@gmail.com
To: Jiri Pirko <jiri@resnulli.us>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34015 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932933AbcFQNso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 09:48:44 -0400
Received: by mail-pa0-f46.google.com with SMTP id bz2so28867672pad.1
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 06:48:43 -0700 (PDT)
In-Reply-To: <20160617082411.GA1981@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/17/16 2:24 AM, Jiri Pirko wrote:
>
> The problem we try to handle is different, it's about offloaded
> forwarded packets which are not seen by kernel. Let me try to draw it :)
>
>     port1                       port2 (HW stats are counted here)
>       \                          /
>        \                        /
>         \                      /
>          --(A)---- ASIC --(B)--
>                     |
>                    (C)
>                     |
>                    CPU (SW stats are counted here)
>
>
> Now we have couple of flows for TX and RX (direction does not matter here):
>
> 1) port1->A->ASIC->C->CPU
>
>    For this flow, HW and SW stats are equal.
>
> 2) port1->A->ASIC->C->CPU->C->ASIC->B->port2
>
>    For this flow, HW and SW stats are equal.
>
> 3) port1->A->ASIC->B->port2
>
>    For this flow, SW stats are 0.
>
> The purpose of this patchset is to provide facility for user to
> find out the difference between flows 1+2 and 3. In other words, user
> will be able to see the statistics for his slow-path (through kernel).
>
> Also, as a default the accumulated stats (HW) will be exposed to user
> so the userspace apps can react properly.
>

You no longer agree with this discussion?
   http://comments.gmane.org/gmane.linux.network/346740

Essentially netdevice stats show counters for packets punted to the cpu 
and ethool -S shows h/w stats. This patch set seems to invert that.
