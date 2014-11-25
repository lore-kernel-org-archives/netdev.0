From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v3 02/17] net: make vid as a parameter for ndo_fdb_add/ndo_fdb_del
Date: Tue, 25 Nov 2014 11:57:40 -0500
Message-ID: <5474B504.1080208@mojatatu.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-3-git-send-email-jiri@resnulli.us> <5474A25C.3080505@mojatatu.com> <5474AC18.8040809@cumulusnetworks.com> <5474AF53.8030709@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, edumazet@google.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, linville@tuxdriver.com, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com,
	simon.horman@netronome.com, alexander.h.duyck@redhat.com,
	john.ronciak@intel.com, mleitner@redhat.com, shrijeet@gmail.com,
	gospo@cumulusnetworks.com, bcrl@kvack.org
To: John Fastabend <john.r.fastabend@intel.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:56162 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbaKYQ5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 11:57:44 -0500
Received: by mail-ig0-f169.google.com with SMTP id hl2so7102615igb.4
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 08:57:43 -0800 (PST)
In-Reply-To: <5474AF53.8030709@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14 11:33, John Fastabend wrote:
> On 11/25/2014 08:19 AM, Roopa Prabhu wrote:

> I agree its needed but your already out of sync for some period of time
> why the software/hardware tables are being programmed. There is no global
> sw/hw commit operation.
>
> I'm not sure it matters if the time being out of sync is a touch longer
> because we go to user space to fix it. But agreed it can be supported.
>


Recent netfilter has 2 phase commit built in. Maybe we can generalize
that?
Note, there are use cases where it is important to do rollbacks.
If i am doing a distributed router, then to make sure a FIB/NH entries
are properly synced in across the cluster is extremely important. You
cant justify letting a few packets sneak in the wrong path.
in other words, strong consistency is important.
Having said that things can be worked around (and i would not use
2pc for the example use case i gave); however, that doesnt negate
the fact we need it.

cheers,
jamal
