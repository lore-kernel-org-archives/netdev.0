From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH] net: Abstract features usage.
Date: Tue, 24 May 2011 16:25:50 -0700
Message-ID: <BANLkTi=zk6aYCMU-UR+_6eXXDk=nQdZSgQ@mail.gmail.com>
References: <1306263162-2022-1-git-send-email-maheshb@google.com>
 <20110524142928.105d66ef@nehalam> <BANLkTin48HKVRn6kG8SCZNfhyWVVhkBArg@mail.gmail.com>
 <20110524161138.55aed6b1@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:61987 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323Ab1EXX0N convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 19:26:13 -0400
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p4ONQCZo017587
	for <netdev@vger.kernel.org>; Tue, 24 May 2011 16:26:12 -0700
Received: from bwz2 (bwz2.prod.google.com [10.188.26.2])
	by kpbe13.cbf.corp.google.com with ESMTP id p4ONPx66005575
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 24 May 2011 16:26:10 -0700
Received: by bwz2 with SMTP id 2so7772462bwz.37
        for <netdev@vger.kernel.org>; Tue, 24 May 2011 16:26:10 -0700 (PDT)
In-Reply-To: <20110524161138.55aed6b1@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 24, 2011 at 4:11 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Tue, 24 May 2011 16:04:20 -0700
> Mahesh Bandewar <maheshb@google.com> wrote:
>
>> On Tue, May 24, 2011 at 2:29 PM, Stephen Hemminger
>> <shemminger@vyatta.com> wrote:
>> > On Tue, 24 May 2011 11:52:42 -0700
>> > Mahesh Bandewar <maheshb@google.com> wrote:
>> >
>> >> Define macros to set/clear/test bits for feature set usage. This =
will eliminate
>> >> the direct use of these fields and enable future ease in managing=
 these fields.
>> >>
>> >> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> >> ---
>> >> =A0include/linux/netdev_features.h | =A0137 +++++++++++++++++++++=
++++++++++++++++++
>> >> =A0include/linux/netdevice.h =A0 =A0 =A0 | =A0 35 ++---------
>> >> =A02 files changed, 142 insertions(+), 30 deletions(-)
>> >> =A0create mode 100644 include/linux/netdev_features.h
>> >>
>> >> diff --git a/include/linux/netdev_features.h b/include/linux/netd=
ev_features.h
>> >> new file mode 100644
>> >> index 0000000..97bf8c4
>> >> --- /dev/null
>> >> +++ b/include/linux/netdev_features.h
>> >> @@ -0,0 +1,137 @@
>> >> +#ifndef =A0 =A0 =A0_NETDEV_FEATURES_H
>> >> +#define =A0 =A0 =A0_NETDEV_FEATURES_H
>> >> +
>> >> +/* Forward declarations */
>> >> +struct net_device;
>> >> +
>> >> +typedef =A0 =A0 =A0unsigned long *nd_feature_t
>> >
>> > typedef'ing a pointer is strongly discouraged by kernel coding sty=
le.
>> > You need to use another way such as open coding it.
>> >
>> The idea here is to have a typedef that we can use to avoid future
>> changes all over the code if we decide to change the way feature bit=
s
>> are stored. So if this is bitmap it will be defined as "unsigned lon=
g
>> *" and if it were to be u64 then it's typedef-ed as "u64". So in one
>> case it's a pointer and in other case it's not! Now how do we handle
>> both these cases?
>
> It is okay to add a typedef for a fixed width type.
> Just not adding the indirection
> because it leads to confusion.
>
> Read "Chapter 5: Typedefs" in Documentation/CodingStyle
>
Yes, this usage matches the (a) case in the documentation. This
typedef is to hide the object but enable APIs to pass it around for
reference and it _should_ only be altered by using the helper APIs
from this file. If we find a certain API is missing, it should be
added here instead of doing some local magic.

Thanks,
--mahesh..
>
>
> --
>
