From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: Mon, 28 Mar 2005 02:15:51 +0200
Message-ID: <20050328001551.GB4110@g5.random>
References: <20050326224621.61f6d917.davem@davemloft.net> <20050327211506.85EDA16022F6@mx1.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: open-iscsi@googlegroups.com, mpm@selenic.com, michaelc@cs.wisc.edu,
        James.Bottomley@HansenPartnership.com, netdev@oss.sgi.com,
        "'David S. Miller'" <davem@davemloft.net>,
        ksummit-2005-discuss@thunk.org
To: Alex Aizman <itn780@yahoo.com>
Content-Disposition: inline
In-Reply-To: <20050327211506.85EDA16022F6@mx1.suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Mar 27, 2005 at 01:14:42PM -0800, Alex Aizman wrote:
> 5) If Resource manager says there is not enough resources, iSCSI fails
> session open. This is better than to get in trouble well into runtime.

Yes, this is the concept we were calling mempooling in earlier emails:
reserve the ram during session open and abort before starting up if we
fail. The kernel already does this in all I/O places.

> 9) Without some awareness of the resource-protected connections, and without
> some kind of resource counting at runtime (let it be partial and incomplete
> for starters) - the only remaining way for customers that require HA (High
> Availability) is to over-engineer: use 64GB RAM, TBs of disk space, etc.

... and most important set freepages.min to 1G or so (assuming 64bit
arch of course). It's _only_ freepages.min that matters, the total ram
doesn't matter at all, since you can mark it all dirty in a few seconds
with MAP_SHARED and then it will be lost (i.e. unfreeable) until iscsi
can succeed the write.
