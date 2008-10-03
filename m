From: "Adam Langley" <agl@imperialviolet.org>
Subject: IPv6 mapped sockets don't work with TCP MD5
Date: Fri, 3 Oct 2008 15:31:11 -0700
Message-ID: <396556a20810031531q7ae71d30q4fb7d21334e4c9b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.231]:1027 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752344AbYJCWbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2008 18:31:11 -0400
Received: by rv-out-0506.google.com with SMTP id k40so1889003rvb.1
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2008 15:31:11 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported by Stephen: connecting to an IPv6 mapped socket using TCP MD5
fails. This has apparently never worked.

Here's the problem: tcp_make_synack (from tcp_output.c) uses the
af_specific structure from the struct sock to find the correct
function to calculate the signature. In the case of v4/v6 mapped
requests, the sock is the listening socket so we end up using the IPv6
signature function. The request sock is of the correct type at this
point however.

So I'm basically looking for guidance on how I should write the patch here.

1) We could add a calc_hash function pointer to request_sock_ops and
use that when building SYNACKs. However, request_socks aren't just
used in TCP.
2) We could pass the signature function as an argument to
tcp_make_synack since we always call it from a v4/v6 specific place

I'm learning towards the second, but whatever wiser heads suggest I'll
implement.


Cheers

AGL

-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
