From: "Julius Volz" <juliusv@google.com>
Subject: Sending big Netlink messages to userspace
Date: Tue, 24 Jun 2008 18:38:07 +0200
Message-ID: <f4845fc0806240938h36d275ect109fd5f5414cba37@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Patrick McHardy" <kaber@trash.net>,
	"Vince Busam" <vbusam@google.com>, "Thomas Graf" <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:1917 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063AbYFXQiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 12:38:13 -0400
Received: from spaceape23.eur.corp.google.com (spaceape23.eur.corp.google.com [172.28.16.75])
	by smtp-out.google.com with ESMTP id m5OGc9FR003801
	for <netdev@vger.kernel.org>; Tue, 24 Jun 2008 17:38:09 +0100
Received: from yx-out-1718.google.com (yxp4.prod.google.com [10.190.4.196])
	by spaceape23.eur.corp.google.com with ESMTP id m5OGc8Er012460
	for <netdev@vger.kernel.org>; Tue, 24 Jun 2008 17:38:09 +0100
Received: by yx-out-1718.google.com with SMTP id 4so532462yxp.42
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2008 09:38:08 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

While adding a Netlink interface to IPVS, I've been wondering how to
properly send very big messages to userspace and found these posts:

http://lists.openwall.net/netdev/2007/03/06/214
http://lists.openwall.net/netdev/2007/03/07/2

Herbert writes in the second one, "Dumps should be done using 4K
(NLMSG_GOODSIZE) skb's, where is the problem?" How is that meant?
Should one manually split up dumps into several NLMSG_GOODSIZE
messages or is there some mechanism for that?

I need to send arbitrarily long lists to userspace and I'm already
choosing a big enough size for nlmsg_new(), so I get no put failures
while constructing the message. However, when receiving the data in
userspace (with libnl), the receive callback is never called. An
strace shows that MSG_TRUNC is set in the oversized message, so the
data is never fully received.

I just call nl_recvmsgs_default(sock) once (which does not return an
error). Am I handling libnl incorrectly or do I need to do this
differently on the kernel side?

Thanks,
Julius

-- 
Google Switzerland GmbH
