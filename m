From: Michael Tuexen <Michael.Tuexen@lurchi.franken.de>
Subject: Re: [PATCH] sctp: make the max_burst min value to 1
Date: Mon, 2 Dec 2013 14:08:21 +0100
Message-ID: <DABC28BB-074A-42CE-ACEC-BE9893B4ED06@lurchi.franken.de>
References: <529C2E01.3090005@huawei.com> <20131202115640.GA10857@hmsreliant.think-freely.org>
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Wang Weidong <wangweidong1@huawei.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, dingtianhong@huawei.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:35106 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039Ab3LBNg2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 08:36:28 -0500
In-Reply-To: <20131202115640.GA10857@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 2, 2013, at 12:56 PM, Neil Horman <nhorman@tuxdriver.com> wrote:

> On Mon, Dec 02, 2013 at 02:51:45PM +0800, Wang Weidong wrote:
>> From: Wang Weidong <wangweidong1@huawei.com>
>> 
>> when I setted the max_burst to 0, do the lksctp-tools I got hang.
>> I found sctp_transport_burst_limited would make the cwnd to 0.
>> so I make the max_burst min value to 1.
>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
>> ---
>> net/sctp/sysctl.c | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
>> index 7637e8e..46832d3 100644
>> --- a/net/sctp/sysctl.c
>> +++ b/net/sctp/sysctl.c
>> @@ -135,7 +135,7 @@ static struct ctl_table sctp_net_table[] = {
>> 		.maxlen		= sizeof(int),
>> 		.mode		= 0644,
>> 		.proc_handler	= proc_dointvec_minmax,
>> -		.extra1		= &zero,
>> +		.extra1		= &one,
>> 		.extra2		= &int_max
>> 	},
>> 	{
>> -- 
>> 1.7.12
>> 
>> 
> 
> 
> This seems like a band-aid to me.  There are a few things wrong:
> 
> 1) You can also set the the max_burst via setsockopt, and so this would need to
> be checked in that path as well.
> 
> 2) I don't see how having a cwnd of zero would cause a hang.  It looks like a
> cwnd of zero would perpetually place the association in a slow start state,
> which is silly but not illegal.  
> 
> Please investigate the acutally root cause of the problem before just avoiding
> it like this.
I second this.

Please note the using max_burst of  in the socket option means that you
deactivate max_burst, not that you actually use the value 0. See
http://tools.ietf.org/html/rfc6458#section-8.1.24

I FreeBSD we use the sysctl variable as the default for sockets. Therefore
max_burst is a valid value, it just disables max_burst.

Best regards
Michael
> 
> Thanks!
> Neil
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
