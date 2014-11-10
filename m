From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [patch net-next v2 01/10] net: rename netdev_phys_port_id to
 more generic name
Date: Mon, 10 Nov 2014 13:33:20 +0100
Message-ID: <5460B090.7080106@redhat.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>	<1415530280-9190-2-git-send-email-jiri@resnulli.us>	<54603270.509@mojatatu.com> <20141110.002336.70350092543746386.davem@davemloft.net> <5460AA45.6000007@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jiri@resnulli.us,
	netdev@vger.kernel.org, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58170 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751311AbaKJMfF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Nov 2014 07:35:05 -0500
In-Reply-To: <5460AA45.6000007@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/2014 01:06 PM, Jamal Hadi Salim wrote:
> On 11/10/14 00:23, David Miller wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>> Date: Sun, 09 Nov 2014 22:35:12 -0500
>>
>>> wouldnt this just break an existing ABI? You may need to introduce a
>>> new attribute.
>>
>> He isn't breaking anything Jamal, he's just changing the internal
>> macro name we use for the attribute's maximum length.
>
> It is a _user space visible rename_, how about:
>
> #define MAX_PHYS_ITEM_ID_LEN 32
> #define MAX_PHYS_PORT_ID_LEN   MAX_PHYS_ITEM_ID_LEN
>
> I did miss the fact that the size didnt change.

Actually, it's currently not exposed via any uapi header ...

$ git grep -n MAX_PHYS_PORT_ID_LEN
include/linux/netdevice.h:756:#define MAX_PHYS_PORT_ID_LEN 32
include/linux/netdevice.h:762:  unsigned char id[MAX_PHYS_PORT_ID_LEN];
net/core/rtnetlink.c:871:              + nla_total_size(MAX_PHYS_PORT_ID_LEN); /* IFLA_PHYS_PORT_ID */
net/core/rtnetlink.c:1199:      [IFLA_PHYS_PORT_ID]     = { .type = NLA_BINARY, .len = MAX_PHYS_PORT_ID_LEN },

... and based on commit 66cae9ed6bc4 ("rtnl: export physical port id
via RT netlink") only exported as read-only.

Best,
Daniel
