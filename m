From: Chuck Ebbert <cebbert@redhat.com>
Subject: Null dereference in socket.c
Date: Fri, 28 Sep 2007 18:58:36 -0400
Message-ID: <46FD871C.2080004@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49622 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755363AbXI1W6j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 18:58:39 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l8SMwdCl024500
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 18:58:39 -0400
Received: from mail.boston.redhat.com (mail.boston.redhat.com [172.16.76.12])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l8SMwaar021862
	for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 18:58:38 -0400
Received: from [172.16.83.145] (dhcp83-145.boston.redhat.com [172.16.83.145])
	by mail.boston.redhat.com (8.13.1/8.13.1) with ESMTP id l8SMwa8l017674
	for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 18:58:36 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After debugging an oops (https://bugzilla.redhat.com/attachment.cgi?id=209231)
I find it happens here in socket.c::sock_ioctl() line 902:

               default:
=============>          err = sock->ops->ioctl(sock, cmd, arg);

                        /*
                         * If this ioctl is unknown try to hand it down
                         * to the NIC driver.
                         */
                        if (err == -ENOIOCTLCMD)
                                err = dev_ioctl(cmd, argp);
                        break;


ioctl is NULL and the kernel jumps to address 0. Should we add a check
for that?

Bug report:
https://bugzilla.redhat.com/show_bug.cgi?id=306801
