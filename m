From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next v4 0/4] return offloaded stats as default and
 expose original sw stats
Date: Sun, 19 Jun 2016 19:57:21 -0700
Message-ID: <CAJieiUi1O8ptD2Dp-cBwjTDLy+Btg5_M2K8nKOqfWSvmxm64Sw@mail.gmail.com>
References: <1466066237-7719-1-git-send-email-jiri@resnulli.us>
	<20160616.172632.1759391103978744570.davem@davemloft.net>
	<20160617082411.GA1981@nanopsycho.orion>
	<f720df39-75c4-9be1-245d-df63bd40d610@cumulusnetworks.com>
	<20160617140512.GB1981@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Ahern <dsa@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Nogah Frankel <nogahf@mellanox.com>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Yotam Gigi <yotamg@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>, sd@queasysnail.net,
	eranbe@mellanox.com, Alexei Starovoitov <ast@plumgrid.com>,
	Eric Dumazet <edumazet@google.com>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f43.google.com ([209.85.213.43]:33734 "EHLO
	mail-vk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752094AbcFTDEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 23:04:44 -0400
Received: by mail-vk0-f43.google.com with SMTP id d185so179970374vkg.0
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2016 20:04:44 -0700 (PDT)
In-Reply-To: <20160617140512.GB1981@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 17, 2016 at 7:05 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Fri, Jun 17, 2016 at 03:48:35PM CEST, dsa@cumulusnetworks.com wrote:
>>On 6/17/16 2:24 AM, Jiri Pirko wrote:
>>>
>>>The problem we try to handle is different, it's about offloaded
>>>forwarded packets which are not seen by kernel. Let me try to draw it :)
>>>
>>>    port1                       port2 (HW stats are counted here)
>>>      \                          /
>>>       \                        /
>>>        \                      /
>>>         --(A)---- ASIC --(B)--
>>>                    |
>>>                   (C)
>>>                    |
>>>                   CPU (SW stats are counted here)
>>>
>>>
>>>Now we have couple of flows for TX and RX (direction does not matter here):
>>>
>>>1) port1->A->ASIC->C->CPU
>>>
>>>   For this flow, HW and SW stats are equal.
>>>
>>>2) port1->A->ASIC->C->CPU->C->ASIC->B->port2
>>>
>>>   For this flow, HW and SW stats are equal.
>>>
>>>3) port1->A->ASIC->B->port2
>>>
>>>   For this flow, SW stats are 0.
>>>
>>>The purpose of this patchset is to provide facility for user to
>>>find out the difference between flows 1+2 and 3. In other words, user
>>>will be able to see the statistics for his slow-path (through kernel).
>>>
>>>Also, as a default the accumulated stats (HW) will be exposed to user
>>>so the userspace apps can react properly.
>>>
>>
>>You no longer agree with this discussion?
>>  http://comments.gmane.org/gmane.linux.network/346740
>>
>>Essentially netdevice stats show counters for packets punted to the cpu and
>>ethool -S shows h/w stats. This patch set seems to invert that.
>
> That is problematic. Existing apps depend on rtnetlink stats. But if we
> don't count offloaded forwarded packets, the apps don't see anything.
> Therefore I believe that this patchset approach is better. The existing
> apps continue to work and future apps can use newly introduces sw_stats
> to query slowpath traffic. Makes sense to me.
>

Apps only care about stats. they don't care about sw vs hardware
stats. what apps are these ?.
For debugging, I agree it would be useful, but thats why we have
always had ethtool stats which
the driver can break down and display. And in all my patches about the
new stats api, i have indicated
that we will migrate the existing ethtool stats to a new netlink
attribute in the new stats api.
