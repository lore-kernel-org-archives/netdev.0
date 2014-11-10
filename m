From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 10/10] rocker: implement L2 bridge offloading
Date: Mon, 10 Nov 2014 07:27:14 -0500
Message-ID: <5460AF22.2040701@mojatatu.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>	<1415530280-9190-11-git-send-email-jiri@resnulli.us>	<546036A3.3010404@mojatatu.com> <CAE4R7bCdfn6rzvY5J5d_aj=eNKoT00iEphGJMnQOWy=WeLePTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, nhorman@tuxdriver.com,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	edumazet@google.com, Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com,
	simon.ho
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:50644 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751926AbaKJM1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 07:27:21 -0500
Received: by mail-ig0-f173.google.com with SMTP id r10so16421191igi.0
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 04:27:20 -0800 (PST)
In-Reply-To: <CAE4R7bCdfn6rzvY5J5d_aj=eNKoT00iEphGJMnQOWy=WeLePTw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/14 03:46, Scott Feldman wrote:

>
> IFLA_BRPORT_LEARNING is u8 attr and we're only using lower bit to turn
> learning on/off.  Maybe we can use another bit to indicate learning to
> be done in sw or hw.  I don't think adding another bit would break
> existing iproute2.
>
> LEARNING_ENABLED    (1 << 0)
> LEARNING_HW              (1 << 1)
>
> Would this work?
>

Yes to making it a bit. But:
This is not *learning*. You are doing a *sync*.
Those are two different things.

Learning on/off exists today. It signals to the L2 whether you
should learn or not.
I like the way fdb_add/del work with a flag which says
it is the software and/or offloaded version. Please keep that
semantic.
What you are doing above is letting the hardware learn then
syncing to software. You need a different flag there. something
like:

SYNC_HW_FDB (1<<1)


cheers,
jamal
