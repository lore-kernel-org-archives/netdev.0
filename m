From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [net-next PATCH] net: ipv6: use common fib_default_rule_pref
Date: Wed, 2 Sep 2015 20:46:06 +0200
Message-ID: <20150902184606.GC20527@pox.localdomain>
References: <1441198992-25359-1-git-send-email-phil@nwl.cc>
 <20150902.113439.1914221451599696711.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: phil@nwl.cc, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:35924 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755870AbbIBSqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 14:46:08 -0400
Received: by wibz8 with SMTP id z8so75529055wib.1
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 11:46:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150902.113439.1914221451599696711.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/15 at 11:34am, David Miller wrote:
> From: Phil Sutter <phil@nwl.cc>
> Date: Wed,  2 Sep 2015 15:03:12 +0200
> 
> > This switches IPv6 policy routing to use the shared
> > fib_default_rule_pref() function of IPv4 and DECnet. It is also used in
> > multicast routing for IPv4 as well as IPv6.
> > 
> > The motivation for this patch is a complaint about iproute2 behaving
> > inconsistent between IPv4 and IPv6 when adding policy rules: Formerly,
> > IPv6 rules were assigned a fixed priority of 0x3FFF whereas for IPv4 the
> > assigned priority value was decreased with each rule added.
> > 
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> 
> All ->default_pref() methods are therefore going to be set to the
> default, so just kill off the method entirely and call
> fib_default_rule_pref() directly.

How strict are we with regard to compatibility here? New IPv6 rules
with no pref specified currently get appended at the end of the list
whereas this would start inserting at the head.

I'm absolutely in favour of the new behaviour but this could break
scripts which do not have proper prefs specified.
