From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v3 15/17] bridge: add new hwmode swdev
Date: Tue, 25 Nov 2014 23:00:53 +0000
Message-ID: <20141125230053.GK3912@casper.infradead.org>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-16-git-send-email-jiri@resnulli.us>
 <5474A95B.3080607@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57026 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828AbaKYXAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 18:00:54 -0500
Content-Disposition: inline
In-Reply-To: <5474A95B.3080607@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14 at 11:07am, Jamal Hadi Salim wrote:
> On 11/25/14 05:28, Jiri Pirko wrote:
> >From: Scott Feldman <sfeldma@gmail.com>
> >
> >Current hwmode settings are "vepa" or "veb".  These are for NIC interfaces
> >with basic bridging function offloaded to HW.  Add new "swdev" for full
> >switch device offloads.
> >
> >Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> >Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> >---
> >new in v3
> >---
> >  include/uapi/linux/if_bridge.h | 1 +
> >  1 file changed, 1 insertion(+)
> >
> >diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
> >index da17e45..60425ca 100644
> >--- a/include/uapi/linux/if_bridge.h
> >+++ b/include/uapi/linux/if_bridge.h
> >@@ -105,6 +105,7 @@ struct __fdb_entry {
> >
> >  #define BRIDGE_MODE_VEB		0	/* Default loopback mode */
> >  #define BRIDGE_MODE_VEPA	1	/* 802.1Qbg defined VEPA mode */
> >+#define BRIDGE_MODE_SWDEV       2       /* Full switch device offload */
> >
> >  /* Bridge management nested attributes
> >   * [IFLA_AF_SPEC] = {
> >
> 
> Again - Why is this not a generic interface the way Roopa had it?
> We need to do offloads for a lot of other things than just bridge..

I agree in general but I'm not sure we should mirror the NETIF_F_*
approach. Even the relatively simple encap offload has turned into
a complex set of feature bitmasks requiring harmonization.

I think we should discuss this in the context of John's work which
neatly abstracts the capabilities.
