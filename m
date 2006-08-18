From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [clarification request] ieee80211_tx_control.pkt_type
Date: Fri, 18 Aug 2006 07:33:21 -0700
Message-ID: <20060818143321.GA23446@instant802.com>
References: <1155901317.22520.2.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Simon Barber <simon@devicescape.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-56.dex002.intermedia.net ([64.78.21.185]:55741 "EHLO
	dhost002-56.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S932462AbWHROdl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 10:33:41 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1155901317.22520.2.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 18, 2006 at 01:41:57PM +0200, Johannes Berg wrote:

> I was pondering the ieee80211_tx_control type and don't see anyone using
> the pkt_type field. d80211 makes great effort to have it correct, but no
> driver uses it.
> 
> Hence, my question: What is the purpose of this field? Under what
> circumstances would a driver have to know this? Especially considering
> that it's only "normal" vs. "probe response"...

Some hardware designs require this configuration for TX frames. It is
used to select whether some of the fields are being filled in hardware
(e.g., timestamp for Probe Response). This would only be needed for AP
mode and IBSS (adhoc), so it is possible that not all low-level dirvers
have yet been implemented to support such operation.

This pkt_type was added at generic 802.11 layer in order to avoid
forcing the low-level driver to even look at the 802.11 header when
queuing the frame for transmission. Taken into account how simple
operation it is to get the type and subtype from the frame control
field, this tx ctrl pkt_type could be removed, if desired. However, it
was added there for a reason.

-- 
Jouni Malinen                                            PGP id EFC895FA
