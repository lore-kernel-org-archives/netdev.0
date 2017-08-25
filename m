From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v6 2/3] net: gso: Add GSO support for NSH
Date: Fri, 25 Aug 2017 18:25:14 +0200
Message-ID: <20170825182514.6ff6c36b@griffin>
References: <1503670805-31051-1-git-send-email-yi.y.yang@intel.com>
        <1503670805-31051-3-git-send-email-yi.y.yang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, e@erig.me,
        blp@ovn.org, jan.scheurich@ericsson.com
To: Yi Yang <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55052 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934196AbdHYQZS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 12:25:18 -0400
In-Reply-To: <1503670805-31051-3-git-send-email-yi.y.yang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Aug 2017 22:20:04 +0800, Yi Yang wrote:
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -766,7 +766,7 @@ struct sk_buff {
>  	__u8			ndisc_nodetype:2;
>  #endif
>  	__u8			ipvs_property:1;
> -	__u8			inner_protocol_type:1;
> +	__u8			inner_protocol_type:2;

Adding anything to sk_buff is pretty much forbidden. You can't add more
bytes to it and there are no more free bits to use, either.

Luckily, we still have one byte hole next to inner_ipproto that we can
use. What is needed is renaming of ENCAP_TYPE_IPPROTO to ENCAP_TYPE_L3
and storing the L3 type in the unused byte. It's not beautiful (would
be better to use ethertype than a custom enum) but it will work.

While looking at this, I realized that GSO for VXLAN-GPE is broken,
too. Let me fix it by implementing what I described above which will
make your patch much easier.

 Jiri
