From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: PROBLEM: Bridging does not work with Mellanox ConnectX-2
 (mlx4_en) card in SR-IOV mode
Date: Mon, 24 Jun 2013 22:42:10 +0300
Message-ID: <CAJZOPZLCG8_zfsP76EnEcGj3nUfP9batXMfvOqsPyNc63JqLSA@mail.gmail.com>
References: <CAJA5wJQDRztwtMxJopUWfmqEOH39Xp0g-hCrY8gMZ2TKccSuhw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Ryousei Takano <takano-ryousei@aist.go.jp>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Amir Vadai <amirv@mellanox.com>, Yan Burman <yanb@mellanox.com>
To: Pawit Pornkitprasan <p.pawit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f41.google.com ([209.85.216.41]:59943 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745Ab3FXTmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 15:42:11 -0400
Received: by mail-qa0-f41.google.com with SMTP id f14so18750qak.14
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 12:42:10 -0700 (PDT)
In-Reply-To: <CAJA5wJQDRztwtMxJopUWfmqEOH39Xp0g-hCrY8gMZ2TKccSuhw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 24, 2013 at 10:55 AM, Pawit Pornkitprasan <p.pawit@gmail.com> wrote:
> [1.] One line summary of the problem:
> Bridging does not work with Mellanox ConnectX-2 (mlx4_en) card in SR-IOV mode
>
> [2.] Full description of the problem/report:
> I am using Mellanox ConnectX-2 card with SR-IOV support enabled.
> (options mlx4_core num_vfs=8). When I use the device as a part of the
> bridge, devices behind the bridge can see broadcast network packets,
> but cannot see unicast packets directed to them. Devices behind the
> bridge can send packets properly (though not so useful since it cannot
> receive any reply). Further detail provided under reproduction
> section.
>
> When SR-IOV is disabled (num_vfs=0), bridging works as expected
>
> [3.] Keywords (i.e., modules, networking, kernel):
> mlx4_en, networking, sr-iov, bridge
>
> [4.] Kernel information
> [4.1.] Kernel version (from /proc/version):
> Linux version 3.10.0-rc7+ (root@khonmek-16) (gcc version 4.7.3
> (Ubuntu/Linaro 4.7.3-1ubuntu1) ) #1 SMP Mon Jun 24 11:42:32 JST 2013


Pawit,

As Greg indicdated, this (== stetting a bridge over a PF or VF in
SRIOV moded) can actually work, if you make sure to use FDB operations
to add the VM unicast MAC to the uplink (the mellanox device) tables,
this is trivial (google for ndo_fdb_add ...) and should work, let us
know if it doesn't.

> also happens with latest Ubuntu-Raring kernel
> Linux version 3.8.0-25-generic (buildd@roseapple) (gcc version 4.7.3
> (Ubuntu/Linaro 4.7.3-1ubuntu1) ) #37-Ubuntu SMP Thu Jun 6 20:47:07 UTC 2013

so on 3.10 it "just" doesn't work (but should as I explained above)
but on 3.8 you're crashing? can you send the oops listings?

Or.
