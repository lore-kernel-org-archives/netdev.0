From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH iproute2 1/2] lib/libnetlink: re malloc buff if size is
 not enough
Date: Mon, 11 Sep 2017 15:19:55 +0800
Message-ID: <20170911071955.GZ5465@leo.usersys.redhat.com>
References: <1504865697-27274-1-git-send-email-liuhangbin@gmail.com>
 <1504865697-27274-2-git-send-email-liuhangbin@gmail.com>
 <20170908110247.GS2399@orbyte.nwl.cc>
 <20170908140131.GU5465@leo.usersys.redhat.com>
 <20170908145113.GA30028@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:38115 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751007AbdIKHUG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 03:20:06 -0400
Received: by mail-pg0-f50.google.com with SMTP id v66so13868773pgb.5
        for <netdev@vger.kernel.org>; Mon, 11 Sep 2017 00:20:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170908145113.GA30028@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Phil and Michal,
On Fri, Sep 08, 2017 at 04:51:13PM +0200, Phil Sutter wrote:
> Hi,
> 
> On Fri, Sep 08, 2017 at 10:01:31PM +0800, Hangbin Liu wrote:
> [...]
> > Since we have to use two static bufffers. So how about check like
> > 
> > 	if (len > strlen(buffer))
> 
> I don't think that will work. We are reusing the buffer and it contains
> binary data, so a NUL byte may appear anywhere. I fear you will have to
> change rtnl_recvmsg() to accept a buflen parameter which callers have to
> define statically together with the buffer pointer.

OK
> 
> Regarding Michal's concern about reentrancy, maybe we should go into a
> different direction and make rtnl_recvmsg() return a newly allocated
> buffer which the caller has to free.

Hmm... But we could not free the buf in __rtnl_talk(). Because in
__rtnl_talk() we assign the answer with the buf address and return to caller.

	for (h = (struct nlmsghdr *)buf; status >= sizeof(*h); ) {
		[...]
		if (answer) {
			*answer= h;
			return 0;
		}
	}

And the caller will keep use it in later code. Since there are plenty of
functions called rtnl_talk. I think it would be much more complex to free
the buffer every time.


Hi Michal,

Would you like to tell me more about your concern with reentrancy? It's looks
arpd doesn't call rtnl_talk() or rtnl_dump_filter_l().

Thanks
Hangbin
