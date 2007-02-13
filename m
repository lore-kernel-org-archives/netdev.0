From: Neil Brown <neilb@suse.de>
Subject: Re: 2.6.20-git8 fails compile -- net/built-in.o __ipv6_addr_type
Date: Tue, 13 Feb 2007 13:52:26 +1100
Message-ID: <17873.10218.683015.201907@notabene.brown>
References: <20070213.111345.78160400.yoshfuji@linux-ipv6.org>
	<200702130236.l1D2a0u7014457@clem.clem-digital.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org (YOSHIFUJIHideaki/=?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=),
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "Chuck Lever" <chuck.lever@oracle.com>
To: Pete Clements <clem@clem.clem-digital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:35745 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030619AbXBMCx2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Feb 2007 21:53:28 -0500
In-Reply-To: message from Pete Clements on Monday February 12
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday February 12, clem@clem.clem-digital.net wrote:
> Quoting YOSHIFUJIHideaki/=?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
>   > In article <20070212181216.c55ca788.akpm@linux-foundation.org> (at Mon, 12 Feb 2007 18:12:16 -0800), Andrew Morton <akpm@linux-foundation.org> says:
>   > 
>   > > > On Mon, 12 Feb 2007 20:10:13 -0500 (EST) Pete Clements <clem@clem.clem-digital.net> wrote:
>   > > > 2.6.20-git8 fails compile:
>   > > > 
>   > > >   CHK     include/linux/compile.h
>   > > >   UPD     include/linux/compile.h
>   > > >   CC      init/version.o
>   > > >   LD      init/built-in.o
>   > > >   LD      .tmp_vmlinux1
>   > > > net/built-in.o: In function `svc_udp_recvfrom':
>   > > > svcsock.c:(.text+0x61be4): undefined reference to `__ipv6_addr_type'
>   > > > make: *** [.tmp_vmlinux1] Error 1
>   > > > 

Hmmm.  

> CONFIG_IPV6=m
combined with
> CONFIG_SUNRPC=y

is a combination that isn't going to work at the moment....

Options?

 - Move __ipv6_addr_type to lib/ ??
        Might not work for modules.
 - Disallow that combination in the .config.
        .. a bit harsh.
 - Only include IPv6 support in SUNRPC is a module or IPV6 is built-in
        A bit of a kludge..

Chuck?  Any ideas?

NeilBrown

