From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v2 08/10] bridge: add API to notify bridge driver
 of learned FBD on offloaded device
Date: Tue, 11 Nov 2014 07:38:10 -1000
Message-ID: <CAE4R7bAqm8Fyu_PfXJ78KgoDTS-3igH+EPO1YMd2ZN1WKZ7RoA@mail.gmail.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
	<1415530280-9190-9-git-send-email-jiri@resnulli.us>
	<54621B77.4050109@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, nhorman@tuxdriver.com,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	vyasevic@redhat.com, Cong Wang <xiyou.wangcong@gmail.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	John Linville <linville@tuxdriver.com>, jasowang@redhat.com,
	ebiederm@xmission.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	Aviad Raveh <aviadr@mellanox.com>, nbd@openwrt.org,
	Alexei Starovoitov <alexei.staro
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:36587 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751184AbaKKRiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 12:38:11 -0500
Received: by mail-wi0-f180.google.com with SMTP id hi2so2368097wib.7
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 09:38:10 -0800 (PST)
In-Reply-To: <54621B77.4050109@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2014 at 4:21 AM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
> On 11/9/14, 2:51 AM, Jiri Pirko wrote:
>>
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> When the swdev device learns a new mac/vlan on a port, it sends some async
>> notification to the driver and the driver installs an FDB in the device.
>> To give a holistic system view, the learned mac/vlan should be reflected
>> in the bridge's FBD table, so the user, using normal iproute2 cmds, can
>> view
>> what is currently learned by the device.  This API on the bridge driver
>> gives
>> a way for the swdev driver to install an FBD entry in the bridge FBD
>> table.
>> (And remove one).
>>
>> This is equivalent to the device running these cmds:
>>
>>    bridge fdb [add|del] <mac> dev <dev> vid <vlan id> master
>>
>> This patch needs some extra eyeballs for review, in paricular around the
>> locking and contexts.
>
>
> scott/jiri, love that you have handled this case!, This will be useful.
> But, quick question, Cant this also be done using the same ndo_op that is
> done to add the static fdb..?

Maybe.  I think I tried sending netlink msg from swdev driver to
bridge driver, but wasn't able to make it to work.  I'm not sure if
it's possible to do that, in general, send netlink kernel-to-kernel.
The other option is to synthesize a netlink msg with needed attrs and
call ndo in bridge directly.  That feels a little yucky to me.
