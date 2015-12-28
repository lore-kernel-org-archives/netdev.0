From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] netconsole: Initialize after all core networking drivers
Date: Mon, 28 Dec 2015 15:24:05 -0800
Message-ID: <CAHA+R7OddkTrOoT1CrvoG=AJKddNyd4PZJFDBJXYXC1ucyHrNw@mail.gmail.com>
References: <20151217235239.GA1444048@devbig337.prn1.facebook.com>
	<1450400894.8474.114.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151218014615.GB1715233@devbig337.prn1.facebook.com>
	<20151223230328.GA967745@devbig337.prn1.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	izumi.taku@jp.fujitsu.com, John Linville <linville@tuxdriver.com>,
	David Ahern <dsa@cumulusnetworks.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel-team <kernel-team@fb.com>
To: Calvin Owens <calvinowens@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:34130 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752618AbbL1XYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2015 18:24:06 -0500
Received: by mail-yk0-f175.google.com with SMTP id a85so39164480ykb.1
        for <netdev@vger.kernel.org>; Mon, 28 Dec 2015 15:24:05 -0800 (PST)
In-Reply-To: <20151223230328.GA967745@devbig337.prn1.facebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 23, 2015 at 3:03 PM, Calvin Owens <calvinowens@fb.com> wrote:
> Commit 7332a13b038be05c ("vxlan: defer vxlan init as late as possible")
> changed vxlan to use late_initcall(), because vxlan relies on ipv6 being
> loaded when a new device is opened.
>
> This causes netconsole to panic at boot when configured via the kernel
> cmdline on an IXGBE NIC, because ixgbe_open() assumes that vxlan has
> already been initialized:

BTW, it is not fair to blame my commit above, since it was merged long before
ixgbe or any hardware driver has vxlan support. Not a big deal, just FYI. ;)
