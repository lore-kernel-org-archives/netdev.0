From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC] bridge and friends: reduce TheLinuxWay(tm)
Date: Wed, 16 Oct 2013 16:22:08 -0400
Message-ID: <525EF570.3050105@redhat.com>
References: <525C62D5.3090004@mojatatu.com>	 <20131014144156.6dc52a78@nehalam.linuxnetplumber.net>	 <525E9AB1.6090502@mojatatu.com> <525EC8AF.6000902@redhat.com>	 <525ED1AE.7050101@mojatatu.com> <1381948550.2045.136.camel@edumazet-glaptop.roam.corp.google.com> <525EE00A.20209@redhat.com> <525EE2AC.50002@mojatatu.com> <525EF4E7.1030003@mojatatu.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7022 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762014Ab3JPUWR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 16:22:17 -0400
In-Reply-To: <525EF4E7.1030003@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/2013 04:19 PM, Jamal Hadi Salim wrote:
>
> And another little glitch, iflink specifies
>
>      [IFLA_AF_SPEC] = {
>          [AF_INET] = {
>              [IFLA_INET_CONF] = ...,
>          },
>          [AF_INET6] = {
>              [IFLA_INET6_FLAGS] = ...,
>              [IFLA_INET6_CONF] = ...,
>          }
>
> But then bridge hijacks it and specifies:
>    [IFLA_AF_SPEC] = {
>        [IFLA_BRIDGE_FLAGS]
>        [IFLA_BRIDGE_MODE]
>        [IFLA_BRIDGE_VLAN_INFO]
>    }
>
> Was that intended as:
>
>   [IFLA_AF_SPEC] = {
>     [AF_BRIDGE] = {
>         [IFLA_BRIDGE_FLAGS]
>         [IFLA_BRIDGE_MODE]
>         [IFLA_BRIDGE_VLAN_INFO]
>     }
>   }
>
> Now granted that bridging uses PF_BRIDGE as the family and iflink uses
> PF_UNSPEC - but i do think this one is polluting the namespace.
>

Yes, I know about that one.  BRIDGE_FLAGS started the polution and then 
we continued it with the other attributes....

-vlad

> cheers,
> jamal
