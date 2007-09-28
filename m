From: Sean Hefty <mshefty@ichips.intel.com>
Subject: Re: [ofa-general] [PATCH v3] iw_cxgb3: Support"iwarp-only"interfacesto
 avoid 4-tuple conflicts.
Date: Fri, 28 Sep 2007 14:34:56 -0700
Message-ID: <46FD7380.6050107@ichips.intel.com>
References: <20070923203649.8324.64524.stgit@dell3.ogc.int><46FBF8AF.9040700@ichips.intel.com><C98692FD98048C41885E0B0FACD9DFB805187514@exnane01.hq.netapp.com> <000101c8013a$41b374f0$a7cc180a@amr.corp.intel.com> <C98692FD98048C41885E0B0FACD9DFB80518755A@exnane01.hq.netapp.com> <46FD5A2F.7010409@opengridcomputing.com> <C98692FD98048C41885E0B0FACD9DFB805187762@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steve Wise <swise@opengridcomputing.com>,
	Sean Hefty <sean.hefty@intel.com>, netdev@vger.kernel.org,
	rdreier@cisco.com, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: "Kanevsky, Arkady" <Arkady.Kanevsky@netapp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:57694 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751567AbXI1VfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 17:35:00 -0400
In-Reply-To: <C98692FD98048C41885E0B0FACD9DFB805187762@exnane01.hq.netapp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kanevsky, Arkady wrote:
> Exactly,
> it forces the burden on administrator.
> And one will be forced to try one mount for iWARP and it does not
> work issue another one TCP or UDP if it fails.
> Yack!
> 
> And server will need to listen on different IP address and simple
> * will not work since it will need to listen in two different domains.

The server already has to call listen twice.  Once for the rdma_cm and 
once for sockets.  Similarly on the client side, connect must be made 
over rdma_cm or sockets.  I really don't see any impact on the 
application for this approach.

We just end up separating the port space based on networking addresses, 
rather than keeping the problem at the transport level.  If you have an 
alternate approach that will be accepted upstream, feel free to post it.

- Sean
