From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: APIC error on 32-bit kernel
Date: Tue, 27 Mar 2007 19:04:27 -0600
Message-ID: <m18xdiw544.fsf@ebiederm.dsl.xmission.com>
References: <20070323200817.1f3e39b9@osprey.hogchain.net>
	<m14po6xvtf.fsf@ebiederm.dsl.xmission.com>
	<20070327174925.5cefb091@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, atl1-devel@lists.sourceforge.net
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:51213 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753922AbXC1BE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 21:04:57 -0400
In-Reply-To: <20070327174925.5cefb091@osprey.hogchain.net> (Jay Cliburn's
	message of "Tue, 27 Mar 2007 17:49:25 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Cliburn <jacliburn@bellsouth.net> writes:

> On Tue, 27 Mar 2007 14:42:20 -0600
> ebiederm@xmission.com (Eric W. Biederman) wrote:
>
> Thanks for replying, Eric.  I've added atl1-devel to the cc list.
>
>> Do you have msi's working in 2.6.21-rc4 in the x86_64 kernel?
>
> I can't personally verify it anymore because I removed x86_64 to
> duplicate the MSI problem on i386, but the driver was working fine under
> x86_64 in earlier versions of 2.6.21-rcX.  The first hint of a problem
> was a report on March 12 by a user running a 32-bit 2.6.19 Fedora 6
> kernel who encountered a kernel panic on network startup.

Just FYI: You can run a 64bit kernel with a 32bit user space...

That this happens as long ago as 2.6.19 is interesting.  That indicates
this is not a brand new problem, and it also makes the 64bit kernel
test a little less interesting.


>> > We also do not see this problem on Intel-based motherboards, with
>> > either 32- or 64-bit kernels.
>> 
>> Can you confirm MSI is enabled in those kernels as well?
>
> Absolutely, yes.  MSI is enabled and working for me on a 64-bit
> kernel on an Intel-based motherboard, and Luca Tettamanti reports no
> problems running a 32-bit kernel on a similar motherboard.  (Luca wrote
> the MSI patch for the atl1 driver.)
>
> We enable MSI by default in the driver.
>
> I can now stimulate a kernel oops by pinging my router.  Here's the
> console output.
>
> ...snip (nothing but a flood of APIC errors above here)...
> [  103.052000] APIC error on CPU1: 08(08)
> [  103.052000] APIC error on CPU0: 08(08)
> [  103.154000] APIC error on CPU1: 08(08)
> [  103.154000] APIC error on CPU0: 08(08)
> [  103.256000] APIC error on CPU1: 08(08)
> [  103.256000] APIC error on CPU0: 08(08)
> [  103.359000] APIC error on CPU1: 08(08)
> [  103.359000] APIC error on CPU0: 08(08)
> [  103.461000] APIC error on CPU1: 08(08)
> [  103.461000] APIC error on CPU0: 08(08)
>
> pinged router somewhere about here...

Ok.  I need to look back the initial APIC errors had a different error
code and I think if we decode that it may give us a clue about what
is going on.

Eric
