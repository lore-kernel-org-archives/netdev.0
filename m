From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 07/10] bridge: call netdev_sw_port_stp_update
 when bridge port STP status changes
Date: Mon, 10 Nov 2014 14:20:02 -0500
Message-ID: <54610FE2.1060605@mojatatu.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us> <1415530280-9190-8-git-send-email-jiri@resnulli.us> <5460B989.8030404@mojatatu.com> <20141110140452.GB19157@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
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
	bcrl@kvack.
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:45161 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178AbaKJTUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 14:20:07 -0500
Received: by mail-ig0-f180.google.com with SMTP id h3so9742888igd.1
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 11:20:07 -0800 (PST)
In-Reply-To: <20141110140452.GB19157@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/14 09:04, Thomas Graf wrote:
> On 11/10/14 at 08:11am, Jamal Hadi Salim wrote:
>> You are unconditionally calling
>> netdev_sw_port_stp_update(p->dev, p->state);
>> Again issue is policy. Could you make this work the same
>> way the fdb_add e.g user intent of whether i want to turn
>> a port in hardware and/or software to disabled/learning/etc
>> is reflected?
>
> Agreed. Can be added in a next series perhaps?
>

Doesnt seem be hard to fix now. As Andy was pointing out, we have
the opportunity to get the basics right in the beggining.


> I think we can just extend the size of IFLA_BRPORT_STATE, accept
> both a u8 and u32, and return a u32 that that is compatible to
> existing u8 readers.
>

Iam thinking we have an opportunity for a totally different new
attribute instead of growing IFLA_BRPORT_STATE to add another bit.
Almost every single u8 that is being carried today in its own attribute
in the bridge code is in fact a boolean (0/1). We could leave just
intro IFLA_BRIDGE_FLAGS and use it for both FDB and BRPORT.

cheers,
jamal
