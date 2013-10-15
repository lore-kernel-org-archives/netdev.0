From: Julian Anastasov <ja@ssi.bg>
Subject: Re: kernel policy routing table src ip not respected since 2.6.37
 and commit 9fc3bbb4a752
Date: Tue, 15 Oct 2013 23:36:47 +0300 (EEST)
Message-ID: <alpine.LFD.2.03.1310152242170.1919@ssi.bg>
References: <CAK3+h2zGFnbC-hpPB8fPX7TC3rKCWbPYVY4WW4HDYbN+LXNXXw@mail.gmail.com> <alpine.LFD.2.03.1310151144580.1562@ssi.bg> <CAK3+h2w13isZEOurBMv57L0H_pkqMdYmPaNE3Kn5vPxfqErOMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Joel Sing <jsing@google.com>
To: Vincent Li <vincent.mc.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:49582 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932576Ab3JOUhF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Oct 2013 16:37:05 -0400
In-Reply-To: <CAK3+h2w13isZEOurBMv57L0H_pkqMdYmPaNE3Kn5vPxfqErOMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 15 Oct 2013, Vincent Li wrote:

> it is strange though when 10.1.1.9 is unreachable address and the ping
> utility reports error 'Destination Host Unreachable' with source
> 10.1.1.1.  before 2.6.37, it reports 10.1.1..2

	I see, it is the icmp_send() function that uses
inet_select_addr() to select primary source for locally generated
ICMP errors that are sent back to the sender (10.1.1.2).
In your case it is the error_report from the ARP code.

	So, you are correct about the commit but I don't
see any problem with this behavior. IIRC, users preferred
to see primary addresses in the traceroute output.

Regards

--
Julian Anastasov <ja@ssi.bg>
