From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2] tipc: fix undefined __ipv6_sock_mc_join compile
 error
Date: Wed, 11 Mar 2015 17:34:58 +0300
Message-ID: <55005292.8050607@cogentembedded.com>
References: <1425976885-18258-1-git-send-email-ying.xue@windriver.com> <54FF3CE1.3080804@cogentembedded.com> <54FFB7A9.5080602@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	erik.hugne@ericsson.com, fengguang.wu@intel.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	kbuild-all@01.org
To: Ying Xue <ying.xue@windriver.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:35457 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752277AbbCKOfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 10:35:03 -0400
Received: by lams18 with SMTP id s18so9255101lam.2
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 07:35:01 -0700 (PDT)
In-Reply-To: <54FFB7A9.5080602@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/11/2015 6:34 AM, Ying Xue wrote:

>>> When CONFIG_IPV6 option is disabled, below error will appear while
>>> building TIPC module:

>>> ERROR: "__ipv6_sock_mc_join" [net/tipc/tipc.ko] undefined!
>>> make[1]: *** [__modpost] Error 1
>>> make: *** [net/tipc/tipc.ko] Error 1

>>> This is because we don't check whether or not the CONFIG_IPV6 is
>>> enabled when calling __ipv6_sock_mc_join().

>>> In addition, especially when TIPC=y, TIPC_MEDIA_UDP=y, and IPV6=m, TIPC
>>> module is also unable to be successfully built. Therefore, we add a
>>> dependency condition like (IPV6 || IPV6=n) to avoid the error.

>>> Fixes: d0f91938bede ("tipc: add ip/udp media type")
>>> Reported-by: Wu Fengguang <fengguang.wu@intel.com>
>>> Cc: Kbuild test robot <kbuild-all@01.org>
>>> Signed-off-by: Ying Xue <ying.xue@windriver.com>
>>> ---
>>> v2:
>>>    Fix another compile error when TIPC=y, TIPC_MEDIA_UDP=y, and IPV6=m

[...]

>>> diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
>>> index fc2fb11..6763002 100644
>>> --- a/net/tipc/udp_media.c
>>> +++ b/net/tipc/udp_media.c
>>> @@ -247,10 +247,12 @@ static int enable_mcast(struct udp_bearer *ub, struct
>>> udp_media_addr *remote)
>>>            mreqn.imr_multiaddr = remote->ipv4;
>>>            mreqn.imr_ifindex = ub->ifindex;
>>>            err = __ip_mc_join_group(sk, &mreqn);
>>> +#if IS_ENABLED(CONFIG_IPV6)
>>>        } else {

>>     How about:

>>      } else if (IS_ENABLED(CONFIG_IPV6)) {

> Sorry, I try to the suggestion, but it doesn't work.

    You mean that the linking error you reported doesn't go away?

> Thanks,
> Ying

>>>            if (!ipv6_addr_is_multicast(&remote->ipv6))
>>>                return 0;
>>>            err = __ipv6_sock_mc_join(sk, ub->ifindex, &remote->ipv6);
>>> +#endif
>>>        }
>>>        return err;
>>>    }

WBR, Sergei
