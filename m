From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Can we rely on ethernet header padding?
Date: Tue, 19 Mar 2013 14:25:53 -0700
Message-ID: <20130319142553.3e08e7b9@nehalam.linuxnetplumber.net>
References: <20130319150545.GA18218@unicorn.suse.cz>
	<1363706495.2558.14.camel@edumazet-glaptop>
	<20130319154806.GB18218@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130319154806.GB18218@unicorn.suse.cz>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 19 Mar 2013 16:48:06 +0100
Michal Kubecek <mkubecek@suse.cz> wrote:

> On Tue, Mar 19, 2013 at 08:21:35AM -0700, Eric Dumazet wrote:
> > 
> > Normally a driver has NET_SKB_PAD bytes of headroom before the ethernet
> > header, so the bridge code is safe only if all drivers use this
> > NET_SKB_PAD padding on receive side. And they really should for
> > performance reasons.
> > 
> > Better not touch bridge code to catch offending drivers
> 
> That makes sense. Thank you for your reply.
> 

My view is that the bridge code must check before assuming headroom.
But because of that, it means a packet copy would be necessary for cases
where packets arrive without enough headroom.
