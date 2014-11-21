From: Hariprasad S <hariprasad@chelsio.com>
Subject: Re: [PATCH net-next 1/5] RDMA/cxgb4: Cleanup Filter related
 macros/register defines
Date: Sat, 22 Nov 2014 01:46:55 +0530
Message-ID: <20141121201653.GA32567@hariprasad-pc>
References: <1416554525-11844-1-git-send-email-hariprasad@chelsio.com>
 <1416554525-11844-2-git-send-email-hariprasad@chelsio.com>
 <1416556554.6651.35.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<linux-scsi@vger.kernel.org>, <davem@davemloft.net>,
	<roland@purestorage.com>, <JBottomley@parallels.com>,
	<hch@infradead.org>, <swise@opengridcomputing.com>,
	<leedom@chelsio.com>, <anish@chelsio.com>, <nirranjan@chelsio.com>,
	<kumaras@chelsio.com>, <praveen@chelsio.com>, <varun@chelsio.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:23841 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998AbaKUUPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 15:15:42 -0500
Content-Disposition: inline
In-Reply-To: <1416556554.6651.35.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 20, 2014 at 23:55:54 -0800, Joe Perches wrote:
> On Fri, 2014-11-21 at 12:52 +0530, Hariprasad Shenai wrote:
> > This patch cleanups all filter related macros/register defines that are defined
> > in t4fw_api.h and the affected files.
> 
> Is there any real value in the FW_FILTER_WR_ prefix?
> Does it need to be so long?
> 
Hey Joe, we have about 600 of these register defines used internally, and more
added as we add functionality and only a small chunk of these are actually used
in the code in kernel. Without the descriptive prefixes code would be extremely
hard to read without having a reference document open at all times. They are
used in 6 different drivers, and no one is proficient enough to know them all
off hand, hence the explanatory prefixes.

> Perhaps it'd be nicer to read if
> _S was _SHIFT
> _M was _MASK
> _V was whatever it's supposed to represent (_SET?)
> and
> _G was _GET
> 
There prefixes are auto-generated based on hardware logic, as the actual
prefixes generated are not acceptable in the kernel due namespace collison
worries, we are trying to keep it in an format that is _both_ acceptable in the
kernel and can be used to convert in-house patches to upstream kernel patches.
Changing the length of the macro names would significantly increase manual
intervention required to ensure that the 80 char limit is not violated. Even
simply changing existing code would require quite a lot of man-hours manually
fixing all the char length issues that would be better spend making code more
maintainable first.

The current focus of the effort is to get all these macros into a uniform
format. Due to legacy reasons, the current macros are represented in 3 varying
formats (one of which actually is _SHIFT, _MASK etc), making code very hard to
maintain, doubly so when transplanting changesets. As a final phase of this, we
will add an explanation about the suffixes used so that the headers are easier
to read.

> > +#define FW_FILTER_WR_TID_S      12
> > +#define FW_FILTER_WR_TID_M      0xfffff
> > +#define FW_FILTER_WR_TID_V(x)   ((x) << FW_FILTER_WR_TID_S)
> > +#define FW_FILTER_WR_TID_G(x)   \
> > +	(((x) >> FW_FILTER_WR_TID_S) & FW_FILTER_WR_TID_M)
> 
> Why aren't the _V defines masked then shifted?
> 
> #define FW_FILTER_WR_<foo>_V(x)				\
> 	(((x) & FW_FILTER_<foo>_M) << FW_FILTER_<foo>_S)
> 
> 
Good point, until now we just have been careful using _V macros. But this too
is best done once we actually have all the macros used to set values in a
uniform format that can be patched in one go.
