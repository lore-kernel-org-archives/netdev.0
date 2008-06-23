From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 12/25] netns ct: actualy enable in netns
Date: Mon, 23 Jun 2008 12:49:32 +0200
Message-ID: <485F7FBC.9040302@trash.net>
References: <20080622011108.GM5392@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	den@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	benjamin.thery@bull.net, dlezcano@fr.ibm.com
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080622011108.GM5392@martell.zuzino.mipt.ru>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> Known to not work/broken:
> 1) event cache -- double free if netns flushes event cache, not netns-ready,
>    haven't looked into this.

The event cache also needs to be per namespace, its not allowed to
be flushed it while connection tracking is still active.

> 2) NOTRACK -- amazing circular dependencies and compile breakages if nf_conn
>    is embedded into netns_ct.
> 
>    This is easy excuse, real excuse is from where to grab netns that early.
>    and since we wait until untracked refcount drops to zero it should be per-netns
>    otherwise one netns which uses NOTRACK can prevent other from stopping.

Yes. For untracked connections we usually return before doing
any real work, so maybe you don't need a valid netns pointer
for the untrack conntrack entry?
