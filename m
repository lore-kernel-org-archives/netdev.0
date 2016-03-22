From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] ipv4: initialize flowi4_flags before calling fib_lookup()
Date: Tue, 22 Mar 2016 14:10:49 -0700
Message-ID: <CAM_iQpURYG=Z-2CO3W57LpKysjx8-173=Kcwbe_=RQbyERCy4A@mail.gmail.com>
References: <1458660679-7279-1-git-send-email-lrichard@redhat.com>
	<56F18EEE.4070000@cumulusnetworks.com>
	<CAM_iQpV6srT84xa4y0WHrKG0mbO2xs=rnKKCx1XB9FtWusxCgw@mail.gmail.com>
	<56F1B300.8070209@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lance Richardson <lrichard@redhat.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f181.google.com ([209.85.161.181]:32878 "EHLO
	mail-yw0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753377AbcCVVKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 17:10:50 -0400
Received: by mail-yw0-f181.google.com with SMTP id h65so128095784ywe.0
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 14:10:49 -0700 (PDT)
In-Reply-To: <56F1B300.8070209@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 22, 2016 at 2:02 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 3/22/16 2:45 PM, Cong Wang wrote:
>>
>> @@ -1426,7 +1426,7 @@ int fib_table_lookup(struct fib_table *tb, const
>> struct flowi4 *flp,
>>                              nh->nh_flags & RTNH_F_LINKDOWN &&
>>                              !(fib_flags & FIB_LOOKUP_IGNORE_LINKSTATE))
>>                                  continue;
>> -                       if (!(flp->flowi4_flags & FLOWI_FLAG_VRFSRC)) {
>> +                       if (!(flp->flowi4_flags & FLOWI_FLAG_SKIP_NH_OIF))
>> {
>>                                  if (flp->flowi4_oif &&
>>                                      flp->flowi4_oif != nh->nh_oif)
>>                                          continue;
>>
>> For me, it looks the bug was introduce by commit
>> 35ebf65e851c6d9731abc6362b1.
>>
>
> Arguably yes since it added the function without initializing flags.
>
> The commit I referenced (and even the VRF predecessor both of which
> originated in the v4.3) is the one introducing use of flow flags to the
> lookup. From a stable perspective going back to v4.3 is what matters.
>

Yeah, then it is commit 613d09b30f8b589d5a9b497. It doesn't matter
for backport, but matters for accuracy. ;)
