From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Iproute2: update
Date: Tue, 29 Mar 2005 10:09:42 -0800
Message-ID: <20050329100942.062a3ed5@dxpl.pdx.osdl.net>
References: <20050112125903.64d42737@dxpl.pdx.osdl.net>
	<20050321201128.GA10625@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050321201128.GA10625@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 21 Mar 2005 21:11:28 +0100
Lennert Buytenhek <buytenh@wantstofly.org> wrote:

> On Wed, Jan 12, 2005 at 12:59:03PM -0800, Stephen Hemminger wrote:
> 
> > There is an new version of iproute2 for testing.
> > http://developer.osdl.org/dev/iproute2/download/iproute2-2.6.10-ss050112.tar.gz	
> 
> Doesn't build on my box (ARM platform):
> 
> 	gcc -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -g -I../include -DRESOLVE_HOSTNAMES -DCONFIG_GACT -DCONFIG_GACT_PROB -o normal normal.c -lm
> 	./normal >normal.dist
> 	*** glibc detected *** double free or corruption: 0x00011050 ***
> 	/bin/sh: line 1: 30106 Aborted                 ./normal >normal.dist
> 	make[1]: *** [normal.dist] Error 134
> 
> The same thing for paretonormal.
> 
> TABLESIZE is 16384, and some debug code shows that it's trying to
> write one element past the end of the table:
> 
> 	setting table[16384] to 4.008800
> 	setting table[16384] to 4.008850
> 	[...]
> 	setting table[16384] to 10.049950
> 	setting table[16384] to 10.050000
> 
> I thought it was a floating point emulation bug at first, but it
> also appears to do this on my x86.
> 
> We don't use table[16384] anyway, so this works:
>

I thought this was fixed in current versions because it allocates
space for TABLESIZE+1 entries in the call to calloc.


	table = calloc(sizeof(double), TABLESIZE+1);
