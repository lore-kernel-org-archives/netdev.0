From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next 3/6] cnic: Fix panic in
 cnic_iscsi_nl_msg_recv() when device is down.
Date: Thu, 25 Feb 2010 23:01:59 -0800
Message-ID: <C27F8246C663564A84BB7AB34397724218312F8FD0@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <20100226005114.GH3876@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "'Simon Horman'" <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4959 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935340Ab0BZHCN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 02:02:13 -0500
In-Reply-To: <20100226005114.GH3876@verge.net.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon Horman wrote:

> On Wed, Feb 24, 2010 at 04:42:06PM -0800, Michael Chan wrote:
> > Some data structures are freed when the device is down and it will
> > crash if an ISCSI netlink message is received.  Add RCU protection
> > to prevent this.  In the shutdown path, ulp_ops[CNIC_ULP_L4] is
> > assigned NULL and rcu_synchronized before freeing the data
> > structures.
>
> Is rcu_assign_pointer() unnecessary in cnic_cm_open()?
> It doesn't seem to be followed by rcu_synchronized() and the pointer
> doesn't seem to be accessible anywhere else at that time.

We assign a valid pointer in cnic_cm_open() so that it can be used
during run-time (in service_kcqes() for example).  During shutdown in
cnic_stop_hw(), we assign NULL followed by rcu_synchronize().

