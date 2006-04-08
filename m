From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch] ipv4: initialize arp_tbl rw lock
Date: Sat, 8 Apr 2006 03:12:35 -0700
Message-ID: <20060408031235.5d1989df.akpm@osdl.org>
References: <20060407081533.GC11353@osiris.boeblingen.de.ibm.com>
	<20060407074627.2f525b2e@localhost.localdomain>
	<20060408100213.GA9412@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fpavlic@de.ibm.com,
	davem@sunset.davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964840AbWDHKOp@vger.kernel.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
In-Reply-To: <20060408100213.GA9412@osiris.boeblingen.de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Heiko Carstens <heiko.carstens@de.ibm.com> wrote:
>
> Ok, so the problem seems to be that inet_init gets called after qeth_init.
>  Looking at the top level Makefile this seems to be true for all network
>  drivers in drivers/net/ and drivers/s390/net/ since we have
> 
>  vmlinux-main := $(core-y) $(libs-y) $(drivers-y) $(net-y)
> 
>  The patch below works for me... I guess there must be a better way to make
>  sure that any networking driver's initcall is made before inet_init?
> 
>  Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
>  ---
> 
>   Makefile |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
>  diff --git a/Makefile b/Makefile
>  index b401942..c5cea07 100644
>  --- a/Makefile
>  +++ b/Makefile
>  @@ -567,7 +567,7 @@ #
>   # System.map is generated to document addresses of all kernel symbols
>   
>   vmlinux-init := $(head-y) $(init-y)
>  -vmlinux-main := $(core-y) $(libs-y) $(drivers-y) $(net-y)
>  +vmlinux-main := $(core-y) $(libs-y) $(net-y) $(drivers-y)

<wonders what this will break>

I have a bad feeling that one day we're going to come unstuck with this
practice.  Is there anything which dictates that the linker has to lay
sections out in .o-file-order?

Perhaps net initcalls should be using something higher priority than
device_initcall().
