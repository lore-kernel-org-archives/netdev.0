From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 02/23] usb-gadget: use per-attribute show and store
	methods
Date: Mon, 28 Sep 2015 15:35:14 +0200
Message-ID: <20150928133514.GB30453@lst.de>
References: <1443189000-13398-1-git-send-email-hch@lst.de> <1443189000-13398-3-git-send-email-hch@lst.de> <20150927155053.GD16364@saruman.tx.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, Joel Becker <jlbec@evilplan.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <tj@kernel.org>,
	Pratyush Anand <pratyush.anand@gmail.com>,
	target-devel@vger.kernel.org, cluster-devel@redhat.com,
	ocfs2-devel@oss.oracle.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Felipe Balbi <balbi@ti.com>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150927155053.GD16364@saruman.tx.rr.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 27, 2015 at 10:50:53AM -0500, Felipe Balbi wrote:
> this (and the other helper below) could be macros just fine.

They could, but they shouldn't.  Inlines are always preferable over
function-like macros.

> Are you 100% compiler
> will *always* inline these helpers.

With gcc you can't ever be sure - but if it doesn't inline a trivial
pointer arithmetic we'll see breakage in various other places, including
the file system fast path which uses this pattern all over.
