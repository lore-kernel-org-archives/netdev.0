From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: kernel mode pppoe ppp if + ifb + mirred redirect, ethernet packets in ifb?!
Date: Tue, 13 Oct 2009 00:54:23 +0300
Message-ID: <200910130054.23237.denys@visp.net.lb>
References: <200910121143.39924.denys@visp.net.lb> <200910121715.35676.denys@visp.net.lb> <1255381064.5406.30.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:45033 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933356AbZJLV40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 17:56:26 -0400
In-Reply-To: <1255381064.5406.30.camel@dogo.mojatatu.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't have problem with existing behaviour, since i am using other way of 
shaping, for my case using pktedit to assign priority to SKB and shaping by 
it.

But generally problem is was told by one of russian developers who is working 
on firmware for few models of broadband routers, he asked to help on ISP 
forum, and if possible to explain this to someone who can give advice, and 
maybe tell that probably there is a bug.

It is explained here (but it is russian language, i dont think worth spending 
time and translating) http://forum.nag.ru/forum/index.php?showtopic=51760
His case a bit complicated, since that ISP who provide pppoe use some kind of 
ugly, oversized packets, and as he mention they can be fragmented. I didn't 
understand exactly how it can be possible and how it can break u32 filter.

Here is one more guy who asked to help about that
http://mailman.ds9a.nl/pipermail/lartc/2007q3/021561.html

His issue that he wants to shape by ip, not by interface, and while it is 
ethernet traffic in ifb, it is not trivial. I told him just to use offset in 
u32,but he said there is case with possible packet fragmentation (not sure it 
can happen) and shaper won't match.
I am just asking to take a look, if there is any bug.
If it is not, then just simple question, it will work reliably if i just use 
u32 filter with offset on ifb?



On Monday 12 October 2009 23:57:44 jamal wrote:
> On Mon, 2009-10-12 at 17:15 +0300, Denys Fedoryschenko wrote:
> > How it can be ethernet packets (with PPPoE headers) if i am redirecting
> > from ppp interface, not ethernet interface?
>
> You are running this on ingress. If you run on egress you will see
> proper header.
> _Most people_ want to see the whole original header for qos accounting
> purposes etc. PPPOE claims to be ethernet, PPP does not. Hence
> difference in observation.
>
> We could add an override feature to say "i only want
> see what was passed not wire packet".
> If this is important to you let me know and i will try to make time to
> add it (with hopefully not breaking old scripts); if you feel brave as
> well i could guide you on how to add it.

