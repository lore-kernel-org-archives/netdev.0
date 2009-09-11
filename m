From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH 1/8] networking/fanotify: declare fanotify socket
 numbers
Date: Fri, 11 Sep 2009 12:04:33 -0400
Message-ID: <1252685073.2305.9.camel@dhcp231-106.rdu.redhat.com>
References: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com>
	 <200909111632.50477.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	viro@zeniv.linux.org.uk, alan@linux.intel.com, hch@infradead.org
To: Andreas Gruenbacher <agruen@suse.de>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <200909111632.50477.agruen@suse.de>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-09-11 at 16:32 +0200, Andreas Gruenbacher wrote:
> The patches did apply and build against next-20090910. I wrote a small user-
> space utility for testing (attached); see how painless the socket interface 
> is. The patches seem to be working well, except that some required 
> functionality is missing still.
> 
> Currently, the CAP_NET_RAW capability is needed for being able to create 
> watches. This seems too strict to me; I don't see why I shouldn't be able to 
> watch my own files, or files which I have read access to (like inotify).

I agree completely.  However since I don't yet have limits on how many
marks a user can add, nor the number of events they can hold in their
queue I'm leaving it as root only for the moment.  Patches have started
to flush out usability by non-root users.

> There are some actions like creating hardlinks in directories or removing 
> files which don't trigger events. From a user point of view, I would prefer to 
> receive those events as well. (I notice that it's not easy to to pass file 
> descriptors to listeners for those events.)

Yes, a number of event types hook into the vfs in places where we do not
have at least a struct path.  I'm certainly considering how to move
hoooks to get that ability.

-Eric

