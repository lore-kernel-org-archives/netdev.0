From: Krister Johansen <kjlx@templeofstupid.com>
Subject: Re: [PATCH] Ipvlan should return an error when an address is already
 in use.
Date: Wed, 4 Jan 2017 02:09:01 -0800
Message-ID: <20170104100901.GF3009@templeofstupid.com>
References: <20161231041058.GC2448@templeofstupid.com>
 <f7td1g49m8n.fsf@redhat.com>
 <20170103.105528.1616978923771083764.davem@davemloft.net>
 <f7ta8b87xqc.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kjlx@templeofstupid.com,
        maheshb@google.com, netdev@vger.kernel.org
To: Aaron Conole <aconole@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub5.mail.dreamhost.com ([208.113.200.129]:48092 "EHLO
        homiemail-a124.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S964784AbdADKkQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 05:40:16 -0500
Received: from homiemail-a124.g.dreamhost.com (localhost [127.0.0.1])
        by homiemail-a124.g.dreamhost.com (Postfix) with ESMTP id 2DD1C60000D07
        for <netdev@vger.kernel.org>; Wed,  4 Jan 2017 02:40:16 -0800 (PST)
Received: from kmjvbox (c-73-70-90-212.hsd1.ca.comcast.net [73.70.90.212])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: kjlx@templeofstupid.com)
        by homiemail-a124.g.dreamhost.com (Postfix) with ESMTPSA id 0E83B60000D01
        for <netdev@vger.kernel.org>; Wed,  4 Jan 2017 02:40:16 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <f7ta8b87xqc.fsf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 03, 2017 at 02:24:43PM -0500, Aaron Conole wrote:
> David Miller <davem@davemloft.net> writes:
> 
> > From: Aaron Conole <aconole@redhat.com>
> > Date: Tue, 03 Jan 2017 10:50:00 -0500
> >
> >>> @@ -489,7 +490,12 @@ static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
> >>>  	   Notifier will trigger FIB update, so that
> >>>  	   listeners of netlink will know about new ifaddr */
> >>>  	rtmsg_ifa(RTM_NEWADDR, ifa, nlh, portid);
> >>> -	blocking_notifier_call_chain(&inetaddr_chain, NETDEV_UP, ifa);
> >>> +	ret = blocking_notifier_call_chain(&inetaddr_chain, NETDEV_UP, ifa);
> >> 
> >> Why are you doing this assignment if you aren't using the result?
> >> 
> >>> +	ret = notifier_to_errno(ret);
> >>> +	if (ret) {
> >>> +		__inet_del_ifa(in_dev, ifap, 1, NULL, portid);
> >>> +		return ret;
> >>> +	}
> >
> > 'ret' assignment is being used, via notifier_to_errno().
> 
> d'oh!  should have had more coffee - sorry for the noise.

No worries, and thanks for taking a look.  That was from checkpatch,
which complained when I wrote it as:

	if ((ret = notifier_to_errno(ret)) != 0) {

-K
