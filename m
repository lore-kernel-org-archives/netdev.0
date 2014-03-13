From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next] xen-netback: Schedule NAPI from dealloc thread
 instead of callback
Date: Thu, 13 Mar 2014 10:42:30 +0000
Message-ID: <1394707350.25873.34.camel@kazak.uk.xensource.com>
References: <1394658281-2488-1-git-send-email-zoltan.kiss@citrix.com>
	 <20140313101720.GA16807@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140313101720.GA16807@zion.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-03-13 at 10:17 +0000, Wei Liu wrote:
> On Wed, Mar 12, 2014 at 09:04:41PM +0000, Zoltan Kiss wrote:
> > If there are unconsumed requests in the ring, but there isn't enough free
> > pending slots, the NAPI instance deschedule itself. As the frontend won't send
> > any more interrupts in this case, it is the task of whoever release the pending
> > slots to schedule the NAPI instance in this case. Originally it was done in the
> > callback, but it's better at the end of the dealloc thread, otherwise there is
> > a risk that the NAPI instance just deschedule itself as the dealloc thread
> > couldn't release any used slot yet. However, as there are a lot of pending
> > packets, NAPI will be scheduled again, and it is very unlikely that the dealloc
> > thread can't release enough slots in the meantime.
> > 
> 
> So this patch restores the property that "only two parties access the
> ring", right?

I think so, and therefore:
Acked-by: Ian Campbell <ian.campbell@citrix.com>

Ian.
