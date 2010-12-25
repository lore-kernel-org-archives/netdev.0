From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: [PATCH] CAN: Use inode instead of kernel address for /proc file
Date: Sat, 25 Dec 2010 17:41:44 -0500
Message-ID: <1293316904.9764.48.camel@Dan>
References: <1293315371.9764.44.camel@Dan> <4D166E9D.5080200@hartkopp.net>
	 <4D1670CC.1000709@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs.thuermann@volkswagen.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	security@kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:49870 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049Ab0LYWmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Dec 2010 17:42:08 -0500
In-Reply-To: <4D1670CC.1000709@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> One minor question:
> 
> AFAIK the inode numbers that can be found in /proc/<pid>/fd/* are in decimal
> and not in hex, right?
> 
> If so, you should use '%lu' instead of '%lx' in the patch.

Yes, that's usually how they're expressed, but I did it this way for two
reasons.  Firstly, %lu would require another change to the buffer size,
since the output could be up to 20 bytes long (plus another for the NULL
terminator).  Secondly, by expressing it as hex it avoids breaking any
userland utilities that are expecting addresses, even if no such
utilities exist.

-Dan

