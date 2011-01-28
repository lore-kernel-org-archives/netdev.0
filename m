From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 27742] New: PPP over SSH tunnel triggers OOPS
Date: Fri, 28 Jan 2011 14:32:38 -0800
Message-ID: <20110128143238.446e1821.akpm@linux-foundation.org>
References: <bug-27742-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, ktk@bigfoot.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35532 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753087Ab1A1WeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 17:34:03 -0500
In-Reply-To: <bug-27742-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 28 Jan 2011 21:58:49 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=27742
> 
>            Summary: PPP over SSH tunnel triggers OOPS
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.30 ?
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: ktk@bigfoot.com
>         Regression: Yes
> 
> 
> Created an attachment (id=45412)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=45412)
> Hand-copied OOPS from 2.6.37 kernel
> 
> When creating a VPN connection by using PPP tunneled over SSH, the kernel will
> OOPS when certain traffic patterns are encountered.  (See attached OOPS)
> 
> I first created such a VPN connection using kernel 2.6.33, which is affected. 
> Kernel 2.6.27 is not affected.  I have not attempted to binary-search for the
> exact commit, but am merely guessing it is in kernel 2.6.30 (as a variety of
> ppp-related commits appear in the changelog there).
> 
> The VPN tunnel is established by invoking 'pppd' with the 'pty' parameter set
> to invoke "ssh remotehost.com pppd" which establishes a SSH tunnel over IPv4 to
> the remote host and then invokes the remote pppd to handle the other end of the
> point-to-point VPN.
> 
> Reproducing this bug is not easy.  With the ppp-ssh-ppp tunnel open, I have
> tried triggering the OOPs by sending PINGs, rsync-ing files in both directions,
> opening interactive SSH connections.  Nothing seems to trigger the OOPS except
> one: running Mozilla Thunderbird on the remote end; it opens several IMAP
> connections over the tunnel simultaneously.  Typically, the OOPS will occur
> within 1 or 2 seconds of invoking Thunderbird.
> 
> When the OOPS occurs, usually the console will be scrolling wildly with OOPS
> after OOPS, making copying impossible.  It has taken me two months of repeated
> tries to get one OOPS that remained on-screen and could be copied.  The kernel
> is in a hard-run state when the OOPS occurs; nothing gets logged to syslog, the
> keyboard is unresponsive (magic sysrq key does nothing).
> 

> skb_over_panic: text:c12a354f len:847 put:847 head:f57e8c00 data:f57e8c00 tail:0xf57e8f4f end:0xf57e8e80 dev:<NULL>
> kernel BUG at net/core/skbuff.c:127!
> invalid opcode: 0000 [#1] SMP
> last sysfs file: /sys/devices/virtual/net/ppp0/flags
> Modules linked in:
> 
> Pid: 0, comm: swapper Not tainted 2.6.37 #1 0KH290/OptiPlex GX620
> EIP: 0060:[<c1330110>] EFLAGS: 00010282 CPU: 0
> EIP is at skb_put+0x82/0x84
> EAX: 00000089 EBX: f57e8f4f ECX: c151579c EDX: 00000046
> ESI: 00000000 EDI: c1530760 EBP: f67bb384 ESP: f6409d50
>  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> Process swapper (pid: 0, ti=f6408000 task=c15114a0 task.ti=c1502000)
> Stack:
>  c14d4590 c12a354f 0000034f 0000034f f57e8c00 f57e8c00 f57e8f4f f57e8e80
>  c14d2509 f67bb380 f454db80 c12a354f 000005e0 00000244 f5f944c2 0000034f
>  c1390a0a f67bb3d4 f4648380 f67bb394 f67bb3a4 00000202 f454db80 f67bb000
> Call Trace:
>  [<c12a354f>] ? ppp_xmit_process+0x45a/0x4e6
>  [<c12a354f>] ? ppp_xmit_process+0x45a/0x4e6
>  [<c1390a0a>] ? tcp_manip_pkt+0xad/0xcb
>  [<c12a36d4>] ? ppp_start_xmit+0xf9/0x175
>  [<c133a496>] ? dev_hard_start_xmit+0x2a4/0x5c3
>  [<c1347cad>] ? sch_direct_xmit+0xb9/0x184
>  [<c134c663>] ? nf_iterate+0x52/0x76
>  [<c1362d56>] ? ip_finish_output+0x0/0x294
>  [<c133a88e>] ? dev_queue_xmit+0xd9/0x3b0
>  [<c1362d56>] ? ip_finish_output+0x0/0x294
>  [<c1362f32>] ? ip_finish_output+0x1dc/0x294
>  [<c1362d56>] ? ip_finish_output+0x0/0x294
>  [<c1360d66>] ? ip_forward_finish+0x36/0x42
>  [<c135f8a4>] ? ip_rcv_finish+0x42/0x323
>  [<c13384ac>] ? __netif_receive_skb+0x225/0x299
>  [<c1048b56>] ? getnstimeofday+0x42/0xe8
>  [<c13386ab>] ? netif_receive_skb+0x41/0x64
>  [<c1339356>] ? dev_gro_receive+0x146/0x1dd
>  [<c133955e>] ? napi_gro_receive+0xa5/0xb3
>  [<c129ae2f>] ? tg3_poll_wor+0x5df/0xaca
>  [<c1007340>] ? nommu_sync_single_for_device+0x0/0x1
>  [<c129b3e2>] ? tg3_poll+0x43/0x19a
>  [<c133893b>] ? net_rx_action+0x6c/0xf4
>  [<c1031eb5>] ? __do_softirq+0x77/0xf0
>  [<c1031e3e>] ? __do_softirq+0x0/0xf0
>  <IRQ>
>  [<c1031fe6>] ? irq_exit+0x5d/0x5f
> 
