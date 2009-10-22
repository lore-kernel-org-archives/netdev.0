From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net,socket: introduce build_sockaddr_check helper to
	catch overflow at build time
Date: Thu, 22 Oct 2009 17:55:57 +0400
Message-ID: <20091022135557.GA5162@lenovo>
References: <20091021170732.GE5976@lenovo> <20091022.044914.36401063.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:57382 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755992AbZJVNz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 09:55:57 -0400
Received: by ewy3 with SMTP id 3so604862ewy.17
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2009 06:56:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20091022.044914.36401063.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[David Miller - Thu, Oct 22, 2009 at 04:49:14AM -0700]
| From: Cyrill Gorcunov <gorcunov@gmail.com>
| Date: Wed, 21 Oct 2009 21:07:32 +0400
| 
| > net,socket: introduce build_sockaddr_check helper to catch overflow at build time
| > 
| > proto_ops->getname implies copying protocol specific data
| > into storage unit (particulary to __kernel_sockaddr_storage).
| > So when one implements new protocol he either may keep this
| > in mind (or may not).
| > 
| > Lets introduce build_sockaddr_check helper which check if
| > storage unit is not overfowed. Note that the check is build
| > time and introduce no slowdown at execution time.
| > 
| > Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
| 
| Nice idea, and I wonder if we can automate it even further.
| Perhaps some tag that gets put on the socket address type
| definition or similar?
| 

Thanks for review David! Not sure if I understand you right.
Initially I was trying to bring as minimum changes as possible.
Also I was shuffle in mind the following possibilities:

1) Since at least one .getname handler use memcpy, we could
   introduce some helper which check size (at build time) and
   then do memcpy (not optimal perhaps).


2) All handlers set *len to some size explicitly so we may
   introduce set_sockaddr_size() helper like

#define set_sockaddr_size(ptr, size)		\
	do {					\
		build_sockaddr_check(size);	\
		*ptr = size;			\
	} while (0)

Or you meant something completely different?

	-- Cyrill
