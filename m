From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: Re: Re: Re: [bisected regression] e1000e: "Detected Hardware Unit Hang"
Date: Thu, 15 Jan 2015 18:04:06 +0100
Message-ID: <1837410.pEGIH05mML@storm>
References: <1719052.SGOfRAJhfQ@storm> <3089325.gjrPpo2XX1@storm> <1421337658.11734.76.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7Bit
Cc: 'Linux Netdev List' <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:57123 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753124AbbAOREL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 12:04:11 -0500
In-Reply-To: <1421337658.11734.76.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, 15. January 2015 08:00:58 Eric Dumazet wrote:
> Please apply this patch, and try to lower
> /proc/sys/net/core/gro_max_frags and see if this makes a difference
> (leaving GRO enabled)
> 
> (start with 7 and increase it, limit being 17)

Patch applied to 3.19-rc4+.

Results:
 7: hang
 8: hang
 9: hang
10: hang
11: hang
12: hang
13: hang
14: hang
15: hang
16: hang
17: hang

for the sake of completeness:
1: hang
2: hang
3: hang
4: hang
5: hang
6: hang

Regarding the test procedure: I stopped the download script on the client,
changed gro_max_frags and started the download again. No cable unplugging / 
reboot of the box in between. Just mentioning it to make sure it somehow 
does not affect what we actually wanted to test.

Additional tests have been done with gro_max_frags 1, 7 and 17:
- stop networking + unload e1000e -> restart -> download: hang

One thing I can say from the testing: The more I increase gro_max_frags,
the longer it takes to trigger it. I tried each setting below three times.
A value of 17 is really noticeable.

1: 3-8 seconds till hang
7: 7-10 seconds till hang
17: 23-26 seconds till hang

Thomas
