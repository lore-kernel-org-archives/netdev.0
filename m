From: "Chris Leech" <chris.leech@gmail.com>
Subject: Re: problems with e1000 and jumboframes
Date: Fri, 4 Aug 2006 08:34:46 -0700
Message-ID: <41b516cb0608040834o1d433f23v2f2ba1a1b05ccbc6@mail.gmail.com>
References: <41b516cb0608031334s6e159e99tb749240f44ae608d@mail.gmail.com>
	 <E1G8sif-0003oY-00@gondolin.me.apana.org.au>
	 <20060804061513.GB413@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>, arnd@arndnet.de,
	olel@ans.pl, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:9025 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1161244AbWHDPes (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 11:34:48 -0400
Received: by ug-out-1314.google.com with SMTP id q2so228811uge
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2006 08:34:46 -0700 (PDT)
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
In-Reply-To: <20060804061513.GB413@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/3/06, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> On Fri, Aug 04, 2006 at 03:59:37PM +1000, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> > Interesting.  Could you guys post figures on alloc_page speed vs. kmalloc?
>
> They probalby measured kmalloc cache access, which only falls to
> alloc_pages when cache is refilled, so it will be faster for some short
> period of time, but in general (especially for such big-sized
> allocations) it is essencially the same.

I think you're right about that.  In particular, I think Jesse was
looking at the impact that changing the drivers buffer allocation
method would have on 1500 byte MTU users.  With a running network
driver you should see lots of fixed size allocations hitting the slab
cache, and occasionally causing an alloc_pages.  If you replace that
with a call to alloc_pages for every packet that ever gets received
it's a performance hit.

So how many skb allocation schemes do you code into a single driver?
Kmalloc everything, page alloc everything, combination of kmalloc and
page buffers for hardware that does header split?  That's three
versions of the drivers receive processing and skb allocation that
need to be maintained.

> > Also, getting memory slower is better than not getting them at all :)

Yep.

- Chris
