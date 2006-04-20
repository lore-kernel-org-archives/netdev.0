From: Mike Christie <michaelc@cs.wisc.edu>
Subject: sendpage and high mem pages
Date: Thu, 20 Apr 2006 14:29:06 -0500
Message-ID: <4447E102.5080203@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabe.cs.wisc.edu ([128.105.6.20]:26515 "EHLO sabe.cs.wisc.edu")
	by vger.kernel.org with ESMTP id S1750970AbWDTT3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2006 15:29:12 -0400
Received: from [192.168.0.6] (c-69-180-176-191.hsd1.mn.comcast.net [69.180.176.191])
	(authenticated bits=0)
	by sabe.cs.wisc.edu (8.13.6/8.13.6) with ESMTP id k3KJTBvj003969
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 14:29:11 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I was wondering if it is ok to pass sendpage high mem pages. If a piece
of code does this:

struct socket *sock;

sock->ops->sendpage(pg...)

and pg is a highmem page will the network layer do the right thing or
should the caller check the page type and call sock_no_sendpage() for
highmen? It looks like net/sunrpc/xprtsock.c does a check but
drivers/scsi/iscsi_tcp.c and some others do not.
