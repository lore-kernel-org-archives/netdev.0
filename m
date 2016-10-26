From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] tc: m_mirred: Fix parsing of 'index'
 optional argument
Date: Wed, 26 Oct 2016 11:23:02 -0700
Message-ID: <20161026112302.7d7fecd0@xeon-e3>
References: <1477080075-17146-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34980 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751129AbcJZSWq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 14:22:46 -0400
Received: by mail-pf0-f175.google.com with SMTP id s8so1139588pfj.2
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 11:22:46 -0700 (PDT)
In-Reply-To: <1477080075-17146-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Oct 2016 23:01:15 +0300
Shmulik Ladkani <shmulik.ladkani@gmail.com> wrote:

> Code in parse_mirred() suggests "index" argument can be placed either
> after the "egress" clause, or as the first argument (after "action mirred").
> 
> However, parse_egress() fails to correctly parse "index" if it's the
> first argument.
> 
> For example:
> 
>  # tc filter add ... action mirred index 5
>  RTNETLINK answers: Invalid argument
>  (unnecessary RTNETLINK issued, should have been parse error)
> 
>  # tc filter add ... action mirred index 5 egress redirect dev eth0
>  bad action type egress
>  (should have been parsed successfully)
> 
> Fix parse_egress as follows:
>  - continue parsing after valid "index" is seen
>  - don't issue the RTNETLINK unless valid "egress" is seen
> 
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Looks like a good fix but does not apply cleanly to current net-next branch.

Please cleanup and resubmit.
