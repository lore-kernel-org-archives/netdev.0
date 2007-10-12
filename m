From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFD] iptables:  mangle table obsoletes filter table
Date: Fri, 12 Oct 2007 14:31:35 +0200
Message-ID: <470F6927.9040505@trash.net>
References: <200710120031.42805.a1426z@gawab.com> <200710120837.18152.a1426z@gawab.com> <470F5F19.70606@trash.net> <200710121525.44510.a1426z@gawab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Al Boldi <a1426z@gawab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57050 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846AbXJLMcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 08:32:11 -0400
In-Reply-To: <200710121525.44510.a1426z@gawab.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Al Boldi wrote:
>>>The problem is that people think they are safe with the filter table,
>>>when in fact they need the prerouting chain to seal things.  Right now
>>>this is only possible in the mangle table.
>>
>>Why do they need PREROUTING?
> 
> 
> Well, for example to stop any transient packets being forwarded.  You could 
> probably hack around this using mark's, but you can't stop the implied route 
> lookup, unless you stop it in prerouting.


This also works fine in FORWARD with a little extra overhead.
If you really have to save resources, you should use PREROUTING/raw
to also avoid the creation of a connection tracking entry.

