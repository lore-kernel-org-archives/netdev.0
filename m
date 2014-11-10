From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v2 10/10] rocker: implement L2 bridge offloading
Date: Sun, 9 Nov 2014 22:46:56 -1000
Message-ID: <CAE4R7bCdfn6rzvY5J5d_aj=eNKoT00iEphGJMnQOWy=WeLePTw@mail.gmail.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
	<1415530280-9190-11-git-send-email-jiri@resnulli.us>
	<546036A3.3010404@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, nhorman@tuxdriver.com,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	edumazet@google.com, Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com,
	simon.ho
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:47177 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962AbaKJIq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 03:46:57 -0500
Received: by mail-wi0-f172.google.com with SMTP id bs8so9907596wib.17
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 00:46:56 -0800 (PST)
In-Reply-To: <546036A3.3010404@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 9, 2014 at 5:53 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>
> On 11/09/14 05:51, Jiri Pirko wrote:
>>
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> Add L2 bridge offloading support to rocker driver.  Here, the Linux bridge
>> driver is used to collect swdev ports into a tagged (or untagged) VLAN
>> bridge.  The swdev will offload from the bridge driver the following L2
>> bridging functions:
>>
>>   - Learning of neighbor MAC addresses on VLAN X  Learned mac/vlan is
>> installed in bridge FDB.  (And removed when device unlearns mac/vlan).
>> Learning must be turned off on each bridge port to disable the feature in
>> the bridge driver.
>>
>
> I have quiet a few use cases where the above is a no-no. I dont want
> learning of any sort (we have a knob for that in the bridge).
> And i dont want learning in hardware to be reflected in software.
> Basically this is a policy decision. Introduce a knob to choose whether
> hardware learnt addresses should be reflected in software.


IFLA_BRPORT_LEARNING is u8 attr and we're only using lower bit to turn
learning on/off.  Maybe we can use another bit to indicate learning to
be done in sw or hw.  I don't think adding another bit would break
existing iproute2.

LEARNING_ENABLED    (1 << 0)
LEARNING_HW              (1 << 1)

Would this work?


>
>
> Have to run, but will comment when i get the time.
>
> cheers,
> jamal
>
