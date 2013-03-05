From: Peter Hurley <peter@hurleysoftware.com>
Subject: [PATCH 0/4] other ircomm_tty fixes (was Re: [PATCH] ircomm: release tty before sleeping potentially indefintely)
Date: Tue,  5 Mar 2013 11:09:03 -0500
Message-ID: <1362499747-4262-1-git-send-email-peter@hurleysoftware.com>
References: <1362371063.3221.185.camel@thor.lan>
Cc: Sasha Levin <sasha.levin@oracle.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, Jiri Slaby <jslaby@suse.cz>,
	linux-kernel@vger.kernel.org,
	Peter Hurley <peter@hurleysoftware.com>
To: David Miller <davem@davemloft.net>,
	Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362371063.3221.185.camel@thor.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-03-03 at 23:24 -0500, Peter Hurley wrote:
> On Sun, 2013-03-03 at 21:36 -0500, David Miller wrote:
> > From: Peter Hurley <peter@hurleysoftware.com>
> > Date: Sun, 03 Mar 2013 20:06:18 -0500
> >
> > > But regardless, this function __cannot__ sleep holding the tty_lock().
> >
> > So drop it across the schedule(), but recheck the termios after
> > regrabbing it.
>
> I'll have to do some research on that.

Still working on this...

> In the meantime, while reviewing that code, I noticed there's a handful
> of serious bugs in that one function that I'll send a patchset for.

As promised.


Peter Hurley (4):
  net/irda: Fix port open counts
  net/irda: Hold port lock while bumping blocked_open
  net/irda: Use barrier to set task state
  net/irda: Raise dtr in non-blocking open

 net/irda/ircomm/ircomm_tty.c | 29 ++++++++++++++++-------------
 1 file changed, 16 insertions(+), 13 deletions(-)

-- 
1.8.1.2
