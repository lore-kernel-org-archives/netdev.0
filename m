From: Sami Farin <safari-kernel@safari.iki.fi>
Subject: Re: [PATCH][IPv6]: Fix incorrect length check in rawv6_sendmsg()
Date: Fri, 30 Mar 2007 01:45:42 +0300
Message-ID: <20070329224542.dqditwbky7ullnkp@m.safari.iki.fi>
References: <1175203048.16183.14.camel@w-sridhar2.beaverton.ibm.com> <20070329.142644.70222545.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout4-sn2.hy.skanova.net ([81.228.8.154]:60412 "EHLO
	pne-smtpout4-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964873AbXC2Xzc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 19:55:32 -0400
Received: from safari.iki.fi (80.223.106.128) by pne-smtpout4-sn2.hy.skanova.net (7.2.075)
        id 45B6216900375A04 for netdev@vger.kernel.org; Fri, 30 Mar 2007 00:45:44 +0200
Content-Disposition: inline
In-Reply-To: <20070329.142644.70222545.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 29, 2007 at 14:26:44 -0700, David Miller wrote:
> From: Sridhar Samudrala <sri@us.ibm.com>
> Date: Thu, 29 Mar 2007 14:17:28 -0700
> 
> > The check for length in rawv6_sendmsg() is incorrect.
> > As len is an unsigned int, (len < 0) will never be TRUE.
> > I think checking for IPV6_MAXPLEN(65535) is better.
> > 
> > Is it possible to send ipv6 jumbo packets using raw
> > sockets? If so, we can remove this check.
> 
> I don't see why such a limitation against jumbo would exist,
> does anyone else?
> 
> Thanks for catching this Sridhar.  A good compiler should simply
> fail to compile "if (x < 0)" when 'x' is an unsigned type, don't
> you think :-)

gcc warns if you use -W or -Wextra (but not if only -Wall is used):

* An unsigned value is compared against zero with '<' or '>='.

-- 
Do what you love because life is too short for anything else.

