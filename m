From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: cqe, cqe_skb: return when both or when either NULL?
Date: Mon, 26 Nov 2007 09:29:22 +0100
Message-ID: <200711260929.22888.ossthema@de.ibm.com>
References: <47474C09.1020107@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, themann@de.ibm.com
To: Roel Kluin <12o3l@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:48832 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754261AbXKZI3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 03:29:52 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id lAQ8TpRQ112098
	for <netdev@vger.kernel.org>; Mon, 26 Nov 2007 08:29:51 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lAQ8Tp5w2494520
	for <netdev@vger.kernel.org>; Mon, 26 Nov 2007 08:29:51 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAQ8Tdg9004193
	for <netdev@vger.kernel.org>; Mon, 26 Nov 2007 08:29:39 GMT
In-Reply-To: <47474C09.1020107@tiscali.nl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

On Friday 23 November 2007 22:54, Roel Kluin wrote:
> In function ehea_poll() drivers/net/ehea/ehea_main.c:667, in a loop cqe and
> cqe_skb - both struct ehea_cqe pointers - are assigned:
> --
> cqe = ehea_poll_rq1(pr->qp, &wqe_index);
> cqe_skb = ehea_poll_cq(pr->send_cq);
> 
> if (!cqe && !cqe_skb)
> 	return rx;
> --
> Is it intended that only when both are NULL there is a return, or should there
> be returned when either is NULL (and the && replaced with ||).

The AND is intended. We can only return if cqe==NULL. If cqe!=NULL and we
return anyway, more packets are in the receive queue and the stack won't call poll again
until the next interrupt occurs. Received packets might stay unprocessed for quite
some time in the queue.
In case there are more resources (SKBs) from send side
to be freed we'll do an extra round.

Regards,
Jan-Bernd
