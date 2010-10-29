From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH 05/15] dec netdev: relocate DIGITAL based drivers to
 legacy
Date: Fri, 29 Oct 2010 06:46:13 +0100 (BST)
Message-ID: <alpine.LFD.2.00.1010290629450.25426@eddie.linux-mips.org>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>        <1288315159-1350-6-git-send-email-paul.gortmaker@windriver.com>        <alpine.LFD.2.00.1010290516110.25426@eddie.linux-mips.org> <20101028.212939.189691515.davem@davemloft.net>
 <alpine.LFD.2.00.1010290545270.25426@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: paul.gortmaker@windriver.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:43072 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777Ab0J2FqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 01:46:18 -0400
Received: from localhost.localdomain ([127.0.0.1]:42291 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S1491016Ab0J2FqN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 07:46:13 +0200
In-Reply-To: <alpine.LFD.2.00.1010290545270.25426@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Oct 2010, Maciej W. Rozycki wrote:

> > This is not about a specific bus technology, it's simply for
> > "really old stuff" so we can declutter the top-level of drivers/net
> 
>  Hmm, what's the difference between placing these drivers here or there 
> and what's so particular about them that they cause clutter?  I mean a 
> mere high number of items does not cause a mess by itself -- the lack of 
> order might.

 I have given myself some food for thought and have come up with the 
following proposal: how about simply classifying drivers according to the 
physical layer they support or if multiple are, such as with the Ethernet 
that is backwards compatible, the newest variation they do?

 This would be no different to what we do wrt network protocols under 
net/, so drivers would go to ethernet/, fasteth/, gbeth/, 10gbeth/, fddi/, 
tokenring/, atm/, appletalk/, etc. (names up to debate if need be) as 
applicable.  This would scale well, avoid the need for arbitrary decisions 
(is this piece legacy yet or not?) and automatically classify drivers as 
more or less obsolescent too, as obviously none of the stuff under 
ethernet/, fddi/ or tokenring/ can be reasonably recent unlike 10gbeth/.

 Software stuff such as SLIP or PPP could go either into separate 
subdirectories or grouped together under software/; I gather we have a few 
such pieces only.

 What do you think?

  Maciej
