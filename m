From: Tom Herbert <therbert@google.com>
Subject: Re: e1000e tx queue timeout in 3.3.0 (bisected to BQL support for e1000e)
Date: Fri, 20 Apr 2012 14:21:31 -0700
Message-ID: <CA+mtBx-K6-O3ea34kmn4LXtx73FqCHF16w7pBSq1fHNN+-DxCA@mail.gmail.com>
References: <4F909F4B.1010707@candelatech.com>
	<CA+mtBx9ZjfC692g1EwNsw=37ijWcGBOUaENCogVS=Bi9rfz0sg@mail.gmail.com>
	<4F91B250.8090509@candelatech.com>
	<CA+mtBx9s70wawA4E3+LyOQhJXRr1y-0j_Pzno5bBSz8TS3SUOA@mail.gmail.com>
	<4F91B554.9060902@candelatech.com>
	<4F91BC82.2000804@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	netdev <netdev@vger.kernel.org>,
	e1000-devel list <e1000-devel@lists.sourceforge.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:54715 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752394Ab2DTVVc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 17:21:32 -0400
Received: by iagz16 with SMTP id z16so13920567iag.19
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 14:21:32 -0700 (PDT)
In-Reply-To: <4F91BC82.2000804@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks John for pointers to those.  Ben, are you running a kernel with
these patches?

Tom

>
> Tom, did you see these two patches? Maybe this is resolved by
> the second patch.
>
> We needed these to fixup ixgbe and igb (i didn't test e1000e)
> looks like we might want to push these at stable. I don't
> believe they are in 3.3.
>
> commit b37c0fbe3f6dfba1f8ad2aed47fb40578a254635
> Author: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: =A0 Tue Feb 7 02:29:06 2012 +0000
>
> =A0 =A0net: Add memory barriers to prevent possible race in byte queu=
e limits
>
> =A0 =A0This change adds a memory barrier to the byte queue limit code=
 to address a
> =A0 =A0possible race as has been seen in the past with the
> =A0 =A0netif_stop_queue/netif_wake_queue logic.
>
> =A0 =A0Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> =A0 =A0Tested-by: Stephen Ko <stephen.s.ko@intel.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
>
> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commit;h=3Db37c0fbe3f6dfba1f8ad2aed47fb40578a254635
>
>
> commit 5c4903549c05bbb373479e0ce2992573c120654a
> Author: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: =A0 Tue Feb 7 02:29:01 2012 +0000
>
> =A0 =A0net: Fix issue with netdev_tx_reset_queue not resetting queue =
from XOFF state
>
> =A0 =A0We are seeing dev_watchdog hangs on several drivers. =A0I susp=
ect this is due
> =A0 =A0to the __QUEUE_STATE_STACK_XOFF bit being set prior to a reset=
 for link
> =A0 =A0change, and then not being cleared by netdev_tx_reset_queue. =A0=
This change
> =A0 =A0corrects that.
>
> =A0 =A0In addition we were seeing dev_watchdog hangs on igb after run=
ning the
> =A0 =A0ethtool tests. =A0We found this to be due to the fact that the=
 ethtool test
> =A0 =A0runs the same logic as ndo_start_xmit, but we were never clear=
ing the XOFF
> =A0 =A0flag since the loopback test in ethtool does not do byte queue=
 accounting.
>
> =A0 =A0Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> =A0 =A0Tested-by: Stephen Ko <stephen.s.ko@intel.com>
> =A0 =A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commit;h=3D5c4903549c05bbb373479e0ce2992573c120654a
>
>
