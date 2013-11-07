From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Using HTB over MultiQ
Date: Thu, 07 Nov 2013 06:54:28 -0800
Message-ID: <1383836068.9412.71.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAEzD07+Haf-Kg52H7GsxC5XiQn2KXozHbxgL4Lvn0grhFXVFmA@mail.gmail.com>
	  <1383833480.9412.58.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1383834021.9412.61.camel@edumazet-glaptop2.roam.corp.google.com>
	 <527BA63F.7040900@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Anton 'EvilMan' Danilov <littlesmilingcloud@gmail.com>,
	netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:35273 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933Ab3KGOyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 09:54:31 -0500
Received: by mail-pb0-f48.google.com with SMTP id mc8so685646pbc.7
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 06:54:30 -0800 (PST)
In-Reply-To: <527BA63F.7040900@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-07 at 06:39 -0800, John Fastabend wrote:

> 
> With the multiq qdisc you could attach filter to the root qdisc and use
> skbedit to set the queue_mapping field,
> 
> #tc filter add dev eth0 parent 1: protocol ip prio 1 u32 \
> 	match ip dst 192.168.0.3 \
> 	action skbedit queue_mapping 3
> 

Oh right, this is the way ;)

I wonder if we can have 'action skbedit rxhash 34' ?


> if you configure the filters to map to the correct classes this would
> work.
> 
> Or another way would be use mqprio and steer packets to HTB classes
> using the skb->priority. The priority can be set by iptables/nftables
> or an ingress filter.

Yes, but this might duplicate the 'customer' tree Anton has to put on
the filters anyway ?
