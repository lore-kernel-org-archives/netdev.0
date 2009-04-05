From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Sun, 05 Apr 2009 19:10:49 +0300
Message-ID: <49D8D809.8040503@redhat.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <200904011638.45135.rusty@rustcorp.com.au> <49D391F5.4080700@codemonkey.ws> <200904051314.23170.rusty@rustcorp.com.au> <49D8BC87.8030401@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Gregory Haskins <ghaskins@novell.com>,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D8BC87.8030401@codemonkey.ws>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anthony Liguori wrote:
>
> What we need is:
>
> 1) Lockless MMIO/PIO dispatch (there should be two IO registration 
> interfaces, a new lockless one and the legacy one)

Not sure exactly how much this is needed, since when there is no 
contention, locks are almost free (there's the atomic and cacheline 
bounce, but no syscall).

For any long operations, we should drop the lock (of course we need some 
kind of read/write lock or rcu to avoid hotunplug or reconfiguration).

> 2) A virtio-net thread that's independent of the IO thread.

Yes -- that saves us all the select() prologue (calculating new timeout) 
and the select() itself.



-- 
error compiling committee.c: too many arguments to function

