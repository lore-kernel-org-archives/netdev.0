From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net 2/2] RDS: TCP: Synchrnozize accept() and connect()
 paths on t_conn_lock.
Date: Mon, 2 May 2016 11:08:37 -0700
Message-ID: <b103ecc8-e224-b657-4ae9-acb39d9cd4f7@oracle.com>
References: <cover.1462127059.git.sowmini.varadhan@oracle.com>
 <5fc507116182afdda4b824173008e09d5d464a33.1462127059.git.sowmini.varadhan@oracle.com>
 <b5d93d46-5465-ce03-74b1-07136eac0cc9@oracle.com>
 <20160502164307.GE20517@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	davem@davemloft.net
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:29898 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754672AbcEBSIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 14:08:46 -0400
In-Reply-To: <20160502164307.GE20517@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/2/2016 9:43 AM, Sowmini Varadhan wrote:
> On (05/02/16 09:33), Santosh Shilimkar wrote:
>>> +	mutex_unlock(&tc->t_conn_lock);
>> Just wondering whether the spin_lock() would better here considering
>> entry into rds_tcp_conn_connect() & rds_tcp_accept_one() might be
>> from softirq context. Ignore it if its not applicable.
>
> It's not from softirq context (both are workqs), but I used a mutex
> to follow c_cm_lock (which I considered reusing, given that it
> is only IB specific?) But spin_lock vs mutex may not be a big
> differentiator here- this is really a one-time start up (corner-case)
> issue in the control path.
>
That should be fine then.

>>> 	rds_conn_transition(conn, RDS_CONN_DOWN, RDS_CONN_CONNECTING);
>> Like patch 1/2, probably we can leverage return value of above.
>      :
>> You probably don't need the local 'conn_state' and below should work.
>> 	if (!rds_conn_connecting(conn) && !rds_conn_up(conn))
>
> see explanation for comment to 1/2.
>
Yep.

 > +rst_nsk:
 > +	/* rest the newly returned accept sock and bail */
s/rest/reset

With typo fixed,
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
