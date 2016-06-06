From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net 1/3] RDS: TCP: Add/use rds_tcp_reset_callbacks to
 reset tcp socket safely
Date: Mon, 6 Jun 2016 12:04:26 -0700
Message-ID: <ed1d0ee5-0006-5773-56cd-a85a2614fece@oracle.com>
References: <cover.1465071319.git.sowmini.varadhan@oracle.com>
 <1d38b67763bc39068310a4dbc13ee9e56b8f0dab.1465071319.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:22562 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313AbcFFTEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 15:04:38 -0400
In-Reply-To: <1d38b67763bc39068310a4dbc13ee9e56b8f0dab.1465071319.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/4/2016 1:59 PM, Sowmini Varadhan wrote:
> When rds_tcp_accept_one() has to replace the existing tcp socket
> with a newer tcp socket (duelling-syn resolution), it must lock_sock()
> to suppress the rds_tcp_data_recv() path while callbacks are being
> changed.  Also, existing RDS datagram reassembly state must be reset,
> so that the next datagram on the new socket  does not have corrupted
> state. Similarly when resetting the newly accepted socket, appropriate
> locks and synchronization is needed.
>
> This commit ensures correct synchronization by invoking
> kernel_sock_shutdown to reset a newly accepted sock, and by taking
> appropriate lock_sock()s (for old and new sockets) when resetting
> existing callbacks.
>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
