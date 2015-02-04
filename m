From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: Let bridge not age 'externally' learnt
 FDB entries, they are removed when 'external' entity notifies the aging
Date: Wed, 04 Feb 2015 08:19:51 -0800
Message-ID: <54D246A7.2020502@cumulusnetworks.com>
References: <1422897714-5956-1-git-send-email-siva.mannem.lnx@gmail.com> <54D0E521.6070100@cumulusnetworks.com> <CA+CtxLSziWmx94_V9S-uW9=6VYg4WXsU4CERx-uovvrFOtO1dA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>
To: Siva Mannem <siva.mannem.lnx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:58562 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965937AbbBDQT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 11:19:56 -0500
Received: by mail-pa0-f49.google.com with SMTP id fa1so3651105pad.8
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 08:19:52 -0800 (PST)
In-Reply-To: <CA+CtxLSziWmx94_V9S-uW9=6VYg4WXsU4CERx-uovvrFOtO1dA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/4/15, 12:02 AM, Siva Mannem wrote:
> On Tue, Feb 3, 2015 at 8:41 PM, roopa <roopa@cumulusnetworks.com> wrote:
>> On 2/2/15, 9:21 AM, Siva Mannem wrote:
>>>    When 'learned_sync' flag is turned on, the offloaded switch
>>>    port syncs learned MAC addresses to bridge's FDB via switchdev notifier
>>>    (NETDEV_SWITCH_FDB_ADD). Currently, FDB entries learnt via this
>>> mechanism are
>>>    wrongly being deleted by bridge aging logic. This patch ensures that FDB
>>>    entries synced from offloaded switch ports are not deleted by bridging
>>> logic.
>>>    Such entries can only be deleted via switchdev notifier
>>>    (NETDEV_SWITCH_FDB_DEL).
>>
>> Your patch seems right and maintains symmetry for fdb add/del of externally
>> learnt entries.
>> However, this could be made configurable. I think some drivers may rely on
>> bridge driver aging these entries (The default setting needs more thought).
>> I am not sure what rocker does (CC'ed rocker maintainers). But, our driver
>> does rely on the bridge driver aging these entries by default.
> added_by_external_learn flag is only set for entries learned via
> switchdev notifier
> (NETDEV_SWITCH_FDB_ADD) and rocker is the only driver using these notifiers.
>   I see that rocker is deleting the entries via switchdev notifier
> (NETDEV_SWITCH_FDB_DEL).
> This mechanism is only used by drivers when learned_sync is turned on by user.
>
> $ sudo bridge link set dev swp1 learning_sync on self
>
> Am I missing something here?
I know that its enabled by an external flag. I wasn't sure rocker was 
doing a del
or was relying on the bridge driver to age those entries (hence the CC 
to rocker maintainers).
And, my only point was its valid in some cases for the switch driver to 
rely on bridge driver ageing those entries.
For symmetry, your patch seems right.
