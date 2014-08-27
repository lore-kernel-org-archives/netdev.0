From: Fernando Gont <fgont@si6networks.com>
Subject: Re: [RFC PATCH net-next] ipv6: stop sending PTB packets for MTU <
 1280
Date: Wed, 27 Aug 2014 17:33:10 -0300
Message-ID: <53FE4086.8040708@si6networks.com>
References: <53F39E50.1020209@gont.com.ar>	 <1409005545-24910-2-git-send-email-hagen@jauu.net> <1409006842.6274.69.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web01.jbserver.net ([37.72.100.182]:53419 "EHLO
	web01.jbserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935499AbaH0VCK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 17:02:10 -0400
In-Reply-To: <1409006842.6274.69.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/2014 07:47 PM, Hannes Frederic Sowa wrote:
> Hi Hagen,
> 
> On Di, 2014-08-26 at 00:25 +0200, Hagen Paul Pfeifer wrote:
>> Reduce the attack vector and stop generating ICMPv6 packet to big for
>> packets smaller then the minimal required IPv6 MTU.
>>
>> See
>> http://tools.ietf.org/html/draft-gont-6man-deprecate-atomfrag-generation-00
> 
> I wonder if we should wait until this gets RFC status?
> 
> I very much welcome this decision! I already raised this problem some
> time ago:
> http://lists.openwall.net/netdev/2013/12/31/17

FWIW, this issue you reported is related, but different from the one
I've described. The one I've described is based on sending ICMPv6
PTB<1280.   RFC2460 states that when you receive an ICMPv6 PTB<1280 you
should add a Fragment Header to all packets sent to that destination
(i.e., produce the so called "IPv6 atomic fragments").

These "atomic fragments" have an offset=0, and MF=0 -- i.e., they are
not really fragmented.

Hence the trivial way to mitigate this attack is to drop incoming ICMPv6
PTB1280 (or, at the very least, don't react to them by sending all
subsequent packets with a Fragment Header).

Thanks!

Best regards,
-- 
Fernando Gont
SI6 Networks
e-mail: fgont@si6networks.com
PGP Fingerprint: 6666 31C6 D484 63B2 8FB1 E3C4 AE25 0D55 1D4E 7492
