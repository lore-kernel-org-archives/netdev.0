From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH] gianfar: Add I/O barriers when touching buffer descriptor ownership.
Date: Wed, 2 May 2007 20:05:43 +0200
Message-ID: <4334c860f893dbc537a51999cea25532@kernel.crashing.org>
References: <20070501165542.GA31285@ld0162-tx32.am.freescale.net> <65f0b79871a670eb595cca7d78e2f4e9@kernel.crashing.org> <4638B673.4090504@freescale.com>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, jgarzik@pobox.com
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-in-07.arcor-online.net ([151.189.21.47]:43277 "EHLO
	mail-in-07.arcor-online.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1767042AbXEBSFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 14:05:50 -0400
In-Reply-To: <4638B673.4090504@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> AFAICS you need stronger barriers though; {w,r,}mb(),
>> to prevent _any_ reordering of those memory accesses,
>> not just the compiler-generated ones.
>
> My impression was that the eieio used by iobarrier would be sufficient 
> for that, as we're not trying to synchronize between accesses to 
> different types of memory.  Is sync really required here?

For accesses to main system memory, eieio only orders
writes, not reads, so iobarrier_r() doesn't do what
you want; and iobarrier_w() isn't meant to be used for
main memory access ordering either.

Also, it is better to not use powerpc-specific interfaces
in a device driver if you don't have a strong reason to.


Segher

