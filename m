From: Roger Willcocks <roger@filmlight.ltd.uk>
Subject: netlink: symantics for NLM_F_MULTI and NLMSG_DONE ?
Date: Tue, 27 Oct 2009 11:43:52 +0000
Message-ID: <1256643832.10998.785.camel@montana.filmlight.ltd.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alto.filmlight.ltd.uk ([77.107.81.250]:44798 "HELO
	a.mx.filmlight.ltd.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750757AbZJ0LoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 07:44:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The netlink rfc (3549) says that in multi-part messages (messages split
over multiple netlink packets), the first and all following headers 
have the NLM_F_MULTI flag set except for the last header which has the
header type NLMSG_DONE.

afaict NLMSG_DONE is redundant, since one could simply not set the
NLM_F_MULTI flag for the final header; and if a multi-part message
can't cross a datagram boundary - which is assumed by e.g. the reading
example in
http://www.kernel.org/doc/man-pages/online/pages/man7/netlink.7.html
- NLMSG_DONE is redundant too.

And the rfc doesn't say what NLMSG_DONE /and/ NLM_F_MULTI should mean,
although net/netlink/af_netlink.c always sets both.

So, what are the symantics for NLM_F_MULTI and NLMSG_DONE?


