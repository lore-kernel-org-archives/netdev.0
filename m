From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 5/5] bonding: Add tlb_dynamic_lb module parameter
Date: Mon, 31 Mar 2014 09:00:02 -0700
Message-ID: <1396281602.29410.44.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1396070949-17783-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:50637 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982AbaCaQAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 12:00:05 -0400
Received: by mail-pa0-f45.google.com with SMTP id kl14so8418296pab.32
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 09:00:04 -0700 (PDT)
In-Reply-To: <1396070949-17783-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-03-28 at 22:29 -0700, Mahesh Bandewar wrote:
> The aggresive load balancing causes packet re-ordering as active
> flows are moved from a slave to another within the group. Sometime
> this aggresive lb is not necessary if the preference is for less
> re-ordering. This module parameter if used with value "0" disables
> this dynamic flow shuffling minimizing packet re-ordering. Of course
> the side effect is that it has to live with the static load balancing
> that the hashing distribution provides. This impact is less severe if
> the correct xmit-hashing-policy is used for the tlb setup.
> 
> The default value of the parameter is set to "1" mimicing the earlier
> behavior.
> 
> Ran the netperf test with 200 stream for 1 min between two hosts with
> 4x1G trunk (xmit-lb mode with xmit-policy L3+4) before and after these
> changes. Following was the command used for those 200 instances -
> 
>     netperf -t TCP_RR -l 60 -s 5 -H <host> -- -r1,1024

There is reordering potential in this workload, as we have at most one
packet containing payload in flight ?

> 
> Transactions per second:
>     Before changes: 109250
>     After  changes: 113752
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---

>  			      "each slaves peer switch. The default is 1.");
> +module_param(tlb_dynamic_lb, int, 0644);
> +MODULE_PARM_DESC(tlb_dynamic_lb, "Enable periodic flow balancing. "
> +				 "The default is 1.");

I am a bit unsure why we need to add a new global parameter.

If the tlb_dynamic_lb can be dynamically changed on a bonding device,
why adding this ?
