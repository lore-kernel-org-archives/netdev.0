From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] Extend netlink error codes
Date: Sat, 11 Sep 2004 17:58:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040911155839.GN4431@wotan.suse.de>
References: <20040910225158.GO20088@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20040910225158.GO20088@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Sep 11, 2004 at 12:51:58AM +0200, Thomas Graf wrote:
> The current situation with error codes sent back to a netlink
> application is unsatisfactory. Most often, the application
> receives EINVAL but has no idea what was wrong.

[...]

IMHO it would be far better to just pass text errors
in a variable length packet back.  It's a bit plan9ish,
but it would work nicely here and be a bit improvement
(especially for the qdiscs) 

Otherwise you will end up with a mainteance nightmare of a
long list of error codes that needs to be updated for every new
subsystem.  And everybody who has a patch to add a new netlink
user would always fight with conflicts in this file.

I don't think an very specific error like
"CFQ subsystem parameter X is FOO, can be only upto BAR" 
can be nicely put into a global error file.
And most errors can only be handled by passing them to the user anyways,
text errors would be fine for that.

There could be still an errno provided for easy success/failure
checking.

-Andi
