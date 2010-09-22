From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 18942] New: change to
 include/linux/netdevice.h prevents compilation for ARM architecture with
 AEABI enabled
Date: Wed, 22 Sep 2010 02:01:13 -0700
Message-ID: <20100922020113.b6ff0fd6.akpm@linux-foundation.org>
References: <bug-18942-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52981 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752033Ab0IVJCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 05:02:40 -0400
In-Reply-To: <bug-18942-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 22 Sep 2010 08:39:05 GMT bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=18942
> 
>            Summary: change to include/linux/netdevice.h prevents
>                     compilation for ARM architecture with AEABI enabled
>            Product: Platform Specific/Hardware
>            Version: 2.5
>     Kernel Version: 2.6.35.4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: blocking
>           Priority: P1
>          Component: ARM
>         AssignedTo: linux-arm-kernel@lists.arm.linux.org.uk
>         ReportedBy: ilya@total-knowledge.com
>         Regression: No
> 
> 
> I am trying to compile the latest kernel, and am running into the following
> error:
> In file included from include/linux/icmpv6.h:173,
>                  from include/linux/ipv6.h:220,
>                  from include/net/ipv6.h:16,
>                  from include/linux/sunrpc/clnt.h:25,
>                  from include/linux/nfs_fs.h:48,
>                  from init/do_mounts.c:20:
> include/linux/netdevice.h:1005: error: width of 'reg_state' exceeds its type
> include/linux/netdevice.h:1010: error: width of 'rtnl_link_state' exceeds its
> type
> 
> 
> There was a change not too long ago, which converted reg_state to a bitfield,
> which apparently doesn't work when -mabi=aapcs.
> I tested it with a gcc versions 4.2.0, 4.4.2, and 4.4.4 and it holds true for
> all of them.
> 
> Here is simple test case:
> struct test {
>         enum { NETREG_UNINITIALIZED=0,
>         } reg_state:16;
> };
> 
> int main(int argc, char** argv)
> {
>         struct test tt;
>         tt.reg_state=NETREG_UNINITIALIZED;
>         return 0;
> }
> 
> Compiles without -mabi=aapcs option, fails with.
> 

Bummer.  I guess that this abi requires that enums have `int' width for
some reason?

Does -mabi=aapcs actually get used, officially?  All I can see in
Linus's tree is

z:/usr/src/linux-2.6.36-rc5> grep -r aapcs .
./arch/arm/Makefile:CFLAGS_ABI  :=-mabi=aapcs-linux -mno-thumb-interwork

