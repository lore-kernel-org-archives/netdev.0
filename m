From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Subject: Re: [ethtool PATCH v3 1/4] ethtool-copy.h:sync with net
Date: Mon, 22 Aug 2016 12:59:13 -0700
Message-ID: <CAKWE-XqoGjWOqmYL+zjsONS5=bMejAidgA_os9sYChCR6grZew@mail.gmail.com>
References: <1471823044-5165-2-git-send-email-vidya@cumulusnetworks.com> <20160822192606.GB2628@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        David Decotigny <decot@googlers.com>, bkenward@solarflare.com,
        daniel@iogearbox.net, Gal Pressman <galp@mellanox.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Andy Gospodarek <gospo@cumulusnetworks.com>,
        Dustin Byford <dustin@cumulusnetworks.com>,
        Ben Hutchings <ben@decadent.org.uk>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:34217 "EHLO
        mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755511AbcHVT7a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 15:59:30 -0400
Received: by mail-yw0-f172.google.com with SMTP id z8so59527163ywa.1
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 12:59:14 -0700 (PDT)
In-Reply-To: <20160822192606.GB2628@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John,
   I will re-submit v4 patchset with these updated bits.

Thanks
Vidya

On Mon, Aug 22, 2016 at 12:26 PM, John W. Linville
<linville@tuxdriver.com> wrote:
> On Sun, Aug 21, 2016 at 04:44:01PM -0700, Vidya Sagar Ravipati wrote:
>> From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
>>
>> This covers kernel changes upto:
>>
>> commit 3851112e4737cd52aaeda0ce8d084be9ee128106
>> Author: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
>> Date:   Sun May 22 23:59:00 2016 -0700
>>
>>     ethtool: add support for 25G/50G/100G speed modes
>>
>>     This patch enhances ethtool link mode bitmap to include
>>     25G/50G/100G speed along with interface modes
>
> There is one more change since then:
>
> commit 89da45b8b5b2187734a11038b8593714f964ffd1
> Author: Gal Pressman <galp@mellanox.com>
> Date:   Thu Jun 23 17:02:43 2016 +0300
>
>     ethtool: Add 50G baseSR2 link mode
>
>     Add ETHTOOL_LINK_MODE_50000baseSR2_Full_BIT bit.
>
>     Signed-off-by: Gal Pressman <galp@mellanox.com>
>     Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
>     Cc: Ben Hutchings <bwh@kernel.org>
>     Cc: David Decotigny <decot@googlers.com>
>     Acked-By: David Decotigny <decot@googlers.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
> Might as well include that here and in the patch that uses the
> new bits?
>
>> Signed-off-by: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
>> Signed-off-by: David S. Miller <davem@davemloft.net>
>> ---
>>  ethtool-copy.h | 17 +++++++++++++----
>>  1 file changed, 13 insertions(+), 4 deletions(-)
>>
>> diff --git a/ethtool-copy.h b/ethtool-copy.h
>> index 7c581ea..7817779 100644
>> --- a/ethtool-copy.h
>> +++ b/ethtool-copy.h
>> @@ -1351,6 +1351,15 @@ enum ethtool_link_mode_bit_indices {
>>       ETHTOOL_LINK_MODE_56000baseCR4_Full_BIT = 28,
>>       ETHTOOL_LINK_MODE_56000baseSR4_Full_BIT = 29,
>>       ETHTOOL_LINK_MODE_56000baseLR4_Full_BIT = 30,
>> +     ETHTOOL_LINK_MODE_25000baseCR_Full_BIT  = 31,
>> +     ETHTOOL_LINK_MODE_25000baseKR_Full_BIT  = 32,
>> +     ETHTOOL_LINK_MODE_25000baseSR_Full_BIT  = 33,
>> +     ETHTOOL_LINK_MODE_50000baseCR2_Full_BIT = 34,
>> +     ETHTOOL_LINK_MODE_50000baseKR2_Full_BIT = 35,
>> +     ETHTOOL_LINK_MODE_100000baseKR4_Full_BIT        = 36,
>> +     ETHTOOL_LINK_MODE_100000baseSR4_Full_BIT        = 37,
>> +     ETHTOOL_LINK_MODE_100000baseCR4_Full_BIT        = 38,
>> +     ETHTOOL_LINK_MODE_100000baseLR4_ER4_Full_BIT    = 39,
>>
>>       /* Last allowed bit for __ETHTOOL_LINK_MODE_LEGACY_MASK is bit
>>        * 31. Please do NOT define any SUPPORTED_* or ADVERTISED_*
>> @@ -1359,7 +1368,7 @@ enum ethtool_link_mode_bit_indices {
>>        */
>>
>>       __ETHTOOL_LINK_MODE_LAST
>> -       = ETHTOOL_LINK_MODE_56000baseLR4_Full_BIT,
>> +       = ETHTOOL_LINK_MODE_100000baseLR4_ER4_Full_BIT,
>>  };
>>
>>  #define __ETHTOOL_LINK_MODE_LEGACY_MASK(base_name)   \
>> @@ -1646,9 +1655,9 @@ enum ethtool_reset_flags {
>>   *   %ETHTOOL_GLINKSETTINGS: on entry, number of words passed by user
>>   *   (>= 0); on return, if handshake in progress, negative if
>>   *   request size unsupported by kernel: absolute value indicates
>> - *   kernel recommended size and cmd field is 0, as well as all the
>> - *   other fields; otherwise (handshake completed), strictly
>> - *   positive to indicate size used by kernel and cmd field is
>> + *   kernel expected size and all the other fields but cmd
>> + *   are 0; otherwise (handshake completed), strictly positive
>> + *   to indicate size used by kernel and cmd field stays
>>   *   %ETHTOOL_GLINKSETTINGS, all other fields populated by driver. For
>>   *   %ETHTOOL_SLINKSETTINGS: must be valid on entry, ie. a positive
>>   *   value returned previously by %ETHTOOL_GLINKSETTINGS, otherwise
>> --
>> 2.1.4
>>
>>
>
> --
> John W. Linville                Someday the world will need a hero, and you
> linville@tuxdriver.com                  might be all we have.  Be ready.
