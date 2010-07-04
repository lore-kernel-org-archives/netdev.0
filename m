From: Andrew Beverley <andy@andybev.com>
Subject: Re: QoS weirdness : HTB accuracy
Date: Sun, 04 Jul 2010 18:50:07 +0100
Message-ID: <1278265807.1506.86.camel@andybev>
References: <067c83163988908ef546d7ff7f560a17@localhost>
	 <4BF32BB0.7010700@redfish-solutions.com>
	 <e6bd0cff8dafc8b3af0760facb5fdc8c@localhost>
	 <1276204948.1403.13.camel@andybev>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>,
	Netdev <netdev@vger.kernel.org>,
	netfilter <netfilter@vger.kernel.org>
To: Julien Vehent <julien@linuxwall.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earth.simplelists.com ([89.16.184.171]:55407 "EHLO
	earth.simplelists.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754528Ab0GDRue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jul 2010 13:50:34 -0400
In-Reply-To: <1276204948.1403.13.camel@andybev>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > I was, in fact, an error in my ruleset. I had put the 'linklayer atm' at
> > both the branch and leaf levels, so the overhead was computed twice,
> > creating those holes in the bandwidth.
> 
> I am seeing similar behaviour with my setup. Am I making the same
> mistake? A subset of my rules is as follows:
> 
> 
> tc qdisc add dev ppp0 root handle 1: htb r2q 1
> 
> tc class add dev ppp0 parent 1: classid 1:1 htb \
>     rate ${DOWNLINK}kbit ceil ${DOWNLINK}kbit \
>     overhead $overhead linklayer atm                   <------- Here
> 
> tc class add dev ppp0 parent 1:1 classid 1:10 htb \
>     rate 612kbit ceil 612kbit prio 0 \
>     overhead $overhead linklayer atm                   <------- And here
> 
> tc qdisc add dev ppp0 parent 1:10 handle 4210: \
>     sfq perturb 10 limit 50
> 
> tc filter add dev ppp0 parent 1:0 protocol ip \
>     prio 10 handle 10 fw flowid 1:10

I removed the overhead option on the first leaf, and the speeds change
to what I expect. However, the rules above are taken straight from the
ADSL Optimizer project, which was the source of the original overhead
patch for tc. So is the ADSL Optimizer project wrong?

Andy


