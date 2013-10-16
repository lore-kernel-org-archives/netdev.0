From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC] bridge and friends: reduce TheLinuxWay(tm)
Date: Wed, 16 Oct 2013 16:19:51 -0400
Message-ID: <525EF4E7.1030003@mojatatu.com>
References: <525C62D5.3090004@mojatatu.com>	 <20131014144156.6dc52a78@nehalam.linuxnetplumber.net>	 <525E9AB1.6090502@mojatatu.com> <525EC8AF.6000902@redhat.com>	 <525ED1AE.7050101@mojatatu.com> <1381948550.2045.136.camel@edumazet-glaptop.roam.corp.google.com> <525EE00A.20209@redhat.com> <525EE2AC.50002@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: vyasevic@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f176.google.com ([209.85.213.176]:40465 "EHLO
	mail-ye0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760915Ab3JPUTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 16:19:53 -0400
Received: by mail-ye0-f176.google.com with SMTP id l4so288267yen.35
        for <netdev@vger.kernel.org>; Wed, 16 Oct 2013 13:19:52 -0700 (PDT)
In-Reply-To: <525EE2AC.50002@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And another little glitch, iflink specifies

     [IFLA_AF_SPEC] = {
         [AF_INET] = {
             [IFLA_INET_CONF] = ...,
         },
         [AF_INET6] = {
             [IFLA_INET6_FLAGS] = ...,
             [IFLA_INET6_CONF] = ...,
         }

But then bridge hijacks it and specifies:
   [IFLA_AF_SPEC] = {
       [IFLA_BRIDGE_FLAGS]
       [IFLA_BRIDGE_MODE]
       [IFLA_BRIDGE_VLAN_INFO]
   }

Was that intended as:

  [IFLA_AF_SPEC] = {
    [AF_BRIDGE] = {
        [IFLA_BRIDGE_FLAGS]
        [IFLA_BRIDGE_MODE]
        [IFLA_BRIDGE_VLAN_INFO]
    }
  }

Now granted that bridging uses PF_BRIDGE as the family and iflink uses
PF_UNSPEC - but i do think this one is polluting the namespace.

cheers,
jamal
