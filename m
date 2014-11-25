From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v3 15/17] bridge: add new hwmode swdev
Date: Tue, 25 Nov 2014 22:56:55 +0000
Message-ID: <20141125225655.GJ3912@casper.infradead.org>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-16-git-send-email-jiri@resnulli.us>
 <5474A83F.7040006@cumulusnetworks.com>
 <20141125161733.GI27416@gospo.rtplab.test>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, jhs@mojatatu.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, bcrl@
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57002 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366AbaKYW47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 17:56:59 -0500
Content-Disposition: inline
In-Reply-To: <20141125161733.GI27416@gospo.rtplab.test>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14 at 11:17am, Andy Gospodarek wrote:
> On Tue, Nov 25, 2014 at 08:03:11AM -0800, Roopa Prabhu wrote:
> > On 11/25/14, 2:28 AM, Jiri Pirko wrote:
> > >From: Scott Feldman <sfeldma@gmail.com>
> > >
> > >Current hwmode settings are "vepa" or "veb".  These are for NIC interfaces
> > >with basic bridging function offloaded to HW.  Add new "swdev" for full
> > >switch device offloads.
> > 
> > still voting for a generic feature flag like NETIF_F_HW_OFFLOAD for use by
> > bridge/bond/vxlan. I can resubmit my patch that does this.
> 
> I know it is _early_ to propose this, but I would even suggest this:
> 
> diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
> index 8e30685..6cea162 100644
> --- a/include/linux/netdev_features.h
> +++ b/include/linux/netdev_features.h
> @@ -124,6 +124,7 @@ enum {
>  #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
>  #define NETIF_F_HW_L2FW_DOFFLOAD	__NETIF_F(HW_L2FW_DOFFLOAD)
>  #define NETIF_F_BUSY_POLL	__NETIF_F(BUSY_POLL)
> +#define NETIF_F_HW_SWITCHING	__NETIF_F(HW_SWITCHING)
>  
>  /* Features valid for ethtool to change */
>  /* = all defined minus driver/device-class-related */

I need more context to understand the intent of this. What does the
presence of the flag indicate? Support for swdev API? My
understanding is that the API will grow quickly and device will
only support a subset of what the API can abstract.
