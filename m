From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [PATCH] qlge: Fix a deadlock when the interface is going down
Date: Wed, 25 Aug 2010 07:42:30 -0700
Message-ID: <20100825144230.GA12700@linux-ox1b.qlogic.org>
References: <1282690240-5301-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "leitao@linux.vnet.ibm.com" <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cain.qlogic.com ([198.70.193.223]:58206 "EHLO cain.qlc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751854Ab0HYOxa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Aug 2010 10:53:30 -0400
Content-Disposition: inline
In-Reply-To: <1282690240-5301-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 24, 2010 at 03:50:40PM -0700, leitao@linux.vnet.ibm.com wrote:
> Currently qlge can deadlock when the interface is going
> down, and the mpi_port_cfg_work() is executing on another
> processor. It happens because unregister_netdev() holds
> the rtnl lock, and the mpi_port_cfg_work() also request
> this lock.
> 
> Since unregiter_netdev() may wait mpi_port_cfg_work(), who
> also request the holding lock, it can cause an deadlock,
> displaying the following error:
> 

Thanks Breno.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
