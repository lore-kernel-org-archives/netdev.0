From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 21/25] netns ct: per-netns event cache
Date: Fri, 05 Sep 2008 13:34:39 +0200
Message-ID: <48C1194F.7030608@trash.net>
References: <20080821220445.GU31136@x200.localdomain> <48C013BE.3060800@trash.net> <20080905034415.GB2789@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080905034415.GB2789@x200.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> On Thu, Sep 04, 2008 at 06:58:38PM +0200, Patrick McHardy wrote:
>> adobriyan@gmail.com wrote:
>>>  static inline void
>>> -nf_conntrack_event_cache(enum ip_conntrack_events event,
>>> +nf_conntrack_event_cache(struct net *net, enum ip_conntrack_events event,
>>>  			 const struct sk_buff *skb)
>>>  {
>> Passing the conntrack instead of the struct net and the skb
>> would probably keep the callers cleaner.
> 
> Dunno, passing netns explicitly like saying conntrack event happened in
> netns A, which is reasonable. OTOH, s/skb/ct/ is indeed nicer.
> 
> I'll change it as you suggest and see what happens.
> 
> BTW, I asked earlier if untracked conntracks are ever supposed to drop into
> event cache. If they're, trimming nf_conntrack_untracked is out of question.

No, they are skipped by the only event handler, ctnetlink.
