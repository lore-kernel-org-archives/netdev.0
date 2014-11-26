From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v3 16/17] bridge: add brport flags to dflt
 bridge_getlink
Date: Wed, 26 Nov 2014 10:48:10 +0000
Message-ID: <20141126104810.GB4321@casper.infradead.org>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-17-git-send-email-jiri@resnulli.us>
 <20141125220753.GD3912@casper.infradead.org>
 <20141126092512.GE1875@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59864 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbaKZKsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 05:48:18 -0500
Content-Disposition: inline
In-Reply-To: <20141126092512.GE1875@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/14 at 10:25am, Jiri Pirko wrote:
> Tue, Nov 25, 2014 at 11:07:53PM CET, tgraf@suug.ch wrote:
> >> +static int brport_nla_put_flag(struct sk_buff *skb, u32 flags, u32 mask,
> >> +			       unsigned int attrnum, unsigned int flag)
> >> +{
> >> +	if (mask & flag)
> >> +		return nla_put_u8(skb, attrnum, !!(flags & flag));
> >
> >nla_put_flag()?
> 
> No, that is not the same. nla_put_flag works differently. The attr is
> either present or not. But in this case, attr is always present and has
> value of either 0 or 1.

So this reports the driver capabilities through this interface as
well.  Cool. Wasn't obvious to me before but that justifies the waste.
