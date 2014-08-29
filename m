From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 12/12] rocker: introduce rocker switch driver
Date: Fri, 29 Aug 2014 09:06:37 +0200
Message-ID: <20140829070637.GB1864@nanopsycho.lan>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-13-git-send-email-jiri@resnulli.us>
 <20140823140450.GA24116@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:35504 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752066AbaH2HGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 03:06:40 -0400
Received: by mail-wi0-f171.google.com with SMTP id hi2so8594725wib.4
        for <netdev@vger.kernel.org>; Fri, 29 Aug 2014 00:06:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140823140450.GA24116@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Aug 23, 2014 at 04:04:50PM CEST, tgraf@suug.ch wrote:
>On 08/21/14 at 06:19pm, Jiri Pirko wrote:
>> This patch introduces the first driver to benefit from the switchdev
>> infrastructure and to implement newly introduced switch ndos. This is a
>> driver for emulated switch chip implemented in qemu:
>> https://github.com/sfeldma/qemu-rocker/
>
>The design looks very clean. I noticed that the TLV API is almost an
>exact dupliate of the Netlink attributes API. Any specific reason for
>not reusing lib/nlattr.c and add what is missing?

Well the api is almost the same. But the implementation is different.
See for example rocker_tlv_put. It works directly with desc info.
But nla_put works with skb which is not convenient for rocker.

Also, struct nlattr is 2xu16 but struct rocker_tlv is u32 u16
