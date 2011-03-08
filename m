From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] cnic: fix double initalization of bnx2 based cards
Date: Tue, 8 Mar 2011 13:41:43 -0800
Message-ID: <1299620503.12601.26.camel@HP1>
References: <1299610588-22356-1-git-send-email-nhorman@tuxdriver.com>
 <1299610768.4957.1.camel@bwh-desktop> <1299611277.12601.15.camel@HP1>
 <20110308193601.GA19669@hmsreliant.think-freely.org>
 <1299613396.12601.21.camel@HP1>
 <20110308214028.GD19669@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eddie Wai" <eddie.wai@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Neil Horman" <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2528 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756376Ab1CHVqz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 16:46:55 -0500
In-Reply-To: <20110308214028.GD19669@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2011-03-08 at 13:40 -0800, Neil Horman wrote:
> > No, that should not happen.  When we compare NULL-terminated "bnx2" with
> > NULL-terminated "bnx2x", it won't match because the '\0' won't match the
> > 'x', right?
> > 
> > I think the patch is good.  We can avoid the unnecessary strcmp() when
> > we have a match with "bnx2" already.  But we should not get both matches
> > even without the patch.
> > 
> Crap, sorry, I rescind this (although you're right, it probably wouldn't hurt to
> roll this change in, just to save a potential second strcmp).  Anywho, I'm
> getting this error on the ifup of my bnx2 interface:
> bnx2i: iSCSI not supported, dev=eth1
> 
> That message appears to only get set (from my read) on cards driven by the bnx2x
> driver, and when I saw the 2 ifs rather than the if/else, I jumped to a
> conclusion that we must be using the bnx2x init path on a bnx2 driver.
> Apologies.
> 
> /me wanders off to see where completion_status gets set to
> ISCSI_KCQE_COMPLETION_STATUS_ISCSI_NOT_SUPPORTED for bnx2.

On bnx2, this error code is set by the firmware if iSCSI is not
configured in NVRAM.

Thanks.


