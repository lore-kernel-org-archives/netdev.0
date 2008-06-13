From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Subject: Re: [PATCH] SCTP: enable cookie-echo retransmission transport switch
Date: Fri, 13 Jun 2008 08:47:41 +0800
Message-ID: <4851C3AD.9030600@cn.fujitsu.com>
References: <4850A7F2.6090906@cn.fujitsu.com> <48513BA4.9030403@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59486 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752305AbYFMAuO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jun 2008 20:50:14 -0400
In-Reply-To: <48513BA4.9030403@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad,

  Thanks for your comments.

Vlad Yasevich wrote:
> Gui Jianfeng wrote:
>> Vlad,
>> This patch enables cookie-echo retransmission transport switch
>> feature. If COOKIE-ECHO retransmission happens, it will be sent to the
>> address other than the one last sent to.
>>
> 
> NAK.
> 
> You can't blindly choose a different transport since they could
> be unconfirmed and can't really be used until we confirm them
> with HBs.  So, you can only do this when the user issued an
> sctp_connectx() and we have multiple confirmed transports.
> 
> In this case only confirmed transports are allowed, otherwise
> there is a possibility of hijacking associations.
> 
  Choosing a transport here just gives a suggestion for sctp_outq_flush(),
  sctp_outq_flush() will judge again. If the selected transport is in 
  INACTIVE or UNCONFIRMED, active_path will be used.
  So COOKIE-ECHO won't be sent to a unconfirmed address.

> 
> Also, looking at this, the same problem exists in current
> code for selection INIT transports.
> 
> We don't correctly treat peers passed to connectx() as confirmed
> and don't select the correct transport.
> 
> Once you fix that above, you can just re-use the function and
> re-use init_last_sent_to.

  Will do.

> 
> -vlad
> 



> 
> 

-- 
Regards
Gui Jianfeng
