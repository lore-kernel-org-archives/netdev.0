From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] BRIDGE : br_fdb_fini() should be __exit_refok instead
 of __exit
Date: Wed, 5 Dec 2007 07:49:59 -0500
Message-ID: <20071205074959.6f9ca8e4@shemminger-laptop>
References: <47569C74.9020008@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42332 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751442AbXLEMvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 07:51:23 -0500
In-Reply-To: <47569C74.9020008@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 05 Dec 2007 13:41:24 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Hi David
> 
> Building last net-2.6.25 git tree gave me this warning :
> 
> WARNING: vmlinux.o(.init.text+0x2a957): Section mismatch: reference to 
> .exit.text:br_fdb_fini (between 'br_init' and 'br_fdb_init')
> 
> This is because br_init() (marked __init) can call br_fdb_fini() (marked __exit).
> 
> I am not sure the following is the right fix, since __exit_refok is quite new, 
> and seldom used.
> 
> [PATCH] BRIDGE : br_fdb_fini() should be __exit_refok instead of __exit
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> 

Andrew put a patch in his tree to just take off the __exit.
That seems like the easiest fix for a one line function.
