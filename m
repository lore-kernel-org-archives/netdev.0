From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [2.6.30-git21] Network Namespace test failure
Date: Wed, 24 Jun 2009 22:14:49 -0500
Message-ID: <20090625031449.GA26767@us.ibm.com>
References: <4A422F1E.3050208@in.ibm.com> <20090624140056.GA11912@us.ibm.com> <4A42391A.4040802@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, serue@linux.vnet.ibm.com,
	David Miller <davem@davemloft.net>, matthltc@us.ibm.com,
	Stephen Hemminger <shemminger@vyatta.com>
To: Sachin Sant <sachinp@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:59112 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548AbZFYDOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 23:14:43 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5P3DIrC021961
	for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 21:13:18 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5P3Ek7w257698
	for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 21:14:46 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5P3EjTG006969
	for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 21:14:46 -0600
Content-Disposition: inline
In-Reply-To: <4A42391A.4040802@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Sachin Sant (sachinp@in.ibm.com):
> Serge E. Hallyn wrote:
>> Precise kernel version and .config?
>>   
> Kernel version is 2.6.30-git21 (626f380d0b264a1e40237f5a2a3dffc5d14f256e)

Thanks.  I bisected it to commit
ae0e8e82205c903978a79ebf5e31c670b61fa5b4 : "veth: prevent oops caused by
netdev destructor".  That moves the free_percpu(priv->stats) from
veth_dev_free to veth_close().  Since it gets allocated at
veth_dev_init, and dveth_xmit uses it unconditionally, that seems like a
likely cause of the oops?

-serge
