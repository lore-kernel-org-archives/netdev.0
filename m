From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH -mm 0/10][RFC] aio: make struct kiocb private
Date: Tue, 16 Jan 2007 03:23:47 +0000
Message-ID: <20070116032347.GA3697@infradead.org>
References: <20070116015450.9764.37697.patchbomb.py@nate-64.agami.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nate Diller <nate.diller@gmail.com>, Andrew Morton <akpm@osdl.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Benjamin LaHaise <bcrl@kvack.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Suparna Bhattacharya <suparna@in.ibm.com>,
	Kenneth W Chen <kenneth.w.chen@intel.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	Christoph Hellwig <hch@infradead.org>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, ocfs2-devel@oss.oracle.com,
	linux-aio@kvack.org, xfs-masters@oss.sgi.com
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Nate Diller <nate@agami.com>
Content-Disposition: inline
In-Reply-To: <20070116015450.9764.37697.patchbomb.py@nate-64.agami.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 15, 2007 at 05:54:50PM -0800, Nate Diller wrote:
> This series is an attempt to generalize the async I/O paths to be
> implementation agnostic.  It completely eliminates knowledge of
> the kiocb structure in the generic code and makes it private within the
> current aio code.  Things get noticeably cleaner without that layering
> violation.
> 
> The new interface takes a file_endio_t function pointer, and a private data
> pointer, which would normally be aio_complete and a kiocb pointer,
> respectively.  If the aio submission function gets back EIOCBQUEUED, that is
> a guarantee that the endio function will be called, or *already has been
> called*.  If the file_endio_t pointer provided to aio_[read|write] is NULL,
> the FS must block on I/O completion, then return either the number of bytes
> read, or an error.

I don't really like this patchet at all.  At some point it's a lot nicer
to have a lot of paramaters that are related and passed down a long
callchain into a structure, and I think the aio code is over that threshold.
The completion function cleanups look okay to me, but I'd rather add
that completion function to struct kiocb instead of removing kiocb use.

I have this slight feeling you want to use this completions for something
else than the current aio code, if that's the case it would help
if you could explain briefly in what direction your heading.

