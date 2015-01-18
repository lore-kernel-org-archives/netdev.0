From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] iproute2: bridge: support vlan range
Date: Sun, 18 Jan 2015 09:44:18 -0800
Message-ID: <CAE4R7bA6f-f9zTL4iKn11xAWD7evbEGMb+b8zgrm780Hx0yg4w@mail.gmail.com>
References: <1421391147-35021-1-git-send-email-roopa@cumulusnetworks.com>
	<CAE4R7bA2VHepe8CCYuubH8teXMvRry10jnpsisYq+7Qv+gXzHQ@mail.gmail.com>
	<54BB78DA.6060208@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, shemminger@vyatta.com,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:50105 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479AbbARRoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 12:44:20 -0500
Received: by mail-we0-f175.google.com with SMTP id k11so27815872wes.6
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 09:44:19 -0800 (PST)
In-Reply-To: <54BB78DA.6060208@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 18, 2015 at 1:11 AM, roopa <roopa@cumulusnetworks.com> wrote:
> On 1/17/15, 5:35 PM, Scott Feldman wrote:
>>
>> On Thu, Jan 15, 2015 at 10:52 PM,  <roopa@cumulusnetworks.com> wrote:
>>>
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>> This patch adds vlan range support to bridge command
>>> using the newly added vinfo flags BRIDGE_VLAN_INFO_RANGE_BEGIN and
>>> BRIDGE_VLAN_INFO_RANGE_END.
>>>
>
>>
>>> +                               vinfo.flags |=
>>> BRIDGE_VLAN_INFO_RANGE_BEGIN;
>>> +                       } else {
>>> +                               vinfo.vid = atoi(*argv);
>>> +                       }
>>>                  } else if (strcmp(*argv, "self") == 0) {
>>>                          flags |= BRIDGE_FLAGS_SELF;
>>>                  } else if (strcmp(*argv, "master") == 0) {
>>> @@ -67,7 +78,7 @@ static int vlan_modify(int cmd, int argc, char **argv)
>>>                  argc--; argv++;
>>>          }
>>>
>>> -       if (d == NULL || vid == -1) {
>>> +       if (d == NULL || vinfo.vid == -1) {
>>
>> Where was vinfo.vid initialized to -1?  Maybe use vid rather than
>> vinfo.vid in the code above where parsing the arg, and continue using
>> vid and vid_end until final put of vinfo.
>>
> There is already a "memset(&vinfo, 0, sizeof(vinfo));"  in the code in the
> beginning of the function.

That's the problem...vinfo.vid is initialized to 0, not -1, so
checking if vinfo.vid == -1 is always false.
