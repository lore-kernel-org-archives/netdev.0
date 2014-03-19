From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] ipv6: fix RTNL assert fail in DAD
Date: Tue, 18 Mar 2014 23:58:11 -0700
Message-ID: <20140318235811.0d8f230a@nehalam.linuxnetplumber.net>
References: <20140317161853.2e880469@nehalam.linuxnetplumber.net>
	<20140318002908.GF12291@order.stressinduktion.org>
	<20140318175406.78339ffe@nehalam.linuxnetplumber.net>
	<20140319.001736.730011705431992209.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:64755 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752555AbaCSG6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 02:58:15 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so8437515pbb.19
        for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 23:58:15 -0700 (PDT)
In-Reply-To: <20140319.001736.730011705431992209.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Mar 2014 00:17:36 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Tue, 18 Mar 2014 17:54:06 -0700
> 
> > On Tue, 18 Mar 2014 01:29:08 +0100
> > Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> > 
> >> I wonder if we should put the whole ipv6_ifa_notify infrastructure in a
> >> workqueue? I don't like that either and it could add subtile races.
> > 
> > That is option, might be some call chains that already have rtnl_lock held.
> 
> There are TAHI ipv6 conformance tests that expect state changes to be
> precisely synchronous.
> 
> And frankly it's pretty reasonable to send two packets back to back,
> one which causes the state change and one which tests if the state
> change happened, and expect that to work.

It is more the timer based state changes that are problematic because
they aren't acquire RTNL.
