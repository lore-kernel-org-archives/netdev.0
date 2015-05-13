From: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Subject: Re: [PATCH ethtool v2 2/3] ethtool: Add copybreak support
Date: Wed, 13 May 2015 10:18:47 +0300
Message-ID: <CAJL1qvEe1FmzN7xtuuhYHM_-0Wy=dGma3aY1e6zAqUiuv5gTWg@mail.gmail.com>
References: <1412637141-3205-1-git-send-email-_govind@gmx.com>
	<1412637141-3205-3-git-send-email-_govind@gmx.com>
	<1418579187.3599.130.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>, yevgenyp@mellanox.com,
	Amir Vadai <amirv@mellanox.com>
To: Govindarajulu Varadarajan <_govind@gmx.com>,
	Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:36504 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752663AbbEMHSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 03:18:48 -0400
Received: by igbpi8 with SMTP id pi8so131089321igb.1
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 00:18:47 -0700 (PDT)
In-Reply-To: <1418579187.3599.130.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 14, 2014 at 8:46 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Tue, 2014-10-07 at 04:42 +0530, Govindarajulu Varadarajan wrote:
>> This patch adds support for setting/getting driver's rx_copybreak value.
>> copybreak is set/get using new ethtool tunable interface.
>>
>> This was added to net-next in
>> commit: f0db9b073415848709dd59a6394969882f517da9
>>
>>       ethtool: Add generic options for tunables
>>
>> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
>> ---
>>  ethtool.c | 177 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>>  1 file changed, 177 insertions(+)
>>
>> diff --git a/ethtool.c b/ethtool.c
>> index bf583f3..4045356 100644
>> --- a/ethtool.c
>> +++ b/ethtool.c
>> @@ -179,6 +179,12 @@ static const struct flag_info flags_msglvl[] = {
>>       { "wol",        NETIF_MSG_WOL },
>>  };
>>
>> +static const char *tunable_name[] = {
>> +     [ETHTOOL_ID_UNSPEC]     = "Unspec",
>> +     [ETHTOOL_RX_COPYBREAK]  = "rx",
>> +     [ETHTOOL_TX_COPYBREAK]  = "tx",
>> +};
>
> Tunables should be named by a string set defined in the kernel.
>
> [...]
>> @@ -4055,6 +4228,10 @@ static const struct option {
>>           "             [ rx-mini N ]\n"
>>           "             [ rx-jumbo N ]\n"
>>           "             [ tx N ]\n" },
>> +       { "-b|--show-copybreak", 1, do_gcopybreak, "Show copybreak values" },
>> +       { "-B|--set-copybreak", 1, do_scopybreak, "Set copybreak values",
>> +         "             [ rx N]\n"
>> +         "             [ tx N]\n" },
>>         { "-k|--show-features|--show-offload", 1, do_gfeatures,
>>           "Get state of protocol offload and other features" },
>>         { "-K|--features|--offload", 1, do_sfeatures,
> [...]
>
> T don't think this is worth two options of its own.  You should be able
> to add generic get/set-tunable optins.  You'll need to get the string
> set to find out the names of tunables.  When setting a tunable, you'll
> need to get it first to find out its type.
>
> Ben.
>
> --
> Ben Hutchings
> The two most common things in the universe are hydrogen and stupidity.

Hi Govindarajulu,

Do you have a patch that fixes Ben's comments?

I would like to add the copybreak feature so let me know if you want
me to fix the patch according to Ben's comments and resend it.

Thanks,
Hadar
