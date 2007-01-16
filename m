From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH -mm 0/10][RFC] aio: make struct kiocb private
Date: Tue, 16 Jan 2007 00:22:35 -0800
Message-ID: <200701160022.38492.david-b@pacbell.net>
References: <20070116015450.9764.37697.patchbomb.py@nate-64.agami.com> <20070116032347.GA3697@infradead.org> <5c49b0ed0701152025t2e9fdd6cld36b077f36c78afe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@osdl.org>,
	Benjamin LaHaise <bcrl@kvack.org>,
	Christoph Hellwig <hch@infradead.org>,
	Kenneth W Chen <kenneth.w.chen@intel.com>,
	linux-aio@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nate Diller <nate@agami.com>,
	netdev@vger.kernel.org, ocfs2-devel@oss.oracle.com,
	Suparna Bhattacharya <suparna@in.ibm.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	xfs-masters@oss.sgi.com
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Nate Diller <nate.diller@gmail.com>
In-Reply-To: <5c49b0ed0701152025t2e9fdd6cld36b077f36c78afe@mail.gmail.com>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 15 January 2007 8:25 pm, Nate Diller wrote:

> I don't think we should be waiting on sync I/O 
> at the *top* of the call stack, like with wait_on_sync_kiocb(), I'd
> say the best place to wait is at the *bottom*, down in the I/O
> scheduler.

Erm ... *what* I/O scheduler?  These I/O requests may go directly
to the end of the hardware I/O queue, which already has an I/O model
where each request can correspond directly to a KIOCB.  And which
does not include any synchronous primitives.

No such scheduler has previously been, or _should_ be, required.

