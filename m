From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.18-rc3-mm2 (+ hotfixes): GPF related to skge on suspend
Date: Sun, 13 Aug 2006 10:38:28 -0700
Message-ID: <20060813103828.b933c32c.akpm@osdl.org>
References: <200608130456_MC3-1-C7EE-44C8@compuserve.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Stephen Hemminger <shemminger@osdl.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>, Keith Owens <kaos@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:25572 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751326AbWHMRjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Aug 2006 13:39:02 -0400
To: Chuck Ebbert <76306.1226@compuserve.com>
In-Reply-To: <200608130456_MC3-1-C7EE-44C8@compuserve.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 13 Aug 2006 04:53:09 -0400
Chuck Ebbert <76306.1226@compuserve.com> wrote:

> > > Code: 44 8b 28 c7 45 d0 00 00 00 00 45 85 ed 0f 89 29 fb ff ff e9
> > > RIP  [<ffffffff88107287>] :skge:skge_poll+0x547/0x570
> > >  RSP <ffffffff80621e70>
> >
> > ksymoops says:
> > 
> > Code;  ffffffff88107287 <_end+7ac9287/7efc2000>
> > 00000000 <_EIP>:
> > Code;  ffffffff88107287 <_end+7ac9287/7efc2000>   <=====
> >    0:   44                        inc    %esp   <=====
> > Code;  ffffffff88107288 <_end+7ac9288/7efc2000>
> >    1:   8b 28                     mov    (%eax),%ebp
> 
> 0x44 is a REX prefix in 64-bit mode, so somehow ksymoops got it
> wrong and gave you an i386-mode decode instead of 64-bit mode.
> Did you run it on a i386 machine and it assumed i386? Maybe you
> need to use "-a x86-64"?  (I can't make it work on my setup.)
> 
> So it's really "mov (%r8),%ebp" if I am reading the manual right.

I don't know what ksymoops's problem is.  I noticed that without `-a' it
gave x86 code so I gave it `-a i386:x86-64' and didn't bother to read the
output ;) Seems that nothing I can do will persuade it to not treat this as
i386 code.
