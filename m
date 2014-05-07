From: David Miller <davem@redhat.com>
Subject: Re: Questions on sk_no_check implemenation
Date: Wed, 07 May 2014 16:15:11 -0400 (EDT)
Message-ID: <20140507.161511.1183516412491161617.davem@redhat.com>
References: <CA+mtBx_SK5LG8z_kTr5sHNhGQMBDgc+kpG49uyjgDM_eoK1hKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13804 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750951AbaEGU1t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2014 16:27:49 -0400
In-Reply-To: <CA+mtBx_SK5LG8z_kTr5sHNhGQMBDgc+kpG49uyjgDM_eoK1hKg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 5 May 2014 19:34:40 -0700

> Hi, I'm looking at sk_no_check implementation and am hoping to get
> clarification on a couple of use cases.
> 
> 1) In l2tp_core.c, if sk_no_check is set it looks like this will
> completely bypass UDP checksum verification on RX even for packets
> with nonzero checksums.
> 
> d2cf33616 (Benjamin LaHaise 2012-04-27 08:24:18 +0000 505) if
> (sk->sk_no_check || skb_csum_unnecessary(skb))
> 
> I don't believe this is standards compliant and seems pretty risky
> otherwise. What is the requirement here? Is this still needed?

I think this is simply a thinko and the code should be checking non-zero
csums.

> 2) The constant UDP_CSUM_NORCV was introduced for sunrpc and in fact
> this looks like the only code that sets it. AFAICT the only effect
> this would have would be to disable receive checksum verification in
> L2TP as described above. What was the intent of UDP_CSUM_NORCV and why
> was using this specific to sunrpc?

I have no idea about this case.
