From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] act_mirred: don't clone skb when skb isn't shared
Date: Sat, 05 Jun 2010 08:53:55 -0400
Message-ID: <1275742435.3490.31.camel@bigi>
References: <1275658990-15838-1-git-send-email-xiaosuo@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:64898 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933259Ab0FEMx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 08:53:59 -0400
Received: by vws5 with SMTP id 5so981543vws.19
        for <netdev@vger.kernel.org>; Sat, 05 Jun 2010 05:53:59 -0700 (PDT)
In-Reply-To: <1275658990-15838-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-06-04 at 21:43 +0800, Changli Gao wrote:
> don't clone skb when skb isn't shared
> 
> When the tcf_action is TC_ACT_STOLEN, and the skb isn't shared, we don't need
> to clone a new skb. As the skb will be freed after this function returns, we
> can use it freely once we get a reference to it.

It looks like a good optimization - but i am not a big fan of one-offs
[because usability goes down and I am forced to explain it longer in the
rules (refer to: Documentation/networking/tc-actions-env-rules.txt)]

How about you update skb_act_clone to take take the action code as well
and do the check the if stolen/queued it does a skb_get otherwise it
calls skb_clone?

cheers,
jamal

