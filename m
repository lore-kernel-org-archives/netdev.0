From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next v3 1/4] net core: Add IFF_PROTO_DOWN support.
Date: Tue, 28 Apr 2015 08:45:50 -0700
Message-ID: <CACcJQnQOei+1Gkc_-1hZ1aFD+3EgFRprUBmqOFWKPh6hcuSvGw@mail.gmail.com>
References: <1430156304-13187-2-git-send-email-anuradhak@cumulusnetworks.com>
	<CAE4R7bBv350WnC4uEp7YZy7Jpq0zaTouWysgbSHXyktwTA9voA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:35229 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965790AbbD1Ppw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 11:45:52 -0400
Received: by lbbuc2 with SMTP id uc2so110518444lbb.2
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 08:45:50 -0700 (PDT)
In-Reply-To: <CAE4R7bBv350WnC4uEp7YZy7Jpq0zaTouWysgbSHXyktwTA9voA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 27, 2015 at 11:05 PM, Scott Feldman <sfeldma@gmail.com> wro=
te:
> On Mon, Apr 27, 2015 at 10:38 AM,  <anuradhak@cumulusnetworks.com> wr=
ote:
>> From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
>>
>> This patch introduces an IFF_PROTO_DOWN flag that can be used by
>> user space applications to notify drivers that errors have been
>> detected on the device.
>>
>> Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
>> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
>> ---
>>  include/uapi/linux/if.h |    4 ++++
>>  net/8021q/vlan_dev.c    |    3 ++-
>>  net/core/dev.c          |    2 +-
>>  3 files changed, 7 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
>> index 9cf2394..e263bd2 100644
>> --- a/include/uapi/linux/if.h
>> +++ b/include/uapi/linux/if.h
>> @@ -66,6 +66,8 @@
>>   * @IFF_LOWER_UP: driver signals L1 up. Volatile.
>>   * @IFF_DORMANT: driver signals dormant. Volatile.
>>   * @IFF_ECHO: echo sent packets. Volatile.
>> + * @IFF_PROTO_DOWN: protocol is down on the interface. Can be toggl=
ed
>> + *     through sysfs.
>
> This comment is stale, right?  I didn't see any sysfs support in the =
patchset.

Correct, No new sysfs has been added for this flag. But IFF_PROTO_DOWN
can be toggled via the already existing generic flags sysfs (similar
to say IFF_MULTICAST); hence the comment =E2=80=93

root@net-next:~# echo 0x81003 > /sys/class/net/eth0/flags

root@net-next:~# cat /sys/class/net/eth0/flags

0x81003
