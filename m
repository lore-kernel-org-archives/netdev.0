From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next 1/2] tipc: Don't use iocb argument in socket
 layer
Date: Sat, 28 Feb 2015 10:29:19 +0800
Message-ID: <54F127FF.1060207@windriver.com>
References: <1425035198-12547-1-git-send-email-ying.xue@windriver.com> <1425035198-12547-2-git-send-email-ying.xue@windriver.com> <A2BAEFC30C8FD34388F02C9B3121859D1C399393@eusaamb103.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Erik Hugne <erik.hugne@ericsson.com>
To: Jon Maloy <jon.maloy@ericsson.com>,
	"viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
	"hch@lst.de" <hch@lst.de>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53272 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbbB1C3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 21:29:32 -0500
In-Reply-To: <A2BAEFC30C8FD34388F02C9B3121859D1C399393@eusaamb103.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/27/2015 09:30 PM, Jon Maloy wrote:
>> > socket *sock, long *timeo_p)  static int tipc_sendmsg(struct kiocb *iocb,
>> > struct socket *sock,
>> >  			struct msghdr *m, size_t dsz)
>> >  {
>> > +	struct sock *sk = sock->sk;
>> > +	int ret;
> alternative method: 
> 
>                 bool has_lock = false;
>> > +
>> > +	lock_sock(sk);
> 
>              if (!owned_by_user(sk) {
>                             lock_sock(sk);
>                             has_lock = true;
>               }      
>> > +	ret = __tipc_sendmsg(sock, m, dsz);
>               [expand  code here, instead of an extra call]
> 
>               if (has_lock))
>                       release_sock();
> 
> Not sure what I prefer, but I just wanted to indicate
> this option.
> 

Thanks! In my opinion, the current version seems more clear. :)

> You can anyway add a "Reviewed-by" from me.

Regards,
Ying
