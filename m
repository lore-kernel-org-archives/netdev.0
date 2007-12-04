From: "Hugo Santos" <hugosantos@gmail.com>
Subject: XFRM and IPv6 raw sockets and multicast
Date: Tue, 4 Dec 2007 16:27:50 +0100
Message-ID: <9c46321e0712040727tee578cm97a83936fefb34ed@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:10539 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755356AbXLDP1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 10:27:53 -0500
Received: by nf-out-0910.google.com with SMTP id g13so2925100nfb
        for <netdev@vger.kernel.org>; Tue, 04 Dec 2007 07:27:51 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

  I've ran into an issue which i'm not sure that is known. I'm able to
provide a patch if people feel this is something that should be fixed.

  Anyway, the source address of packets is not taken into account when
matching for xfrm policies when socket(AF_INET6, SOCK_RAW,
IPPROTO_RAW) sockets are used. This doesn't allow for (S,G) policies
to be deployed for IPv6 for local output packets as is required for
some multicast communications (read: SSM).

  The behavior is the same as in UDP, but ipv6_pinfo->saddr is not
usually set for these kind of sockets. I would say that if fl6_src is
any, it should be copied from the ipv6 header.

  Another question is why does raw.c require a msg_name? If
inet->hdrincl was set, it could use the ipv6 header destination
address in the absense of msg_name.

  Any comments? :-)

  Thanks,
    Hugo
