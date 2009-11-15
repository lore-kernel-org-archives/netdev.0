From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] act_mirred: cleanup and optimization
Date: Sun, 15 Nov 2009 01:13:35 -0500
Message-ID: <1258265615.3251.10.camel@bigi>
References: <4AFCF06B.1090602@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:43551 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155AbZKOGNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Nov 2009 01:13:32 -0500
Received: by yxe17 with SMTP id 17so3974189yxe.33
        for <netdev@vger.kernel.org>; Sat, 14 Nov 2009 22:13:38 -0800 (PST)
In-Reply-To: <4AFCF06B.1090602@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2009-11-13 at 13:36 +0800, Changli Gao wrote:
> act_mirred: cleanup and optimization.
> 
> cleanup and optimization.
> 1. don't let go back using goto.
> 2. move checking if eaction is valid in tcf_mirred_init().
> 3. don't call skb_act_clone() until it is necessary.
> 4. one exit of the critical context.
> 5. allow eaction is TCA_INGRESS_MIRROR & TCA_INGRESS_REDIR.
> 

I would break this into the following patches:
patch 1: #1, #3, and #4 (this is what we discussed before)
patch 2: #2 (Ive had this in my todo list forever)

For #5 i think you misunderstood me earlier - TCA_INGRESS_* means
not to do dev xmit (that is the domain of TCA_EGRESS_*) but rather
something along the lines of netif_rx; this needs a lot of 
validation - the code has changed quiet a bit since the early days
and as it has turned out noone has exactly been shedding any tears
for that feature. The challenge is in the variety of netdevices which
have different semantics..

Sorry - I am in some hectic travel mode (hence delayed response)
but to answer your earlier question: no you cant redirect to packet
socket today.

cheers,
jamal

