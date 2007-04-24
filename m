From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] sis900: Allocate rx replacement buffer before rx operation
Date: Tue, 24 Apr 2007 12:43:20 -0400
Message-ID: <462E33A8.5060107@garzik.org>
References: <20070420135458.GB16191@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, venza@brownhat.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39672 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753221AbXDXQnZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 12:43:25 -0400
In-Reply-To: <20070420135458.GB16191@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Neil Horman wrote:
> Hey there-
> 	The sis900 driver appears to have a bug in which the receive routine
> passes the skbuff holding the received frame to the network stack before
> refilling the buffer in the rx ring.  If a new skbuff cannot be allocated, the
> driver simply leaves a hole in the rx ring, which causes the driver to stop
> receiving frames and become non-recoverable without an rmmod/insmod according to
> reporters.  This patch reverses that order, attempting to allocate a replacement
> buffer first, and receiving the new frame only if one can be allocated.  If no
> skbuff can be allocated, the current skbuf in the rx ring is recycled, dropping
> the current frame, but keeping the NIC operational.
> 
> Thanks & Regards
> Neil
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> 
>  sis900.c |   44 ++++++++++++++++++++------------------------
>  1 file changed, 20 insertions(+), 24 deletions(-)

applied


