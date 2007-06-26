From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8678] New: Kernel OOPSes when suspend/resume
Date: Tue, 26 Jun 2007 10:53:03 -0700
Message-ID: <20070626105303.6a2ffdeb.akpm@linux-foundation.org>
References: <bug-8678-10286@http.bugzilla.kernel.org/>
	<20070626100953.a842b081.akpm@linux-foundation.org>
	<200706261942.14722.cijoml@volny.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pm@lists.linux-foundation.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: CIJOML <cijoml@volny.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58823 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756714AbXFZRxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2007 13:53:23 -0400
In-Reply-To: <200706261942.14722.cijoml@volny.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 26 Jun 2007 19:42:14 +0200 CIJOML <cijoml@volny.cz> wrote:

> > > EIP is at put_page+0x5/0xb2
> > > eax: 00000000   ebx: 00000000   ecx: c0317380   edx: f63f70c0
> > > esi: ea6e2680   edi: f784dd84   ebp: f784de48   esp: f784dd4c
> > > ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss: 0068
> > > Process syslogd (pid: 3160, ti=f784c000 task=f7995070 task.ti=f784c000)
> > > Stack: 00000001 ea6e2680 f784dd84 c02aebed ea6e2680 f784df20 c02aea21
> > > ea6e26b0 c02f58fb 00000036 000001ff f7ca36c0 f7dcfb00 ea6e2680 00000d1f
> > > 00000000 00000000 00000000 00000001 00000000 000001ff 0ac3ac80 00000036
> > > c0317380 Call Trace:
> > >  [<c02aebed>] skb_release_data+0x4e/0x80
> > >  [<c02aea21>] kfree_skbmem+0x8/0x61
> > >  [<c02f58fb>] unix_dgram_recvmsg+0x214/0x239
> > >  [<c02a9e24>] sock_recvmsg+0xec/0x107
> > >  [<c0128b23>] autoremove_wake_function+0x0/0x35
> > >  [<c0166775>] core_sys_select+0x1aa/0x2bc
> > >  [<c0160a26>] pipe_write+0x356/0x3ed
> > >  [<c015ae4d>] do_sync_readv_writev+0xc1/0xfe
> > >  [<c02aad15>] sys_recvfrom+0xd7/0x12b
> > >  [<c0128b23>] autoremove_wake_function+0x0/0x35
> > >  [<c02aada0>] sys_recv+0x37/0x3b
> > >  [<c02ab283>] sys_socketcall+0x19c/0x261
> > >  [<c0120dc5>] sigprocmask+0x94/0xb1
> > >  [<c0103cdc>] syscall_call+0x7/0xb
> > >  =======================
> > > Code: 42 c0 e8 66 fe ff ff 89 e0 25 00 e0 ff ff ff 48 14 8b 40 08 a8 08
> > > 74 05 e9 18 0f 1b 00 c3 e8 b4 ff ff ff 31 c0 c3 57 56 53 89 c
> > >                                                3 <8b> 00 f6 c4 40 74 0a
> > > 89 d8 5b 5e 5f e9 e9 fb ff ff ff 4b 04 0f
> > > EIP: [<c014787a>] put_page+0x5/0xb2 SS:ESP 0068:f784dd4c
> >
> > Good heavens.
> >
> > Does it oops every time?  And does the oops trace always look like this?
> 
> Hi Andrew,
> 
> let's guess why I marked it Critical ;)

dayum.  I cannot imagine how a susend/resume can cause a crash in
AF_UNIX code.  Which network device driver(s) are in use?
