From: "Jon Smirl" <jonsmirl@gmail.com>
Subject: Re: [PATCH] phy: export phy_mii_ioctl
Date: Tue, 18 Sep 2007 15:29:09 -0400
Message-ID: <9e4733910709181229m4afe7ecr56e2411f52a84232@mail.gmail.com>
References: <20070810095153.GC13994@moe.telargo.com>
	 <20070902074143.GB2642@nd47.coderock.org>
	 <fa686aa40709030857j6c36c87ek60215f812864ee0f@mail.gmail.com>
	 <20070915121444.GA19857@nd47.coderock.org>
	 <20070917095334.GA4546@powerlinux.fr>
	 <20070917202140.GB2642@nd47.coderock.org>
	 <9e4733910709171508s76c842c8hca236249617cbb44@mail.gmail.com>
	 <20070918151622.GD32628@nd47.coderock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-embedded@ozlabs.org,
	sven@powerlinux.fr
To: "Domen Puncer" <domen@coderock.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.249]:41651 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753012AbXIRT3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 15:29:14 -0400
Received: by an-out-0708.google.com with SMTP id d31so300376and
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 12:29:13 -0700 (PDT)
In-Reply-To: <20070918151622.GD32628@nd47.coderock.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/18/07, Domen Puncer <domen@coderock.org> wrote:
> More testing and getting it to work properly on Phytec pcm030 would
> be great.

Do we want to do anything about this?

[    1.569657] net eth0: attached phy 0 to driver Generic PHY
[    2.576013] Sending DHCP requests .<6>PHY: f0003000:00 - Link is Up
- 100/Full
[    4.612000] ., OK
[    6.764005] IP-Config: Got DHCP answer from 192.168.1.200, my
address is 192.168.1.5

What is happening is the printk for "<6>PHY: f0003000:00 - Link is Up
- 100/Full" is done in an interrupt and it comes in the middle of the
kernel doing DHCP and printing ... without a CR.

Two possible solutions, get rid of the link-up message or wait in in
the initial driver load until the link is up. Or we could leave it the
way it is, but some people may report this as a bug.


-- 
Jon Smirl
jonsmirl@gmail.com
