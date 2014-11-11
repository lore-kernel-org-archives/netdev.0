From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 05/10] rocker: introduce rocker switch driver
Date: Tue, 11 Nov 2014 16:19:28 +0100
Message-ID: <20141111151928.GF1825@nanopsycho.lan>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
 <1415530280-9190-6-git-send-email-jiri@resnulli.us>
 <5461366A.9050900@gmail.com>
 <20141111142946.GG19157@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, jhs@mojatatu.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cum
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:44115 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097AbaKKPTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 10:19:31 -0500
Received: by mail-wg0-f53.google.com with SMTP id b13so11892621wgh.26
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 07:19:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141111142946.GG19157@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Nov 11, 2014 at 03:29:46PM CET, tgraf@suug.ch wrote:
>On 11/10/14 at 02:04pm, John Fastabend wrote:
>> On 11/09/2014 02:51 AM, Jiri Pirko wrote:
>> >+static int rocker_port_sw_parent_id_get(struct net_device *dev,
>> >+					struct netdev_phys_item_id *psid)
>> >+{
>> >+	struct rocker_port *rocker_port = netdev_priv(dev);
>> >+	struct rocker *rocker = rocker_port->rocker;
>> >+
>> 
>> hmm looks like you read this out of a magic switch register :) but
>> my switch doesn't have this magic reg. I suposse the switch MAC address
>> should work.
>
>This needs more work afterwards. Either we define that the switch ID
>is only unique in combination with the parent ifindex or we need to
>introduce a notation of uniquness into the switch ID itself.

This is something similar to physical port id. Each driver should take
care of generating that id.

>
>Is the goal to expose a hardware ID here to allow identification of
>the hardware chip?
>
>MAC is tempting but I'm pretty sure that we'll have pure L3 devices
>being handled by this API at some point.
