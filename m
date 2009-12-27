From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Sun, 27 Dec 2009 08:51:13 +0000
Message-ID: <20091227085113.GX18217@ZenIV.linux.org.uk>
References: <20091227010441.GA12077@heat> <200912271736.GDB17180.OFJHOOQStMFLVF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: michael@laptop.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	andi@firstfloor.org, david@lang.hm, socketcan@hartkopp.net,
	alan@lxorguk.ukuu.org.uk, herbert@gondor.apana.org.au,
	Valdis.Kletnieks@vt.edu, bdonlan@gmail.com, zbr@ioremap.net,
	cscott@cscott.net, jmorris@namei.org, ebiederm@xmission.com,
	bernie@codewiz.org, mrs@mythic-beasts.com, randy.dunlap@oracle.com,
	xiyou.wangcong@gmail.com, sam@synack.fr, casey@schaufler-ca.com,
	serue@us.ibm.com, pavel@ucw.cz
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:58771 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbZL0IvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2009 03:51:25 -0500
Content-Disposition: inline
In-Reply-To: <200912271736.GDB17180.OFJHOOQStMFLVF@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 27, 2009 at 05:36:48PM +0900, Tetsuo Handa wrote:

> Application writers know better what syscalls the application will call than
> application users.

Aren't you forgetting about libc?  Seriously, any interface along the
lines of "pass a set of syscall numbers to kernel" is DOA:
	* syscall numbers are architecture-dependent
	* there are socketcall-style multiplexors (sys_ipc, anyone?)
	* libc is free to substitute one for another
	* libc is free to do so in arch-specific manner
	* libc is free to do so in kernel-revision-specific manner
	* libc is free to do so in libc-revision-specific manner
(... and does all of the above)
	* new syscalls get added
	* e.g. on sparc64 32bit task can issue 64bit syscalls
