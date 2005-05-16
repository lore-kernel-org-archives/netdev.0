From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: patch tulip-natsemi-dp83840a-phy-fix.patch added to -mm tree
Date: Mon, 16 May 2005 16:26:12 -0600
Message-ID: <20050516222612.GD9282@colo.lackof.org>
References: <200505101955.j4AJtX9x032464@shell0.pdx.osdl.net> <42881C58.40001@pobox.com> <20050516050843.GA20107@colo.lackof.org> <4288CE51.1050703@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>, akpm@osdl.org,
        T-Bone@parisc-linux.org, varenet@parisc-linux.org,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4288CE51.1050703@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, May 16, 2005 at 12:46:09PM -0400, Jeff Garzik wrote:
> Simply ensure that tulip_select_media() is always called from a process 
> context. Then can you delay all you want.  Several of the calls are 
> already this way, so that leaves two cases:
> 
> 1) called from timer context, from the media poll timer
> 
> 2) called from spin_lock_irqsave() context, in the ->tx_timeout hook.
> 
> The first case can be fixed by moved all the timer code to a workqueue. 
> Then when the existing timer fires, kick the workqueue.
> 
> The second case can be fixed by kicking the workqueue upon tx_timeout 
> (which is the reason why I did not suggest queue_delayed_work() use).

Thanks - the above guidance has much more detail than you offered before
and is much more useful.
Too bad that schedule_timeout() was the only option at the time. :^(

And I apologize I don't recall what the issues were with schedule_timeout().
I suspect they will rear their ugly head with the workqueue
implementation as well. But if they don't, that will be great.

> See, it's not rocket science :)

Well, then it's a great opportunity for someone interested in hacking
NIC drivers to cut their teeth on. :^)

After three years of using/maintaining the (trivial) tulip patch
in parisc-linux tree (and shipped with RH/SuSe ia64 releases),
I don't recall anyone complaining that udelays in tulip phy reset
caused them problems. Sorry, I'm unmotivated to revisit this.
Convince someone else to make tulip to use workqueues and I'll
resubmit a clean patch on top of that for the phy init sequences.

thanks,
grant
