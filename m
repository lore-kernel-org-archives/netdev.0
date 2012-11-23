From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [Qemu-devel] tap devices not receiving packets from a bridge
Date: Fri, 23 Nov 2012 08:02:11 +0100
Message-ID: <20121123070211.GC22787@stefanha-thinkpad.hitronhub.home>
References: <50AE36E0.8000307@dlhnet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>,
	netdev@vger.kernel.org
To: Peter Lieven <pl@dlhnet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:53779 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932352Ab2KWHCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2012 02:02:15 -0500
Received: by mail-bk0-f46.google.com with SMTP id q16so3695386bkw.19
        for <netdev@vger.kernel.org>; Thu, 22 Nov 2012 23:02:13 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <50AE36E0.8000307@dlhnet.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 22, 2012 at 03:29:52PM +0100, Peter Lieven wrote:
> is anyone aware of a problem with the linux network bridge that in very rare circumstances stops
> a bridge from sending pakets to a tap device?
> 
> My problem occurs in conjunction with vanilla qemu-kvm-1.2.0 and Ubuntu Kernel 3.2.0-34.53
> which is based on Linux 3.2.33.
> 
> I was not yet able to reproduce the issue, it happens in really rare cases. The symptom is that
> the tap does not have any TX packets. RX is working fine. I see the packets coming in at
> the physical interface on the host, but they are not forwarded to the tap interface.
> The bridge itself has learnt the mac address of the vServer that is connected to the tap interface.
> It does not help to toggle the bridge link status,  the tap interface status or the interface in the vServer.
> It seems that problem occurs if a tap interface that has previously been used, but set to nonpersistent
> is set persistent again and then is by chance assigned to the same vServer (=same mac address on same
> bridge) again. Unfortunately it seems not to be reproducible.

Not sure but this patch from Michael Tsirkin may help - it solves an
issue with persistent tap devices:

http://patchwork.ozlabs.org/patch/198598/

Stefan
