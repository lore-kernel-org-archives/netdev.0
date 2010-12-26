From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] CAN: Use inode instead of kernel address for /proc file
Date: Sun, 26 Dec 2010 12:29:15 +0100
Message-ID: <4D17270B.5000204@hartkopp.net>
References: <1293315371.9764.44.camel@Dan> <4D166E9D.5080200@hartkopp.net>	 <4D1670CC.1000709@hartkopp.net> <1293316904.9764.48.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs.thuermann@volkswagen.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	security@kernel.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:49348 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751794Ab0LZL3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Dec 2010 06:29:18 -0500
In-Reply-To: <1293316904.9764.48.camel@Dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25.12.2010 23:41, Dan Rosenberg wrote:
> 
>>
>> One minor question:
>>
>> AFAIK the inode numbers that can be found in /proc/<pid>/fd/* are in decimal
>> and not in hex, right?
>>
>> If so, you should use '%lu' instead of '%lx' in the patch.
> 
> Yes, that's usually how they're expressed, but I did it this way for two
> reasons.  Firstly, %lu would require another change to the buffer size,
> since the output could be up to 20 bytes long (plus another for the NULL
> terminator).

This is not *really* a good reason as the buffer size can be changed easily
within the same patch, right? ;-)

> Secondly, by expressing it as hex it avoids breaking any
> userland utilities that are expecting addresses, even if no such
> utilities exist.

I'm very sure there are no userland utilities. And if there were any, they
only would use the filename as unique identifiers and can't do anything with
the (kernel)addresses - as you already stated in the patch description. E.g.
thinking of some shell script the content of the filename is pretty useless
unless it is unique.

The recent patch for the 64 bit compatibility broke the length of the filename
anyway, so IMO there's no real reason left to write the inode number as a hex
value for the unique filename.

Indeed having it a decimal number would bring some added value as you can
reference the filename to the numbers in /proc/<pid>/fd/* easily.

Convinced? 8-)

Regards,
Oliver
