From: Werner Almesberger <werner@almesberger.net>
Subject: Re: minimum ICMPv6 message size vs. RPL's DIS
Date: Thu, 25 Jul 2013 11:32:23 -0300
Message-ID: <20130725143223.GC29572@ws>
References: <20130724232852.GA29572@ws>
 <20130725061731.GA12365@order.stressinduktion.org>
 <20130725103048.GB29572@ws>
 <20130725135820.GB11592@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hydra.openmoko.org ([144.76.72.4]:37689 "EHLO
	hydra.openmoko.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756258Ab3GYOdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 10:33:51 -0400
Content-Disposition: inline
In-Reply-To: <20130725135820.GB11592@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:
> I would say no problem. But as I just realized that it could be a bit
> problematic because the new defines have actually pretty common names,
> let's cc David Miller. Perhaps he has an advice?

Yeah, I'll let the issue sit here for a while so that more people
can comment. The change has numerous implications, including

- there may actually be a minimum size requirement *somewhere*
  and I just didn't find it, in which case Linux would be right,

- name pollution visible to future user space,

- subtly changes kernel API semantics for ICMPv6 receivers, to
  the detriment of those that rely on the kernel to filter
  messages < 8 bytes and misbehave if exposed to them.

So this is definitely not the kind of change I want to rush.

Even the pointer fix changes the API in a way that could break
applications that currently work (if only on 32 bit platforms,
but it's not their fault that things would go wrong on 64 bit),
so we can't apply that one before having a decision on the other
issue as well.

Thanks,
- Werner
