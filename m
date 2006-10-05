From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: Request to postpone WE-21
Date: Thu, 5 Oct 2006 14:57:51 -0700
Message-ID: <20061005215751.GI17517@instant802.com>
References: <20061005163113.GB6510@bougret.hpl.hp.com> <20061005204949.GF18408@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jean Tourrilhes <jt@hpl.hp.com>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-53.dex002.intermedia.net ([64.78.21.155]:42036 "EHLO
	dhost002-53.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S932307AbWJEV6C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 17:58:02 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
In-Reply-To: <20061005204949.GF18408@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 05, 2006 at 04:49:54PM -0400, John W. Linville wrote:

> What about a patch like the one below?  It tries to detect WE-20
> ESSID/NICKN accesses and adjust them to WE-21 style.  What am
> I missing?

> diff --git a/net/core/wireless.c b/net/core/wireless.c

> +			else if (IW_IS_SET(cmd)) {
> +				char essid[IW_ESSID_MAX_SIZE + 1];
> +
> +				err = copy_from_user(essid, iwr->u.data.pointer,
> +						     iwr->u.data.length *
> +						     descr->token_size);

> +				if (essid[iwr->u.data.length] == '\0')
> +					essid_compat = 1;

This looks somewhat confusing.. WE-20 (and older) included '\0' in both
the data value and length (well, at least in most drivers and user space
tools, if I remember correctly), i.e., essid[iwr->u.data.length] would
be pointing one byte after the '\0' termination.. And since '\0' is
valid character in SSID (it is just an arbitrary array of octets) it can
also be the last octet of the SSID and WE-21 style case could have
essid[iwr->u.data.length - 1] == '\0'..

-- 
Jouni Malinen                                            PGP id EFC895FA
