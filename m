From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 09/11] forcedeth: improve NAPI logic
Date: Thu, 26 Apr 2007 14:24:16 -0400
Message-ID: <4630EE50.4000109@garzik.org>
References: <200704260723.l3Q7NNCj023844@shell0.pdx.osdl.net> <4630B76C.7070603@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org, mingo@elte.hu
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60279 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031410AbXDZSYZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 14:24:25 -0400
In-Reply-To: <4630B76C.7070603@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayaz Abdulla wrote:
> I don't see why the NAPI handler needs to process tx packets. The ISR 
> will handle all tx processing.

It is a design choice, not a requirement.

Moving non-RX interrupt processing to the NAPI handler can help as loads 
increase.  The basic idea is to do as much work as possible in the NAPI 
handler with NIC interrupts masked.  That mitigates global system 
per-interrupt overhead even more than an only-RX NAPI scheme.

Several net drivers do TX completion handling in the NAPI handler.

	Jeff


