From: Marcelo Leitner <mleitner@redhat.com>
Subject: Question about be2net error field, rx_drops_no_pbuf
Date: Mon, 14 May 2012 18:25:55 -0300
Message-ID: <4FB17863.5020908@redhat.com>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49712 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932258Ab2ENVZ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2012 17:25:57 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q4ELPvJa018994
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 14 May 2012 17:25:57 -0400
Received: from localhost.localdomain ([10.3.113.8])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id q4ELPuef016496
	for <netdev@vger.kernel.org>; Mon, 14 May 2012 17:25:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

What does 'rx_drops_no_pbuf' mean at be2net driver? I can see it is a 
hardware counter for some type of error, which I would like to know 
about. What causes it?

All documentation I could find about it is a comment referring firmware 
specification:

struct be_rxf_stats_v0 {
     struct be_port_rxf_stats_v0 port[2];
     u32 rx_drops_no_pbuf;   /* dword 132*/
     ...
}

struct be_rxf_stats_v1 {
     struct be_port_rxf_stats_v1 port[4];
     u32 rsvd0[2];
     u32 rx_drops_no_pbuf;
     ...
}

That, plus this:

be_get_stats64()
{
     ...
     /* receiver fifo overrun */
     /* drops_no_pbuf is no per i/f, it's per BE card */
     stats->rx_fifo_errors = drvs->rxpp_fifo_overflow_drop +
                 drvs->rx_input_fifo_overflow_drop +
                 drvs->rx_drops_no_pbuf;
     return stats;
}

Thanks,
Marcelo.
