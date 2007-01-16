From: Ingo Oeser <ioe-lkml@rameria.de>
Subject: Re: [PATCH -mm 3/10][RFC] aio: use iov_length instead of ki_left
Date: Wed, 17 Jan 2007 00:36:07 +0100
Message-ID: <200701170036.12359.ioe-lkml@rameria.de>
References: <20070116015450.9764.37697.patchbomb.py@nate-64.agami.com> <20070116021438.GA15774@infradead.org> <5c49b0ed0701152137s52e8f2c8sc93ea3a073e17e1c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Christoph Hellwig" <hch@infradead.org>,
	"Nate Diller" <nate@agami.com>, "Andrew Morton" <akpm@osdl.org>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"Benjamin LaHaise" <bcrl@kvack.org>,
	"Alexander Viro" <viro@zeniv.linux.org.uk>,
	"Suparna Bhattacharya" <suparna@in.ibm.com>,
	"Kenneth W Chen" <kenneth.w.chen@intel.com>,
	"David Brownell" <dbrownell@users.sourceforge.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, ocfs2-devel@oss.oracle.com,
	linux-aio@kvack.org, xfs-masters@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751788AbXAPXgb@vger.kernel.org>
To: "Nate Diller" <nate.diller@gmail.com>
In-Reply-To: <5c49b0ed0701152137s52e8f2c8sc93ea3a073e17e1c@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, 16. January 2007 06:37, Nate Diller wrote:
> On 1/15/07, Christoph Hellwig <hch@infradead.org> wrote:
> > On Mon, Jan 15, 2007 at 05:54:50PM -0800, Nate Diller wrote:
> > > Convert code using iocb->ki_left to use the more generic iov_length() call.
> >
> > No way.  We need to reduce the numer of iovec traversals, not adding
> > more of them.
> 
> ok, I can work on a version of this that uses struct iodesc.  Maybe
> something like this?
> 
> struct iodesc {
>         struct iovec *iov;
>         unsigned long nr_segs;
>         size_t nbytes;
> };
> 
> I suppose it's worth doing the iodesc thing along with this patchset
> anyway, since it'll avoid an extra round of interface churn.

What about this instead

struct iodesc {
	struct iovec *iov;
	unsigned long nr_segs;
	unsigned long seg_limit;
	size_t nr_bytes;
};

That will enable resizeable iodescs with partial completion state and
will enable successive filling of an iodesc with iovs.

This will be needed anyway. I built an complete short userspace 
module for that already. I can post and GPLv2 it somewhere, if people
are interested.

Regards

Ingo Oeser
