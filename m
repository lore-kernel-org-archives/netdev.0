From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v2 10/10] rocker: implement L2 bridge offloading
Date: Mon, 10 Nov 2014 07:22:09 -1000
Message-ID: <CAE4R7bBAt1ngGr2C2jc3vXxPvH7nd+Qa33VqOeU-OahbCrgisg@mail.gmail.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
	<1415530280-9190-11-git-send-email-jiri@resnulli.us>
	<546036A3.3010404@mojatatu.com>
	<CAE4R7bCdfn6rzvY5J5d_aj=eNKoT00iEphGJMnQOWy=WeLePTw@mail.gmail.com>
	<5460AF22.2040701@mojatatu.com>
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
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Neil.Je
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:40805 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005AbaKJRpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 12:45:04 -0500
Received: by mail-wg0-f52.google.com with SMTP id b13so9417685wgh.11
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 09:45:03 -0800 (PST)
In-Reply-To: <5460AF22.2040701@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 10, 2014 at 2:27 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 11/10/14 03:46, Scott Feldman wrote:
>
>>
>> IFLA_BRPORT_LEARNING is u8 attr and we're only using lower bit to turn
>> learning on/off.  Maybe we can use another bit to indicate learning to
>> be done in sw or hw.  I don't think adding another bit would break
>> existing iproute2.
>>
>> LEARNING_ENABLED    (1 << 0)
>> LEARNING_HW              (1 << 1)
>>
>> Would this work?
>>
>
> Yes to making it a bit. But:
> This is not *learning*. You are doing a *sync*.
> Those are two different things.
>
> Learning on/off exists today. It signals to the L2 whether you
> should learn or not.
> I like the way fdb_add/del work with a flag which says
> it is the software and/or offloaded version. Please keep that
> semantic.
> What you are doing above is letting the hardware learn then
> syncing to software. You need a different flag there. something
> like:
>
> SYNC_HW_FDB (1<<1)

Agreed, that's more accurate.  Thanks for the refinement.

>
> cheers,
> jamal
