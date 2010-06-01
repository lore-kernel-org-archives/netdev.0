From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] vhost: apply cpumask and cgroup to vhost workers
Date: Tue, 01 Jun 2010 12:56:33 +0200
Message-ID: <4C04E761.4020800@kernel.org>
References: <20100527173207.GA21880@redhat.com> <4BFEE216.2070807@kernel.org> <20100528150830.GB21880@redhat.com> <4BFFE742.2060205@kernel.org> <20100530112925.GB27611@redhat.com> <4C02C961.9050606@kernel.org> <20100531152221.GB2987@redhat.com> <4C03D983.9010905@kernel.org> <20100531160020.GC3067@redhat.com> <4C04D453.9040208@kernel.org> <20100601101703.GB9178@redhat.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:41769 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753128Ab0FAK5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jun 2010 06:57:16 -0400
In-Reply-To: <20100601101703.GB9178@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 06/01/2010 12:17 PM, Michael S. Tsirkin wrote:
> Something that I wanted to figure out - what happens if the
> CPU mask limits us to a certain CPU that subsequently goes offline?

The thread gets unbound during the last steps of cpu offlining.

> Will e.g. flush block forever or until that CPU comes back?
> Also, does singlethreaded workqueue behave in the same way?

So, things will proceed as usual although the thread will lose its
affinity.  Singlethread wqs don't bind their workers (and they
shouldn't! :-).  MT ones explicitly manage workers according to cpu
up/down events.

Thanks.

-- 
tejun
