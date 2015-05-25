From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: skip fdb add if the port shouldn't learn
Date: Mon, 25 May 2015 13:41:20 +0200
Message-ID: <CABQ03vG0FG5qs9EwjAeKoZv2k2Eez58v6oEjj4HoHY8wN8s34g@mail.gmail.com>
References: <1432204977-4293-1-git-send-email-nikolay@cumulusnetworks.com>
	<20150524.225902.2017701461230237731.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Wilson Kok <wkok@cumulusnetworks.com>,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:34779 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751638AbbEYLlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 07:41:21 -0400
Received: by igbhj9 with SMTP id hj9so35868607igb.1
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 04:41:20 -0700 (PDT)
In-Reply-To: <20150524.225902.2017701461230237731.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 25, 2015 at 4:59 AM, David Miller <davem@davemloft.net> wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Date: Thu, 21 May 2015 03:42:57 -0700
>
>> From: Wilson Kok <wkok@cumulusnetworks.com>
>>
>> Check in fdb_add_entry() if the source port should learn, similar
>> check is used in br_fdb_update.
>> Note that new fdb entries which are added manually or
>> as local ones are still permitted.
>> This patch has been tested by running traffic via a bridge port and
>> switching the port's state, also by manually adding/removing entries
>> from the bridge's fdb.
>>
>> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> ---
>> Nik: Maybe it'd be better if we returned an error even though it
>>      doesn't look necessary. I'm open to suggestions.
>
> If you don't return an error, then rtnetlink.c is going to emit a
> NEWNEIGH netlink message.  I seriously doubt we want that to happen.

Thanks Dave, I was afraid I've missed something like that. I'll re-spin, test
and post a v2.

Nik
