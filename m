From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH][resend] add driver for enc28j60 ethernet chip
Date: Fri, 18 Jan 2008 15:01:39 -0500
Message-ID: <479105A3.3040508@garzik.org>
References: <478B32BC.6070206@eptar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59693 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762865AbYARUBn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2008 15:01:43 -0500
In-Reply-To: <478B32BC.6070206@eptar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Claudio Lanconelli wrote:
> This patch add support for Microchip enc28j60 10Mbps Ethernet chip used 
> in embedded systems
> due to its cheap SPI interface.
> This 2nd version include changes from previous comments by Jeff and 
> Stephen,
> all but NAPI, see comments below at this regard.
> 
> I resend the patch because I didn't receive any feedback.
> 
> Changes to 1st version:
> - use mutex instead of semaphore
> - add carrier detect handling
> - add ethtool support
> - set_multicast_list when the interface is up using a workqueue
> - add restart_work to reset the chip in case of tx_timeout
> - removed kmalloc() for spi_transfer_buf (array defined in the priv struct)
> 
> Jeff Garzik wrote:
>>
>> comments:
>>
>> * Why do interrupt work in a kernel thread?  Your comment says you 
>> cannot, but does not explain.
> The enc28j60 is a SPI to Ethernet adapter, so we cannot access register 
> with simple in() out() instructions, but we need to use the SPI 
> subsystem. The spi_sync() basic operation to read/write a register is a 
> blocking operation, so can't be done in interrupt context.
> Since every basic operation like read interrupt flag register call 
> spi_sync() we need the work queue for almost everything.
> 
>>
>> * should use NAPI
>>
> For the reason I just explained I don't think NAPI is a viable way for 
> enc28j60.
> Furthermore enc28j60 is a 10Mb only device and probably don't suffer to 
> interrupt overload.
> 
> I'm waiting for any comments, please.

applied


