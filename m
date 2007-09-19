From: Holger Eitzenberger <holger@my-eitzenberger.de>
Subject: Re: [FIX NETLINK] properly check arguments to netlink_bind()
Date: Wed, 19 Sep 2007 09:16:00 +0200
Message-ID: <873axb6s7j.fsf@kruemel.my-eitzenberger.de>
References: <87fy1belij.fsf@kruemel.my-eitzenberger.de>
	<876427elan.fsf@kruemel.my-eitzenberger.de>
	<20070918.145331.67883847.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.174]:50832 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752858AbXISHQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 03:16:28 -0400
In-Reply-To: <20070918.145331.67883847.davem@davemloft.net> (David Miller's
 message of "Tue, 18 Sep 2007 14:53:31 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

>> > while going through going netlink code I found out that netlink_bind()
>> > does not properly check bind parameters.  I checked both 2.6.23-rc1 as
>> > well as 2.6.16.53, both are affected.

> Firstly, you patch compares the address _pointer_ against
> the minimum length.  That's obviously wrong.

True, the message send later fixed that.

> And if you check the call sites of the protocol ->bind() methods, they
> all use on-stack buffer for the address object which is at least
> MAX_SOCK_ADDR bytes in length so that the bind methods don't have to
> check the size if they don't want to.

Also true, but in that case you still end up accessing uninitialized
data.  Also note that e. g. inet_bind() checks explicitely for that and
it's not clear to me why netlink_bind() is different.  Maybe you just
help me figuring out.

Another point is that simply calling

 bind(nl_fd, (struct sockaddr *)&an_int, sizeof(int));

will not return EINVAL but depends on the randomn data after an_int.

   /holger

 
