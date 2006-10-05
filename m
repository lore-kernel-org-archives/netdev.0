From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: Request to postpone WE-21
Date: Thu, 5 Oct 2006 15:07:04 -0700
Message-ID: <20061005220704.GA7533@bougret.hpl.hp.com>
References: <20061005163113.GB6510@bougret.hpl.hp.com> <20061005204949.GF18408@tuxdriver.com> <20061005215751.GI17517@instant802.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:34509 "EHLO madara.hpl.hp.com")
	by vger.kernel.org with ESMTP id S932310AbWJEWH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 18:07:57 -0400
To: Jouni Malinen <jkm@devicescape.com>
Content-Disposition: inline
In-Reply-To: <20061005215751.GI17517@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 05, 2006 at 02:57:51PM -0700, Jouni Malinen wrote:
> On Thu, Oct 05, 2006 at 04:49:54PM -0400, John W. Linville wrote:
> 
> > What about a patch like the one below?  It tries to detect WE-20
> > ESSID/NICKN accesses and adjust them to WE-21 style.  What am
> > I missing?
> 
> > diff --git a/net/core/wireless.c b/net/core/wireless.c
> 
> > +			else if (IW_IS_SET(cmd)) {
> > +				char essid[IW_ESSID_MAX_SIZE + 1];
> > +
> > +				err = copy_from_user(essid, iwr->u.data.pointer,
> > +						     iwr->u.data.length *
> > +						     descr->token_size);
> 
> > +				if (essid[iwr->u.data.length] == '\0')
> > +					essid_compat = 1;
> 
> This looks somewhat confusing.. WE-20 (and older) included '\0' in both
> the data value and length (well, at least in most drivers and user space
> tools, if I remember correctly), i.e., essid[iwr->u.data.length] would
> be pointing one byte after the '\0' termination..

	Obviously. John's code was only a proof of concept, tested
patch is coming in another e-mail.

> And since '\0' is
> valid character in SSID (it is just an arbitrary array of octets) it can
> also be the last octet of the SSID and WE-21 style case could have
> essid[iwr->u.data.length - 1] == '\0'..

	I think we will have to suffer a bit. After the big mess
created by the whole story, I think it might not be a bad idea to get
90% of the way there, and add the remaining 10% of a later date. At
the rate userspace is progressing, it's only a matter of weeks.

> Jouni Malinen

	Have fun...

	Jean

