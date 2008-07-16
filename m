From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: IPV4: Enable IP_ID sequencing for all traffic (inquiring minds want to
 know why its set to zero)
Date: Wed, 16 Jul 2008 12:03:25 -0700
Message-ID: <OF5F2AB2D4.EAFD2016-ON88257488.0067DC0C-88257488.0068AE15@us.ibm.com>
References: <487E0C15.1070001@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:53162 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169AbYGPTD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 15:03:29 -0400
In-Reply-To: <487E0C15.1070001@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IP_ID is needed for reassembly of fragments, but a fast network can
go through all the ID's available before datagrams you've already sent
have reached their time to live.

That means you can end up with two different datagrams with the same ID
and incorrectly reassemble parts of them together (which you can hope
the checksum will catch and cause a drop).

By not using IDs for non-fragmented datagrams, the time to wrap the ID
space is increased, which reduces the chance of getting into that
situation.

That really is the only protocol use of IP_IDs, so there isn't any point
in consuming them for non-fragment datagrams. It's useful sometimes
when looking at packet traces to correlate pieces on two different
networks, which I'm guessing is why you want it, but I don't think it's
a good idea to do it all the time.

                                                +-DLS

