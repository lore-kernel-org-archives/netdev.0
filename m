From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 00/25] Conntracking and NAT in netns
Date: Mon, 23 Jun 2008 01:54:21 +0400
Message-ID: <20080622215420.GA4076@martell.zuzino.mipt.ru>
References: <20080622005916.GA5392@martell.zuzino.mipt.ru> <485EC724.1030005@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, den@openvz.org, xemul@openvz.org,
	ebiederm@xmission.com, benjamin.thery@bull.net
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:9782 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756577AbYFVV6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2008 17:58:30 -0400
Received: by ug-out-1314.google.com with SMTP id h2so381326ugf.16
        for <netdev@vger.kernel.org>; Sun, 22 Jun 2008 14:58:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <485EC724.1030005@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 22, 2008 at 11:41:56PM +0200, Daniel Lezcano wrote:
> Alexey Dobriyan wrote:
>> Hi, patchbomb below makes significant parts of connection tracking and
>> NAT code usable in netns and independent from other netns.
>> Status is that it is lightly tested but more or less works, I used it on
>> a box which provides NAT for another with all netdevices moved to netns,
>> routing and iptables rules set up and rules flushed in init_net.
>> So far so good.
>> Weak points:
>> a) races during netns destruction or conntrack modules unload
>>    (see more in patches)
>> b) grabbing netns from skb->dev or skb->dst->dev
>>    these places should be checked with extreme scrunity :-\
>> c) some stuff not converted (pptp, h323) -- it's like 10 minutes to make
>>    a patch and full day to setup and test it :^)
>> d) IPv6 conntracking wasn't tested.
>> e) ordering probably should be redone (or it shouldn't since netfilter
>>    is banned in netns as is, so nobody will care)
>
> You describe this patchset as no finished and there is a patch to not be 
> applied, shall I assume it is a RFC ?

Well, more or less. It's something like 90% similar to final thing
unless somebody will find some serious issue.

Patch to not be applied (yet) is for people wanting to try these patches
and not waste time fixing "iptables doesn't work" problem.

