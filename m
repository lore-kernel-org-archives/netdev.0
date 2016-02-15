From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 1/3] lwtunnel: autoload of lwt modules
Date: Mon, 15 Feb 2016 17:32:09 +0100
Message-ID: <20160215173209.055b7b6b@griffin>
References: <1455550923-23673-1-git-send-email-rshearma@brocade.com>
	<1455550923-23673-2-git-send-email-rshearma@brocade.com>
	<20160215170232.5f73b111@griffin>
	<56C1FB30.8090005@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Tom Herbert <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Robert Shearman <rshearma@Brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45485 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752455AbcBOQcP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2016 11:32:15 -0500
In-Reply-To: <56C1FB30.8090005@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Feb 2016 16:22:08 +0000, Robert Shearman wrote:
> Yeah, it's the C preprocessor. MODULE_ALIAS_RTNL_LWT includes the string 
> for the encap type in the module alias, and since the LWT encap types 
> are defined as enums this is symbolic name. I can't see any way of 
> getting the preprocessor to convert 
> MODULE_ALIAS_RTNL_LWT(LWTUNNEL_ENCAP_MPLS) into "rtnl-lwt-MPLS", but I'm 
> open to suggestions.

MODULE_ALIAS_RTNL_LWT(MPLS)?

But whatever, as I said, no strong preference.

> True, but I figured that it was cleaner for the lwtunnel infra to not 
> assume whether how those modules are implemented. If you disagree, then 
> I can change to doing as you suggest.

It's not completely transparent to the infrastructure anyway, the
tunnel type needs to be added to lwtunnel_encap_str for new tunnels.
The way I suggested, it's only added for those tunnels having the
module alias set.

Just trying to get rid of the unnecessary strings in
lwtunnel_encap_str. There's no need to bloat kernel with them if
they're never used.

 Jiri

-- 
Jiri Benc
