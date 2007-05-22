From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: hard freezes on TX
Date: Tue, 22 May 2007 22:29:34 +0200
Message-ID: <20070522202934.GA21991@electric-eye.fr.zoreil.com>
References: <200705201520.36672.eike-kernel@sf-tec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Rolf Eike Beer <eike-kernel@sf-tec.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:56259 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754343AbXEVUbb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2007 16:31:31 -0400
Content-Disposition: inline
In-Reply-To: <200705201520.36672.eike-kernel@sf-tec.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rolf Eike Beer <eike-kernel@sf-tec.de> :
[...]
> I often see freezes when I do much outgoing transfer. I have never seen this 
> happening on incoming transfers. When this happens the system locks up hard, 
> I don't see anything in the log. Since this is my laptop I have trouble 
> debugging it: there is no serial console and debugging this via netconsole 
> doesn't look like a good idea.

Keyboard leds are dead afterwards I guess, right ?

If you are experiencing bugs related to networking, I suggest to stay
away from netconsole. It is not funny to analyze several bugs at the same
time.

> When I say "much outgoing transfer" this means "several megabytes". If I copy 
> out 30 MB I almost everytime get this. I usually copy that much only at home 
> when I feed my gentoo server. That host only has a 10 MBit connection. 
> Nevertheless I've also seen that on different hosts using different files on 
> different protocols (ftp, scp, smb).

:o/

So it can be reproduced with a simple ftp put of several megabytes of
data completely cached in memory (no disk access) ?

[...]
> This is the output of lspci for my NIC:
> 
> 05:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8101E PCI 
> Express Fast Ethernet controller (rev 01)

I have not seen a lot of reports for this one. Either it is perfect or
it is barely used.

[...]
> Hm, is there a reason why we don't use MSI here?

A request for testers was posted (netdev + lk) on 16/03/2007 which contained
MSI code for the 8168. I did not enable it for the 8101 because it had only
received (positive) reports from 8168 users.

Afair, the RFT got no feedback.

> Ah, one thing is missing: I've not tested it with current kernel, latest I 
> tested was 2.6.21-rc7. But I've seen this on many previous version, although 
> I thought it became better some versions ago. I wont bet on it, it might just 
> have been luck.

You can/should try:
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.22-rc2 (patch-kit)
or:
http://www.fr.zoreil.com/people/francois/misc/20070522-2.6.22-rc2-r8169.patch

If you are fluent with git and you do not mind rebasing, you can try
git://electric-eye.fr.zoreil.com/home/romieu/linux/linux-2.6-out r8169

(don't do the initial clone from here, thanks)

As an option, akpm includes the git branch for you in -mm.

-- 
Ueimor
