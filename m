From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2] net: suppress warnings on dev_alloc_skb
Date: Thu, 19 May 2016 10:39:50 -0700
Message-ID: <1463679590.18194.207.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463585124-13086-1-git-send-email-nhorman@tuxdriver.com>
	 <1463671854-26829-1-git-send-email-nhorman@tuxdriver.com>
	 <1463672936.18194.195.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160519173412.GG4128@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33148 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751646AbcESRjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 13:39:53 -0400
Received: by mail-pf0-f194.google.com with SMTP id y7so8785200pfb.0
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 10:39:53 -0700 (PDT)
In-Reply-To: <20160519173412.GG4128@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-05-19 at 13:34 -0400, Neil Horman wrote:
> On Thu, May 19, 2016 at 08:48:56AM -0700, Eric Dumazet wrote:
> > On Thu, 2016-05-19 at 11:30 -0400, Neil Horman wrote:
> > > Noticed an allocation failure in a network driver the other day on a 32 bit
> > > system:
> > 
> > Presumably driver could fall back to HIGH memory allocation for the page
> > frag.
> > 
> Is that safe on a 32 bit system?
> Neil

This should be.

Unless a bug somewhere was added, since most dev are using 64bit kernels
these days.

All frag consumers use the appropriate kmap_atomic()/kunmap_atomic()
pairs before copying data from a page frag. Meaning the page can be in
HIGH memory.
