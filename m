From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH 3/3] [RFC] TCP syncookies: only allow 3 MSS values by
 default to mitigate spoofing attacks
Date: Tue, 27 Aug 2013 15:52:21 +0200
Message-ID: <20130827135221.GB1195@midget.suse.cz>
References: <520A3B4A.1050704@jakoblell.com>
 <20130815235743.GA25665@midget.suse.cz>
 <20130816000523.GC11950@midget.suse.cz>
 <20130816213101.GD5154@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>, Jakob Lell <jakob@jakoblell.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42582 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753062Ab3H0NwZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 09:52:25 -0400
Content-Disposition: inline
In-Reply-To: <20130816213101.GD5154@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First of all - I don't really care about the default values as
long as they are tunable at run time. I'm fine with leaving the 8
valye MSS table as a default.

On Fri, Aug 16, 2013 at 11:31:01PM +0200, Florian Westphal wrote:
> Jiri Bohac <jbohac@suse.cz> wrote:
> > Rationale for the new values
> > - most packets are (1500 - headers); (1450 - headers) is not a huge waste and
> >   prevents fallback to much lower values
> 
> Still, 1410 seems weird.

I was thinking the path MTU would often be 1500 minus something
for various tunnelling/encapsualtion along the path. The packets
may have some options, so the 1450 was just a wild guess.

If we have only 3 differrent MSS values, I feel it is better to
waste 50 bytes on the "standard" 1500 MTU links instead of making 
packets with options and tunelled traffic fall back to something
like 500.

> > - clients will rarely send MSS below 536, so that's a safe fallback
> 
> Can you elaborate?
> You say 'is a safe fallback', yet it is removed in the patch?

Yeah, sorry,  I was writing the patch description before the patch
itself; I noticed the 512 in the original table and thought it
would be a good idea to keep this.

> > - we need to keep the minimum (64)

I don't know - I could imagine there is some embedded hardware
that can't do fragmentation and advertises very low MSS instead, for
example. I just felt removing this fallback could break things.
I'm not sure. 


-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
