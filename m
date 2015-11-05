From: Patrick Schaaf <netdev@bof.de>
Subject: Re: kernel 3.14.53 + bnx2x loss of connectivity / parity errors / MCP SCPAD
Date: Thu, 05 Nov 2015 09:25:30 +0100
Message-ID: <6380451.UzJpC4z4kH@rofl>
References: <1727409.Ct3NHyBiXb@rofl> <B5657A6538887040AD3A81F1008BEC63E6B99B@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev <netdev@vger.kernel.org>,
	Greg KH <gregkh@linuxfoundation.org>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mars.intermailgate.com ([80.242.145.70]:58808 "EHLO
	mars.intermailgate.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030562AbbKEIZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 03:25:32 -0500
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63E6B99B@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Yuval,

thanks for your notes.

> 4. The patch you've listed merely removes the MCP SCPAD prints, as they're
> unavoidable in certain scenarios; It doesn't actually solve anything.

I also thought so, thanks for confirming. Do you know whether the messages 
might have hidden earlier messages pointing to the real problem?

> Having said that, do you know if anything happened to the setup that
> triggered this? I.e., so configuration change, new utility, etc.?
> Alternatively, did the log show anything else in addition to the MCP SCPAD?

There was no update or configuration activity on the box, it was just running 
along as usual, operating some virtual machines. Uptime was about 22 days. I 
have a second, practically identical server, running pretty much the same 
workload, which is still up + running nicely.

I was a bit overeager to reboot the server (power reset) and didn't even try 
whether I could still log in (shame on me). After the reset the virtual 
machines all came up fine, so at least filesystem flushing was still working 
properly during the network breakage event.

The systemd journal logged a vast amount of the messages I've shown (with lots 
of "missed kernel messages" too), for a duration of about 8 seconds. In total, 
including the suppressions, it would have been over 1 million messages during 
the 8 seconds. Running a "sort|uniq" over the visibly logged messages I see:

   8786 kernel: bnx2x 0000:04:00.0 eth0: Parity errors detected in blocks:
   8768 kernel: bnx2x 0000:04:00.1 eth1: Parity errors detected in blocks:
   1583 kernel: bnx2x: [bnx2x_attn_int_deasserted3:4080(eth0)]LATCHED 
attention 0x80000000 (masked)
   1743 kernel: bnx2x: [bnx2x_attn_int_deasserted3:4080(eth1)]LATCHED 
attention 0x80000000 (masked)
  36092 kernel: MCP SCPAD:
      1 kernel: RAX: 0000000000000000 RBX: 000000198111fb67 RCX: 
00000000ffffffff

I'll now see that I backport that "MCP SCPAD" logging suppression patch to the 
latest 3.14 kernel, and reboot the boxes with that, hoping to learn more if 
the situation reoccurs.

best regards
  Patrick
