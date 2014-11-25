From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v3 02/17] net: make vid as a parameter for ndo_fdb_add/ndo_fdb_del
Date: Tue, 25 Nov 2014 10:38:04 -0500
Message-ID: <5474A25C.3080505@mojatatu.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:57483 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbaKYPiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 10:38:09 -0500
Received: by mail-ie0-f180.google.com with SMTP id rp18so758859iec.11
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 07:38:08 -0800 (PST)
In-Reply-To: <1416911328-10979-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14 05:28, Jiri Pirko wrote:
> Do the work of parsing NDA_VLAN directly in rtnetlink code, pass simple
> u16 vid to drivers from there.
>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

I know this maintains status quo of what is already in the kernel.
But we need to take care of policy (pass it from user space) which
dictates how to proceed on failure. Three possible options:
1) If something fails just continue with the rest of the transaction.
Return success if at least one thing succeeds.
2) If something fails stop transaction and return some partial success code
3) If something fails undo everything that has been done and return failure.

So two bits from somewhere would be useful to send from userspace->kernel


> +static int fbd_vid_parse(struct nlattr *vlan_attr, u16 *p_vid)

typo fbd_vid_parse -> fdb_vid_parse

cheers,
jamal
