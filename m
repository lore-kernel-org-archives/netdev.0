From: Xi Wang <xi.wang@gmail.com>
Subject: Re: [PATCH v2] rps: fix insufficient bounds checking in store_rps_dev_flow_table_cnt()
Date: Fri, 23 Dec 2011 00:10:04 -0500
Message-ID: <ACB00AE8-CFEF-4535-9242-1B5C44F05C13@gmail.com>
References: <1324493459-19764-1-git-send-email-xi.wang@gmail.com> <4EF3BEBA.4040402@gmail.com> <1324613414.2674.2.camel@edumazet-laptop> <C0DC969A-A32B-4CC8-B565-FF741E9D75DA@gmail.com> <1324616007.2674.8.camel@edumazet-laptop>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:41547 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108Ab1LWFKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 00:10:09 -0500
Received: by iaeh11 with SMTP id h11so14532932iae.19
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2011 21:10:08 -0800 (PST)
In-Reply-To: <1324616007.2674.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 22, 2011, at 11:53 PM, Eric Dumazet wrote:
> All I wanted to say is that while mixing INT_MAX/ULONG_MAX, you could
> have spotted the other bug in the code :
> 
> unsigned int count;
> 
> count = simple_strtoul(buf, &endp, 0);

Are you suggesting to change the type of "count" to unsigned long?
That seems like a separate issue from the bounds checking part.

I don't see the possible 32-bit truncation here is a serious issue though.
The user could even echo "128abc" into rps_flow_cnt and simple_strtoul()
would be happy to pick 128.

- xi
