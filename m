From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] vti: remove GRE_KEY flag for vti tunnel
Date: Thu, 5 Dec 2013 11:58:57 +0100
Message-ID: <20131205105857.GV31491@secunet.com>
References: <1386146917-2951-1-git-send-email-liuhangbin@gmail.com>
 <529F2430.9050906@6wind.com>
 <20131205094741.GR1258@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christophe Gouault <christophe.gouault@6wind.com>,
	network dev <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:54074 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752658Ab3LEK7A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Dec 2013 05:59:00 -0500
Content-Disposition: inline
In-Reply-To: <20131205094741.GR1258@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 05, 2013 at 05:47:41PM +0800, Hangbin Liu wrote:
> On Wed, Dec 04, 2013 at 01:46:40PM +0100, Christophe Gouault wrote:
> > Hello Hangbin,
> > 
> > vti interfaces precisely need an o_key to be configured (it must be set
> > to the mark of ipsec policies attached to this interface). Consequently,
> > this flag must not be removed.
> 
> I saw the o_key was used here, do you mean this? I'm not clearly understand
> xfrm4_policy_check(), does it really need GRE_KEY? or any value is ok?

It does not need GRE_KEY at all, this flag is not even set on vti
tunnels. The vti key is just a mark that will be set on the skb.
It is used to match the right policy for that tunnel, so the policy
that should match must be configured to have the same mark.
