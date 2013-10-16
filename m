From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: DomU's network interface will hung when Dom0 running 32bit
Date: Wed, 16 Oct 2013 09:46:43 +0100
Message-ID: <1381913203.21901.46.camel@kazak.uk.xensource.com>
References: <52590DFE.6080203@oracle.com>
	  <20131014111958.GE11739@zion.uk.xensource.com>
	  <525CAC21.5040202@oracle.com>
	 <1381826609.24708.135.camel@kazak.uk.xensource.com>
	 <525E3BDC.4060309@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jianhai luan <jianhai.luan@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>
To: annie li <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:43810 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933953Ab3JPIsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 04:48:46 -0400
In-Reply-To: <525E3BDC.4060309@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-16 at 15:10 +0800, annie li wrote:
> Is it a timer to be set as less than ULONG_MAX/2 to avoid
> credit_timeout.expires rolling over? But the problem is that we can
> not assure where jiffies start from, and this probably results into
> current issue again.

Not less than the absolute value ULONG_MAX/2, just less than ULONG_MAX/2
offset from "now". The time_eq macros deal with wraparound.

Looks like Jianhai and Wei are discussing a better fix than an
additional timer though.

Ian
