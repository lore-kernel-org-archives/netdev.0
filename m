From: James Morris <jmorris@redhat.com>
Subject: Re: [PATCH][SELINUX] 2/2 sock_create_lite()
Date: Fri, 7 May 2004 11:21:52 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0405071118490.21529-100000@thoron.boston.redhat.com>
References: <20040507161455.A31114@infradead.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, Stephen Smalley <sds@epoch.ncsc.mil>,
        Chris Wright <chrisw@osdl.org>, <linux-kernel@vger.kernel.org>,
        <netdev@oss.sgi.com>, <selinux@tycho.nsa.gov>
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20040507161455.A31114@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 7 May 2004, Christoph Hellwig wrote:

> On Fri, May 07, 2004 at 11:06:04AM -0400, James Morris wrote:
> > This patch adds a function sock_create_lite(), deprecating kernel-wide use
> > of sock_alloc(), which has been made static to net/socket.c.
> 
> We're in the stable series and removing exported APIs there shoudn't happen.
> Given that sock_alloc() is actually okay for every normal use I don't think
> there's enough reason to remove it from the API.

Fair enough.

> > +int sock_create_lite(int family, int type, int protocol, struct socket **res)
> 
> Should probably be called __sock_create according to linux naming rules.
> Also I guess you should actually call it from sock_create instead of
> duplicating the code.

sock_create() is really very different to sock_alloc(), and the only real
duplication is calling the LSM hooks.  The version I sent seems to be the
simplest approach.

(note that __sock_create() is already created in the previous patch).


- James
-- 
James Morris
<jmorris@redhat.com>
