From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [2.6 patch] unexport icmpmsg_statistics
Date: Wed, 24 Oct 2007 13:43:14 -0700
Message-ID: <OF03E20988.736A2E51-ON8825737E.007067FE-8825737E.0071B902@us.ibm.com>
References: <471FAA03.9090003@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Adrian Bunk <bunk@kernel.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:58582 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755919AbXJXUnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 16:43:18 -0400
In-Reply-To: <471FAA03.9090003@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

My bad -- I see what it's doing, and it looks ok after all.

I thought I saw an INMSGS (but didn't).  These are ICMP errors that
went through icmp_rcv() and were counted correctly before getting
to the protocol error handlers. These are failures due mostly to not
having enough, or the right protocol info in the error packet being
handled. I'm not sure I'd count those as ICMP errors, since the
ICMP header itself is correct, but ok...

SCTP doesn't look so bad, though I think the references are
still questionable (but debatable) as ICMP errors.

sctp_v4_err is incrementing ICMP_MIB_INERRORS if there
isn't enough IP header to find the ports, I see. I'm not sure
that counts as an ICMP error, but it's not so terrible.

It's doing the same thing if a lookup fails to match "vtag" from
the encapsulated error packet. Again, I don't know that those
are ICMP errors (which normally are something wrong with
the ICMP header).

So, I stand corrected, and sorry about the histrionics. Since
these are arguably ICMP errors, and since errors is the only
thing being MIB-counted in DCCP and SCTP, then it now looks
ok to me as-is, and also ok to remove icmpmsg_statistics from
exporting.

                                        +-DLS

