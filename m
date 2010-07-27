From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH UPDATED 1/3] vhost: replace vhost_workqueue with per-vhost
 kthread
Date: Tue, 27 Jul 2010 10:18:04 +0200
Message-ID: <4C4E963C.8080308@kernel.org>
References: <4C48B664.9000109@kernel.org> <20100724191447.GA4972@redhat.com> <4C4BEAA2.6040301@kernel.org> <20100726152510.GA26223@redhat.com> <4C4DAB14.5050809@kernel.org> <20100726155014.GA26412@redhat.com> <4C4DB247.9060709@kernel.org> <4C4DB466.6000409@kernel.org> <20100726163108.GE26412@redhat.com> <4C4DD946.2080502@kernel.org> <20100726195714.GD27644@redhat.com>
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
In-Reply-To: <20100726195714.GD27644@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 07/26/2010 09:57 PM, Michael S. Tsirkin wrote:
>> For freeze, it probably is okay but for stop, I think it's better to
>> keep the semantics straight forward.
> 
> What are the semantics then? What do we want stop followed
> by queue and flush to do?

One scenario I can think of is the following.

 kthread_worker allows kthreads to be attached and stopped anytime, so
 if the caller stops the current worker while flushing is pending and
 attaches a new worker, the flushing which was pending will never
 happen.

But, in general, it's nasty to allow execution and its completion to
be separated.  Things like that are likely to bite us back in obscure
ways.  I think it would be silly to have such oddity in generic code
when it can be avoided without too much trouble.

Thanks.

-- 
tejun
