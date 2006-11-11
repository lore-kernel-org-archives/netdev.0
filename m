From: Paul Moore <paul.moore@hp.com>
Subject: Re: [NETLINK]: Do precise netlink message allocations where possible
Date: Fri, 10 Nov 2006 23:06:31 -0500
Message-ID: <45554C47.9020709@hp.com>
References: <20061110121706.GH8693@postel.suug.ch> <4554A2FE.2020405@hp.com> <20061110221640.GN8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.cce.hp.com ([161.114.21.23]:6189 "EHLO
	ccerelrim02.cce.hp.com") by vger.kernel.org with ESMTP
	id S1947081AbWKKEHI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 23:07:08 -0500
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061110221640.GN8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Paul Moore <paul.moore@hp.com> 2006-11-10 11:04
> 
>>I like this approach, it makes much more sense to me then the previous
>>implementation which was a simple "alias" to alloc_skb().  Also, the NetLabel
>>relevant sections look fine to me.
> 
> Question is wheter to do the same for genetlink and add genlmsg_new().

If it makes sense to modify nlmsg_new() I think it makes sense modify
genlmsg_new().  My vote is for "yes".

> I'm currently thinking about this and also about some _reply() function
> which takes a struct genl_info so a genetlink module doesn't have to
> know about how to address the client by pid anymore.

Hmm, interesting idea.  I've only thought about it for a few minutes now but it
might be nice to do something like the following:

* genlmsg_put_reply()
  - write the message headers using genlmsg_put()
    + take the snd_pid and snd_seq from the genl_info struct
    + ?lookup the hdrlen based on the genl family info in the message
      headers in the genl_info struct?

* genlmsg_new_reply()
  - allocate a buffer using genlmsg_new()
  - call genlmsg_put_reply()

* genlmsg_{unicast,multicast}_reply()
  - take the pid from the genl_info struct

I think this would simply the genetlink handlers job a little bit.

> Ideas or even patches very welcome.

If that sounds reasonable I can put together a patch sometime next week,
although it will probably be later in the week as I have some NetLabel stuff I
want to get done for 2.6.20.

-- 
paul moore
linux security @ hp
