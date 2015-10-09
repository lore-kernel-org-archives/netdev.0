From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 0/4] tcp: better smp listener behavior
Date: Fri, 09 Oct 2015 03:53:27 -0700
Message-ID: <1444388007.27760.58.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1444358004-26483-1-git-send-email-edumazet@google.com>
	 <56173FA6.70701@fastly.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Grant Zhang <gzhang@fastly.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36173 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754093AbbJIKx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 06:53:29 -0400
Received: by pablk4 with SMTP id lk4so84074908pab.3
        for <netdev@vger.kernel.org>; Fri, 09 Oct 2015 03:53:29 -0700 (PDT)
In-Reply-To: <56173FA6.70701@fastly.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-10-08 at 21:16 -0700, Grant Zhang wrote:

> 
> Does it make sense to make the listener hash table percpu? Socket with 
> SO_INCOMING_CPU set could just be add to the hashtable for that specific 
> cpu.

Not sure : We plan to upstream a patch adding a soreuseport specific
table to make the lookup time independent of number of sockets bound to
one particular port. This simply adds an RCU protected array, with
ability to immediately fetch slot number X from this array.
