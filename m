From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] SCTP: enable cookie-echo retransmission transport switch
Date: Thu, 12 Jun 2008 11:07:16 -0400
Message-ID: <48513BA4.9030403@hp.com>
References: <4850A7F2.6090906@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:11862 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085AbYFLPHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 11:07:20 -0400
In-Reply-To: <4850A7F2.6090906@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gui Jianfeng wrote:
> Vlad,
> This patch enables cookie-echo retransmission transport switch
> feature. If COOKIE-ECHO retransmission happens, it will be sent 
> to the address other than the one last sent to.
> 

NAK.

You can't blindly choose a different transport since they could
be unconfirmed and can't really be used until we confirm them
with HBs.  So, you can only do this when the user issued an
sctp_connectx() and we have multiple confirmed transports.

In this case only confirmed transports are allowed, otherwise
there is a possibility of hijacking associations.


Also, looking at this, the same problem exists in current
code for selection INIT transports.

We don't correctly treat peers passed to connectx() as confirmed
and don't select the correct transport.

Once you fix that above, you can just re-use the function and
re-use init_last_sent_to.

-vlad

