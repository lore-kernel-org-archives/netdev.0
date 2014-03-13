From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next] xen-netback: Schedule NAPI from
 dealloc thread instead of callback
Date: Thu, 13 Mar 2014 10:17:20 +0000
Message-ID: <20140313101720.GA16807@zion.uk.xensource.com>
References: <1394658281-2488-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jonathan.davies@citrix.com, wei.liu2@citrix.com, ian.campbell@citrix.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	xen-devel@lists.xenproject.org
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
Content-Disposition: inline
In-Reply-To: <1394658281-2488-1-git-send-email-zoltan.kiss@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 12, 2014 at 09:04:41PM +0000, Zoltan Kiss wrote:
> If there are unconsumed requests in the ring, but there isn't enough free
> pending slots, the NAPI instance deschedule itself. As the frontend won't send
> any more interrupts in this case, it is the task of whoever release the pending
> slots to schedule the NAPI instance in this case. Originally it was done in the
> callback, but it's better at the end of the dealloc thread, otherwise there is
> a risk that the NAPI instance just deschedule itself as the dealloc thread
> couldn't release any used slot yet. However, as there are a lot of pending
> packets, NAPI will be scheduled again, and it is very unlikely that the dealloc
> thread can't release enough slots in the meantime.
> 

So this patch restores the property that "only two parties access the
ring", right?

Wei.
