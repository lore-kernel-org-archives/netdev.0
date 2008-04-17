From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] natsemi: fix MMIO for PPC 44x platforms
Date: Wed, 16 Apr 2008 20:53:59 -0400
Message-ID: <48069FA7.5060207@pobox.com>
References: <200804122058.31075.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38357 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751152AbYDQAyE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 20:54:04 -0400
In-Reply-To: <200804122058.31075.sshtylyov@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sergei Shtylyov wrote:
> The driver stores the PCI resource address into 'unsigned long' variable before
> calling ioremap()  on it. This warrants a kernel oops when the registers are
> accessed on PPC 44x platforms which (being 32-bit) have PCI memory space mapped
> beyond 4 GB.
> 
> The arch/ppc/ kernel has a fixup in ioremap() that creates an illusion of the
> PCI memory resources are mapped below 4 GB, but arch/powerpc/ code got rid of
> this trick, having instead CONFIG_RESOURCES_64BIT enabled.
> 
> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>
> 
> ---
> Reposting the patch with the typecast, log, and summary corrected.
> This is the same issue as the one that has been recently addressed by commits
> 3c34ac36ac1084e571ef9b6fb1d6a5b10ccc1fd0 (e1000: Fix for 32 bits platforms with
> 64 bits resources) and c976816b6e901341ec3c4653147316c15549a1c4 (siimage: fix
> kernel oops on PPC 44x).  The patch has only been compile tested though...
> 
>  drivers/net/natsemi.c |   10 ++++++----
>  1 files changed, 6 insertions(+), 4 deletions(-)

applied


