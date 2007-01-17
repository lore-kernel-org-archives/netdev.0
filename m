From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH -mm 0/10][RFC] aio: make struct kiocb private
Date: Wed, 17 Jan 2007 16:52:30 -0500
Message-ID: <20070117215230.GB28828@kvack.org>
References: <20070116015450.9764.37697.patchbomb.py@nate-64.agami.com> <20070116032347.GA3697@infradead.org> <5c49b0ed0701152025t2e9fdd6cld36b077f36c78afe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Nate Diller <nate@agami.com>, Andrew Morton <akpm@osdl.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Suparna Bhattacharya <suparna@in.ibm.com>,
	Kenneth W Chen <kenneth.w.chen@intel.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, ocfs2-devel@oss.oracle.com,
	linux-aio@kvack.org, xfs-masters@oss.sgi.com
Return-path: <owner-linux-aio@kvack.org>
To: Nate Diller <nate.diller@gmail.com>
Content-Disposition: inline
In-Reply-To: <5c49b0ed0701152025t2e9fdd6cld36b077f36c78afe@mail.gmail.com>
Sender: owner-linux-aio@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 15, 2007 at 08:25:15PM -0800, Nate Diller wrote:
> the right thing to do from a design perspective.  Hopefully it enables
> a new architecture that can reduce context switches in I/O completion,
> and reduce overhead.  That's the real motive ;)

And it's a broken motive.  Context switches per se are not bad, as they 
make it possible to properly schedule code in a busy system (which is 
*very* important when realtime concerns come into play).  Have a look 
at how things were done in the 2.4 aio code to see how completion would 
get done with a non-retry method, typically in interrupt context.  I had 
code that did direct I/O rather differently by sharing code with the 
read/write code paths at some point, the catch being that it was pretty 
invasive, which meant that it never got merged with the changes to handle 
writeback pressure and other work that happened during 2.5.

That said, you can't make kiocb private without completely removing the 
ability of the rest of the kernel to complete an aio sanely from irq context.  
You need some form of i/o descriptor, and a kiocb is just that.  Adding more 
layering is just going to make things messier and slower for no real gain.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.

--
To unsubscribe, send a message with 'unsubscribe linux-aio' in
the body to majordomo@kvack.org.  For more info on Linux AIO,
see: http://www.kvack.org/aio/
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
