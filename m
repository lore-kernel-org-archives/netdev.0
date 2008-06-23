From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 05/25] netns ct: per-netns conntrack count
Date: Mon, 23 Jun 2008 12:12:14 +0200
Message-ID: <485F76FE.8030602@trash.net>
References: <20080622010411.GF5392@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	den@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	benjamin.thery@bull.net, dlezcano@fr.ibm.com
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080622010411.GF5392@martell.zuzino.mipt.ru>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> proc and sysctl are stubbed to init_net's value, that's for later.
> 
> Note: conntracks are recycled RCU-way, netns as well.
> During destruction, conntrack count of netns is decremented.
> I'm not sure it's not racy and it will not decrement in freed netns
> since conntrack doesn't pin netns (and pinning it is out of question).
> Probably, decrement should be moved earlier.
> 
> FWIW, I haven't seen this race (if it exists at all). But my cloning
> proggie sucks big way, so don't count on me. :^)


Since conntrack cleanup is invoken from netns cleanup while
the namespace still exists, this shouldn't happen. The
conntrack cleanup doesn't return until all entries are
freed, creation of new entries is prevented by unregistering
the hooks previously, at least without namespaces. Mhh ok,
actually this can happen since the hooks don't seem to be
per namespace. In that case, making sure that all devices
from that namespace are unregistered previously should
have the same effect.
