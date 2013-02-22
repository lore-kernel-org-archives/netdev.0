From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: [PATCH] net: fec: Ensure that initialization is done prior to =?utf-8?b?cmVxdWVzdF9pcnEoKQ==?=
Date: Fri, 22 Feb 2013 01:13:01 +0000 (UTC)
Message-ID: <loom.20130222T020618-678@post.gmane.org>
References: <1361474510-14286-1-git-send-email-fabio.estevam@freescale.com> <20130221.152724.6508078801736235.davem@davemloft.net> <CAOMZO5ArHJy=KN8R5F0cOhDN=MnxRTmBUOgDsn8zutrTNw=igg@mail.gmail.com> <20130221.153812.2039434956437238374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:44420 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753022Ab3BVBNY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Feb 2013 20:13:24 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1U8hCn-0001mt-Tu
	for netdev@vger.kernel.org; Fri, 22 Feb 2013 02:13:41 +0100
Received: from jimbax.plus.com ([81.174.248.107])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2013 02:13:41 +0100
Received: from jim_baxter by jimbax.plus.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2013 02:13:41 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem <at> davemloft.net> writes:

> 
> From: Fabio Estevam <festevam <at> gmail.com>
> Date: Thu, 21 Feb 2013 17:29:46 -0300
> 
> > On Thu, Feb 21, 2013 at 5:27 PM, David Miller <davem <at> davemloft.net> 
wrote:
> > 
> >> Looks good, did you test this yourself or should we wait for others to
> >> test it out?
> > 
> > Yes, I tested it myself. I was the one who reported this bug and this
> > fixes the problem.
> 
> Perfect, applied to 'net', thanks!
> 


There is a divide by zero error.

If I enable these 3 kernel hacking options;
CONFIG_DEBUG_SPINLOCK:   -- Spinlock and rw-lock debugging: basic checks
CONFIG_DEBUG_LOCK_ALLOC: -- Lock debugging: detect incorrect freeing of live 
locks
CONFIG_PROVE_LOCKING:    -- Lock debugging: prove locking correctness


I get this error:


[   17.895723] Division by zero in kernel.
[   17.899571] Backtrace: 
[   17.902094] [<80012564>] (dump_backtrace+0x0/0x10c) from [<8056deec>] 
(dump_stack+0x18/0x1c)
[   17.910539]  r6:bfba8500 r5:8075c950 r4:bfba8000 r3:bfbd0000
[   17.916284] [<8056ded4>] (dump_stack+0x0/0x1c) from [<80012688>] 
(__div0+0x18/0x20)
[   17.923968] [<80012670>] (__div0+0x0/0x20) from [<802829c4>] (Ldiv0+0x8/0x10)
[   17.931140] [<80398534>] (fec_ptp_start_cyclecounter+0x0/0x110) from 
[<80394f64>] (fec_restart+0x6c8/0x754)
[   17.940898] [<8039489c>] (fec_restart+0x0/0x754) from [<803969a0>] 
(fec_enet_adjust_link+0xdc/0x108)
[   17.950046] [<803968c4>] (fec_enet_adjust_link+0x0/0x108) from [<80390bc4>] 
(phy_state_machine+0x178/0x534)
[   17.959791]  r8:00000000 r7:00000000 r6:bf80da5c r5:bf80da04 r4:bf80d800
r3:00000001
[   17.967750] [<80390a4c>] (phy_state_machine+0x0/0x534) from [<8003be40>] 
(process_one_work+0x1c0/0x464)
[   17.977147]  r8:00000000 r7:8150a300 r6:815071c0 r5:bf850c00 r4:bf80da04
r3:bfbd0000
[   17.985097] [<8003bc80>] (process_one_work+0x0/0x464) from [<8003ea64>] 
(worker_thread+0x134/0x3f0)
[   17.994165] [<8003e930>] (worker_thread+0x0/0x3f0) from [<8004420c>] 
(kthread+0xac/0xb8)
[   18.002271] [<80044160>] (kthread+0x0/0xb8) from [<8000ebf0>] 
(ret_from_fork+0x14/0x24)
[   18.010280]  r7:00000000 r6:00000000 r5:80044160 r4:bf875e10
