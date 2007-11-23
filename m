From: Roel Kluin <12o3l@tiscali.nl>
Subject: cqe, cqe_skb: return when both or when either NULL?
Date: Fri, 23 Nov 2007 22:54:17 +0100
Message-ID: <47474C09.1020107@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, themann@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out3.tiscali.nl ([195.241.79.178]:34929 "EHLO
	smtp-out3.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757529AbXKWVyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 16:54:23 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In function ehea_poll() drivers/net/ehea/ehea_main.c:667, in a loop cqe and
cqe_skb - both struct ehea_cqe pointers - are assigned:
--
cqe = ehea_poll_rq1(pr->qp, &wqe_index);
cqe_skb = ehea_poll_cq(pr->send_cq);

if (!cqe && !cqe_skb)
	return rx;
--
Is it intended that only when both are NULL there is a return, or should there
be returned when either is NULL (and the && replaced with ||).

If the code is ok as is, sorry for the noise.
