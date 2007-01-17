From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: Can someone please try...
Date: Wed, 17 Jan 2007 10:52:12 +0100
Message-ID: <200701171052.12855.mb@bu3sch.de>
References: <200701161806.02780.mb@bu3sch.de> <200701162307.02891.mb@bu3sch.de>
	<1168991519.17787.17.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
In-Reply-To: <1168991519.17787.17.camel@dv>
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 17 January 2007 00:51, Pavel Roskin wrote:
> On Tue, 2007-01-16 at 23:07 +0100, Michael Buesch wrote:
> > On Tuesday 16 January 2007 22:50, Pavel Roskin wrote:
> > > On Tue, 2007-01-16 at 20:23 +0100, Michael Buesch wrote:
> > > 
> > > > A patch for that is already upstream.
> > > 
> > > I don't see it.  It's not in your tree yet.
> > 
> > It is on its way upstream to linville.
> 
> Well, it's pretty cruel to ask others to test code with known fatal
> bugs, IMHO.

I forgot that the bug was there, because it doesn't trigger on my
machines. I already explained that...

> Even it git were extremely poor at handling a patch applied 
> in two branches.  In fact, git is not so bad at all at handling such
> situations.

I have to wait until linville pulls it. Fullstop.

> > > > It's surprising that it doesn't happen for me, though.
> > > > Neiter on PPC, nor on i386.
> > > 
> > > It did happen for me on i386, as well as on x86_64.  The dump was for
> > > x86_64, as evidenced by the register size.  Maybe you have less
> > > debugging options enabled?
> > 
> > All.
> 
> That's commendable.  I tried the 32-bit kernel without SMP and with
> almost all debugging.  One thing I noticed is that scanning ignores the
> pure 802.11b AP running HostAP that I was going to use for testing.
> Other APs are detected.  The association didn't work, probably for that
> reason.

Probably some d80211 bug. Dunno.

> Scanning may trigger many assertion failures:
> 
> bcm43xx_d80211: ASSERTION FAILED ((lna & ~0x7) == 0)
> at: /home/proski/src/linux-2.6/drivers/net/
> wireless/d80211/bcm43xx/bcm43xx_lo.c:235:lo_measure_feedthrough()

It's not triggered by scanning, it's known and it's nonfatal.

