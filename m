From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH 1/9] task_struct: add PF_NONOTIFY for fanotify to use
Date: Thu, 03 Sep 2009 16:25:49 -0400
Message-ID: <1252009549.2425.42.camel@dhcp231-106.rdu.redhat.com>
References: <20090828185542.8014.22791.stgit@paris.rdu.redhat.com>
	 <20090828223626.GA8283@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	viro@zeniv.linux.org.uk, alan@linux.intel.com, hch@infradead.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090828223626.GA8283@ioremap.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Fri, Aug 28, 2009 at 02:55:42PM -0400, Eric Paris (eparis@redhat.com) wrote:
> > Since fanotify opens file descriptors inside the kernel for it's listeners
> > it needs a way to make sure that 2 fanotify listeners, both which listen to
> > open events do not continuously see each others open events (and get into a
> > livelock reporting on each other's activity).  This fix is to create a new
> > tast_struct flags called PF_NONOTIFY.  If this flag is set in a task no
> > fanotify events will be generated for that task.   fanotify will set the
> > flag before and open call and will clear it immediately after.

So this patch isn't actually needed, I thought the fsnotify_open() call
was deeper than it is.  I'm going to drop this particular patch.

Can I take silence on the list as a lack of disagreement?  I'd like to
start putting these into linux-next starting tomorrow.  Obviously I'd
like to see the networking definitions approved and taken by davem, I'd
like to see the FMODE_ change approved and taken by viro, but if you two
would like me to push it directly I'd be happy to.

Davem, maybe you'd rather my af_fanotify was somewhere inside net/
instead of in fs/notify/fanotify?  I'd love to get some review here, but
noone onlist is excited enough to step up.  (I have numerous people who
have privately claimed they intend to use this stuff, so i promise it
won't be dead code.)

I'm ready to start committing and adding features, anyone telling me no?

-Eric



