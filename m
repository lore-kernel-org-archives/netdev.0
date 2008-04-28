From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: 2.6.25: Weird IPv4 stack behaviour, IPv6 is fine
Date: Mon, 28 Apr 2008 13:00:22 +0100
Message-ID: <20080428120022.GB1011@flint.arm.linux.org.uk>
References: <48157685.1040709@openvz.org> <20080428093130.GA1011@flint.arm.linux.org.uk> <20080428101835.GA13522@flint.arm.linux.org.uk> <20080428.033022.166259760.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xemul@openvz.org, netdev@vger.kernel.org, netfilter@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:33905 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763309AbYD1MAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 08:00:39 -0400
Content-Disposition: inline
In-Reply-To: <20080428.033022.166259760.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 28, 2008 at 03:30:22AM -0700, David Miller wrote:
> From: Russell King <rmk@arm.linux.org.uk>
> Date: Mon, 28 Apr 2008 11:18:35 +0100
> 
> > Further to this, it's looking like there's a nf_conntrack issue.  Having
> > placed similar printks in the netfilter code, I see the ipv4_confirm()
> > hook normally returning 1 (NF_ACCEPT), but then decides to return 0
> > (NF_DROP) and no ping replies.
> 
> There's already been a report about specific hashing problems with
> conntrack on ARM.  It has something to do with how structures are
> padding on ARM combined with the following patch made by Patrick:
> 
> commit 0794935e21a18e7c171b604c31219b60ad9749a9
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Thu Jan 31 04:40:52 2008 -0800

Yup, reverting that appears to fix the problem.  Looking at the
structure, it will contain two bytes of padding in the 'u' union
and another two bytes in the 'dst' structure.

I suspect there'll be objections to packing the structure, in which
case what's the permanent fix?

-- 
Russell King
