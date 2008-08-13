From: "Pravin Bathija" <pbathija@amcc.com>
Subject: RE: [Qdisc] Prioritizing traffic per vlan using qdisc.
Date: Wed, 13 Aug 2008 10:05:03 -0700
Message-ID: <9D1E2BDCB5C57B46B56E6D80843439EB05990123@SDCEXCHANGE01.ad.amcc.com>
References: <20080811181712.462cb2cf@extreme>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Stephen Hemminger" <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sdcmail02-ext1.amcc.com ([198.137.200.73]:36321 "EHLO
	sdcmail02.amcc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757216AbYHMRFD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 13:05:03 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080811181712.462cb2cf@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

-----Original Message-----
From: Stephen Hemminger [mailto:stephen.hemminger@vyatta.com] 
Sent: Monday, August 11, 2008 6:17 PM
To: Pravin Bathija
Cc: netdev@vger.kernel.org
Subject: Re: [Qdisc] Prioritizing traffic per vlan using qdisc.

On Mon, 11 Aug 2008 17:48:22 -0700
"Pravin Bathija" <pbathija@amcc.com> wrote:

> Using Linux 2.6.23 I want to create multiple Vlans for voice, data, 
> video etc. The requirement is to prioritize each vlan on the ingress 
> and egress. I am looking at qdisc to do this however without success. 
> Could you please advise is there is a way to do this using qdisc 
> tc(traffic
> control) commands. If not - is there another way to do this in Linux ?
> Any help would be greatly appreciated.
> 
> Thanks,
> Pravin
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in 
> the body of a message to majordomo@vger.kernel.org More majordomo info

> at  http://vger.kernel.org/majordomo-info.html

> For 2.6.25, an addition to the tc meta match to allow matching on vlan
tag was added.  Using this it is possible to use meta match to>  convert
tag -> flowid then use the flowid with a priority (or htb) queue.

Thanks for your input Stephen. So here is the problem: I created 3 vlans
on "eth1" interface with the following ips
eth1.4: 192.152.0.11
eth1.5: 192.154.0.11
eth1.6: 192.156.0.11
Now I created an ingress qdisc on eth1 and defined filters in the
following way. The filter configuration below  gives priority to packets
received from subnet 192.152.0.0 then 192.154.0.0 and finally
192.156.0.0 
tc qdisc add dev eth1 ingress 
tc filter add dev eth1 parent ffff: protocol ip prio 1 u32 match ip src
192.152.0.0/24 flowid :1 
tc filter add dev eth1 parent ffff: protocol ip prio 2 u32 match ip src
192.154.0.0/24 flowid :2
tc filter add dev eth1 parent ffff: protocol ip prio 3 u32 match ip src
192.156.0.0/24 flowid :3

# tc qdisc show eth1
qdisc ingress ffff: parent ffff:fff1 ---------------- 
When I send concurrent traffic to these 3 interfaces using "ttcp" all of
the above complete reception of data at the same time. With the above
filter I would expect flowid :1 to complete receiving data before
others. I also notice that when I run the following command "tc filter
show dev eth1" it does not list any filters. My linux kernel is compiled
with CONFIG_NET_SCHED. 
Am I missing something here ? Please advise.




