From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: Request to postpone WE-21
Date: Thu, 5 Oct 2006 15:20:43 -0700
Message-ID: <20061005222043.GA7614@bougret.hpl.hp.com>
References: <20061005163113.GB6510@bougret.hpl.hp.com> <20061005204949.GF18408@tuxdriver.com> <20061005221246.GB7533@bougret.hpl.hp.com> <20061005221550.GJ17517@instant802.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:1278 "EHLO
	gundega.hpl.hp.com") by vger.kernel.org with ESMTP id S932378AbWJEW2n
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 18:28:43 -0400
To: Jouni Malinen <jkm@devicescape.com>
Content-Disposition: inline
In-Reply-To: <20061005221550.GJ17517@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 05, 2006 at 03:15:50PM -0700, Jouni Malinen wrote:
> On Thu, Oct 05, 2006 at 03:12:46PM -0700, Jean Tourrilhes wrote:
> > +			if((cmd == SIOCSIWESSID) ||
> > +			   (cmd == SIOCSIWNICKN)) {
> > +				if(extra[iwr->u.data.length - 1] == '\0') {
> 
> Can't iwr->u.data.length be zero here (with WE-21)? Maybe better add
> 'iwr->u.data.length > 0 &&'..

	It's already implied. I did not put the code in the same place
a John.
	It looks like :
----------------------------------------------------------
		/* If it is a SET, get all the extra data in here */
		if(IW_IS_SET(cmd) && (iwr->u.data.length != 0)) {
			err = copy_from_user(extra, iwr->u.data.pointer,
					     iwr->u.data.length *
					     descr->token_size);

			if((cmd == SIOCSIWESSID) ||
			   (cmd == SIOCSIWNICKN)) {
				if(extra[iwr->u.data.length - 1] == '\0') {
					iwr->u.data.length--;
				}
			}
		}
----------------------------------------------------------

> Jouni Malinen

	Thanks for the quick review !

	Jean

