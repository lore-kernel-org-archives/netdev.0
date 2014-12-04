From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2 1/6] iproute2: ipa: show switch id
Date: Thu, 4 Dec 2014 16:12:18 +0100
Message-ID: <20141204151218.GD1861@nanopsycho.orion>
References: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
 <1417683438-10935-2-git-send-email-jiri@resnulli.us>
 <20141204142015.GR27416@gospo.rtplab.test>
 <20141204143306.GB1861@nanopsycho.orion>
 <20141204145743.GS27416@gospo.rtplab.test>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
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
	mleitner@redhat.com, shrijeet@gmail.com, bcrl@kvack.org,
	hemal@broadcom.com
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:40182 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753832AbaLDPMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 10:12:21 -0500
Received: by mail-wg0-f52.google.com with SMTP id a1so22975492wgh.39
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 07:12:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141204145743.GS27416@gospo.rtplab.test>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Dec 04, 2014 at 03:57:43PM CET, gospo@cumulusnetworks.com wrote:
>On Thu, Dec 04, 2014 at 03:33:06PM +0100, Jiri Pirko wrote:
>> Thu, Dec 04, 2014 at 03:20:15PM CET, gospo@cumulusnetworks.com wrote:
>> >On Thu, Dec 04, 2014 at 09:57:13AM +0100, Jiri Pirko wrote:
>> >> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> >> ---
>> >>  include/linux/if_link.h | 1 +
>> >>  ip/ipaddress.c          | 8 ++++++++
>> >>  2 files changed, 9 insertions(+)
>> >> 
>> >> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
>> >> index 4732063..a6e2594 100644
>> >> --- a/include/linux/if_link.h
>> >> +++ b/include/linux/if_link.h
>> >> @@ -145,6 +145,7 @@ enum {
>> >>  	IFLA_CARRIER,
>> >>  	IFLA_PHYS_PORT_ID,
>> >>  	IFLA_CARRIER_CHANGES,
>> >> +	IFLA_PHYS_SWITCH_ID,
>> >
>> >Serious question for Stephen et al, once we take this to iproute2 are we
>> >going to be able to change the name but the string diplayed if needed?
>> >
>> >I had a patch that called this IFLA_PARENT_ID that I was using with the
>> >older github tree used by Jiri and Scott before these were in net-next.
>> >I wanted to submit that as a change to what became
>> >82f2841291cfaf4d225aa1766424280254d3e3b2, but was waiting for things to
>> >be accepted and the dust settled.
>> >
>> >I like the parent/child/sibling nomenclature better for 4 reasons:
>> >
>> >- Most did not seem to like the term 'offload' since that term would be
>> >  confusing with, GRO, GSO, etc.
>> >- A *significant* use case for many of the high-end ASICs in datacenters
>> >  is routing.
>> >- switchid does not make sense in the OVS/flow case because it is all
>> >  about flows, not switches or routers, and parent made sense there.
>> 
>> well ovs is all about flows and has the "switch" word in the name. I
>> believe that people are talking about "switches" in case of these "flow
>> devices" as well. I see nothing wrong in that. I think that "switch"
>> became generic name for "packet forwarding machines".
>
>Just because one chose to use it that way does not mean I agree with it
>and that we should copy their bad decision.  :-)
>
>> "parent" is very generic and may mean 100 things...
>
>But in this case, it means 1 thing.  The netdev you are using is
>connected to another device that controls it rather than being just a
>NIC.

when we discussed linkage now called upper/lower devices, there was a
proposal to use "parent" as well. And then it ment only 1 thing as well.
Why for example pf is not parent of vf? Using "parent" word here and
assume that it just makes sense for this case is IMHO wrong. Too
generic. "switch_parent" - that I am okay with.


>
>> 
>> 
>> >- I wanted to combine this for use with SR-IOV use case, so one can more
>> >  easily map PF->VF using this.
>> 
>> Ugh, please don't mix this up with pf, vf. That is completely different
>> thing.
>> 
>> pf vf mapping is done in sysfs. In netlink, physportid is used for that
>> purpose. We can expose this phys port id for pf as well (as a different
>> attr) and we are done.
>
>I know that attribute is there, but I find it more valuable for
>solutions like nPAR than for PF/VF use-case.

Why it is not good enough for pf/vf? There are SR-IOV drivers using
this:
$ git grep ndo_get_phys_port_id
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:       .ndo_get_phys_port_id   = bnx2x_get_phys_port_id,
drivers/net/ethernet/intel/i40e/i40e_main.c:    .ndo_get_phys_port_id   = i40e_get_phys_port_id,
drivers/net/ethernet/mellanox/mlx4/en_netdev.c: .ndo_get_phys_port_id   = mlx4_en_get_phys_port_id,
drivers/net/ethernet/mellanox/mlx4/en_netdev.c: .ndo_get_phys_port_id   = mlx4_en_get_phys_port_id,
drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c:       .ndo_get_phys_port_id   = qlcnic_get_phys_port_id,


>Parent/child relationship
>makes more sense to me since for forwarding will be controlled by the
>embedded switch on those devices.  (Notice I specifically chose not to
>use 'master' since that is already overloaded by bridge, bonding,
>teaming, etc.)

But is that embedded switch the same thing as PF? I doubt that. Let the
aspect of PF/VF aside and look at it as on ordinary switch. The eswitch
driver needs te be implemented and add netdevs for internal ports (they
do not exist now).

You have to look at PF/VF and eSwitch as on separate things.

>
>> 
>> >
>> >Can you give me a bit (a day) to clean-up that patch and submit an
>> >alternative proposal to these?
>> >
>> >>  	__IFLA_MAX
>> >>  };
>> >>  
>> >> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
>> >> index 4d99324..bd36a07 100644
>> >> --- a/ip/ipaddress.c
>> >> +++ b/ip/ipaddress.c
>> >> @@ -589,6 +589,14 @@ int print_linkinfo(const struct sockaddr_nl *who,
>> >>  				      b1, sizeof(b1)));
>> >>  	}
>> >>  
>> >> +	if (tb[IFLA_PHYS_SWITCH_ID]) {
>> >> +		SPRINT_BUF(b1);
>> >> +		fprintf(fp, "switchid %s ",
>> >> +			hexstring_n2a(RTA_DATA(tb[IFLA_PHYS_SWITCH_ID]),
>> >> +				      RTA_PAYLOAD(tb[IFLA_PHYS_SWITCH_ID]),
>> >> +				      b1, sizeof(b1)));
>> >> +	}
>> >> +
>> >>  	if (tb[IFLA_OPERSTATE])
>> >>  		print_operstate(fp, rta_getattr_u8(tb[IFLA_OPERSTATE]));
>> >>  
>> >> -- 
>> >> 1.9.3
>> >> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
