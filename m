From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] vsprintf.c: Use noinline_for_stack
Date: Fri, 12 Mar 2010 16:25:59 -0800
Message-ID: <20100312162559.a8e51777.akpm@linux-foundation.org>
References: <cover.1267682641.git.joe@perches.com>
	<20100304143837.af39845d.akpm@linux-foundation.org>
	<alpine.LFD.2.00.1003041504080.3751@localhost.localdomain>
	<1267911399.849.39.camel@Joe-Laptop.home>
	<alpine.LFD.2.00.1003061356420.31447@localhost.localdomain>
	<1267914654.849.81.camel@Joe-Laptop.home>
	<alpine.LFD.2.00.1003061445490.31447@localhost.localdomain>
	<alpine.LFD.2.00.1003061455590.31447@localhost.localdomain>
	<1267918554.849.89.camel@Joe-Laptop.home>
	<alpine.LFD.2.00.1003061540470.23804@localhost.localdomain>
	<alpine.LFD.2.00.1003061547490.23804@localhost.localdomain>
	<alpine.LFD.2.00.1003061556420.23804@localhost.localdomain>
	<1267924214.1937.12.camel@Joe-Laptop.home>
	<alpine.LFD.2.00.1003061755400.23804@localhost.localdomain>
	<1267929215.1937.18.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Nick Andrew <nick@nick-andrew.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org,
	Bjorn Helgaas <bjorn.helgaas@hp.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1267929215.1937.18.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 06 Mar 2010 18:33:35 -0800
Joe Perches <joe@perches.com> wrote:

> On Sat, 2010-03-06 at 18:03 -0800, Linus Torvalds wrote:
> > A few noinlines might be appropriate.
> 
> Mark static functions with noinline_for_stack
> 

-ENOTESTINGRESULTS.



Before:

akpm:/usr/src/25> objdump -d lib/vsprintf.o | perl scripts/checkstack.pl
0x00000e82 pointer [vsprintf.o]:                        344
0x0000198c pointer [vsprintf.o]:                        344
0x000025d6 scnprintf [vsprintf.o]:                      216
0x00002648 scnprintf [vsprintf.o]:                      216
0x00002565 snprintf [vsprintf.o]:                       208
0x0000267c sprintf [vsprintf.o]:                        208
0x000030a3 bprintf [vsprintf.o]:                        208
0x00003b1e sscanf [vsprintf.o]:                         208
0x00000608 number [vsprintf.o]:                         136
0x00000937 number [vsprintf.o]:                         136

After:

akpm:/usr/src/25> objdump -d lib/vsprintf.o | perl scripts/checkstack.pl  
0x00000a7c symbol_string [vsprintf.o]:                  248
0x00000ae8 symbol_string [vsprintf.o]:                  248
0x00002310 scnprintf [vsprintf.o]:                      216
0x00002382 scnprintf [vsprintf.o]:                      216
0x0000229f snprintf [vsprintf.o]:                       208
0x000023b6 sprintf [vsprintf.o]:                        208
0x00002ddd bprintf [vsprintf.o]:                        208
0x00003858 sscanf [vsprintf.o]:                         208
0x00000625 number [vsprintf.o]:                         136
0x00000954 number [vsprintf.o]:                         136

nice.
