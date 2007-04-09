From: Patrick McHardy <kaber@trash.net>
Subject: Re: two gateways with one NIC
Date: Mon, 09 Apr 2007 18:13:50 +0200
Message-ID: <461A663E.4050904@trash.net>
References: <1176003353.686.45.camel@owl.home.ie> <20070408150123.GA3511@csclub.uwaterloo.ca> <1176048615.686.78.camel@owl.home.ie> <20070408182210.GJ3508@csclub.uwaterloo.ca> <1176060547.686.95.camel@owl.home.ie> <20070409145403.GB2299@csclub.uwaterloo.ca> <1176134180.686.102.camel@owl.home.ie> <20070409161142.GC2299@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: W Agtail <wagtail@iol.ie>, netdev@vger.kernel.org
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39477 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966115AbXDIQN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 12:13:57 -0400
In-Reply-To: <20070409161142.GC2299@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lennart Sorensen wrote:
> On Mon, Apr 09, 2007 at 04:56:20PM +0100, W Agtail wrote:
> 
>>Hi there, and thanks v. much for getting back to me on this one.
>>I now have changed iptables on the web servers to the following:
>>
>>iptables -t mangle -A POSTROUTING -p tcp --sport 8088 -o eth0 -j MARK
>>--set-mark 1
>>iptables -t mangle -A POSTROUTING -p tcp --sport 8089 -o eth0 -j MARK
>>--set-mark 2
>>
>>But I'm still seeing traffic being returned via gw2 for port 8088 :(
>>Any ideas? Thanks.
> 
> 
> Hmm, I know I have done something like this before (I made all port 80
> traffic return through another host rather than the default gateway, but
> it was about 3 years ago and I don't remember the exact syntax).


As the name suggests, POSTROUTING comes after routing, so marking
packets there doesn't affect routing. Use PREROUTING for forwarded
traffic and OUTPUT for locally generated traffic.

