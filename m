From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] smsc95xx: fix suspend buffer overflow
Date: Wed, 28 Nov 2012 20:54:26 -0800
Message-ID: <1354164866.29762.24.camel@joe-AO722>
References: <1354022623-7317-1-git-send-email-steve.glendinning@shawell.net>
	 <1354038178.8028.0.camel@joe-AO722>
	 <CAKh2mn4pJG-F4zxpBj3MmRSNSV1Gwnxjw=kvfD0xqqYxErdEHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	netdev <netdev@vger.kernel.org>,
	Dan Carpenter <dan.carpenter@oracle.com>
To: Steve Glendinning <steve@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:37289 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751062Ab2K2Ey2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2012 23:54:28 -0500
In-Reply-To: <CAKh2mn4pJG-F4zxpBj3MmRSNSV1Gwnxjw=kvfD0xqqYxErdEHg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-28 at 18:06 +0000, Steve Glendinning wrote:
> that filter code isn't pretty!  If you have time
> to knock up a patch I'd be happy to test it.

Looking a bit at the code, I don't know how it's supposed to work.

This function seems broken:

static u16 smsc_crc(const u8 *buffer, size_t len, int filter)
{
        return bitrev16(crc16(0xFFFF, buffer, len)) << ((filter % 2) * 16);
}

It always returns 0 when filter is odd.

I imagine 2 things:
o It should return u32
o when multiple WAKE_<foo> flags are set,
  the code doesn't work properly.
