From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Thu, 7 Oct 2004 16:50:26 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041007215025.GT31237@waste.org>
References: <20041006232544.53615761@jack.colino.net> <20041006214322.GG31237@waste.org> <20041007075319.6b31430d@jack.colino.net> <20041006234912.66bfbdcc.davem@davemloft.net> <20041007160532.60c3f26b@pirandello> <20041007112846.5c85b2d9.davem@davemloft.net> <20041007224422.1c1bea95@jack.colino.net> <20041007214505.GB31558@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Colin Leroy <colin@colino.net>, "David S. Miller" <davem@davemloft.net>,
        akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20041007214505.GB31558@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 07, 2004 at 11:45:05PM +0200, Andi Kleen wrote:
> On Thu, Oct 07, 2004 at 10:44:22PM +0200, Colin Leroy wrote:
> > On 07 Oct 2004 at 11h10, David S. Miller wrote:
> > 
> > Hi again, 
> > 
> > > So, netpoll needs to have the NETIF_F_LLTX stuff added to it.
> > 
> > This patch should do that. It works OK for me, but I'd like it checked
> > before sent upstream...
> > 
> > However, it doesn't fix the hang. it looks like this hang is really
> > coming from sungem.
> 
> IMHO it's not needed. Taking xmit_lock is harmless even when
> the NETIF_F_LLTX flag is set. 
> 
> (or at least it was with my original patchkit. In theory it's 
> possible someone changed their driver to take xmit_lock in hard_start_xmit,
> but if they did that I would just consider it a driver bug) 

Ok, this part makes sense.

> The only drawback is that there won't be a reply when the driver try
> lock fails, but netpoll doesn't have a queue for that anyways. You could
> probably poll then, but I'm not sure it's a good idea.

But your meaning here is not entirely clear.

-- 
Mathematics is the supreme nostalgia of our time.
