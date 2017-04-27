From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] routel: fix infinite loop in line parser
Date: Thu, 27 Apr 2017 16:46:47 -0700
Message-ID: <20170427164647.3f0e09bf@xeon-e3>
References: <20170427094347.3EB63A0F1C@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:34701 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754271AbdD0Xq4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 19:46:56 -0400
Received: by mail-pg0-f49.google.com with SMTP id v1so5757120pgv.1
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 16:46:55 -0700 (PDT)
In-Reply-To: <20170427094347.3EB63A0F1C@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Apr 2017 11:43:47 +0200 (CEST)
Michal Kubecek <mkubecek@suse.cz> wrote:

> As noticed by one of the few users of routel script, it ends up in an
> infinite loop when they pull out the cable from the NIC used for some
> route. This is caused by its parser expecting the line of "ip route show"
> output consists of "key value" pairs (except for the initial target range),
> together with an old trap of Bourne style shells that "shift 2" does
> nothing if there is only one argument left. Some keywords, e.g. "linkdown",
> are not followed by a value.
> 
> Improve the parser to
> 
>   (1) only set variables for keywords we care about
>   (2) recognize (currently) known keywords without value
> 
> This is still far from perfect (and certainly not future proof) but to
> fully fix the script, one would probably have to rewrite the logic
> completely (and I'm not sure it's worth the effort).
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Appled, but this really needs to be done better.
Either as a simplified output of route command. See ip -br link
Or ip route should have a json output option and use python/perl/xss
to reformat.
