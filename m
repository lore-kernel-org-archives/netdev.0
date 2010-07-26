From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH UPDATED 1/3] vhost: replace vhost_workqueue with per-vhost
 kthread
Date: Mon, 26 Jul 2010 18:05:27 +0200
Message-ID: <4C4DB247.9060709@kernel.org>
References: <4C03D983.9010905@kernel.org> <20100531160020.GC3067@redhat.com> <4C04D41B.4050704@kernel.org> <4C06A580.9060300@kernel.org> <20100722155840.GA1743@redhat.com> <4C48B664.9000109@kernel.org> <20100724191447.GA4972@redhat.com> <4C4BEAA2.6040301@kernel.org> <20100726152510.GA26223@redhat.com> <4C4DAB14.5050809@kernel.org> <20100726155014.GA26412@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
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
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100726155014.GA26412@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 07/26/2010 05:50 PM, Michael S. Tsirkin wrote:
>> Hmmm... I'm not quite sure whether it's an optimization.  I thought
>> the patch was due to feeling uncomfortable about using barriers?
> 
> Oh yes. But getting rid of barriers is what motivated me originally.

Yeah, getting rid of barriers is always good.  :-)

> Is there a git tree with kthread_worker applied?
> I might do this just for fun ...

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/wq.git for-next

For the original implementaiton, please take a look at commit
b56c0d8937e665a27d90517ee7a746d0aa05af46.

* Can you please keep the outer goto repeat loop?  I just don't like
  outermost for (;;).

* Placing try_to_freeze() could be a bit annoying.  It shouldn't be
  executed when there's a work to flush.

* I think A - B <= 0 test would be more familiar.  At least
  time_before/after() are implemented that way.

Thanks.

-- 
tejun
