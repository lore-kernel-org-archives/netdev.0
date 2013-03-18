From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: Who/What is supposed to remove IPv6 address from interface when
 moving from one network to another ?
Date: Mon, 18 Mar 2013 21:49:37 +0100 (CET)
Message-ID: <alpine.DEB.2.00.1303182143050.2309@uplift.swm.pp.se>
References: <CAF6-1L4=xACZdqvJ6AZL4XkY17N0pC9PnPfNfK9Tk7QB47c1tw@mail.gmail.com>  <CAF6-1L5cxguK8tHxjMACZJ8xNmAXLLXwP086eF4_SEctZdiZ3g@mail.gmail.com>  <1363290495.1643.29.camel@dcbw.foobar.com>  <CAKD1Yr1=1kfcSmRYgnrYQBhNPPc=nquB2c1jLbopbvqz848cxQ@mail.gmail.com>
  <1363626191.6437.2.camel@dcbw.foobar.com>  <CAF6-1L7De=QQz9YnRxqovnoxzfR0WHnQ-Fi4T_LZ+j9s=oQWyA@mail.gmail.com>  <CAKD1Yr1Dd0ngiB0WhEQCjCrrEVrtqs9VuHPWukCdupkfLWjqaQ@mail.gmail.com>  <CAF6-1L7Von88pAhHzhyaJiL8x4w9cNpJw+k+0Giu5Jh-fYJ37g@mail.gmail.com>
 <1363639366.7698.10.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: Sylvain Munaut <s.munaut@whatever-company.com>,
	Lorenzo Colitti <lorenzo@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swm.pp.se ([212.247.200.143]:43555 "EHLO uplift.swm.pp.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753347Ab3CRU7I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Mar 2013 16:59:08 -0400
In-Reply-To: <1363639366.7698.10.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 Mar 2013, Dan Williams wrote:

> While I'm not an IPv6 expert I would actually expect the kernel to stop 
> using any IPv6 address or route that had expired, and that was *added 
> automatically* by the kernel as a result of a router advertisement. 
> Perhaps that's not how it actually works, but would be nice to hear from 
> some kernel IPv6 people why that's not how it works, if that's the case.

It's my experience that the kernel doesn't detect link-down events and do 
anything useful with that information. When I have asked about this, I get 
server-usage scenarios and people don't want the kernel to do anything.

In older Ubuntu, when moving between wifis with different IPv6 subnets on 
them, you after a while were sitting there with IPv6 addresses from 
several different subnets, of which just one worked. Fail. I believe 
enhancements in the connection manager fixed this, because from 12.04 or 
something, this is not a problem anymore. When eth0 or wlan0 goes down, so 
IPv6 addresses and default routes go away just like the IPv4 equivalents.

Before the IPv4 equivalents went away on link-down but IPv6 was on 
autopilot by kernel seeing RAs and they stayed there long after they 
overspent their welcome.

So, my opinion is that the connection manager needs to take care of this, 
because the kernel doesn't do it (intentionally, by design).

I'm sure the kernel will stop using addresses after they expire, but that 
doesn't happen when a link goes down.

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
