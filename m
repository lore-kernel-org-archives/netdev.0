From: Nelson Elhage <nelhage@ksplice.com>
Subject: Re: [PATCH] pktgen: Remove a dangerous debug print.
Date: Wed, 27 Oct 2010 15:28:08 -0400
Message-ID: <20101027192808.GP16803@ksplice.com>
References: <1288206788-21063-1-git-send-email-nelhage@ksplice.com>
 <20101027.122143.02260950.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robert.olsson@its.uu.se, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, eugene@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:56441 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753857Ab0J0T2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 15:28:13 -0400
Content-Disposition: inline
In-Reply-To: <20101027.122143.02260950.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

How would you feel about limiting the debug print to at most, say, 512 or 1024
bytes? Even if it's only accessible to root by default, I don't a userspace
program should be able to accidentally corrupt the kernel stack by writing too
many bytes to a file in /proc.

- Nelson

On Wed, Oct 27, 2010 at 12:21:43PM -0700, David Miller wrote:
> From: Nelson Elhage <nelhage@ksplice.com>
> Date: Wed, 27 Oct 2010 15:13:08 -0400
> 
> > We were allocating an arbitrarily-large buffer on the stack, which would allow a
> > buggy or malicious userspace program to overflow the kernel stack.
> > 
> > Since the debug printk() was just printing exactly the text passed from
> > userspace, it's probably just as easy for anyone who might use it to augment (or
> > just strace(1)) the program writing to the pktgen file, so let's just not bother
> > trying to print the whole buffer.
> > 
> > Signed-off-by: Nelson Elhage <nelhage@ksplice.com>
> 
> Only root can write to the pktgen control file.
> 
> Also, the debug feature really is used by people's pktgen scripts, you
> can't just turn it off.
