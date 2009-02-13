From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: WARNING: at net/core/skbuff.c:154 with tcpdump and ipsec
Date: Fri, 13 Feb 2009 20:24:48 +0100
Message-ID: <20090213192448.GA2929@ami.dom.local>
References: <20090213121424.GA8717@ff.dom.local> <4995C241.1030507@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krzysztof Oledzki <ole@ans.pl>,
	Marco Berizzi <pupilla@hotmail.com>, netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:37957 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001AbZBMTYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2009 14:24:16 -0500
Received: by bwz5 with SMTP id 5so1960085bwz.13
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2009 11:24:14 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4995C241.1030507@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 13, 2009 at 01:56:01PM -0500, Vlad Yasevich wrote:
...
> I did notice that pskb_expand_head() doesn't change the skb->truesize even
> though it could grow the skb.  I saw this problem with tcpdump while
> experimenting with some SCTP code.
> 
> This is not to say that it is the problem in this case, but it's one of
> them that I've seen.

Yes, I've read Herbert Xu's message pointing especially to
xfrm_state_check_space(). So I would like to make sure if there is no
other reason it triggers in packet_recvmsg() on these several reports.

If af_packet code is OK, I guess we could update truesize for it:
there is no reason to warn here about bugs from other, well known
places.

Jarek P.
