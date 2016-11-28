From: Alex Sidorenko <alexandre.sidorenko@hpe.com>
Subject: Re: Receive offloads, small RCVBUF and zero TCP window
Date: Mon, 28 Nov 2016 16:14:04 -0500
Message-ID: <15427752.RvQkb5CQdb@zbook>
References: <2080597.A38JFJZ1AD@zbook> <20161128.155459.1527519991492144879.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hpe.com ([15.241.32.99]:31431 "EHLO
        g9t1613g.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932675AbcK1VOJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 16:14:09 -0500
Received: from g2t2354.austin.hpe.com (g2t2354.austin.hpe.com [15.233.44.27])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by g9t1613g.houston.hpe.com (Postfix) with ESMTPS id 0899F6125D
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 21:14:08 +0000 (UTC)
In-Reply-To: <20161128.155459.1527519991492144879.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, November 28, 2016 3:54:59 PM EST David Miller wrote:
> From: Alex Sidorenko <alexandre.sidorenko@hpe.com>
> Date: Mon, 28 Nov 2016 15:49:26 -0500
> 
> > Now the question is whether is is OK to have icsk->icsk_ack.rcv_mss
> > larger than MTU.
> 
> It absolutely is not OK.
> 
> If VMWare wants to receive large frames for batching purposes it must
> use GRO or similar to achieve that, not just send vanilla frames into
> the stack which are larger than the device MTU.
> 

As VMWare's vmxnet3 driver is open-sourced and part of generic kernel, do you think the problem is in that driver or elsewhere? I looked at vmxnet3 sources and see that it uses LRO/GRO subroutines. Unfortunately, I don't understand its logic enough to see whether they are doing anything incorrectly.

Alex 

-- 

------------------------------------------------------------------
Alex Sidorenko	email: asid@hpe.com
ERT  Linux 	Hewlett-Packard Enterprise (Canada)
------------------------------------------------------------------
