From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH 2.6.18] WE-21 support (core API)
Date: Tue, 5 Sep 2006 10:06:41 -0700
Message-ID: <20060905170641.GA18704@bougret.hpl.hp.com>
References: <20060830005655.GA8405@bougret.hpl.hp.com> <1157093640.2878.26.camel@ux156> <20060901163558.GB13815@bougret.hpl.hp.com> <200609012055.48799.mb@bu3sch.de> <20060901221045.GB13975@bougret.hpl.hp.com> <1157358909.3324.42.camel@ux156>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:17378 "EHLO madara.hpl.hp.com")
	by vger.kernel.org with ESMTP id S932150AbWIERIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2006 13:08:23 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1157358909.3324.42.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 04, 2006 at 10:35:09AM +0200, Johannes Berg wrote:
> Uh, please don't strip me from the CC list :)
> 
> > 	WE-netlink is optional. And WE-ioctl could be made optional
> > (still on the todo list). You can also disable WE-event and WE-iwspy
> > for further footprint reduction.
> 
> The real question is: Why does removing WE-event reduce footprint? I
> guess the answer is that there's a lot of non-generic code needed to
> pack/unpack all the data. Which is not really something you want.

	Wrong answer.

> wireless.c has about 2.3k lines of code. But, for example airo.c
> contains another 15 lines of code just for the trivial *parameter
> checking* in airo_set_essid. This is duplicated all over. Did it never
> occur to you that things like
>                 /* Check the size of the string */
>                 if(dwrq->length > IW_ESSID_MAX_SIZE+1) {
>                         return -E2BIG ;
>                 }
> can be checked generically? Maybe you're actually checking this
> generically. But if I did it your way, I'd copy and paste this all
> over...

	It is actually checked generically, that's the whole point of
the code in wireless.c. But, driver authors don't trust generic
checks.

> > 	It was designed this way on purpose, because you get low
> > footprint and very good scalability.
> 
> Wtf does scalability have to do with it?

	Footprint scalability.

> johannes

	Jean
