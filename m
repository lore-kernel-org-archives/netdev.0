From: jamal <hadi@cyberus.ca>
Subject: Re: one more... iproute commands lockup whole system
Date: Wed, 04 Apr 2007 10:10:10 -0400
Message-ID: <1175695810.4063.10.camel@localhost>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net>
	 <20070322124533.M79867@visp.net.lb> <46027FF2.6020001@trash.net>
	 <20070322101224.3e6bb899@freekitty>  <20070404000054.M58020@visp.net.lb>
	 <1175649016.3957.10.camel@localhost> <461301C0.2050409@trash.net>
	 <20070404020622.M69215@visp.net.lb> <1175684114.4088.12.camel@localhost>
	 <20070404125231.M65138@visp.net.lb>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:8457 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753855AbXDDOKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 10:10:13 -0400
Received: by wx-out-0506.google.com with SMTP id h31so234347wxd
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2007 07:10:13 -0700 (PDT)
In-Reply-To: <20070404125231.M65138@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-04-04 at 15:56 +0300, Denys wrote:

> Rules:
> tc qdisc del dev eth0.5 root
> tc qdisc add dev eth0.5 handle 1: root htb
> tc class add dev eth0.5 parent 1:0 classid 1:2 htb rate 128Kbit
> 
> tc qdisc add dev eth0.5 parent 1:2 handle 2: prio
> 
> tc filter add dev eth0.5 parent 1: protocol ip prio 10 u32 \
> match ip src 195.69.208.253/32 flowid 1:2
> 
> tc filter add dev eth0.5 parent 2: protocol ip prio 10 u32 \
>     match ip src 195.69.208.253/32 flowid 2:1 \
>     action mirred egress redirect dev eth0.6
>
> (it is not working, but just i tried few things)
> 

This will still mean the physical device is eventually going to be 
eth0. You are hanging, correct?
If you redirected to another vlan ontop of a different physical
ethernet, and the problem persists then it will be worrisome.
Actually i am begining to doubt myself. Maybe the vlan device is acting
strangely. I will try to test your simple setup towards the end of day
and see what happens.

cheers,
jamal




