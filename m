From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Distributed storage. Move away from char device ioctls.
Date: Sat, 15 Sep 2007 00:40:30 -0400
Message-ID: <20070915044030.GA702@fieldses.org>
References: <20070914185429.GA9439@2ka.mipt.ru> <46EADC02.9070409@garzik.org> <20070914211210.GB12444@fieldses.org> <46EAF9CD.1090808@garzik.org> <20070914211828.GC12444@fieldses.org> <46EB0BEB.2090808@garzik.org> <20070914224212.GJ12444@fieldses.org> <46EB5ACA.5000207@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <46EB5ACA.5000207@garzik.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 15, 2007 at 12:08:42AM -0400, Jeff Garzik wrote:
> J. Bruce Fields wrote:
>> No, servers are required to support ordinary nfs operations to the
>> metadata server.
>> At least, that's the way it was last I heard, which was a while ago.  I
>> agree that it'd stink (for any number of reasons) if you ever *had* to
>> get a layout to access some file.
>> Was that your main concern?
>
> I just sorta assumed you could fall back to the NFSv4.0 mode of operation, 
> going through the metadata server for all data accesses.

Right.  So any two pNFS implementations *will* be able to talk to each
other; they just may not be able to use the (possibly higher-bandwidth)
read/write path that pNFS gives them.

> But look at that choice in practice:  you can either ditch pNFS completely, 
> or use a proprietary solution.  The market incentives are CLEARLY tilted in 
> favor of makers of proprietary solutions.

I doubt somebody would go to all the trouble to implement pNFS and then
present their customers with that kind of choice.  But maybe I'm missing
something.  What market incentives do you see that would make that more
attractive than either 1) using a standard fully-specified layout type,
or 2) just implementing your own proprietary protocol instead of pNFS?

> Overall, my main concern is that NFSv4.1 is no longer an open architecture 
> solution.  The "no-pNFS or proprietary platform" choice merely illustrate 
> one of many negative aspects of this architecture.

It's always been possible to extend NFS in various ways if you want.
You could use sideband protocols with v2 and v3, for example.  People
have done that.  Some of them have been standardized and widely
implemented, some haven't.  You could probably add your own compound ops
to v4 if you wanted, I guess.

And there's advantages to experimenting with extensions first and then
standardizing when you figure out what works.  I wish it happened that
way more often.

> Now, for the first time in NFS's history (AFAIK), the protocol is no longer 
> completely specified, completely known.  No longer a "closed loop."  
> Private layout types mean that it is _highly_ unlikely that any OS or 
> appliance or implementation will be able to claim "full NFS compatibility."

Do you know of any such "private layout types"?

This is kind of a boring argument, isn't it?  I'd rather hear whatever
ideas you have for a new distributed filesystem protocol.

--b.
