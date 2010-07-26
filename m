From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH UPDATED 1/3] vhost: replace vhost_workqueue with
 per-vhost kthread
Date: Mon, 26 Jul 2010 18:25:10 +0300
Message-ID: <20100726152510.GA26223@redhat.com>
References: <4C02C961.9050606@kernel.org>
 <20100531152221.GB2987@redhat.com>
 <4C03D983.9010905@kernel.org>
 <20100531160020.GC3067@redhat.com>
 <4C04D41B.4050704@kernel.org>
 <4C06A580.9060300@kernel.org>
 <20100722155840.GA1743@redhat.com>
 <4C48B664.9000109@kernel.org>
 <20100724191447.GA4972@redhat.com>
 <4C4BEAA2.6040301@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oleg Nesterov <oleg@redhat.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4C4BEAA2.6040301@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 25, 2010 at 09:41:22AM +0200, Tejun Heo wrote:
> Hello,
> 
> On 07/24/2010 09:14 PM, Michael S. Tsirkin wrote:
> >> I've created kthread_worker in wq#for-next tree and already converted
> >> ivtv to use it.  Once this lands in mainline, I think converting vhost
> >> to use it would be better choice.  kthread worker code uses basically
> >> the same logic used in the vhost_workqueue code but is better
> >> organized and documented.  So, I think it would be better to stick
> >> with the original implementation, as otherwise we're likely to just
> >> decrease test coverage without much gain.
> >>
> >>   http://git.kernel.org/?p=linux/kernel/git/tj/wq.git;a=commitdiff;h=b56c0d8937e665a27d90517ee7a746d0aa05af46;hp=53c5f5ba42c194cb13dd3083ed425f2c5b1ec439
> > 
> > Sure, if we keep using workqueue. But I'd like to investigate this
> > direction a bit more because there's discussion to switching from kthread to
> > regular threads altogether.
> 
> Hmmm? It doesn't have much to do with workqueue.  kthread_worker is a
> simple wrapper around kthread.  It now assumes kthread but changing it
> to be useable with any thread shouldn't be too hard.  Wouldn't that be
> better?

BTW, kthread_worker would benefit from the optimization I implemented
here as well.

-- 
MST
