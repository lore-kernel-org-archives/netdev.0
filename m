From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support for datapath
 hardware offload
Date: Tue, 26 Aug 2014 10:26:17 -0400
Message-ID: <53FC9909.7000007@mojatatu.com>
References: <53F79C54.5050701@gmail.com> <464DB0A8-0073-4CE0-9483-0F36B73A53A1@cumulusnetworks.com> <53F9459B.2070801@mojatatu.com> <20140824111218.GA32741@casper.infradead.org> <53FA01AC.10507@mojatatu.com> <A67C7591-19BF-4431-9119-F61361F5E618@cumulusnetworks.com> <53FAA2A2.7070801@gmail.com> <53FB3FD5.2030905@mojatatu.com> <20140825141754.GA30140@casper.infradead.org> <53FB6122.2040901@mojatatu.com> <20140825225057.GD30140@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	dev@openvswitch.org, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mella
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:35487 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755427AbaHZO0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 10:26:20 -0400
Received: by mail-pd0-f169.google.com with SMTP id y10so22722467pdj.14
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 07:26:19 -0700 (PDT)
In-Reply-To: <20140825225057.GD30140@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/14 18:50, Thomas Graf wrote:
> On 08/25/14 at 12:15pm, Jamal Hadi Salim wrote:
>> On 08/25/14 10:17, Thomas Graf wrote:

>> I dont think we have a problem handling any of this today.
>
> Yes we do. It's restricted to L2 and we can't extend it easily

It is restricted to L2 because it is L2 processing;->
i.e a fixed function that is widely deployed and well understood.
Possible new extensions that are added are still L2
(example I think if you were to add TRILL support, you would
likely need to inherit and extend the bridge then add new TLVs).

> because it is based on NDA_*. The use of Netlink makes in-kernel
> usage a pain.

Ok, I understand what you mean by "in kernel" now.
I believe we have representations that are complete today at L3.
The offloader just feeds on that.
L2 needs some work because we have only been offloading the fdb.

>To me this is the sole reason for not using fdb_add()
> in the first place. It seems absolutely clear though that fdb_add()
> should be removed after the more generic ndo is in place providing
> a superset of what fdb_add() can do today.
>

It is by no means complete as i pointed to in my other email.
We need to worry about bridge ports, vlan filtering, igmp snooping
possibly STP parametrization and other knobs of control (flood control,
learning control etc).

> OK, let me do the convertion for you:
>
> NDA_DST		unused
> NDA_LLADDR	sw_flow_key.eth.dst
> NDA_CACHEINFO	unused
> NDA_PROBES	unused
> NDA_VLAN	sw_flow_key.eth.tci
> NDA_PORT	unused
> NDA_VNI		sw_flow_key.tun_key.tun_id
> NDA_IFINDEX	sw_flow_key.phys.in_port
> NDA_MASTER	unused
>

You are waaaay oversimplifying;->.
You need to worry about the rest of the other knobs that
are relevant when one offloads the bridge (refer above to
some of the things i said are missing from current fdb()
interface).

> Agreed but tc is only one out of many possible existing interfaces
> we have. macvtap (given we want to extend beyond L2), routing,
> OVS, bridge and eventually even things like a team device can and
> should make use of offloads.
>

Sure. I just want my cookies. I want it such that if i use tc filter
and that filter is offloadable and there exist a device capable
of offloading in my system - that it should work.


> Can you share that preso? I was not present.
>

I think it should be posted in the netconf site.
Also refer to my earlier presentation in the online meeting
which you were present at.

> Let me remind you about the name of the structure behind all L3
> forwarding decisions:
>
>          struct flowi4 {
> 		[...]
> 	}
>
> Adding a route means adding a flow.

Come on Thomas;->
It is called "flowi" structure - but it represent a much complex thing
than your definition of "flow".

>Can we please stop the flow bashing?

Let me get out my club and bash it some more ;->
I am going to start a newsgroup called alt.bash.bash.flow
Any postings from stanford will be censored by the banana republic
dictator.

cheers,
jamal
