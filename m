From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: cannot ARP macvlan on top of bonding device
Date: Fri, 19 Sep 2014 14:32:12 -0700
Message-ID: <1411162332.26859.36.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140919210040.E09BA481010@fruggeri-Arora18.sjc.aristanetworks.com>
	 <1411161451.26859.32.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fruggeri@arista.com, davem@davemloft.net,
	herbert@gondor.apana.org.au
To: Francesco Ruggeri <fruggeri@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:46378 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758103AbaISVcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 17:32:15 -0400
Received: by mail-pd0-f181.google.com with SMTP id r10so678943pdi.12
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 14:32:14 -0700 (PDT)
In-Reply-To: <1411161451.26859.32.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-19 at 14:17 -0700, Eric Dumazet wrote:

> You're right, we probably should use netdev_max_backlog instead.
> 
> Please send a formal patch ?

BTW, we should add a cond_resched() in macvlan_process_broadcast() ...

It also seems MACVLAN_SKB_CB(skb)->src escapes an RCU protected region,
without taking a refcount on struct macvlan_dev

This seems racy to me :(
