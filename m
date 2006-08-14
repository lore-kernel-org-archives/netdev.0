From: Daniel Phillips <phillips@google.com>
Subject: Re: [RFC][PATCH 0/9] Network receive deadlock prevention for NBD
Date: Sun, 13 Aug 2006 17:56:08 -0700
Message-ID: <44DFCA28.7040808@google.com>
References: <1155127040.12225.25.camel@twins> <20060809130752.GA17953@2ka.mipt.ru> <1155130353.12225.53.camel@twins> <44DD4E3A.4040000@redhat.com> <20060812084713.GA29523@2ka.mipt.ru> <1155374390.13508.15.camel@lappy> <20060812093706.GA13554@2ka.mipt.ru> <44DDE857.3080703@redhat.com> <20060812144921.GA25058@2ka.mipt.ru> <44DDEC1F.6010603@redhat.com> <20060812150842.GA5638@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rik van Riel <riel@redhat.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.12]:16040 "EHLO
	smtp-out.google.com") by vger.kernel.org with ESMTP
	id S1751177AbWHNA4Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 20:56:25 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060812150842.GA5638@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> One must receive a packet to determine if that packet must be dropped
> until tricky hardware with header split capabilities or MMIO copying is
> used. Peter uses special pool to get data from when system is in OOM (at
> least in his latest patchset), so allocations are separated and thus
> network code is not affected by OOM condition, which allows to make
> forward progress.

Nice executive summary.  Crucial point: you want to say "in reclaim"
not "in OOM".

Yes, right from the beginning the patch set got its sk_buff memory
from a special pool when the system is in reclaim, however the exact
nature of the pool and how/where it is accounted has evolved... mostly
forward.

Regards,

Daniel
