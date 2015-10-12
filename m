From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: a question about the kcm proposal
Date: Mon, 12 Oct 2015 15:51:32 -0400
Message-ID: <20151012195132.GY14646@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23664 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457AbbJLTvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 15:51:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thinking back a bit about the kcm proposal:
 https://www.mail-archive.com/netdev@vger.kernel.org/msg78696.html
I had a question:

If the user-space  has decided to encrypt the http/2 header using tls,
the len (and other http/2 fields) is no longer in the clear for the kernel.

My understanding is that http header encryption is common practice/BCP,
since the http hdr may contain a lot of identity, session and tenancy data.
If that's true, then wouldn't this break the BPF/kcm assumptions? 

There is a different but related problem in this space- existing TLS/DTLS
libraries (openssl, gnutls etc) only know how to work with tcp
or udp sockets - they do not know anything about PF_RDS or the
newly proposed kcm socket type.

In theory, it is possible to extend these libraries to handle
RDS/kcm etc, but (as we found out with RDS and IP_PKTINFO/BINDTODEVICE),
some things become tricky because of the many-to-one dgram-over-stream
hybrid.

I've looked at  IPSEC/IKE in transport mode for RDS on the kernel tcp
socket as we discussed at Plumbers in August, and that has some costs..
would be interesting to evaluate against other options..

--Sowmini
