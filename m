From: "Simon Barber" <simon@devicescape.com>
Subject: RE: proposal for new wireless configuration API
Date: Wed, 16 Aug 2006 11:02:00 -0700
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F0165AF0E@dhost002-46.dex002.intermedia.net>
References: <1155711061.3600.6.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "Jean Tourrilhes" <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:64167 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751235AbWHPSCE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 14:02:04 -0400
Content-class: urn:content-classes:message
in-reply-to: <1155711061.3600.6.camel@ux156>
To: "Johannes Berg" <johannes@sipsolutions.net>,
	"Dan Williams" <dcbw@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'd suggest that the new signal strength measure should be defined as
'RCPI' - the 'Received Channel Power Indicator' - which is defined in
IEEE 802.11k (the Radio Measurements amendment to 802.11).  Here is the
full text of the definition from 802.11k draft 5.0:

received channel power indicator (RCPI): An indication of the total
channel power (signal, noise, and interference) of a received IEEE
802.11 frame measured on a single channel and at the antenna connector
used to receive the frame.

The RCPI indicator is a measure of the received RF power in the selected
channel for a received frame. This parameter shall be a measure by the
PHY sublayer of the received RF power in the channel measured over the
entire received frame or by other equivalent means which meet the
specified accuracy. RCPI shall be a monotonically increasing,
logarithmic function of the received power level defined in dBm. The
allowed values for the Received Channel Power Indicator (RCPI) parameter
shall be an 8 bit value in the range from 0 through 220, with indicated
values rounded to the nearest 0.5 dB as follows:

0: Power < -110 dBm
1: Power = -109.5 dBm
2: Power = -109.0 dBm

and so on where

RCPI = int{(Power in dBm +110)*2} for 0dbm > Power > -110dBm

220: Power > -0 dBm
221-254: reserved
255: Measurement not available

RCPI shall equal the received RF power within an accuracy of +/-5 dB
(95% confidence interval) within the specified dynamic range of the
receiver. The received RF power shall be determined assuming a receiver
noise equivalent bandwidth equal to the channel bandwidth multiplied by
1.1.



Simon

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Johannes Berg
Sent: Tuesday, August 15, 2006 11:51 PM
To: Dan Williams
Cc: netdev@vger.kernel.org; Jean Tourrilhes
Subject: Re: proposal for new wireless configuration API

On Tue, 2006-08-15 at 12:29 -0400, Dan Williams wrote:

> We might want to take the time to fix up a few of the ambiguities of 
> WEXT that we've encountered over the past few years:

Yes, I definitely agree.

> o Separate attributes for signal strength units; signed integer type 
> for dBm, unsigned integer type for RSSI.  One 8-bit var to represent 
> both is just too confusing for people, evidently (which is true...)

Yes, agreed, they should be separated. In general, I think that one
attribute should always have a single meaning and unit attached, except
for explicitly unit-less attributes (number of frames or whatever), or
attributes that explicitly have no stable unit (raw rssi).

> o Merge functionality ENCODE and ENCODEEXT handlers into one

Good one. I'm still not sure whether we should have an attribute for
this, or a command. The whole key business seems rather complex and it
might be good to have a command 'set key' with say a possible attribute
for the mac address of a pairwise key, a key material attribute and an
IV attribute or something. Otherwise we'll end up parsing the contents
of an attribute again, which rather sucks...

On the other hand, having it as a command won't allow the user to
optimize setting the key and other things at once. I'm not too sure we
should pay all that much attention to this problem though, it can't take
forever and typically a user with such a card won't be changing the key
or parameters all the time, hence it's usually probably done only at boo
or association time.

johannes
-
To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html