> Finally, interrupting wpa_supplicant hits another bug:
> 
> BUG: unable to handle kernel paging request at virtual address c3e2cbf8
>  printing eip:
> e03835e1
> *pde = 0000f067
> *pte = 03e2c000
> Oops: 0002 [#1]
> DEBUG_PAGEALLOC
> Modules linked in: bcm43xx_d80211 ssb
> CPU:    0
> EIP:    0060:[<e03835e1>]    Not tainted VLI
> EFLAGS: 00210282   (2.6.20-rc3 #3)
> EIP is at bcm43xx_wireless_core_init+0x5a/0x98e [bcm43xx_d80211]
> eax: 00000000   ebx: c3dab740   ecx: 000000e1   edx: c3493808
> esi: c34937f8   edi: c3e2cbf8   ebp: c3e60e38   esp: c3e60db8
> ds: 007b   es: 007b   ss: 0068
> Process wpa_supplicant (pid: 2942, ti=c3e60000 task=c3f92590 task.ti=c3e60000)
> Stack: c0339db6 c0339db6 00000000 c3f92590 c0339db6 00200246 c3e60df0 c3f30000 
>        c3dab740 c0339de4 c3493808 c3e60e0c c3e60e0c 00200246 c3e60e2c c0339dc0 
>        00000000 00000002 c0339de4 c3e60e50 c3f92590 22222222 22222222 22222222 
> Call Trace:
>  [<c010335d>] show_trace_log_lvl+0x1a/0x2f
>  [<c010340d>] show_stack_log_lvl+0x9b/0xa3
>  [<c01035a6>] show_registers+0x191/0x267
>  [<c010378f>] die+0x113/0x212
>  [<c011010a>] do_page_fault+0x43a/0x50c
>  [<c033b47c>] error_code+0x74/0x7c
>  [<e03850bc>] bcm43xx_add_interface+0x4f/0xb7 [bcm43xx_d80211]
>  [<c032022f>] ieee80211_open+0x19d/0x27e
>  [<c02dbb77>] dev_open+0x2d/0x64
>  [<c02da71f>] dev_change_flags+0x51/0xf1
>  [<c030b67a>] devinet_ioctl+0x235/0x53a
>  [<c030bc38>] inet_ioctl+0x73/0x91
>  [<c02d1db8>] sock_ioctl+0x1ac/0x1c9
>  [<c015dd64>] do_ioctl+0x1c/0x51
>  [<c015df94>] vfs_ioctl+0x1fb/0x212
>  [<c015dfdc>] sys_ioctl+0x31/0x49
>  [<c0102cba>] sysenter_past_esp+0x5f/0x99
>  =======================
> Code: 00 80 66 0d ef 8d be 9c 01 00 00 f3 ab 8b 7a 5c 80 62 49 c5 c7 42 4c ff ff ff ff 85 ff c7 
> 42 50 00 00 00 00 74 13 b9 e1 00 00 00 <f3> ab 8b 42 5c 66 c7 80 76 03 00 00 ff ff 8b 4d a8 89 f
> 0 c7 41 
> EIP: [<e03835e1>] bcm43xx_wireless_core_init+0x5a/0x98e [bcm43xx_d80211] SS:ESP 0068:c3e60db8

Doesn't happen for me. I have no idea what's happening.
Care to debug it?
But it's weird that _killing_ the supplicant calls add_interface.
I'd expect it to call remove_interface.

> Then I used MadWifi on the AP side, and "iwpriv scan" picked it.
> Moreover, wpa_supplicant reported connection!  I interrupted
> wpa_supplicant and started it again, and then the kernel oopsed again.
> Strangely, the driver is not even mentioned in the backtrace.
> 
> BUG: unable to handle kernel NULL pointer dereference at virtual address 00000004
>  printing eip:
> c02d8863
> *pde = 00000000
> Oops: 0002 [#1]
> DEBUG_PAGEALLOC
> Modules linked in: bcm43xx_d80211 ssb
> CPU:    0
> EIP:    0060:[<c02d8863>]    Not tainted VLI
> EFLAGS: 00210246   (2.6.20-rc3 #3)
> EIP is at datagram_poll+0xba/0xc5
> eax: 00000000   ebx: cc252bf8   ecx: 00000049   edx: 00000000
> esi: 00000002   edi: 00000004   ebp: cb940b70   esp: cb940b68
> ds: 007b   es: 007b   ss: 0068
> Process wpa_supplicant (pid: 4344, ti=cb940000 task=c2be0590 task.ti=cb940000)
> Stack: c0353220 c9fedf2c cb940b7c c02d1643 00000000 cb940e30 c015ebae c033b3bd
>        cb940e54 cb940e50 cb940f9c cb940f50 cb940be0 00000000 00000000 cb940e5c
>        cb940e60 cb940e64 cb940e50 cb940e54 cb940e58 00000070 00000000 00000000
> Call Trace:
>  [<c010335d>] show_trace_log_lvl+0x1a/0x2f
>  [<c010340d>] show_stack_log_lvl+0x9b/0xa3
>  [<c01035a6>] show_registers+0x191/0x267
>  [<c010378f>] die+0x113/0x212
>  [<c011010a>] do_page_fault+0x43a/0x50c
>  [<c033b47c>] error_code+0x74/0x7c
>  [<c02d1643>] sock_poll+0x12/0x15
>  [<c015ebae>] do_select+0x2b4/0x4cc
>  [<c015f076>] core_sys_select+0x2b0/0x2d5
>  [<c015f631>] sys_select+0x99/0x170
>  [<c0102cba>] sysenter_past_esp+0x5f/0x99
>  =======================
> Code: ca 3c 02 74 2b 8b 83 7c 01 00 00 ba 02 00 00 00 89 d6 99 f7 fe 39 83 cc 00 00 00 7d 08 81
> c9 04 03 00 00 eb 0b 8b 83 44 02 00 00 <0f> ba 68 04 00 5b 89 c8 5e 5d c3 55 89 e5 57 56 89 c6 5
> 3 83 ec
> EIP: [<c02d8863>] datagram_poll+0xba/0xc5 SS:ESP 0068:cb940b68

I have absolutely no idea. Did not happen a single time for me.
In fact. It's all pretty stable on my machines.

-- 
Greetings Michael.
