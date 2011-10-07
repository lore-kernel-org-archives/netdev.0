From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Flow control config vs status
Date: Fri, 7 Oct 2011 14:19:18 -0700
Message-ID: <20111007211918.GA7388@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2799 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751209Ab1JGVTs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Oct 2011 17:19:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben.  I've been encountering with a small problem with how ethtool
handles flow control settings.

When the admin runs 'ethtool -A ...', ethtool will run an
ETHTOOL_GPAUSEPARAM query, check the new settings against the 'old',
and then issue ETHTOOL_SPAUSEPARAM if they don't match.  My problem is
that the tg3 driver returns the flow control status in a
ETHTOOL_GPAUSEPARAM query, not the configuration.

So, as an example of the problem, if the local side sets
'ethtool -A ethx rx on tx on autoneg on', and then the remote side sets
'ethtool -A ethy rx off tx off autoneg off', the link will autoneg to rx
off, tx off.  Then, the local side will be unable to turn off rx or tx
flow control because ethtool will act on the current link flow control
status, not the config.

The tg3 isn't the only driver that reports flow control status through
ETHTOOL_GPAUSEPARAM.  The e1000e, bnx2, and bnx2x drivers do this as
well.

The ETHTOOL_GSET query does make room for flow control advertisements,
but a device doesn't have to advertise its flow control settings if flow
control autoneg is turned off.  I'm thinking this interface doesn't
really solve the problem.

Any recommendations?
