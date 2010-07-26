From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH UPDATED 1/3] vhost: replace vhost_workqueue with per-vhost
 kthread
Date: Mon, 26 Jul 2010 20:51:50 +0200
Message-ID: <4C4DD946.2080502@kernel.org>
References: <4C06A580.9060300@kernel.org> <20100722155840.GA1743@redhat.com> <4C48B664.9000109@kernel.org> <20100724191447.GA4972@redhat.com> <4C4BEAA2.6040301@kernel.org> <20100726152510.GA26223@redhat.com> <4C4DAB14.5050809@kernel.org> <20100726155014.GA26412@redhat.com> <4C4DB247.9060709@kernel.org> <4C4DB466.6000409@kernel.org> <20100726163108.GE26412@redhat.com>
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
In-Reply-To: <20100726163108.GE26412@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 07/26/2010 06:31 PM, Michael S. Tsirkin wrote:
>> On 07/26/2010 06:05 PM, Tejun Heo wrote:
>>> * Placing try_to_freeze() could be a bit annoying.  It shouldn't be
>>>   executed when there's a work to flush.
> 
> BTW why is this important?
> We could always get another work and flush right after
> try_to_freeze, and then flush would block for a long time.
> 
> BTW the vhost patch you sent does not do this at all.
> I am guessing it is because our thread is not freezable?

Yeap, I think so.

>> * Similar issue exists for kthread_stop().  The kthread shouldn't exit
>>   while there's a work to flush (please note that kthread_worker
>>   interface allows detaching / attaching worker kthread during
>>   operation, so it should remain in consistent state with regard to
>>   flushing).
> 
> Not sure I agree here. Users must synchronise flush and stop calls.
> Otherwise a work might get queued after stop is called, and
> you won't be able to flush it.

For freeze, it probably is okay but for stop, I think it's better to
keep the semantics straight forward.  It may be okay to do otherwise
but having such oddity in generic interface is nasty and may lead to
surprises which can be pretty difficult to track down later on.  It's
just a bit more of annoyance while writing the generic code, so...

Thanks.

-- 
tejun
