From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 07/10] bridge: call netdev_sw_port_stp_update
 when bridge port STP status changes
Date: Fri, 7 Nov 2014 09:32:19 +0100
Message-ID: <20141107083219.GA1848@nanopsycho.orion>
References: <1415265610-9338-1-git-send-email-jiri@resnulli.us>
 <1415265610-9338-8-git-send-email-jiri@resnulli.us>
 <545BA8EF.4060601@gmail.com>
 <CAE4R7bBarGQPsuM5js20RwPLOBF24AtiiHM-f2EvkHNObp7NDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, nhorman@tuxdriver.com,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	edumazet@google.com, jhs@mojatatu.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com,
	simon.horman@netrono
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:47209 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbaKGIcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 03:32:25 -0500
Received: by mail-wi0-f172.google.com with SMTP id bs8so3758361wib.17
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2014 00:32:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAE4R7bBarGQPsuM5js20RwPLOBF24AtiiHM-f2EvkHNObp7NDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Nov 06, 2014 at 07:53:35PM CET, sfeldma@gmail.com wrote:
>On Thu, Nov 6, 2014 at 6:59 AM, Florian Fainelli <f.fainelli@gmail.com>
>wrote:
>
>> On 11/06/2014 01:20 AM, Jiri Pirko wrote:
>> > From: Scott Feldman <sfeldma@gmail.com>
>> >
>> > To notify switch driver of change in STP state of bridge port, add new
>> > .ndo op and provide swdev wrapper func to call ndo op. Use it in bridge
>> > code then.
>> >
>> > Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> > Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> > ---
>>
>> [snip]
>>
>> >  #endif /* _LINUX_SWITCHDEV_H_ */
>> > diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>> > index 86c239b..13fecf1 100644
>> > --- a/net/bridge/br_netlink.c
>> > +++ b/net/bridge/br_netlink.c
>> > @@ -17,6 +17,7 @@
>> >  #include <net/net_namespace.h>
>> >  #include <net/sock.h>
>> >  #include <uapi/linux/if_bridge.h>
>> > +#include <net/switchdev.h>
>> >
>> >  #include "br_private.h"
>> >  #include "br_private_stp.h"
>> > @@ -304,6 +305,7 @@ static int br_set_port_state(struct net_bridge_port
>> *p, u8 state)
>> >
>> >       br_set_state(p, state);
>> >       br_log_state(p);
>> > +     netdev_sw_port_stp_update(p->dev, p->state);
>>
>> Is there a reason netdev_sw_port_stp_update() is not folded in
>> br_set_state()? Are we missing calls to br_set_state() in some locations?
>>
>
>I put the netdev_sw call at the same level as br_log_state() and
>br_ifinfo_notify(),
>but now that you bring up the question, I agree it would be cleaner/safer
>if netdev_sw call was from br_set_state().

Not sure about this. netdev_sw_port_stp_update is not called every time
br_set_state is called. br_log_state is in simillar position.
br_set_state is now just a simple setter. I would probably leave this
change for the possible future follow-up. It can move br_log_state call
as well.


>
>
>> --
>> Florian
>>
