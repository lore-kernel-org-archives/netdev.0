From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 01/17] shm-signal: shared-memory signals
Date: Wed, 01 Apr 2009 15:24:50 +0300
Message-ID: <49D35D12.6080209@redhat.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <20090331184252.28333.70623.stgit@dev.haskins.net> <49D280C0.8010802@redhat.com> <49D283F7.7030508@novell.com> <49D285AE.7030604@redhat.com> <49D35A2B.10907@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D35A2B.10907@novell.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gregory Haskins wrote:
> Note that this is exactly what I do (though it is device specific). 
> venet-tap has a ioq_notifier registered on its "rx" ring (which is the
> tx-ring for the guest) that simply calls ioq_notify_disable() (which
> calls shm_signal_disable() under the covers) and it wakes its
> rx-thread.  This all happens in the context of the hypercall, which then
> returns and allows the vcpu to re-enter guest mode immediately.
>   
I think this is suboptimal.  The ring is likely to be cache hot on the 
current cpu, waking a thread will introduce scheduling latency + IPI 
+cache-to-cache transfers.

On a benchmark setup, host resources are likely to exceed guest 
requirements, so you can throw cpu at the problem and no one notices.  
But I think the bits/cycle figure will decrease, even if bits/sec increases.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

