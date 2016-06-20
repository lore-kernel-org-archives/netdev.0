From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next v4 0/4] return offloaded stats as default and
 expose original sw stats
Date: Sun, 19 Jun 2016 20:06:46 -0700
Message-ID: <CAJieiUh77JaUHE90Qrcp_kqeCOrnXJ9ouAH5X2=cR71DAQJgyA@mail.gmail.com>
References: <1466066237-7719-1-git-send-email-jiri@resnulli.us>
	<20160616.172632.1759391103978744570.davem@davemloft.net>
	<20160617082411.GA1981@nanopsycho.orion>
	<f720df39-75c4-9be1-245d-df63bd40d610@cumulusnetworks.com>
	<20160617140512.GB1981@nanopsycho.orion>
	<57640F2A.7090003@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>,
	David Ahern <dsa@cumulusnetworks.com>,
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
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f41.google.com ([209.85.213.41]:35545 "EHLO
	mail-vk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559AbcFTDGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 23:06:48 -0400
Received: by mail-vk0-f41.google.com with SMTP id j2so179865435vkg.2
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2016 20:06:47 -0700 (PDT)
In-Reply-To: <57640F2A.7090003@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 17, 2016 at 7:54 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 16-06-17 10:05 AM, Jiri Pirko wrote:
>>
>> Fri, Jun 17, 2016 at 03:48:35PM CEST, dsa@cumulusnetworks.com wrote:
>>>
>>> On 6/17/16 2:24 AM, Jiri Pirko wrote:
>>>>
>>>>
>
>>
>> That is problematic. Existing apps depend on rtnetlink stats. But if we
>> don't count offloaded forwarded packets, the apps don't see anything.
>> Therefore I believe that this patchset approach is better. The existing
>> apps continue to work and future apps can use newly introduces sw_stats
>> to query slowpath traffic. Makes sense to me.
>>
>
> I agree with Jiri. It is a bad idea to depend on ethtool for any of
> this stuff.

The concern should not be that it is an ethtool api.
In all previous discussions on this patchset and also my
stats api patches, i have indicated that we have to move all stats
in one place, so naturally, ethtool stats should move eventually to the
stats api as a new nested netlink attribute. I think i called it
IFLA_STATS_LINK_HW  (or something like that)...
and this nested attribute should provide the flexibility and extensibility
of the current ethtool stats api.


> Is there a way we can tag netlink stats instead
> to indicate they are hardware or software?
> We already have a use case with the tc where someone could get/set
> hardware and/or software.
>
> cheers,
> jamal
