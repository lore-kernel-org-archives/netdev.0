From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [RFC] cfg80211 and nl80211
Date: Thu, 5 Oct 2006 08:46:33 -0700
Message-ID: <20061005154633.GB17517@instant802.com>
References: <1159435399.2648.17.camel@ux156> <1159805711.2834.67.camel@localhost.localdomain> <1159947674.2817.19.camel@ux156> <1159971561.2817.87.camel@ux156> <1159984658.3287.98.camel@localhost.localdomain> <20061005131353.GA3432@shaftnet.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-93.dex002.intermedia.net ([64.78.20.220]:6469 "EHLO
	DHOST002-93.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751420AbWJERNA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 13:13:00 -0400
To: Dan Williams <dcbw@redhat.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20061005131353.GA3432@shaftnet.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 05, 2006 at 09:13:53AM -0400, Stuffed Crust wrote:

> (Leave out the RSNIE, AuthType and KeyMgmt stuff; while they're 
>  used in the actual key negotiation/derivation, they're separate 
>  problems and have no bearing on the crypto layer.  From the driver's 
>  perspective the RSNIE is just an opaque blob to be appended to 
>  beacons,presps and [re]assoc frames, KeyMgmt is purely a matter for 
>  the authenticator/supplicant, and AuthType is just a toggle that 
>  happens to be off for post-802.11i, although LEAP v1 adds some 
>  complications there..)

They are separate problems, but they do need to be taken into account in
802.11 interface to user space. Some drivers generate WPA/RSN IE
internally and they need to be told about the allowed protocol version,
authenticated key management suite, and pairwise/group cipher suites. In
other words, key management is not purely for authenticator/supplicant.

> Each key has:
> 
> * Key type (WEP/TKIP/AES-CCMP/NONE)
> * Key length (implied, but WEP can have varying key lengths)
> * Key index (only '0' is generally used for unicast frames, but 802.11i 
>              requires use of simultaneous broadcast keys)

Pre-802.11i supported key mapping and multiple default keys.. To make
things complex, many Cisco APs are configured to use non-zero key
indexes with dynamic WEP keys..

> ...Meanwhile.  It's foolish to ignore the 802.11 MLME.  It lists out
> pretty much everything that's necessary to get a working connection, and
> looking at its evolution (and changes in the pipeline) shows that it's
> impossible to do it all (right) the first time, and that changes, not
> just additions, will be necessary.

There are non-standard WLAN security protocols (look at Cisco) and one
needs to keep in mind that just looking at 802.11 MLME may not cover all
cases that, in practice, have to be supported.. Anyway, I agree that
MLME primitives do change and there will be new commands needed to cover
needs of future amendments to 802.11 (see, e.g., 802.11r and 802.11w
drafts).

-- 
Jouni Malinen                                            PGP id EFC895FA
