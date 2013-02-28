From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC Patch net-next] vxlan: add ipv6 support
Date: Thu, 28 Feb 2013 16:07:41 -0500
Message-ID: <512FC71D.8080508@redhat.com>
References: <1362031286-23295-1-git-send-email-amwang@redhat.com> <20130228103311.GC7558@casper.infradead.org>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1916 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755208Ab3B1VHw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2013 16:07:52 -0500
In-Reply-To: <20130228103311.GC7558@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/28/2013 05:33 AM, Thomas Graf wrote:
> On 02/28/13 at 02:01pm, Cong Wang wrote:
>> WARNING: This is just an RFC patch, it only compiles!!
>>
>> This patch adds IPv6 support to vxlan device, as the new version
>> RFC already mentioned it:
>>
>> 	http://tools.ietf.org/html/draft-mahalingam-dutt-dcops-vxlan-03
>>
>> I am not sure if the following trick will work:
>>
>> 	+       if (nla_len(nla) == sizeof(__be32)) {
>> 	+               ip->ip4 = nla_get_be32(nla);
>> 	+               ip->proto = htons(ETH_P_IP);
>> 	+       }
>> 	+#if IS_ENABLED(CONFIG_IPV6)
>> 	+       else if (nla_len(nla) == sizeof(struct in6_addr)) {
>> 	+               nla_memcpy(&ip->ip6, nla, sizeof(struct in6_addr));
>> 	+               ip->proto = htons(ETH_P_IPV6);
>> 	+       }
>> 	+#endif
>>
>> otherwise we have to introduce some new netlink attributes for
>> IPv6 addresses? Any comments?
>
> How about setting ndm_family to AF_INET6 and parse NDA_DST based on
> that?
>

Not sure if you can do that without registering your own fdb netlink 
handler.  rtnl_fdb_add is registered for PF_BRIDGE family.

You could do that, or use NDA_DST similar to how neighbor table uses it.
There the data inside of NDA_DST holds an address family and other data.

-vlad

> Assuming that nla_len(NDA_DST) > 4 == ip6 is a bit weak as like with
> any Netlink attribute we only ever enforce a minimum length and never
> a maximum or exact length.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
