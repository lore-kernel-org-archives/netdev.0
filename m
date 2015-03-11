From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next v2] tipc: fix undefined __ipv6_sock_mc_join compile
 error
Date: Wed, 11 Mar 2015 11:40:03 +0800
Message-ID: <54FFB913.2060301@windriver.com>
References: <1425976885-18258-1-git-send-email-ying.xue@windriver.com> <CA+FuTSdxmae0DnNnQdCgCdaThVtZ1raqEg9z6XpHE5N9u5MCfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <jon.maloy@ericsson.com>,
	<Paul.Gortmaker@windriver.com>, <erik.hugne@ericsson.com>,
	Fengguang Wu <fengguang.wu@intel.com>,
	Network Development <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>, <kbuild-all@01.org>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:64322 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751389AbbCKDk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 23:40:29 -0400
In-Reply-To: <CA+FuTSdxmae0DnNnQdCgCdaThVtZ1raqEg9z6XpHE5N9u5MCfw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/10/2015 11:41 PM, Willem de Bruijn wrote:
>> l
>> > diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
>> > index fc2fb11..6763002 100644
>> > --- a/net/tipc/udp_media.c
>> > +++ b/net/tipc/udp_media.c
>> > @@ -247,10 +247,12 @@ static int enable_mcast(struct udp_bearer *ub, struct udp_media_addr *remote)
> 
>> >                 mreqn.imr_multiaddr = remote->ipv4;
>> >                 mreqn.imr_ifindex = ub->ifindex;
>> >                 err = __ip_mc_join_group(sk, &mreqn);
>> > +#if IS_ENABLED(CONFIG_IPV6)
>> >         } else {
>> >                 if (!ipv6_addr_is_multicast(&remote->ipv6))
>> >                         return 0;
>> >                 err = __ipv6_sock_mc_join(sk, ub->ifindex, &remote->ipv6);
>> > +#endif
>> >         }
>> >         return err;
> It may also be prudent to initialize err to -EAFNOSUPPORT instead of
> 0. This function is currently only called when the protocol family has
> been checked, but relying on that is a bit fragile.
> 
> 

Thanks for your suggestion, and I will fix it in next version.

Regards,
Ying
