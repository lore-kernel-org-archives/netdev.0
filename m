From: Stefano Brivio <sbrivio@redhat.com>
Subject: Re: [PATCH] i40e{,vf}: Fix out-of-bound cpumask read in IRQ
 affinity handler
Date: Tue, 15 Aug 2017 12:33:48 +0200
Message-ID: <20170815123348.711b1680@elisabeth>
References: <ae9c9586f61e914dc1c6fe2e6ac1fb2bf07283bc.1502792828.git.sbrivio@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Alan Brady <alan.brady@intel.com>,
        Stefan Assmann <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33502 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753423AbdHOKdy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 06:33:54 -0400
In-Reply-To: <ae9c9586f61e914dc1c6fe2e6ac1fb2bf07283bc.1502792828.git.sbrivio@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Aug 2017 12:30:14 +0200
Stefano Brivio <sbrivio@redhat.com> wrote:

> The cpumask used in i40e{,vf}_irq_affinity_notify() is allocated
> by irq_affinity_notify() with alloc_cpumask_var(), which doesn't
> allocate NR_CPUS bits, but only nr_cpumask_bits bits. If we just
> dereference it, we'll read way more than what is allocated, e.g.
> 1024 bytes vs. 8 bytes allocated on x86_64 machine with 24 CPUs.

Sorry, just two minutes after sending this I noticed Juergen submitted
the same fixes on Saturday:

From: Juergen Gross <jgross@suse.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,         intel-wired-lan@lists.osuosl.org
Cc: jeffrey.t.kirsher@intel.com, Juergen Gross <jgross@suse.com>,         stable@vger.kernel.org
Subject: [PATCH] net/i40e: use cpumask_copy() for assigning cpumask
Date: Sat, 12 Aug 2017 18:09:46 +0200

Please discard.
