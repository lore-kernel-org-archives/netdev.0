From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH net-next] lec: Use rtnl lock/unlock when updating MTU
Date: Thu, 14 Aug 2014 20:56:27 -0400
Message-ID: <201408150056.s7F0uRg7003712@thirdoffive.cmf.nrl.navy.mil>
References: <20140814.143706.1833450188258591738.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:36629 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869AbaHOA4w convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 20:56:52 -0400
In-reply-to: <20140814.143706.1833450188258591738.davem@redhat.com>
Content-ID: <3710.1408064187.1@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <20140814.143706.1833450188258591738.davem@redhat.com>,David Miller writes:
>From: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
>Date: Thu, 14 Aug 2014 09:19:47 -0400
>
>> The LECS response contains the MTU that should be used.  Correctly
>> synchronize with other layers when updating.
>> 
>> Signed-off-by: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
>
>I don't think you can sleep from this function, which rtnl_lock() may
>require.  Look elsewhere in this routine, it's doing GFP_ATOMIC
>allocations even.

Its been a while but...

This is the send routine for a virtual atm device that is the control
interface bewteen the user space client and the kernel.  The user space
client creates an atm socket and uses an ioctl to connect that atm socket
to the this virtual device.  So the call path is something like:

sendmsg() -> vcc_sendmsg() -> virtual atm device.send()

Generally speaking, you can't sleep in the send routine of an atm device
since there are other potential users besides sockets.

The GFP_ATOMIC usage is probably a lack of understanding.  The other
IRQ level locks are necessary for coordination.
