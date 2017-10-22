From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: [jkirsher/net-queue PATCH] i40e: Add programming descriptors to
 cleaned_count
Date: Mon, 23 Oct 2017 01:15:00 +0200
Message-ID: <003ecf6b-bd50-51fa-79a7-eab2b100257b@itcare.pl>
References: <20171022011222.12997.53593.stgit@localhost.localdomain>
 <1508695307.4970.32.camel@cohaesio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
To: "Anders K. Pedersen | Cohaesio" <akp@cohaesio.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp12.iq.pl ([86.111.240.243]:52574 "EHLO smtp12.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932120AbdJVXPA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 22 Oct 2017 19:15:00 -0400
In-Reply-To: <1508695307.4970.32.camel@cohaesio.com>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes can confirm that after adding patch:

[jkirsher/net-queue PATCH] i40e: Add programming descriptors to 
cleaned_count


There is no memleak.



W dniu 2017-10-22 o 20:01, Anders K. Pedersen | Cohaesio pisze:
> On lør, 2017-10-21 at 18:12 -0700, Alexander Duyck wrote:
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>>
>> This patch updates the i40e driver to include programming descriptors
>> in
>> the cleaned_count. Without this change it becomes possible for us to
>> leak
>> memory as we don't trigger a large enough allocation when the time
>> comes to
>> allocate new buffers and we end up overwriting a number of rx_buffers
>> equal
>> to the number of programming descriptors we encountered.
>>
>> Fixes: 0e626ff7ccbf ("i40e: Fix support for flow director programming
>> status")
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> This patch solves the remaining memory leak we've seen, so
>
> Tested-by: Anders K. Pedersen <akp@cohaesio.com>
>
> Regards,
> Anders
