From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC] percpu: convert SNMP mibs to new infra
Date: Thu, 2 Apr 2009 15:34:33 +1030
Message-ID: <200904021534.34084.rusty@rustcorp.com.au>
References: <49D32212.80607@cosmosbay.com> <49D3A0C2.9000403@cosmosbay.com> <49D3B61F.8010507@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Jeremy Fitzhardinge <jeremy@goop.org>,
	Tejun Heo <htejun@gmail.com>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:39735 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750986AbZDBFEq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2009 01:04:46 -0400
In-Reply-To: <49D3B61F.8010507@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 02 April 2009 05:14:47 Eric Dumazet wrote:
> Here is a preliminary patch for SNMP mibs that seems to work well on x86_32
> 
> [RFC] percpu: convert SNMP mibs to new infra

OK, I have a whole heap of "convert to dynamic per-cpu" patches waiting in
the wings too, once Tejun's conversion is complete.

Also, what is optimal depends on the arch: we had a long discussion on this
(it's what local_t was supposed to do, with cpu_local_inc() etc: see
Subject: local_add_return 2008-12-16 thread).

eg. on S/390, atomic_inc is a win over the two-counter version.  On Sparc,
two-counter wins.  On x86, inc wins (obviously).

But efforts to create a single primitive have been problematic: maybe
open-coding it like this is the Right Thing.

Cheers,
Rusty.
