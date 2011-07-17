From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: problem with function vlan_get_protocol()
Date: Sun, 17 Jul 2011 09:34:04 +0200
Message-ID: <20110717073404.GA6786@electric-eye.fr.zoreil.com>
References: <201107171253127340006@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: "jiangtao.jit" <jiangtao.jit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:32833 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752130Ab1GQHtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2011 03:49:00 -0400
Content-Disposition: inline
In-Reply-To: <201107171253127340006@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jiangtao.jit <jiangtao.jit@gmail.com> :
[...]
> do we need an else branch on pointer protop failed ?  through the else is unlikely 
> 
> 	if (likely(protop))
> 		protocol = *protop;
>     else
> 		protocol = proto;
> 
> is it necessary ?

The else branch signals that skb_header_pointer uncloaked a really tiny
ethernet frame : the content of proto is not even initialized (stack
allocation), whence irrelevant. In such circumstances the default
initialization value of protocol (0) does not seem too bad.

-- 
Ueimor
