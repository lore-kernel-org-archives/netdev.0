From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] AFS: Implement basic file write support
Date: Wed, 9 May 2007 03:41:35 -0700
Message-ID: <20070509034135.853ae84c.akpm@linux-foundation.org>
References: <20070508170051.eb4751ce.akpm@linux-foundation.org>
	<20070508194358.27477.74888.stgit@warthog.cambridge.redhat.com>
	<20070508194411.27477.7552.stgit@warthog.cambridge.redhat.com>
	<997.1178706347@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757104AbXEIKmJ@vger.kernel.org>
In-Reply-To: <997.1178706347@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 09 May 2007 11:25:47 +0100 David Howells <dhowells@redhat.com> wrote:

> > > +	set_page_dirty(page);
> > > +
> > > +	if (PageDirty(page))
> > > +		_debug("dirtied");
> > > +
> > > +	return 0;
> > > +}
> > 
> > One would normally run mark_inode_dirty() after any i_size_write()?
> 
> Not in this case, I assume, because set_page_dirty() ultimately calls
> __mark_inode_dirty(), but I could be wrong.

set_page_dirty() will set I_DIRTY_PAGES only.  ie: the inode has dirty
pagecache data.

To tell the VFS that the inode itself is dirty one needs to run
mark_inode_dirty().  Or maybe mark_inode_dirty_sync() but I can never for
the life of me remember what that thing does.
