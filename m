From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: RESEND, HTB(?) softlockup, vanilla 2.6.24
Date: Sat, 16 Feb 2008 09:00:36 +0100
Message-ID: <47B69824.4030405@gmail.com>
References: <20080213081318.M90354@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:31784 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401AbYBPH5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2008 02:57:39 -0500
Received: by fg-out-1718.google.com with SMTP id e21so737109fga.17
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2008 23:57:37 -0800 (PST)
In-Reply-To: <20080213081318.M90354@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote, On 02/13/2008 09:13 AM:

> It is very difficult to reproduce, happened after running about 1month. No 
> changes done in classes at time of crash.
> 
> Kernel 2.6.24 vanilla


Hi,

I could be wrong, but IMHO this looks like stack was overridden here,
so my proposal is to try this:

CONFIG_DEBUG_STACKOVERFLOW=y

But, if you're not very interested in reproducing this, you could also
try to turn off some other debugging, especially lockdep.

Regards,
Jarek P.

...

> Feb 10 15:53:22 SHAPER [ 8271.778915] BUG: NMI Watchdog detected LOCKUP
> Feb 10 15:53:22 SHAPER on CPU1, eip c01f0e5d, registers:

...

> Feb 10 15:53:22 SHAPER [ 8271.779307] Pid: 0, comm: swapper Not tainted 
> (2.6.24-build-0021 #26)
> Feb 10 15:53:22 SHAPER [ 8271.779327] EIP: 0060:[<c01f0e5d>] EFLAGS: 00000082 
> CPU: 1
> Feb 10 15:53:22 SHAPER [ 8271.779349] EIP is at __rb_rotate_right+0x5/0x50
> Feb 10 15:53:22 SHAPER [ 8271.779366] EAX: f76494a4 EBX: f76494a4 ECX: 
> f76494a4 EDX: c1ff5f80
> Feb 10 15:53:22 SHAPER [ 8271.779386] ESI: f76494a4 EDI: c1ff5f80 EBP: 
> 00000000 ESP: f7c29c70
> Feb 10 15:53:22 SHAPER [ 8271.779406]  DS: 007b ES: 007b FS: 00d8 GS: 0000 
> SS: 0068
> Feb 10 15:53:22 SHAPER [ 8271.779425] Process swapper (pid: 0, ti=f7c28000 
> task=f7c20a60 task.ti=f7c28000)
> Feb 10 15:53:22 SHAPER
> Feb 10 15:53:22 SHAPER [ 8271.779446] Stack:
> Feb 10 15:53:22 SHAPER f76494a4
> Feb 10 15:53:22 SHAPER f76494a4
> Feb 10 15:53:22 SHAPER f76494a4
> Feb 10 15:53:22 SHAPER c01f0ef4
> Feb 10 15:53:22 SHAPER c1ff5f80
> Feb 10 15:53:22 SHAPER f76494a4
> Feb 10 15:53:22 SHAPER f76494a8
> Feb 10 15:53:22 SHAPER c1ff5f78
> Feb 10 15:53:22 SHAPER
> Feb 10 15:53:22 SHAPER [ 8271.779493]
> Feb 10 15:53:22 SHAPER [ 8271.779307] Pid: 0, comm: swapper Not tainted 
> (2.6.24-build-0021 #26)
> Feb 10 15:53:22 SHAPER [ 8271.779327] EIP: 0060:[<c01f0e5d>] EFLAGS: 00000082 
> CPU: 1
> Feb 10 15:53:22 SHAPER [ 8271.779349] EIP is at __rb_rotate_right+0x5/0x50
> Feb 10 15:53:22 SHAPER [ 8271.779366] EAX: f76494a4 EBX: f76494a4 ECX: 
> f76494a4 EDX: c1ff5f80
> Feb 10 15:53:22 SHAPER [ 8271.779386] ESI: f76494a4 EDI: c1ff5f80 EBP: 
> 00000000 ESP: f7c29c70
> Feb 10 15:53:22 SHAPER [ 8271.779406]  DS: 007b ES: 007b FS: 00d8 GS: 0000 
> SS: 0068
> Feb 10 15:53:22 SHAPER [ 8271.779425] Process swapper (pid: 0, ti=f7c28000 
> task=f7c20a60 task.ti=f7c28000)
> Feb 10 15:53:22 SHAPER
> Feb 10 15:53:22 SHAPER [ 8271.779446] Stack:
> Feb 10 15:53:22 SHAPER f76494a4
> Feb 10 15:53:22 SHAPER f76494a4
> Feb 10 15:53:22 SHAPER f76494a4

...
