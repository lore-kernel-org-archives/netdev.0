From: Baruch Even <baruch@ev-en.org>
Subject: Possible bugs in SACK processing
Date: Thu, 25 Jan 2007 21:19:57 +0200
Message-ID: <20070125191957.GD22455@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Douglas Leith <doug@eee.strath.ac.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:40465
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030514AbXAYTT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 14:19:58 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In addition to the patch I've provided there are two more issues that I
believe are bugs in the SACK processing code. Since I'm not certain but
I don't have the time to look into them I'd like to raise them for other
folks to look at.

First issue is the checking of the applicability of the fast path. The
sack blocks are compared directly, but there is no comparison of the
number of sack blocks. If in the former sack we had two blocks and now
we have three we will compare the third sack block from now against old
or uninitialised data. The chance of anything really bad happening might
not be high but it seems to be a bad behaviour.

The second issue is that there is no check that the fast path is
actually behind the hint. Consider a scenario where we have three sack
blocks and the first sack update is about an old location. And then
comes another sack packet with only an update to the old location. The
result will be that after the former sack block the hint is in the
latest location it can be and when the next sack packet arrives we
detect its an increase only but the fast path hint is too far and we do
no updating at all.

Baruch
