From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: tc-ipt v0.2: Extension does not know id 1504083504
Date: Fri, 29 Sep 2017 23:52:33 -0700
Message-ID: <7c4735f2-3f0a-093b-2dfc-8b25c08caf05@fatooh.org>
References: <CAGv8E+wkpsZL8SMzx+oXei6245RU+SacrBcUN7p2RtXcaBCafw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: "Sergey K." <simkergey@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from juniper.fatooh.org ([173.255.221.30]:36384 "EHLO
        juniper.fatooh.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750933AbdI3G7b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 02:59:31 -0400
In-Reply-To: <CAGv8E+wkpsZL8SMzx+oXei6245RU+SacrBcUN7p2RtXcaBCafw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-09-29 23:34, Sergey K. wrote:
> Hello.
> 
> I have to apply this patch
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git/commit/?h=v4.10.0&id=97a02cabefb2e2dcfe27f89943709afa84be5525
> 
> to my version of iproute2.
> But now I have a new information message, when I'm using construction like this:
> 
> tc filter add dev eth0 parent ffff: u32 match u32 0 0 action xt -j
> MARK --set-mark 0
> 
> message text:
> tc-ipt v0.2: Extension does not know id 1504083504
> 
> 
> I'm using Debian Stretch, kernel 4.9.0-3-amd64, iptables 1.6.0 and
> patched iproute 4.9.0
> 
> How to solve?

Funny, I just ran into this too and subscribed here to report it. The 
error occurs during parsing of any options to the jump target; if the 
target has no options, there is no error.

The problem seems to be an outdated version of struct xtables_target in 
include/xtables.h. The version in iptables has an additional member 
"udata" that makes the offsets in the struct different for anything 
following.

A quick fix for this particular problem is to copy include/xtables.h from:
git://git.netfilter.org/iptables
...into include/ in the iproute2 source, then recompile after a 'make 
clean'.

As for a comprehensive fix, I don't know--presumably other headers in 
include/ may be out of date, but I don't want to just blindly send a 
patch unless someone who knows the ramifications says it's ok. This 
seems like it would need maintainer oversight. If there's something I 
can do, though, let me know.

-Corey
