From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [iproute PATCH v3 0/6] Big C99 style initializer rework
Date: Fri, 24 Jun 2016 09:17:07 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4E3E8D@AcuExch.aculab.com>
References: <1466703254-5174-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Phil Sutter' <phil@nwl.cc>,
	Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.194]:50544 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750996AbcFXJT3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 05:19:29 -0400
In-Reply-To: <1466703254-5174-1-git-send-email-phil@nwl.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter
> Sent: 23 June 2016 18:34
>
> This is v3 of my C99-style initializer related patch series.
...

It would be interesting to know how this affect the kernel code size?

While gcc will generate a memset() call for 'struct foo = {0}' if you
initialise some members it might generate explicit zeroing instructions
for all the other words of the structure.

I've seen gcc use memset() to zero the end of a structure, it may use
memset() for large gaps earlier in the structure.

But if you initialise a byte half way down you are very unlikely to
get a single memset() and then a write to the single location.

	David
