From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: proposal for new wireless configuration API
Date: Wed, 16 Aug 2006 08:51:01 +0200
Message-ID: <1155711061.3600.6.camel@ux156>
References: <1155655728.17742.30.camel@ux156>
	 <1155659387.3005.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:32219 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750865AbWHPGum
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 02:50:42 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1155659387.3005.15.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-15 at 12:29 -0400, Dan Williams wrote:

> We might want to take the time to fix up a few of the ambiguities of
> WEXT that we've encountered over the past few years:

Yes, I definitely agree.

> o Separate attributes for signal strength units; signed integer type for
> dBm, unsigned integer type for RSSI.  One 8-bit var to represent both is
> just too confusing for people, evidently (which is true...)

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
