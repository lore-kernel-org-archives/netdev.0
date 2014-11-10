From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 10/10] rocker: implement L2 bridge offloading
Date: Mon, 10 Nov 2014 16:14:09 -0500
Message-ID: <54612AA1.4020903@mojatatu.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>	<1415530280-9190-11-git-send-email-jiri@resnulli.us>	<546036A3.3010404@mojatatu.com>	<CAE4R7bCdfn6rzvY5J5d_aj=eNKoT00iEphGJMnQOWy=WeLePTw@mail.gmail.com>	<5460AF22.2040701@mojatatu.com>	<5460E3D5.3000104@cumulusnetworks.com>	<CAE4R7bARr8_=sS+6aezKDX0FfERUj8AD6eOGONKAeRd-g+9nDA@mail.gmail.com>	<5461058F.1020709@cumulusnetworks.com>	<54611192.5080606@mojatatu.com> <CAE4R7bDQesnq8kDFsUqiY0+H1SnUHPSJACLMgFc9eX8chjoxKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, nhorman@tuxdriver.com,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	vyasevic@redhat.com, Cong Wang <xiyou.wangcong@gmail.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	John Linville <linville@tuxdriver.com>, jasowang@redhat.com,
	ebiederm@xmission.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org,
	Alexei Starovoitov <alexei.starovoitov@gm
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:43507 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751922AbaKJVON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 16:14:13 -0500
Received: by mail-ie0-f171.google.com with SMTP id x19so10201641ier.30
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 13:14:13 -0800 (PST)
In-Reply-To: <CAE4R7bDQesnq8kDFsUqiY0+H1SnUHPSJACLMgFc9eX8chjoxKA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/14 14:47, Scott Feldman wrote:
> On Mon, Nov 10, 2014 at 9:27 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:

>
> For swdev, I don't care for the model where each port has an fdb and
> the bridge has an fdb.  The bridge's fdb lookup/learning/fwding is
> what we're offloading to HW, so it makes more sense from the driver
> and to the user to use one fdb, the bridge's fdb.  So user types
> "bridge fdb show" and static fdbs installed on the bridge and learned
> fdbs synced from HW are represented.  One table.
>

side note:
I hope we'd be able to tell apart what is in hardware vs software
and what has been synced up from hardware (assuming policy says we
are allowed to sync things).
Yes, there is one fdb table per bridge - but each entry would say
which brport is involved. So the reference point being a bridge point
sounds reasonable to me. i.e
Any fdb entry whether in h/w or s/w would point to an egress
brport *always*. Are you thinking there is only one possible bridge?
Caveat: a piece of hardware could have multiple virtual bridges.
In what Ben showed on the $5 realtek, after boot up we just
know which brports exist and nothing more.
We can then create a bridge and attach brport to each. This gets
reflected into hardware on a per brport level (I think there was
a field called FID?).
Constraint: Each brport connects only to one bridge.

> I view the existing ndo_fdb_add/del ops useful for devices working
> standalone without the bridge driver that have some HW fwding
> capabilities and need to manage their own fdb.

As in offload said fdb?

>For devices under
> bridge, let's use the bridge's fdb, at least for swdev.
>

If the hardware can only do one bridge sure.

> Does this make sense?

not quiet for me but i may be missing something.

I hate to use a lot of "I"s in my sentences,
> but looks like I did exactly that in above, so take this as an
> opinion, within the scope of swdev.
>

"I" is useful for expressing an opinion or an expectation of course ;->
As an example:
_I_ believe we should be able to define how {learning, flooding etc} and 
where {hw vs sw} things are to be installed or learnt-from.
I have use cases where the controller makes all the decisions.
And i tried to provide my motivation in one of the meetings here:
https://linux.cumulusnetworks.com/offload-discussion-1/jamal-NFstatecaching.pdf

cheers,
jamal
