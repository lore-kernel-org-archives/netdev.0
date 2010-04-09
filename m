From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: HTB - What's the minimal value for 'rate' parameter?
Date: Fri, 9 Apr 2010 23:26:57 +0200
Message-ID: <20100409212657.GA3560@del.dom.local>
References: <z2q298f5c051004080407r5dfb27fai74c5cf74d0048ca5@mail.gmail.com>
 <4BBE4BB4.1060209@gmail.com>
 <i2k298f5c051004090840y7e47a53eqd17b0685088551ac@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net,
	devik@cdi.cz
To: Antonio Almeida <vexwek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f223.google.com ([209.85.220.223]:64869 "EHLO
	mail-fx0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757371Ab0DIV1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 17:27:05 -0400
Received: by fxm23 with SMTP id 23so3108393fxm.21
        for <netdev@vger.kernel.org>; Fri, 09 Apr 2010 14:27:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <i2k298f5c051004090840y7e47a53eqd17b0685088551ac@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 09, 2010 at 04:40:44PM +0100, Antonio Almeida wrote:
> So, what about the rate limit miss?
> As you can see the ceil of class 1:2 is set to 4096Kbit but its
> sending rate is actually 8071Kbit!
> It looks like classes 1:10 and 1:11 are ignoring hierarchical rate
> restrictions of class 1:2
> Here:
> class htb 1:2 parent 1:1 rate 4096Kbit ceil 4096Kbit burst 3655b cburst 3655b
>  Sent 84285894 bytes 55671 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 8071Kbit 666pps backlog 0b 0p requeues 0
>  lended: 0 borrowed: 0 giants: 0
>  tokens: -937499999 ctokens: -937499999

Yes, since 1:2 has grandchildren with overflown rate tables, they
could behave as if they had set rates higher than their parents or
grandparent (and HTB doesn't restrict it hierarchically).

Jarek P.
