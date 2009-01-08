From: Michael Stone <michael@laptop.org>
Subject: Re: [PATCH] Security: Implement and document RLIMIT_NETWORK.
Date: Wed, 7 Jan 2009 22:34:54 -0500
Message-ID: <20090108033454.GK3164@didacte.laptop.org>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <1231307334-9542-2-git-send-email-michael@laptop.org> <20090107114703.GB28161@ioremap.net> <20090107210758.GH3164@didacte.laptop.org> <alpine.LRH.1.10.0901081057430.10976@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.laptop.org ([18.85.2.145]:50985 "EHLO mail.laptop.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752350AbZAHDez (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 22:34:55 -0500
Received: from didacte.laptop.org (dhcp-47-72.media.mit.edu [18.85.47.72])
	by mail.laptop.org (Postfix) with SMTP id F3A7E23B6B
	for <netdev@vger.kernel.org>; Wed,  7 Jan 2009 22:34:55 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <alpine.LRH.1.10.0901081057430.10976@tundra.namei.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 08, 2009 at 12:22:17PM +1100, James Morris wrote:
>Have you considered utilizing network namespaces [1] ?  A process created 
>with a private network namespace has no network interfaces configured, 
>except loopback, which is down.  Does this do what you want?  The launcher 
>could optionally allow local IP by bringing up the loopback interface.

James,

This net-namespaces work sounds quite apropos to some of my other
projects but I'm having trouble figuring out whether it can be used to
solve my current problem. Two questions which immediately occur to me
include:

  1) As with the netfilter suggestions provided by Andi and Evgeniy, it
  seems that processes require special privileges (e.g. CAP_NET_ADMIN) in
  order to drop network privileges by means of entering a new net
  namespace. Is this correct? If so, why is it necessary or appropriate?

  2) What happens if I call unshare(CLONE_NEWNET) after I've bound some
  sockets to an address or connected some sockets to remote endpoints?

Perhaps you can help straighten me out, e.g. by pointing me at the
relevant code?

Thanks very much,

Michael
