From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 8/9] net: ipmr: rearrange and cleanup
 setsockopt
Date: Mon, 23 Nov 2015 11:49:02 +0100
Message-ID: <5652EF1E.6090108@cumulusnetworks.com>
References: <1448117852-4254-1-git-send-email-razor@blackwall.org>
 <1448117852-4254-9-git-send-email-razor@blackwall.org>
 <CAHA+R7MO7OSjSTei7pSCZWmJzXNQqS8vPc0Z2fEz_m2vKvkd+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Cong Wang <cwang@twopensource.com>,
	Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:34200 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbbKWKtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 05:49:06 -0500
Received: by wmvv187 with SMTP id v187so154274955wmv.1
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 02:49:05 -0800 (PST)
In-Reply-To: <CAHA+R7MO7OSjSTei7pSCZWmJzXNQqS8vPc0Z2fEz_m2vKvkd+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/23/2015 06:44 AM, Cong Wang wrote:
> On Sat, Nov 21, 2015 at 6:57 AM, Nikolay Aleksandrov
> <razor@blackwall.org> wrote:
>>  net/ipv4/ipmr.c | 191 +++++++++++++++++++++++++++++++-------------------------
>>  1 file changed, 107 insertions(+), 84 deletions(-)
> 
> Does this really simplify the code? :-/
> 
Did I really say it does ? :-) Now, to the point it just makes it
much easier to reason about this setsockopt which was doing conditional
locking in some of the cases before, and some were left out, also "v"
was sometimes signed and sometimes unsigned, it's clearer now which type
is used. I've left a comment why the only special case needs to unlock
rtnl (MRT_DONE).
