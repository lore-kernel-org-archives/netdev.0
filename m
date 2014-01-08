From: Masatake YAMATO <yamato@redhat.com>
Subject: Re: [PATCH] unix: show socket peer if no addr is given in
 /proc/net/unix
Date: Wed, 08 Jan 2014 15:50:40 +0900 (JST)
Message-ID: <20140108.155040.860515040229514881.yamato@redhat.com>
References: <1389158288-2855-1-git-send-email-yamato@redhat.com>
	<20140108.010043.2192738470649350132.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31466 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751456AbaAHGum (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 01:50:42 -0500
In-Reply-To: <20140108.010043.2192738470649350132.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you for reviwing.
I'll use netlink diag facility.

Masatake YAMATO

On Wed, 08 Jan 2014 01:00:43 -0500 (EST), David Miller <davem@davemloft.net> wrote:
> From: Masatake YAMATO <yamato@redhat.com>
> Date: Wed,  8 Jan 2014 14:18:08 +0900
> 
>> Path field of /proc/net/unix is empty if an address is not given
>> to a socket. Typical way to create such socket is calling
>> socketpair. The empty fields make it difficult to understand the
>> communication between processes. e.g. lsof cannot resolve the role of
>> file descriptors well.
>> 
>> This patch fills the empty fields with unix_peer.
>> 
>> Signed-off-by: Masatake YAMATO <yamato@redhat.com>
> 
> You cannot change the format of a procfs file without potentially
> breaking some application which might interpret the output.
> 
> In this case an application might be looking for an empty field
> as meaning the sockhad has no given address.
> 
> I cannot apply this patch.  People have repeatedly tried making
> changes to these networking socket procfs files, and I really wish
> people would stop trying to do so.
> 
> If you want specific pieces of new information, extend the socket
> dumping facility that is actually extensible in a way which will not
> break existing applications, and that's netlink.
