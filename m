From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: IPV6 nf defrag does not work
Date: Tue, 29 Oct 2013 15:30:30 +0100
Message-ID: <20131029143030.GC18526@minipsycho.orion>
References: <20131029105208.GA18526@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	yoshfuji@linux-ipv6.org, kadlec@blackhole.kfki.hu, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f171.google.com ([209.85.215.171]:60351 "EHLO
	mail-ea0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755542Ab3J2Oad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 10:30:33 -0400
Received: by mail-ea0-f171.google.com with SMTP id h10so1366816eak.16
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 07:30:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20131029105208.GA18526@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 29, 2013 at 11:52:08AM CET, jiri@resnulli.us wrote:
>Hi All.
>
>On the current net-next if you on HOSTA do:
>ip6tables -I INPUT -p icmpv6 -j DROP
>ip6tables -I INPUT -p icmpv6 -m icmp6 --icmpv6-type 128 -j ACCEPT
>
>and on HOSTB you do:
>ping6 HOSTA -s2000    (MTU is 1500)
>
>Only the first ICMP echo request will be passed through, the rest is not
>passed on HOSTA. This issue does not occur with smaller packets than MTU (where
>fragmentation does not happen).
>

Hmm. The reason why first packet goes through is because of:
commit 58a317f1061c894d2344c0b6a18ab4a64b69b815
Author: Patrick McHardy <kaber@trash.net>
Date:   Sun Aug 26 19:14:12 2012 +0200

    netfilter: ipv6: add IPv6 NAT support


First packet will hit "if ((help && help->helper) || !nf_ct_is_confirmed(ct))"
(ct is uncorfirmed for it).


For this, nf_conntrack_ipv6 has to be loaded. Continuing investigation.



>I'm trying to find out where the problem is.
>
>Any quick ideas?
>
>Thanks
>
>Jiri
