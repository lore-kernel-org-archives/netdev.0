From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: MSI interrupts and disable_irq
Date: Sat, 06 Oct 2007 13:59:13 -0400
Message-ID: <4707CCF1.8080909@pobox.com>
References: <46FC15A9.1070803@nvidia.com> <46FDBCB4.9090802@pobox.com> <86802c440710061043u6e51cd7q468346bd06b08657@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ayaz Abdulla <aabdulla@nvidia.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	nedev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55811 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756750AbXJFR7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Oct 2007 13:59:31 -0400
In-Reply-To: <86802c440710061043u6e51cd7q468346bd06b08657@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yinghai Lu wrote:
> On 9/28/07, Jeff Garzik <jgarzik@pobox.com> wrote:
>> Ayaz Abdulla wrote:
>>> I am trying to track down a forcedeth driver issue described by bug 9047
>>> in bugzilla (2.6.23-rc7-git1 forcedeth w/ MCP55 oops under heavy load).
>>> I added a patch to synchronize the timer handlers so that one handler
>>> doesn't accidently enable the IRQ while another timer handler is running
>>> (see attachment 'Add timer lock' in bug report) and for other processing
>>> protection.
>>>
>>> However, the system still had an Oops. So I added a lock around the
>>> nv_rx_process_optimized() and the Oops has not happened (see attachment
>>> 'New patch for locking' in bug report). This would imply a
>>> synchronization issue. However, the only callers of that function are
>>> the IRQ handler and the timer handlers (in non-NAPI case). The timer
>>> handlers  use disable_irq so that the IRQ handler does not contend with
>>> them. It looks as if disable_irq is not working properly.
>>>
>>> This issue repros only with MSI interrupt and not legacy INTx
>>> interrupts. Any ideas?
>> (added linux-kernel to CC, since I think it's more of a general kernel
>> issue)
>>
> I wonder if the race is between soft_timer for nv_do_nic_poll from
> different CPUs

Interested parties should try the forcedeth patches I just posted :)

	Jeff



