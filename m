From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 10/10] forcedeth: work around NULL skb dereference crash
Date: Tue, 3 Apr 2007 08:26:29 +0200
Message-ID: <20070403062629.GA13210@elte.hu>
References: <20070402115325.GA945@elte.hu> <DBFABB80F7FD3143A911F9E6CFD477B0189CB20B@hqemmail02.nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ayaz Abdulla <AAbdulla@nvidia.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753396AbXDCG0u@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <DBFABB80F7FD3143A911F9E6CFD477B0189CB20B@hqemmail02.nvidia.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Ayaz Abdulla <AAbdulla@nvidia.com> wrote:

> I had responded eariler to the thread asking you to try out the patch
> found in bug 8058:
> http://bugzilla.kernel.org/show_bug.cgi?id=8058
> 
> I believe that is the caush of the NULL skb dereference issue.

there's a different type of regression now: under high load i dont get a 
crash, i get a hung interface instead. No error packets or other weird 
interface state - just a hung interface. The condition happens after a 
stream of:

 eth1: too many iterations (6) in nv_nic_irq.
 eth1: too many iterations (6) in nv_nic_irq.
 eth1: too many iterations (6) in nv_nic_irq.
 eth1: too many iterations (6) in nv_nic_irq.
 eth1: too many iterations (6) in nv_nic_irq.

If i increase max_interrupt_work from 5 to 50 to paper over this 
condition then the hangs go away. So i suspect there might still be a 
queue-wakeup problem in one of these paths - or that a filled up tx ring 
somehow gets stuck. (and i've got commits 3ba4d093fe8a26f and 
fcc5f2665c81e08, so all the latest stuff that is upstream at the moment)

	Ingo
