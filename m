From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [GIT] Networking
Date: Tue, 15 Mar 2011 08:52:40 -0400
Message-ID: <1300193560.9910.265.camel@gandalf.stny.rr.com>
References: <20110310.155556.48513201.davem@davemloft.net>
	 <AANLkTik3AyFTNoytebmOOZ=JSFMkt0bw7au-CSncUHJu@mail.gmail.com>
	 <20110311204823.GB7906@fieldses.org>
	 <20110311.130128.71121155.davem@davemloft.net>
	 <1299878274.2814.8.camel@bwh-desktop> <20110311214209.GB9404@fieldses.org>
	 <20110312040941.GA15526@home.goodmis.org>
	 <alpine.DEB.2.00.1103150019060.5340@asgard.lang.hm>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: david@lang.hm
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1103150019060.5340@asgard.lang.hm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-03-15 at 00:20 -0700, david@lang.hm wrote:

> > It really is meaningless to do so, as all you are doing is documenting
> > what commit caused this bug, and producing more problems by branching
> > off of the broken commit. It wont matter till it is merged, but then if
> > there are a lot of simple bug fixes, then you will have a lot of single
> > merges of branches that fix those bugs.
> 
> what effect would this have on bisecting? if this helped people avoid 
> bisecting in between the bad commit and the fix for it, it may be worth 
> it.
> 

But it wont, as the fix will still be brought in at a later time. It has
nothing to do with being based off of the broken commit.

         A  +
            +   merged in fix
         B  + \
            |  |
            |  |
            |  |
Lots of     |  |
  stuff     |  |
            |  |
            |  |
            |  + - fix for bug
            | /
 Bug commit +
            |

A bisect will still be testing lots of stuff without that fix. And if it
goes into the branch with the fix, we just brought the kernel way back
in time from point A. Then if it goes back to point B, then we zoom back
to the future and bounce the kernel all over the place.

I see no gain for having a fixed based off of the bug that it fixes.

Pros of doing this:

1) documents the point that things broke (can be done by commenting it
in the change log too)

2) probably good for back porting (but Con 3 may out weigh this)

Cons:

1) Adds many more branches and merges for no real good reason

2) Makes bisects even less linear than it already is

3) May cause more conflicts at the merge point as the broken code may
have changed.



Who will be doing the conflict resolutions? Linus? I doubt he would be
happy with that, but he can speak for himself.

-- Steve
