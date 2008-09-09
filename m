From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 17/33] netns ct: final init_net tweaks
Date: Tue, 09 Sep 2008 09:51:56 +0200
Message-ID: <48C62B1C.7070104@trash.net>
References: <48C01046.2070704@trash.net> <1220842990-30500-17-git-send-email-adobriyan@gmail.com> <48C623CA.9060803@trash.net> <20080909073245.GA7307@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65431 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753657AbYIIHwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 03:52:01 -0400
In-Reply-To: <20080909073245.GA7307@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> On Tue, Sep 09, 2008 at 09:20:42AM +0200, Patrick McHardy wrote:
>> Having multiple of these net_eq checks per function (14 total) is
>> not a very nice way to do this.
> 
> Yep, I was just afraid of some subtle ordering rules and to keep
> potential init_net breakage to minimum.

Me too, but I still prefer to do it properly once.

>> How about splitting the code into a netns and a global part instead?
> 
> Prebably they aren't strict at all.

Not particulary. For cleanup a three stage approach with

1. init_net deactivation (ip_ct_attach = NULL)
2. generic netns cleanup
3. init_net specific final cleanup (slab cache, nf_conntrack_cachep,
    accounting, helpers, protocols, ...)

should work fine.

The initialization should be OK with just a init_net part
and a generic netns part.
