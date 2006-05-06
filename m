From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [RFC] Proposed structure for Regulatory/Geographical Wireless database
Date: Fri, 5 May 2006 18:31:25 -0700
Message-ID: <20060506013125.GL27667@instant802.com>
References: <445BB22B.30505@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Faidon Liambotis <faidon@cube.gr>,
	Rick Jones <rick.jones2@hp.com>,
	Ulrich Kunitz <kune@deine-taler.de>,
	Harald Welte <laforge@gnumonks.org>,
	Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-57.dex002.intermedia.net ([64.78.21.226]:52838 "EHLO
	dhost002-57.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1750781AbWEFBbb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 May 2006 21:31:31 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
Content-Disposition: inline
In-Reply-To: <445BB22B.30505@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 05, 2006 at 03:14:35PM -0500, Larry Finger wrote:

> * A new routine (ieee80211_init_geo ?) will be written to be called by the 
> driver to load the geo structure into the kernel. Information passed to the 
> daemon will be the country code in ASCII and whether the interface is to be 
> used indoors or outdoors.

The driver may not know the country code, so there should be mechanism
for user space to override this.

> * Checksum routines will be used to validate the data base. Such a simple 
> scheme will not inhibit anyone with moderate skills from hacking the 
> channel/power settings, but such hacking will require some effort.

I did not see this included in the example file. Did you have more
detailed plans on how this would be done?

> * Each channel in the resulting kernel data structure will have appropriate 
> flags set indicating if it is to be used indoors, outdoors, or both. In 
> addition, if the channel should be used only for passive scanning, a 
> suitable flag will be set. In the 2.4 GHz band, a flag will indicate if it 
> should be used for 802.11b, otherwise both b and g mode will be assumed. In 
> the 5.0 GHz bands, a flag will be set if the channel is to conform with 
> 802.11h or 802.11a standards.

802.11h, radar detection, and DFS may need to be more complex than just
a one-bit value of it being enabled. Countries may have different
requirements for different areas related to 802.11h..

> The database consists of two sections. The first relates the Country Codes 
> to a wireless group. The second section describes the channel parameters 
> for the groups. Shown below is a fragment showing the Country Code - Group 
> info for a few countries and the definitions for a few of the groups.

One way to compress this and possible make maintaining quite a bit
easier would be to use two different set of groups: one for 2.4 GHz band
and another one for 5 GHz band. Many countries share the same
requirements for 2.4 GHz, but have different 5 GHz requirements.. This
is not really a requirement, but could end up making this easier to use.

> Number of Countries: 100
> Number of Groups: 15

These are not really needed and unless a tool is used to update this
file, they will most likely end up being out of sync at some point ;-).
The parser can just read through the file twice if it need to know these
numbers before parsing (though, that should not really be needed with
dynamic data structures)..

> # group Country Code    Description
> #
> 1       AT              Austria (Standard EU)
> 1       DE              Germany (Standard EU)
> 2       FRI             France Indoor (Not Guyana or La Reunion)
> 3       FRO             France Outdoor (Not Guyana or La Reunion)
> 4       FR1             French Departments of Guyana and La Reunion Indoor
> 5       FR2             French Departments of Guyana and La Reunion Outdoor

Country code has to be two characters to fit into country IE..

AT and DE are a good example of possible use for different 2.4 GHz and 5
GHz groups.. If I remember correctly, they have the same rules for 2.4
GHz, but different for 5 GHz.. (unless--of course--they already changed
them since I looked last time.. ;-)

> # Ch. Range - Minimum and Maximum Channels for this range
> # Ch. Spacing - Number of channels between adjacent entries

Other option would be to use start channel and number of channels.
Channel spacing is also fixed in practice (1 for 2.4 GHz, 4 for 5 GHz),
so it may not be needed here.

> # Power in mW EIRP

I would prefer to see the maximum TX power in dBm, not mW.

> # Flag Codes
> # B - Both Indoor and Outdoor
> # I - Indoor Only
> # O - Outdoor Only
> # P - Passive Scan Only

Some more flags may need to be added in the future. It looks like the
format used here makes this trivial to extend.

-- 
Jouni Malinen                                            PGP id EFC895FA
