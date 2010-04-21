From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] gianfar: Wait for both RX and TX to stop
Date: Wed, 21 Apr 2010 14:13:00 -0500
Message-ID: <CD8C73BA-0E18-4F85-A90B-C2FA5FFC8689@kernel.crashing.org>
References: <o2oed82fe3e1004200801n98683cdalb2898c879b93f8fd@mail.gmail.com>  <20100420.180646.216759318.davem@davemloft.net> <A20F7457-20BC-493C-B800-3933D8FC4D5C@kernel.crashing.org>  <20100420.223659.236667659.davem@davemloft.net> <10AE27BE-1830-4AAD-83E6-20001BC430D8@kernel.crashing.org> <z2ged82fe3e1004210733v8fa40902k664549aa9620b13@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, afleming@freescale.com,
	netdev@vger.kernel.org
To: Timur Tabi <timur.tabi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:50345 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754129Ab0DUTNS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 15:13:18 -0400
In-Reply-To: <z2ged82fe3e1004210733v8fa40902k664549aa9620b13@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 21, 2010, at 9:33 AM, Timur Tabi wrote:

> On Wed, Apr 21, 2010 at 7:17 AM, Kumar Gala <galak@kernel.crashing.org> wrote:
> 
>> I understand, its more a sense that we are saying we want to time out for what I consider a catastrophic HW failure.
> 
> And how else will you detect and recover from such a failure without a
> timeout?  And are you absolutely certain that there will never be a
> programming failure that will cause this loop to spin forever?
> 
> If you're really opposed to a timeout, you can still use
> spin_event_timeout() by just setting the timeout to -1 and adding a
> comment explaining why.

I'm not opposed, I'm just asking if we are saying we shouldn't be using cpu_relax() for spinning on HW status registers ever.

If we are suggesting that cpu_relax() shouldn't be used in these scenarios going forward I'm ok w/the change you suggest and starting to convert other cpu_relax() calls to use spin_event_timeout()

- k