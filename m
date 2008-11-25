From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [BUILD_FAILURE] linux-next: 20081125 - 8390 network driver build
 fails
Date: Tue, 25 Nov 2008 11:46:54 -0800
Message-ID: <492C562E.9090302@oracle.com>
References: <20081125213738.881b425e.sfr@canb.auug.org.au>	<20081125182542.GA4914@linux.vnet.ibm.com>	<492C464D.4080704@oracle.com>	<20081125185154.2845e8f1@lxorguk.ukuu.org.uk>	<492C5334.2090801@oracle.com> <20081125193853.076c7b58@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	p_gortmaker@yahoo.com, netdev@vger.kernel.org, mel@csn.ul.ie
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:63887 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076AbYKYTrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 14:47:10 -0500
In-Reply-To: <20081125193853.076c7b58@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alan Cox wrote:
>> The problem is that both 8390.c and 8390p.c #include lib8390.c
>> and when they are both linked to built-in drivers (not loadable
>> modules), the symbols in lib8390.c are duplicated.  I think.
> 
> And the symbols in question are static so are scoped within the file
> only. Thats why it looks to me as if someone has done "#define static" in
> another patch somewhere in -next.

Try again:

  LD      drivers/net/built-in.o
drivers/net/8390p.o: In function `ei_get_stats':
(.text+0x1050): multiple definition of `ei_get_stats'
drivers/net/8390.o:(.text+0xe20): first defined here
drivers/net/8390p.o: In function `ei_start_xmit':
(.text+0x1100): multiple definition of `ei_start_xmit'
drivers/net/8390.o:(.text+0xef0): first defined here
drivers/net/8390p.o: In function `ei_tx_timeout':
(.text+0xec0): multiple definition of `ei_tx_timeout'
drivers/net/8390.o:(.text+0xce0): first defined here
drivers/net/8390p.o: In function `ei_set_multicast_list':
(.text+0x1000): multiple definition of `ei_set_multicast_list'
drivers/net/8390.o:(.text+0xea0): first defined here
make[2]: *** [drivers/net/built-in.o] Error 1

and none of these functions is static in lib8390.c.

~Randy
