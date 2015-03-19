From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: Re: [PATCH v1 net-next] tuntap: convert to 64-bit interface statistics
Date: Thu, 19 Mar 2015 19:52:04 -0400
Message-ID: <550B6124.7070001@cumulusnetworks.com>
References: <1426794689-29943-1-git-send-email-jtoppins@cumulusnetworks.com>	 <1426801109.25985.8.camel@edumazet-glaptop2.roam.corp.google.com>	 <550B4619.6020203@cumulusnetworks.com> <1426805764.25985.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Curt Brune <curt@cumulusnetworks.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:34970 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342AbbCSXwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 19:52:05 -0400
Received: by qgew92 with SMTP id w92so4646956qge.2
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2015 16:52:04 -0700 (PDT)
In-Reply-To: <1426805764.25985.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/19/15 6:56 PM, Eric Dumazet wrote:
> On Thu, 2015-03-19 at 17:56 -0400, Jonathan Toppins wrote:
>
>
>> Or are you suggesting per-cpu counters would be preferred which would
>> possibly eliminate the need for this lock?
>
> Might be overkill for a device that is probably used by one cpu,
> considering you defined a full  struct rtnl_link_stats64, instead of the
> fields that are really handled.
>

Ok. So summarizing for v2, so far; eliminating the back-to-back lock -> 
release -> lock -> release is preferred (I agree with this).

It still seems like you are not a huge fan of the additional lock, 
should I hold off on sending v2 for a day, so we can ponder alternatives?
