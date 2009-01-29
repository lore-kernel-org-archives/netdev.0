From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH 17/21] RDS/IB: Receive datagrams via IB
Date: Thu, 29 Jan 2009 22:02:28 +0100
Message-ID: <200901292202.28625.okir@suse.de>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com> <ada1vunt1sg.fsf@cisco.com> <49811278.3050806@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org, netdev@vger.kernel.org
To: Andy Grover <andy.grover@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:53097 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751678AbZA2VCc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2009 16:02:32 -0500
In-Reply-To: <49811278.3050806@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 29 January 2009 03:20:40 Andy Grover wrote:
> > This is racy.  You check if you're at the limit, do the allocation, and
> > then increment the atomic rds_ib_allocation count.  So many threads can
> > pass the atomic_read() test and then take you over the limit.  If you
> > want to make it safe then you could do atomic_inc_return() and check if
> > that took you over the limit.
>
> Woah, yup, thanks.

The refill code used to be single-threaded; and I think it still is. So
this can't race I think

Olaf
