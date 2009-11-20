From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 0/7] via-velocity performance fixes
Date: Fri, 20 Nov 2009 09:03:48 -0800
Message-ID: <20091120090348.1e51e29e@nehalam>
References: <20091120160633.77b7aee0@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, davej@redhat.com,
	romieu@fr.zoreil.com
To: Simon Kagstrom <simon.kagstrom@netinsight.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40648 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752695AbZKTRDx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Nov 2009 12:03:53 -0500
In-Reply-To: <20091120160633.77b7aee0@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Nov 2009 16:06:33 +0100
Simon Kagstrom <simon.kagstrom@netinsight.net> wrote:

> 1. Correct setting of skipped checksums (unsure about this). The
>    mainline driver sets CHECKSUM_UNNECESSARY if this is an IP packet
>    except if the TCP checksum is NOT ok.
> 
>    The VIA driver sets CHECKSUM_UNNECESSARY if this is an UDP/TCP
>    packet except if the TCP checksum is not OK. The patch selects the
>    VIA behavior.

This doesn't seem correct.

The mainline driver is already doing the correct thing. 
The VIA driver would send packet
with known bad checksum up the stack with CHECKSUM_UNNECESSARY.
What is supposed to happen is:

Checksum good:  set CHECKSUM_UNNECESSARY
          bad:  leave CHECKSUM_NONE

This is all documented in skbuff.h

-- 
