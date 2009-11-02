From: Patrick McHardy <kaber@trash.net>
Subject: Re: HTB accuracy on 10GbE
Date: Mon, 02 Nov 2009 16:43:42 +0100
Message-ID: <4AEEFE2E.7090706@trash.net>
References: <b30d1c3b0911012322v5d553fd6va56575fcf5e3daf8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, Linux Netdev List <netdev@vger.kernel.org>,
	takano-ryousei@aist.go.jp
To: Ryousei Takano <ryousei@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53211 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755441AbZKBPnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 10:43:39 -0500
In-Reply-To: <b30d1c3b0911012322v5d553fd6va56575fcf5e3daf8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ryousei Takano wrote:
> Hi Stephen and all,
> 
> I have observed a HTB accuracy problem on the Linux kernel 2.6.30 and
> the Myri-10G 10 GbE NIC.
> HTB can control the transmission rate at Gigabit speed, however it can
> not work well at 10 Gigabit speed.
> 
> I asked Stephen this problem at Japan Linux Symposium.  He mentioned a
> HTB bug related to the timer granularity.
> I want to know what is happen, and what should be do for fixing it.
> 
> Any comments and suggestions will be welcome.
> 
> For more detail, please see the following page:
> http://code.google.com/p/pspacer/wiki/HTBon10GbE

This is not an easy problem to fix. Userspace, the kernel and the
netlink API use 32 bit for timing related values, which is too small
to use more than microsecond resolution. All of them need to be
converted to use bigger types, additionally some kind of compatibility
handling to deal with old iproute versions still using microsecond
resolution is required.
