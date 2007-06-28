From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: a maze of twisty stats, most different
Date: Thu, 28 Jun 2007 11:17:51 -0700
Message-ID: <OF4B8149B6.D8E6CC86-ON88257308.006345F0-88257308.0064762A@us.ibm.com>
References: <4683F10F.6070007@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Chris Snook <csnook@redhat.com>,
	Linux Network Development list <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:41145 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759616AbXF1S1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 14:27:04 -0400
In-Reply-To: <4683F10F.6070007@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I think there's a more general problem that's a huge hassle. There are 
lots of
new SNMP MIB's, but no conventions (that I'm aware of, at least) to allow 
for
changes to the /proc entries that get them to applications. For example, 
the
route age data recently submitted. I agree that existing apps rely on 
these
and are generally very fragile, but in practice it means it isn't easy to 
do any
changes for RFC compliance with new MIBS, short of replicating existing 
data
in a new /proc entry along with the old one.

How do people feel about adding a MIB subtree in /proc that tracks MIB
updates with some basic rules:

1) all fields must be tagged with a label
2) all apps using it must match the label, and ignore anything they don't
        match

Then future additions to a row just mean adding a label (like route age),
and items like the one-per-line v6 statistics could add new ones easily, 
too.
And the existing MIB and non-MIB stats can be the same format, though
possibly derived from different data.

I've got a patch for doing ICMPMsgStats, which replaces the individual
ICMP counters now defined (and which are deprecated), but changing
/proc/net/snmp6 doesn't seem so wise, given how fragile some of these
apps are.

Defined device stats could live in that proposed tree, too, and with basic
rules for users would allow Linux-only useful extensions without breaking
the rules that apps using it should follow (and therefore without breaking 
the
apps). That's independent of ethtool extensions, but at least marginally 
related...

Comments?

                                                +-DLS

