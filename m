From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/5] dev_<level> and dynamic_debug cleanups
Date: Fri, 07 Sep 2012 07:58:41 -0700
Message-ID: <1347029921.13424.14.camel@joe2Laptop>
References: <cover.1345978012.git.joe@perches.com>
	 <20120906175158.GB9786@redhat.com> <1346957026.13424.5.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jim Cromie <jim.cromie@gmail.com>, Kay Sievers <kay@vrfy.org>,
	linux-kernel@vger.kernel.org
To: Jason Baron <jbaron@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:48066 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751737Ab2IGO6m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2012 10:58:42 -0400
In-Reply-To: <1346957026.13424.5.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-06 at 11:43 -0700, Joe Perches wrote:
> On Thu, 2012-09-06 at 13:51 -0400, Jason Baron wrote:
> > On Sun, Aug 26, 2012 at 04:25:25AM -0700, Joe Perches wrote:
> > > The recent commit to fix dynamic_debug was a bit unclean.
> > > Neaten the style for dynamic_debug.
> > > Reduce the stack use of message logging that uses netdev_printk
> > > Add utility functions dev_printk_emit and dev_vprintk_emit for /dev/kmsg.
[]
> > The one thing that is bothering me though, is that for
> > __dynamic_dev_dbg(), __dynamic_netdev_dbg(), we are copying much of the core
> > logic of __dev_printk(), __netdev_printk(), respectively. I would prefer
> > have this in one place. Can we add a 'prefix' argument to __dev_printk(),
> > and __netdev_printk() that dynamic debug can use, but is simply empty
> > for dev_printk() and netdev_printk().
> 
> I don't think that's an improvement actually.

Because it would add an always effectively unused "" argument
to dev_printk and netdev_printk calls in non dynamic_debug
builds.

dynamic_debug is still mostly a developer feature and I
believe most distros do not enable it.
