From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH WAS( Re: [ANNOUNCE] iproute2 v2.6.25
Date: Mon, 21 Apr 2008 09:07:07 -0400
Message-ID: <1208783227.12249.172.camel@localhost>
References: <20080417103858.0075236b@extreme>
	 <1208464539.15888.22.camel@localhost> <20080417134656.761748d4@extreme>
	 <1208465951.15888.33.camel@localhost>  <20080417140837.1e92b449@extreme>
	 <1208467480.15888.50.camel@localhost> <1208522727.4422.79.camel@localhost>
	 <4808AEBF.7040504@trash.net> <1208563696.4450.43.camel@localhost>
	 <480A21AF.1040405@trash.net> <1208692128.12249.26.camel@localhost>
	 <480C7F68.7090105@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.186]:13866 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756305AbYDUNHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 09:07:22 -0400
Received: by gv-out-0910.google.com with SMTP id s4so57917gve.37
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2008 06:07:21 -0700 (PDT)
In-Reply-To: <480C7F68.7090105@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-21-04 at 13:50 +0200, Patrick McHardy wrote:


> I just noticed the libnl example code already supports this:
> 
> $ ./nl-link-dump env dev eth0
> LINK_NAME=eth0
> LINK_IFINDEX=2
> LINK_FAMILY=unspec
> LINK_TYPE=ether
> ...
> 
> I wouldn't duplicate it for iproute, but rather complete the
> libnl support (I think some object types are still missing
> ENV dump format support) and tell people to use that for
> scripting.

Sounds sensible.
It would be useful to probably port iproute2 to use libnl. Or something
new that provides iproute2 input/output.

on libnl (CC Thomas):
I havent looked at libnl in a long time; it is certainly the right
direction forward - my main contention with it (which i mentioned to
Thomas) is it has too many knobs/hooks. Last conversation we had he told
me it is optional for me to use all those knobs. For a geek that may not
be sufficient answer: if you give me a swiss army knife i need to know
what everything does ;->
Once you go that path network code that provides callbacks in more than
send/recv as well as statefulness (like caching runtime objects which
libnl did when i looked) then you no longer pass the smell-test for
"library" - you are into "framework" domain[1] - which requires more
steep knowledge of the framework to bypass mechanisms provided to you
that you dont like. I tried to port some app back then from libnetlink
to libnl and found it to be extra curve-climbing and abandoned it; i
will revisit at some point.

cheers,
jamal
[1] Python twisted for example falls under "framework"

