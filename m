From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH] phy: power management support
Date: Tue, 2 Dec 2008 19:25:05 -0800
Message-ID: <20081203032505.GA13484@xw6200.broadcom.net>
References: <1227794220-19872-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Giuseppe CAVALLARO" <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3901 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750877AbYLDIHw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2008 03:07:52 -0500
In-Reply-To: <1227794220-19872-1-git-send-email-peppe.cavallaro@st.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A while ago Andy Fleming had replied to one of my patches expressing an
interest in implementing WOL (which I expanded to mean "more control of
the lifetime of the phy") within the phylib.  I responded that there
were two problems with that approach.  Very briefly, the problems were
that the phylib did not have enough information available to determine
what power state to put the phy into (think management firmware), and
that turning off the phy might interfere with the normal operation of
some MAC registers.  I'm sorry that thread died so abruptly.

My concerns remain though.  At the time the phy is initially probed,
there is no way to gather enough information to determine whether or not
it is safe to power down the phy.  The earliest such information can be
communicated is through the flags parameter of the phy_connect()
function.

I can't speak for the other uses of the phylib, but for tg3 it makes a
lot of sense to place phy power management in the hands of the driver
that controls it.  If you agree, can we devise a way to bypass the
suspend callback?


