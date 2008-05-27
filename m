From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: race in skb_splice_bits?
Date: Tue, 27 May 2008 17:39:11 +0300
Message-ID: <200805271739.11612.opurdila@ixiacom.com>
References: <200805270325.24323.opurdila@ixiacom.com> <20080527132148.GA7368@2ka.mipt.ru> <20080527140318.GA6963@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:4663 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754538AbYE0OkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 10:40:20 -0400
In-Reply-To: <20080527140318.GA6963@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 27 May 2008, Evgeniy Polyakov wrote:
> On Tue, May 27, 2008 at 05:21:48PM +0400, Evgeniy Polyakov 
(johnpol@2ka.mipt.ru) wrote:
> > On Tue, May 27, 2008 at 03:53:49PM +0300, Octavian Purdila 
(opurdila@ixiacom.com) wrote:
> > > When you interrupt the program, the system will crash.
> >
> > Cool!
> >
> > I've reproduced the problem and will try to work it out, thank you.
>
> Attached patch fixes the crash for me, Octavian could you please test
> it.
>

On my system it still crashes, if I interrupt the program before splice 
blocks:

[   16.170009] NIP [8014d0c0] tcp_read_sock+0x138/0x1f8
[   16.170009] LR [8014d090] tcp_read_sock+0x108/0x1f8
[   16.170009] Call Trace:
[   16.170009] [bcd21dd0] [8014d090] tcp_read_sock+0x108/0x1f8 (unreliable)
[   16.170009] [bcd21e20] [8014b590] __tcp_splice_read+0x34/0x44
[   16.170009] [bcd21e40] [8014b620] tcp_splice_read+0x80/0x220
[   16.170009] [bcd21e90] [80105730] sock_splice_read+0x2c/0x44
[   16.170009] [bcd21ea0] [8008a374] do_splice_to+0x90/0xac
[   16.170009] [bcd21ed0] [8008a850] do_splice+0x258/0x2f0
[   16.170009] [bcd21f10] [8008b1d4] sys_splice+0xe0/0xe8
[   16.170009] [bcd21f40] [8000ff14] ret_from_syscall+0x0/0x38


Thanks,
tavi
