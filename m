From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] Extend netlink error codes
Date: Sat, 11 Sep 2004 18:50:56 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040911165056.GQ4431@wotan.suse.de>
References: <20040910225158.GO20088@postel.suug.ch> <20040911155839.GN4431@wotan.suse.de> <20040911162433.GC21181@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20040911162433.GC21181@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Sep 11, 2004 at 06:24:33PM +0200, Thomas Graf wrote:
> * Andi Kleen <20040911155839.GN4431@wotan.suse.de> 2004-09-11 17:58
> > IMHO it would be far better to just pass text errors
> > in a variable length packet back.  It's a bit plan9ish,
> > but it would work nicely here and be a bit improvement
> > (especially for the qdiscs) 
> 
> I had the same idea and the only good way to do so would
> be to add a char * errbuf or alike to struct netlink_opt
> and access it via skb.sk.sk_protinfo.

I was thinking about a variable length netlink packet
that contains it and that is sent back to the application.  
No need to store it anywhere else.
> 
> The bad side is that the for example cls and sch api don't
> provide the skb to the implementing modules and therefore
> they can't access the error buffer. I don't want to change
> all netlink users because of this.

Indeed, that's an issue. Even with the retry packet you need
the sequence number. On the other hand there are not 
that many sched/cls modules and some minor changes to them
are probably ok.

In the worst case you can define new entry points and
keep the old ones for compatibility, but it is probably
not worth it to be that compatible because there are not
enough different users.

-Andi
