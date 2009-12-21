From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Mon, 21 Dec 2009 10:37:03 -0600
Message-ID: <4B2FA42F.3070408@codemonkey.ws>
References: <4B1D4F29.8020309@gmail.com> <20091218215107.GA14946@elte.hu> <4B2F9582.5000002@gmail.com> <4B2F978D.7010602@redhat.com> <4B2F9C85.7070202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.211.182]:44496 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbZLUQhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 11:37:13 -0500
In-Reply-To: <4B2F9C85.7070202@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/2009 10:04 AM, Gregory Haskins wrote:
> No, B and C definitely are, but A is lacking.  And the performance
> suffers as a result in my testing (vhost-net still throws a ton of exits
> as its limited by virtio-pci and only adds about 1Gb/s to virtio-u, far
> behind venet even with things like zero-copy turned off).
>    

How does virtio-pci limit vhost-net?  The only time exits should occur 
are when the guest notifies the host that something has been placed on 
the ring.  Since vhost-net has no tx mitigation scheme right now, the 
result may be that it's taking an io exit on every single packet but 
this is orthogonal to virtio-pci.

Since virtio-pci supports MSI-X, there should be no IO exits on 
host->guest notification other than EOI in the virtual APIC.  This is a 
light weight exit today and will likely disappear entirely with newer 
hardware.

Regards,

Anthony Liguori
