From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPSec Oops when deleting an ip address
Date: Mon, 24 May 2004 10:14:49 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040524101449.053e74f9.davem@redhat.com>
References: <20040510134958.13691.qmail@mason.oriente.labs.it>
	<20040521131950.GA20040@gondor.apana.org.au>
	<20040521144346.7887dbf0.davem@redhat.com>
	<20040524114751.GA28571@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040524114751.GA28571@gondor.apana.org.au>
List-Id: netdev.vger.kernel.org

On Mon, 24 May 2004 21:47:51 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Hence the problem is still a bug in the ref counting.  I think I've found
> the real culprit now.  __xfrm?_find_acq() is missing an xfrm_state_hold
> on the create path.  This also explains why I never see it myself since
> Openswan never creates states through that code-path.

Applied, thanks Herbert.

How the heck are you generating your patches?  Because the file paths
look like this in the patch:

--- 1.6/net/ipv4/xfrm4_state.c	2003-07-21 21:49:43 +10:00
+++ edited/xfrm4_state.c	2004-05-24 21:41:29 +10:00

My auto-patch-application scripts explode since the path
depth of the file is different in the second line there.
How come it doesn't look like:

--- 1.6/net/ipv4/xfrm4_state.c	2003-07-21 21:49:43 +10:00
+++ edited/net/ipv4/xfrm4_state.c	2004-05-24 21:41:29 +10:00

So that I can throw "-p1" to tools like diffstat and get sane
output?

Your patches never did this in the past :-)
