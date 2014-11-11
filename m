From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next v2 03/10] rtnl: expose physical switch id for
 particular device
Date: Tue, 11 Nov 2014 05:55:21 -0800
Message-ID: <54621549.90909@cumulusnetworks.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us> <1415530280-9190-4-git-send-email-jiri@resnulli.us> <5460FCB0.1040409@cumulusnetworks.com> <CAE4R7bA_u=E-Vm5Zx74NJugV1JgSj1dOmBGkBZG18kcnkXH1OQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
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
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:53767 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924AbaKKNzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 08:55:36 -0500
In-Reply-To: <CAE4R7bA_u=E-Vm5Zx74NJugV1JgSj1dOmBGkBZG18kcnkXH1OQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/14, 12:02 PM, Scott Feldman wrote:
> On Mon, Nov 10, 2014 at 7:58 AM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>> On 11/9/14, 2:51 AM, Jiri Pirko wrote:
>>> The netdevice represents a port in a switch, it will expose
>>> IFLA_PHYS_SWITCH_ID value via rtnl. Two netdevices with the same value
>>> belong to one physical switch.
>>>
>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>> ---
>>>    include/uapi/linux/if_link.h |  1 +
>>>    net/core/rtnetlink.c         | 26 +++++++++++++++++++++++++-
>>>    2 files changed, 26 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
>>> index 7072d83..4163753 100644
>>> --- a/include/uapi/linux/if_link.h
>>> +++ b/include/uapi/linux/if_link.h
>>> @@ -145,6 +145,7 @@ enum {
>>>          IFLA_CARRIER,
>>>          IFLA_PHYS_PORT_ID,
>>>          IFLA_CARRIER_CHANGES,
>>> +       IFLA_PHYS_SWITCH_ID,
>>
>> Jiri, since we have not really converged on the switchdev class or having a
>> separate switchdev instance,
>> am thinking it is better if we dont expose any such switch_id to userspace
>> yet until absolutely needed. Do you need it today ?
>> There is no real in kernel hw switch driver that will use it today. And
>> quite likely this will need to change when we introduce real hw switch
>> drivers.
> How will it change when real hw switch drivers are introduced?  Will
> the real sw driver not be able to give a up unique ID for the switch?
  With my question i was trying to see if there are other ways to manage 
the relationship between the
switch device and the ports, instead of an random id provided by each 
switch driver. Today the switch id namespace seems
to be with each switch driver. On my systems on the first switch chip 
quite likely i will choose an id 0.,,and possibly some other
driver will choose the same id. The switch id namespace handling was not 
clear to me.

But, to your question, am sure we will have some id to go in there since 
the field is now available.

Thanks,
Roopa
