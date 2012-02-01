From: Michal Soltys <soltys@ziu.info>
Subject: Re: VLAN 1 - Native
Date: Wed, 01 Feb 2012 20:26:53 +0100
Message-ID: <4F2991FD.8090407@ziu.info>
References: <1328095366.10975.YahooMailNeo@web29004.mail.ird.yahoo.com> <1328095449.75127.YahooMailNeo@web29014.mail.ird.yahoo.com> <1328101484.2595.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CADDf=MQ8EYEtOO2e5NJLrW0DKDz5xCBEBwuY6rxNu4Cybq=kKQ@mail.gmail.com> <CADDf=MQ=0eadY-zT_YAgp17fo_xRUh0dg6nHCLpNXcMQnUdyCQ@mail.gmail.com> <1328108723.2595.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CADDf=MRDa6C47ToCnR3_cTkfJR8VL9UAScwzwGVUDn3O4nL6fA@mail.gmail.com> <1328114680.76107.YahooMailNeo@web29019.mail.ird.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yao zhao <yao.development@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Leonardo Uzcudun <uzcudunl@yahoo.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:1237 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754426Ab2BAT0v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Feb 2012 14:26:51 -0500
In-Reply-To: <1328114680.76107.YahooMailNeo@web29019.mail.ird.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-02-01 17:44, Leonardo Uzcudun wrote:
> I'm sorry guys but i'm not understanding. Allow me to ask in a different way.
>
> I've a linux computer with 3 network cards (eth0, eth1 and eth2)
>
> eth0 is connected to a switch with vlans config.
> eth1 is connected to a network that has VID 1
> eth2 is connected to a network that has VID 101
>

Assuming you have:

eth0: 1u 101t
eth1: 1u
eth2: 101u

would this work for you ?:

ip link add link eth0 name eth0.101 type vlan id 101
ebtables -t broute -A BROUTING -i eth0 --vlan-id 101 -j DROP
brctl addbr br_vlan_1
brctl addbr br_vlan_101
brctl addif br_vlan_1 eth0 eth1
brctl addif br_vlan_101 eth0.101 eth2

ebtables should make 101 tagged traffic go through br_vlan_101 instead 
of br_vlan_1

I think there's also option for doing it with single bridge interface 
and some more complex ebtables rules, but the above if I didn't miss 
anything, should work fine.
