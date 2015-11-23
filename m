From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Mon, 23 Nov 2015 07:43:07 -0500
Message-ID: <20151123124307.GA24663@oracle.com>
References: <1448054520-1464587-1-git-send-email-tom@herbertland.com>
 <1448272388.3983270.447381049.07BA3A5C@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org, kernel-team@fb.com, davewatson@fb.com,
	alexei.starovoitov@gmail.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:51807 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112AbbKWMnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 07:43:24 -0500
Content-Disposition: inline
In-Reply-To: <1448272388.3983270.447381049.07BA3A5C@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (11/23/15 10:53), Hannes Frederic Sowa wrote:
> > 
> >  - Integration with TLS (TLS-in-kernel is a separate initiative).
> 
> This is interesting:
> 
> Regarding the last week's discussion about better OOB support in TCP
> e.g. for SOCKET_DESTROY, do you already have a plan to handle TLS alerts
> and do CHANGE_CIPHER on the socket synchronously?

I have had that same question too. In fact I pointed this out already
in the thread at http://permalink.gmane.org/gmane.linux.network/382278

In addition to CCS, TLS does other complex things such as mid-session
regeneration of new session keys based on the master-secret. If you
move TLS to the kernel, there may be a lot of 
synchronicity/security/inter-op issues to resolve.

Perhaps it's not a good idea to use "TLS" on the TCP socket, but let
each kcm application negotiate a crypto key (in any manner that it wants) 
and set it on the PF_KCM socket, then use that key to encrypt application
data just before passing it off to tcp. (Of course, then you have to deal 
with the fact that BPF still needs to get to the clear data somehow)

--Sowmini
