From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Packet mmap: TX RING and zero copy
Date: Wed, 03 Sep 2008 09:57:46 -0500
Message-ID: <48BEA5EA.3050809@linux-foundation.org>
References: <20080902194603.GA2825@2ka.mipt.ru> <7e0dd21a0809030056q2bfd0344kf3b86a90a4b3fc5f@mail.gmail.com> <7e0dd21a0809030338k3335a5eah4be6e27c26aecf59@mail.gmail.com> <20080903.040626.198546183.davem@davemloft.net> <7e0dd21a0809030605odc28306re8b7640f0632ac36@mail.gmail.com> <20080903132734.GA17541@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Johann Baudy <johaahn@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:42285 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751398AbYICO6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 10:58:43 -0400
In-Reply-To: <20080903132734.GA17541@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov wrote:
> Hi Johann.
> 
> On Wed, Sep 03, 2008 at 03:05:07PM +0200, Johann Baudy (johaahn@gmail.com) wrote:
>> TCP socket, transferring 20Mbytes file (located in initramfs) in loop
>> with sendfile() : 5.7Mbytes/s
> 
> And _THIS_ is a serious problem. Let's assume that sendfile is broken or
> driver/hardware does not support scatter/gather and checksumming (does it?).
> Can you saturate the link with pktgen (1) and usual tcp socket (2).
> Assuming second case will fail, does it also broken because of very
> small performance of the copy from the userspace?

Could we see the code that was used to get these numbers? The problem may just
be in the way that the calls to sendfile() have been coded.

The TX code looks intriguing. Seems that some vendors are tinkering with VNIC
ideas in order to bypass context switches and data copies. Maybe this is a
cheap way to attain the same goals?


