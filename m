From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC/PATCH 2/3] UDP memory usage accounting: accounting unit and variable
Date: 21 Sep 2007 15:10:18 +0200
Message-ID: <p734pho9nb9.fsf@bingen.suse.de>
References: <46F3B88D.1030601@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, haoki@redhat.com,
	=?euc-jp?b?tcjGow==?= =?euc-jp?b?sdHMwA==?=
	<yoshfuji@linux-ipv6.org>
To: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33456 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755528AbXIUNKX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2007 09:10:23 -0400
In-Reply-To: <46F3B88D.1030601@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com> writes:

> This patch introduces global variable for UDP memory accounting.
> The unit is page.

The global variable doesn't seem to be very MP scalable, especially
if you change it for each packet. This will be a very hot cache line,
in the worst case bouncing around a large machine.

Possible alternatives:
- Per CPU variables
- You only change the global on socket creation time (by pre allocating a large
amount) or when the system comes under memory pressure.
- Batching of the global updates for multiple packets [that's a variant
of the previous one, might be still too costly though]

Also for such variables it's usually good to cache line pad them on SMP
to avoid false sharing with something else.

-Andi
