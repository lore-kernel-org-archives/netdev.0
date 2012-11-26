From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH RFC] [INET]: Get cirtical word in first 64bit of cache
 line
Date: Mon, 26 Nov 2012 20:40:39 +0000
Message-ID: <1353962439.2717.13.camel@bwh-desktop.uk.solarflarecom.com>
References: <1353900555-5966-1-git-send-email-ling.ma.program@gmail.com>
	 <1353912241.30446.1257.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <ling.ma.program@gmail.com>, <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1353912241.30446.1257.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2012-11-25 at 22:44 -0800, Eric Dumazet wrote:
> On Mon, 2012-11-26 at 11:29 +0800, ling.ma.program@gmail.com wrote:
> > From: Ma Ling <ling.ma.program@gmail.com>
> > 
> > In order to reduce memory latency when last level cache miss occurs,
> > modern CPUs i.e. x86 and arm introduced Critical Word First(CWF) or
> > Early Restart(ER) to get data ASAP. For CWF if critical word is first member
> > in cache line, memory feed CPU with critical word, then fill others
> > data in cache line one by one, otherwise after critical word it must
> > cost more cycle to fill the remaining cache line. For Early First CPU will
> > restart until critical word in cache line reaches.
> > 
> > Hash value is critical word, so in this patch we place it as first member
> > in cache line(sock address is cache-line aligned), and it is also good for
> > Early Restart platform as well .
> > 
> > Thanks
> > Ling
> 
> networking patches should be sent to netdev.
> 
> (I understand this patch is more a generic one, but at least CC netdev)
> 
> You give no performance numbers for this change...
> 
> I never heard of this CWF/ER, where are the official Intel documents
> about this, and what models really benefit from it ?
[...]

CWF is a standard feature of SDRAM.  Ulrich Drepper's series of articles
on memory covers this in part 2 <http://lwn.net/Articles/252125/>
section 3.5.2.  As for whether it's slower to start fetching from the
middle, that may depend on the memory controller and memory type that
are used.  Drepper's benchmark showed only a small penalty (<1%) for
fetching from the middle, though he didn't say anything particular about
the hardware configuration.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
