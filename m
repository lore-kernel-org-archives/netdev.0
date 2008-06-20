From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH net-next 1/8] af_packet: Check return of dev_set_promiscuity/allmulti
Date: Fri, 20 Jun 2008 10:13:18 +0800
Message-ID: <485B123E.3020501@cn.fujitsu.com>
References: <485AFFC8.2040701@cn.fujitsu.com> <20080619.190522.237900335.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51747 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751582AbYFTCTM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 22:19:12 -0400
In-Reply-To: <20080619.190522.237900335.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller said the following on 2008-6-20 10:05:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Fri, 20 Jun 2008 08:54:32 +0800
> 
>> @@ -1245,7 +1247,8 @@ static int packet_mc_add(struct sock *sk, struct packet_mreq_max *mreq)
>>  	i->count = 1;
>>  	i->next = po->mclist;
>>  	po->mclist = i;
>> -	packet_dev_mc(dev, i, +1);
>> +	/* Positive increment should be checked for overflow --WCN */
>> +	err = packet_dev_mc(dev, i, 1);
>>  
> 
> Please don't add these little signatures to comments.  That might have
> been useful to do 10 years ago when we didn't use proper source
> control, but now we do and anyone interested can do a "git blame"
> to see who added that comment and why.
> 
> Also, this comment doesn't really add any information.  We check
> error return values simply because errors can happen, that's just
> a straight fact.  If packet_dev_mc() and it's sub calls can error
> for other reasons this comment is only telling part of the story
> and as a result becomes inaccurate.
> 
> Therefore, I'd like to ask that you not add this comment, it doesn't
> really help anything.  This kind of information can go into the
> commit log message.  That's where "why" information tends to belong.
> 

Roger.
I will remove all useless comment in my patch series.
Thanks David.
Don't blame me in every patch :)

