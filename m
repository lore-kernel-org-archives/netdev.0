From: Tyler Hicks <tyhicks@ou.edu>
Subject: [IPSEC] RFC 4301 PFP Support
Date: Tue, 11 Dec 2007 13:34:45 -0800
Message-ID: <20071211213445.GA11887@hestia>
Reply-To: tyhicks@ou.edu
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <latten@us.ibm.com>, <herbert@gondor.apana.org.au>,
	<davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2007asmtp.zero.ou.edu ([129.15.0.236]:55055 "EHLO
	it-wildcat.sooner.net.ou.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750847AbXLKVjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 16:39:53 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm working on adding populate from packet (PFP) support to the kernel,
as specified in RFC 4301.  While testing with openswan (2.4.9), I
noticed that the state selector values in the SAD were empty.  It seems
that when openswan sends a ALLOCSPI message, the kernel finds the larval
xfrm_state with selector fields filled in and passes it to openswan.
Openswan will then respond with an UPDSA message that includes an
xfrm_usersa_info that has empty selector values.  The kernel assumes
that these selector values are valid and deletes the larval SA and
inserts the new SA containing empty selectors.  We need SAs with valid
selectors in the SAD in order to implement PFP support.

Should we just use the larval selectors or should we assume that
openswan will begin to send valid selectors?  I asked for the openswan
dev's opinions and they referred me to Herbert Xu.  It seems as though
the correct solution would be for openswan to pass valid selectors in
UPDSA messages, even if it is the larval selectors we gave them.

On a side note, Joy Latten has reported to see the same behavior while
using ipsec-tools.

Thanks!

Tyler Hicks

