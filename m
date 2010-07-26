From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH UPDATED 1/3] vhost: replace vhost_workqueue with per-vhost
 kthread
Date: Mon, 26 Jul 2010 21:04:17 +0200
Message-ID: <4C4DDC31.9070206@kernel.org>
References: <4C04D41B.4050704@kernel.org> <4C06A580.9060300@kernel.org> <20100722155840.GA1743@redhat.com> <4C48B664.9000109@kernel.org> <20100724191447.GA4972@redhat.com> <4C4BEAA2.6040301@kernel.org> <20100726152510.GA26223@redhat.com> <4C4DAB14.5050809@kernel.org> <20100726155014.GA26412@redhat.com> <4C4DB247.9060709@kernel.org> <20100726162346.GD26412@redhat.com>
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
In-Reply-To: <20100726162346.GD26412@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/26/2010 06:23 PM, Michael S. Tsirkin wrote:
>> * Can you please keep the outer goto repeat loop?  I just don't like
>>   outermost for (;;).
> 
> Okay ... can we put the code in a {} scope to make it clear
> where does the loop starts and ends?

If we're gonna do that, it would be better to put it inside a loop
construct.  The reason why I don't like it is that loops like that
don't really help read/writeability much while indenting the whole
logic unnecessarily and look more like a result of obsession against
goto rather than any practical reason.  It's just a cosmetic
preference and I might as well be the weirdo here, so if you feel
strong about it, please feel free to put everything in a loop.

>> * Placing try_to_freeze() could be a bit annoying.  It shouldn't be
>>   executed when there's a work to flush.
> 
> It currently seems to be executed when there is work to flush.
> Is this wrong?

Oh, does it?  As I wrote in the other mail, things like that wouldn't
necessarily break correctness but I think it would be better to avoid
surprises in the generic code if not too difficult.

>> * I think A - B <= 0 test would be more familiar.  At least
>>   time_before/after() are implemented that way.
> 
> I am concerned that this overflows a signed integer -
> which I seem to remeber that C99 disallows.

Really?  Overflows of pointer isn't expected and that's why we have
weird RELOC_HIDE() macro for such calculations but integers not
expected to overflow is a news to me.  Are you sure?  That basically
means time_before/after() aren't safe either.

> timer macros are on data path so might be worth the risk there,
> but flush is slow path so better be safe?

I don't think performance matters much here.  I just think the sign
test is clearer / more familiar for the logic.

Thanks.

-- 
tejun
