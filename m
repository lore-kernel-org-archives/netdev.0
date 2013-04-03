From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [Suggestion] ISDN: isdnloop:  C grammar issue,  '}' miss match
 'if' and 'switch' statement.
Date: Wed, 3 Apr 2013 17:08:09 +0200
Message-ID: <20130403150809.GC3401@unicorn.suse.cz>
References: <515C303B.1040304@asianux.com>
 <20130403140823.GB3401@unicorn.suse.cz>
 <1364999477.13853.21.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chen Gang <gang.chen@asianux.com>, fengguang.wu@intel.com,
	isdn@linux-pingi.de,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Joe Perches <joe@perches.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:48385 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761450Ab3DCPIL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Apr 2013 11:08:11 -0400
Content-Disposition: inline
In-Reply-To: <1364999477.13853.21.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 03, 2013 at 07:31:17AM -0700, Eric Dumazet wrote:
> On Wed, 2013-04-03 at 16:08 +0200, Michal Kubecek wrote:
> 
> > As far as I can see, this rather comes from
> > 
> > commit 475be4d85a274d0961593db41cf85689db1d583c
> > Author: Joe Perches <joe@perches.com>
> > Date:   Sun Feb 19 19:52:38 2012 -0800
> > 
> >     isdn: whitespace coding style cleanup
> 
> And what is the problem exactly ?
> 
> # make drivers/isdn/isdnloop/isdnloop.o
>   ...
>   CC [M]  drivers/isdn/isdnloop/isdnloop.o
> 
> No error here.

I just checked that gcc (surprisingly - at least for me) accepts

	switch(a) {
	case 1:
		if(...) {
			do_something();
			break;
		case 2:
			...
			break;
		default:
			...
			break;
		}
	}

and it seems to work the same as

	switch(a) {
	case 1:
		if(...) {
			do_something();
		}
		break;
	case 2:
		...
		break;
	default:
		...
		break;
	}

However, I can't think of a reason to use the former.

Michal Kubecek
