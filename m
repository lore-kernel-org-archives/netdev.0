From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next v4 0/4] return offloaded stats as default and
 expose original sw stats
Date: Wed, 22 Jun 2016 07:30:57 -0700
Message-ID: <CAJieiUjK1vyoxTxvrKUdrNwX09NqDEZD0jxx8YxgKAKvdqPiyg@mail.gmail.com>
References: <1466066237-7719-1-git-send-email-jiri@resnulli.us>
 <20160616.172632.1759391103978744570.davem@davemloft.net> <20160617082411.GA1981@nanopsycho.orion>
 <f720df39-75c4-9be1-245d-df63bd40d610@cumulusnetworks.com>
 <20160617140512.GB1981@nanopsycho.orion> <57640F2A.7090003@mojatatu.com>
 <9f8e85ac-3e96-257e-cf7f-e7e793d41cf4@cumulusnetworks.com>
 <20160617154243.GD1981@nanopsycho.orion> <57642F76.6090403@gmail.com>
 <CAJieiUhFRp6wE_gt-0q9KYQTYdEyg5yFUYa89K+ovaQr7QE5Zg@mail.gmail.com> <5767E16F.2040902@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
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
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f52.google.com ([209.85.213.52]:34401 "EHLO
	mail-vk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752731AbcFVOiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 10:38:24 -0400
Received: by mail-vk0-f52.google.com with SMTP id c2so34260028vkg.1
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 07:37:21 -0700 (PDT)
In-Reply-To: <5767E16F.2040902@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 20, 2016 at 5:28 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 16-06-19 11:14 PM, Roopa Prabhu wrote:
>>
>> On Fri, Jun 17, 2016 at 10:12 AM, Florian Fainelli <f.fainelli@gmail.com>
>> wrote:
>
>
>
>>
>> I have also mentioned this before, the default api must provide
>> accumulated (hw and sw) stats...,
>> because this is the api that the user queries on an interface.
>
>
> Sorry - I missed those discussions.
> What is current practise? Do people request for one via ip link
> stats and the other via ethtool?
> What do you guys do in your implementation?

for us the standard netlink api that returns netdev stats includes all
stats hw and sw.
When i say hw and sw, I mean some of the error counters can also include errors
counted by sw.

ethtool stats has always provided drivers/users with additional stats
that the hw or driver
can expose.


> Yes, it would be more accurate to provide aggregated stats but
> it may break backward compat if expectation is both are read
> separately today.

I don't think people see netdev stats as sw and ethtool as hw stats.
The latter just provides more granularity for debugging.
Thats the way i have looked at it forever.


> Maybe it makes sense to have a brand new TLV for these aggregated
> stats as Jiri was suggesting.That means two new TLVs not one.
> 1) TLV for aggregated stats - which cant be current one
> 2) TLV for h/w stats
>
> The existing stat implies s/ware only.
>

I don't think existing stat implies s/ware stats only. so, I think we
should be careful
about changing the meaning of existing stats.

logical devices like bridge stats have always been software only...but
with switchdev
the way we see these or implement these is to also include hardware stats when
they are hw offloaded. For us bridge vlan stats, vxlan stats and so on
will follow the
same model. You cannot introduce separate sw and hw stats for these.
All stats will have to follow a consistent model.

Thanks,
Roopa
