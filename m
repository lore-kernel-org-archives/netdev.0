From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v2 03/10] rtnl: expose physical switch id for
 particular device
Date: Mon, 10 Nov 2014 10:02:11 -1000
Message-ID: <CAE4R7bA_u=E-Vm5Zx74NJugV1JgSj1dOmBGkBZG18kcnkXH1OQ@mail.gmail.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
	<1415530280-9190-4-git-send-email-jiri@resnulli.us>
	<5460FCB0.1040409@cumulusnetworks.com>
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
	aviadr@mellanox.com, nbd@openwrt.org,
	Alexei Starovoitov <alexei.starovoitov@gmail.c
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:32780 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431AbaKJUCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 15:02:13 -0500
Received: by mail-wi0-f176.google.com with SMTP id h11so11721019wiw.15
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 12:02:11 -0800 (PST)
In-Reply-To: <5460FCB0.1040409@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 10, 2014 at 7:58 AM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
> On 11/9/14, 2:51 AM, Jiri Pirko wrote:
>>
>> The netdevice represents a port in a switch, it will expose
>> IFLA_PHYS_SWITCH_ID value via rtnl. Two netdevices with the same value
>> belong to one physical switch.
>>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>   include/uapi/linux/if_link.h |  1 +
>>   net/core/rtnetlink.c         | 26 +++++++++++++++++++++++++-
>>   2 files changed, 26 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
>> index 7072d83..4163753 100644
>> --- a/include/uapi/linux/if_link.h
>> +++ b/include/uapi/linux/if_link.h
>> @@ -145,6 +145,7 @@ enum {
>>         IFLA_CARRIER,
>>         IFLA_PHYS_PORT_ID,
>>         IFLA_CARRIER_CHANGES,
>> +       IFLA_PHYS_SWITCH_ID,
>
>
> Jiri, since we have not really converged on the switchdev class or having a
> separate switchdev instance,
> am thinking it is better if we dont expose any such switch_id to userspace
> yet until absolutely needed. Do you need it today ?
> There is no real in kernel hw switch driver that will use it today. And
> quite likely this will need to change when we introduce real hw switch
> drivers.

How will it change when real hw switch drivers are introduced?  Will
the real sw driver not be able to give a up unique ID for the switch?
