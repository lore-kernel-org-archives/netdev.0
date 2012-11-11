From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH v3 8/7] pppoatm: fix missing wakeup in pppoatm_send()
Date: Sun, 11 Nov 2012 17:12:19 +0100
Message-ID: <20121111161219.GA25360@shrek.podlesie.net>
References: <1352240222-363-1-git-send-email-krzysiek@podlesie.net>
 <1352292734.7340.35.camel@shinybook.infradead.org>
 <20121110202338.GA1749@shrek.podlesie.net>
 <1352618933.9449.113.camel@shinybook.infradead.org>
 <20121111110437.GA25894@shrek.podlesie.net>
 <1352633993.9449.120.camel@shinybook.infradead.org>
 <20121111135002.GA32390@shrek.podlesie.net>
 <1352647601.9449.130.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	davem@davemloft.net
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1352647601.9449.130.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 11, 2012 at 03:26:41PM +0000, David Woodhouse wrote:
> On Sun, 2012-11-11 at 14:50 +0100, Krzysztof Mazur wrote:
> > Looks and works ok after:
> > +       atmvcc->unlock_cb = pppoatm_unlock_cb;
> 
> Heh, yeah. That would probably help :)
> 
> Not sure if it's really necessary to optimise out the unneeded wakeups ???
> I don't think that code path gets exercised very hard for normal passing
> of packets. Maybe only LCP echo and responses, on a live connection?
> 
> But yeah, the locking *is* that simple, isn't it ??? and not the painful
> stuff I had to do for the BLOCKED flag, which is why I deferred that
> question to concentrate on the basic concept of using ->release_cb().
> 
> So it's silly *not* to do the 'need_wakeup'. But could it also live in
> the 'blocked' word rather than expanding the structure further? Or just
> *use* the BLOCKED bit, for that matter?
> 

It would require using atomic ops because also pppoatm_pop() can modify this
word. I think it's better to add additional word instead of using
atomic ops.

Krzysiek
