From: Christopher Schramm <netdev@shakaweb.org>
Subject: Re: ip_rt_min_pmtu
Date: Wed, 05 Dec 2012 10:33:43 +0100
Message-ID: <50BF14F7.8060105@shakaweb.org>
References: <50BE654D.2010602@shakaweb.org> <CAKoUArn0EYaeebFXtCgqDSYeJD2oFKUfns7Lbk7Rsg=N=pnpHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rami Rosen <roszenrami@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.shakaweb.org ([89.238.65.242]:40903 "EHLO shakaweb.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751771Ab2LEJdw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2012 04:33:52 -0500
In-Reply-To: <CAKoUArn0EYaeebFXtCgqDSYeJD2oFKUfns7Lbk7Rsg=N=pnpHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 05 Dec 2012 09:46:18 +0100, Rami Rosen wrote:
> But RFC 791 also declares 576 as PMTU:
> "All hosts must be prepared to accept datagrams of up to 576 octets".

That's the common mistake I mentioned. The sentence goes on: "(whether 
they arrive whole or in fragments)", so it says nothing about lower 
layers, especially not about the MTU.

The 576 octects IP datagram every implementation is required to be able 
to handle could be transferred in 12 up to over 60 fragments if we had 
the minimal PMTU of 68, depending on the header size. Of course that 
leads to an overhead of nearly 90 percent, but it should be possible 
following the RFC.

With Linux, trying to send large data over a path with PMTU < 552 will 
probably fail (unless you change the min_pmtu value).
