From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 02/17] net: make vid as a parameter for
 ndo_fdb_add/ndo_fdb_del
Date: Thu, 27 Nov 2014 22:55:29 +0100
Message-ID: <20141127215529.GA17784@nanopsycho.orion>
References: <5474ABF0.60901@mojatatu.com>
 <5474AE9B.6000500@intel.com>
 <5474B353.10802@mojatatu.com>
 <CAE4R7bD1Hi+fnKp-Sg6Tn4AcpOu2pwgEYecP8LVA1ioO4FkgRQ@mail.gmail.com>
 <547546C5.3060207@mojatatu.com>
 <CAE4R7bA2VPZ3tm2MrsXAm4XfNX0TguT=vUma-3HrZSu98hBGyA@mail.gmail.com>
 <5475B952.2080500@mojatatu.com>
 <CAE4R7bAM+orLXdEn0qCu2rKj+W5_681RHmvgW4CY5H7jZ0ijfQ@mail.gmail.com>
 <54771598.80806@mojatatu.com>
 <CAE4R7bDzxo1xY-MHzqtQ70s+nf+3dkWhr7neV-atk1YkMP3KJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"azhou@nicira.com" <azhou@nicira.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriv
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:56699 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756AbaK0Vzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 16:55:31 -0500
Received: by mail-wg0-f46.google.com with SMTP id x12so7479368wgg.33
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 13:55:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAE4R7bDzxo1xY-MHzqtQ70s+nf+3dkWhr7neV-atk1YkMP3KJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Nov 27, 2014 at 09:59:37PM CET, sfeldma@gmail.com wrote:
>Ya right now the driver just doesn't call br_fdb_external_learn_add()
>if LEARNING_SYNC is not set.  It's a port driver setting so it seems
>fine to handle it in the port driver.  You could move the check up to
>br_fdb_external_learn_add(), but then you have an extra call every 1s
>for each fdb entry being refreshed.  (1s or whatever the refresh
>frequency is).  Easier to avoid this overhead and make the decision at
>the source.

I have been thinking about moving the check into bridge code, it to make
it there as well as in drivers. This is easily changeable on demenad
later though, so I left this for now.

>
>-scott
>
>On Thu, Nov 27, 2014 at 2:14 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> On 11/27/14 01:50, Scott Feldman wrote:
>>
>> [..]
>>
>>>
>>> It's there: IFLA_BRPORT_LEARNING_SYNC.  From iproute2:
>>>
>>> $ bridge -d link show dev swp1
>>> 2: swp1 state UNKNOWN : <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
>>> master br0 state forwarding priority 32 cost 2
>>>      hairpin off guard off root_block off fastleave off learning off flood
>>> off
>>> 2: swp1 state UNKNOWN : <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master
>>> br0
>>>      learning on learning_sync on hwmode swdev
>>>
>>> Turn it off:
>>>
>>> $ bridge link set dev swp1 hwmode swdev learning_sync off
>>>
>>> And now:
>>>
>>> $ bridge -d link show dev swp1
>>> 2: swp1 state UNKNOWN : <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
>>> master br0 state forwarding priority 32 cost 2
>>>      hairpin off guard off root_block off fastleave off learning off flood
>>> off
>>> 2: swp1 state UNKNOWN : <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master
>>> br0
>>>      learning on learning_sync off hwmode swdev
>>>
>>>
>>
>> Yes, this is the nice control portion.
>> From reviewing the patches, I didnt see how the core to the driver was
>> using the  learning_sync. IOW, how do i turn off the drivers sync
>> from being activated? Maybe you are doing this in the rocker patches
>> which i didnt review? i think this needs to be core infrastructure i.e
>> if you are doing this in a timer (as opposed to interrupt driven), then
>> the core sync timer would kick in and call some driver ops.
>> In any case, details that can be ironed out later..
>>
>> cheers,
>> jamal
>>
