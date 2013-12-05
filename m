From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] vti: remove GRE_KEY flag for vti tunnel
Date: Thu, 5 Dec 2013 09:47:27 +0100
Message-ID: <20131205084727.GT31491@secunet.com>
References: <1386146917-2951-1-git-send-email-liuhangbin@gmail.com>
 <529F2430.9050906@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hangbin Liu <liuhangbin@gmail.com>,
	network dev <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>
To: Christophe Gouault <christophe.gouault@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51261 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751191Ab3LEIra (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Dec 2013 03:47:30 -0500
Content-Disposition: inline
In-Reply-To: <529F2430.9050906@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 04, 2013 at 01:46:40PM +0100, Christophe Gouault wrote:
> Hello Hangbin,
> 
> vti interfaces precisely need an o_key to be configured (it must be set
> to the mark of ipsec policies attached to this interface). Consequently,
> this flag must not be removed.
> 

Why do we need to set these flags in vti_tunnel_ioctl()? All we do
here, is to cheat userspace. The userspace should set these flags
to configure the tunnel. Please note that we completely ignore
the flags from userspace, instead we set our own flags.

I think the only reason why we set these flags here, is to make iproute2
to print the i_key/o_key.

I've already metntioned that I'am a bit disappointed on how the gre
keys and flags are used with vti. But I fear we need to keep it
as it is for now, because it would at least change the behaviour
of iproute2 if we remove the flags.
