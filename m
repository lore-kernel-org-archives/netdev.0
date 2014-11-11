From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next v2 05/10] rocker: introduce rocker switch driver
Date: Tue, 11 Nov 2014 07:41:31 -0800
Message-ID: <54622E2B.10900@cumulusnetworks.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us> <1415530280-9190-6-git-send-email-jiri@resnulli.us> <5461366A.9050900@gmail.com> <20141111142946.GG19157@casper.infradead.org> <20141111151928.GF1825@nanopsycho.lan> <20141111153232.GH19157@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>,
	John Fastabend <john.fastabend@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, linville@tuxdriver.com, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com,
	simon.horman@netronome.com, alexander.h.duyck@redhat.com,
	john.ronciak@intel.com, mleitner@redhat.com, shrijeet@gmail.com,
	gos
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:36384 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbaKKPmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 10:42:12 -0500
In-Reply-To: <20141111153232.GH19157@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/11/14, 7:32 AM, Thomas Graf wrote:
> On 11/11/14 at 04:19pm, Jiri Pirko wrote:
>> Tue, Nov 11, 2014 at 03:29:46PM CET, tgraf@suug.ch wrote:
>>> On 11/10/14 at 02:04pm, John Fastabend wrote:
>>>> On 11/09/2014 02:51 AM, Jiri Pirko wrote:
>>>>> +static int rocker_port_sw_parent_id_get(struct net_device *dev,
>>>>> +					struct netdev_phys_item_id *psid)
>>>>> +{
>>>>> +	struct rocker_port *rocker_port = netdev_priv(dev);
>>>>> +	struct rocker *rocker = rocker_port->rocker;
>>>>> +
>>>> hmm looks like you read this out of a magic switch register :) but
>>>> my switch doesn't have this magic reg. I suposse the switch MAC address
>>>> should work.
>>> This needs more work afterwards. Either we define that the switch ID
>>> is only unique in combination with the parent ifindex or we need to
>>> introduce a notation of uniquness into the switch ID itself.
>> This is something similar to physical port id. Each driver should take
>> care of generating that id.
> If the ID is only unique within a driver, then the user space cannot
> rely on using the ID to group switch ports. Multiple drivers might
> come up with the same ID.
>
> Even now, multiple rocker instances would have the same ID.
yep, that was my concern on the switch id namespace handling (on the 
other thread).
