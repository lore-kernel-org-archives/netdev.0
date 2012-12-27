From: Balakumaran Kannan <kumaran.4353@gmail.com>
Subject: echo 0 > /proc/sys/net/ipv6/conf/lo/disable_ipv6 broken re-investigation
Date: Thu, 27 Dec 2012 18:00:20 +0530
Message-ID: <CAHPKR9+MGY=GgOzrofNb_0+H9CWrvOMNBgoDKLkRNhpxCp2gmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:64659 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752293Ab2L0MaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2012 07:30:21 -0500
Received: by mail-oa0-f42.google.com with SMTP id j1so8927772oag.15
        for <netdev@vger.kernel.org>; Thu, 27 Dec 2012 04:30:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear All,
     Please have a look at the references below.

Ref1: http://markmail.org/message/q2u2eik3pvm6qprg#query:+page:1+mid:q2u2eik3pvm6qprg+state:results

Ref2: http://markmail.org/message/ikfz2iiuyimwp35l#query:+page:1+mid:ikfz2iiuyimwp35l+state:results

In Ref1, "disable_ipv6 for lo broken in 2.6.37-rc4" issue was reported.
In Ref2, this issue seems to have fixed by "reverting 'administrative
down' address handling" commits.

It seems above fix solves only "ping6 ::1" issue, But it has some
other issues like below
1. ping6 to link local addresses of the host fails.
2. ping6 to link local addresses of other hosts fails.
3. It seems link local addresses of other interfaces has become non
functional, so dhcpv6 will fail to assign dynamic IPv6 address because
dhcp6c uses link local address of the interface.

The above observation is on 2.6.35 kernel, but it seems this can be
reproduced in latest kernel versions also (3.6).

Could anybody verify and confirms this issue?

It seems the fix provided in Ref2, adds route only for ::1 but not for
other local addresses (host's own address). Disabling IPv6 of lo
removes all entries for lo from routing table. Enabling IPv6 of lo
doesn't re-creates these entries. So pinging to local addresses of
other interfaces (for example eth0) fails. Also can't able to ping
other machines connected to host. It seems like a total network
communication failure happens after disabling and enabling IPv6 of lo.

Regards,
K.Balakumaran
