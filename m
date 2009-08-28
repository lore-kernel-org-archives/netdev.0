From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH 1/9] task_struct: add PF_NONOTIFY for fanotify to use
Date: Fri, 28 Aug 2009 18:39:28 -0400
Message-ID: <1251499168.28787.2.camel@dhcp231-106.rdu.redhat.com>
References: <20090828185542.8014.22791.stgit@paris.rdu.redhat.com>
	 <20090828223626.GA8283@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	viro@zeniv.linux.org.uk, alan@linux.intel.com, hch@infradead.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090828223626.GA8283@ioremap.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2009-08-29 at 02:36 +0400, Evgeniy Polyakov wrote:
> Hi.
> 
> On Fri, Aug 28, 2009 at 02:55:42PM -0400, Eric Paris (eparis@redhat.com) wrote:
> > Since fanotify opens file descriptors inside the kernel for it's listeners
> > it needs a way to make sure that 2 fanotify listeners, both which listen to
> > open events do not continuously see each others open events (and get into a
> > livelock reporting on each other's activity).  This fix is to create a new
> > tast_struct flags called PF_NONOTIFY.  If this flag is set in a task no
> > fanotify events will be generated for that task.   fanotify will set the
> > flag before and open call and will clear it immediately after.
> 
> Is there a way to get old-school notifications with the object
> information instead of opened file desriptor, which may suffer rlimit
> problems and scalability issues with too many opened/closed descriptors?

Use inotify.

-Eric

