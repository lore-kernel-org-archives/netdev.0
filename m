From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 5/5] bonding: Add tlb_dynamic_lb module parameter
Date: Wed, 02 Apr 2014 04:11:25 -0700
Message-ID: <1396437085.3989.36.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1396422017-32099-1-git-send-email-maheshb@google.com>
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
Received: from mail-pb0-f54.google.com ([209.85.160.54]:35074 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758419AbaDBLL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 07:11:28 -0400
Received: by mail-pb0-f54.google.com with SMTP id ma3so26412pbc.27
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2014 04:11:28 -0700 (PDT)
In-Reply-To: <1396422017-32099-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-04-02 at 00:00 -0700, Mahesh Bandewar wrote:
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
>     netperf -t TCP_RR -l 60 -s 5 -H <host> -- -r81920,81920
> 
> Transactions per second:
>     Before change: 1,367.11
>     After  change: 1,470.65
> 
> Change-Id: Ie3f75c77282cf602e83a6e833c6eb164e72a0990
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---

Sorry, but a new module parameter with no documentation of why it is
needed is not welcomed.

You provided all knobs to be able to set the parameter on each bonding,
so why do we have to introduce this global setting ?

Also please add documentation on Documentation/networking/bonding.txt
