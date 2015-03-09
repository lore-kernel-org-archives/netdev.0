From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] rocker: check for BRIDGE_FLAGS_SELF in bridge
 setlink handler
Date: Mon, 9 Mar 2015 16:23:47 -0700
Message-ID: <CAJieiUj6C1EQ4JpXZjB-wg2gcGJuci+Kya9i_qz95XzQHpRJ2w@mail.gmail.com>
References: <CAE4R7bArwsNUdtNM25Zm=ZccrmVqC8e45E6qsjMdO3s0FrOVog@mail.gmail.com>
	<54F6C788.2010201@cumulusnetworks.com>
	<20150305080218.GB2033@nanopsycho.orion>
	<54F86E4B.9040403@cumulusnetworks.com>
	<CAE4R7bCQHcR4Ne-ssCRRvw0czKxRJfykcBFY6c_9haRF3pRJYA@mail.gmail.com>
	<54F8C00C.2010303@cumulusnetworks.com>
	<CAE4R7bAaLxCebc7cuYB9NQ_Duo8a6LvxWDwWOD9Wn8ROWjvDGw@mail.gmail.com>
	<54FC5A60.7000800@cumulusnetworks.com>
	<CAE4R7bDrhnK_a9dvyMqSJkGgod6AM=HDE6CAKkG_RnjuDxB2-Q@mail.gmail.com>
	<CAJieiUhHdXOZjWkb4s_GviLwzq5Gct-1o8xv8b-JeM46S4e-dg@mail.gmail.com>
	<20150309064043.GB2053@nanopsycho.orion>
	<E4CD12F19ABA0C4D8729E087A761DC35067E6A8D@ORSMSX101.amr.corp.intel.com>
	<CAJieiUhcdfGitY7rbG11Vt_Beemz8dy3=gKtvbyVLS8O0DkgNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: "Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:37973 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324AbbCIXXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 19:23:47 -0400
Received: by pabrd3 with SMTP id rd3so52339974pab.5
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 16:23:47 -0700 (PDT)
In-Reply-To: <CAJieiUhcdfGitY7rbG11Vt_Beemz8dy3=gKtvbyVLS8O0DkgNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sorry, this email might have gone with non-text (though i selected
'plain text' in my google mail web client). Retrying...apologize for
multiple emails.

On Mon, Mar 9, 2015 at 3:56 PM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>
>
> On Mon, Mar 9, 2015 at 8:59 AM, Arad, Ronen <ronen.arad@intel.com> wrote:
>>
>>
>>
>> >-----Original Message-----
>> >From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>> > On
>> >Behalf Of Jiri Pirko
>> >
>> >
>>
>> >I also think that is is fine that in case either master or self are not
>> > set,
>> >driver ndo setlink is called as well (in case the offload bit is on). It
>> >makes it transparent for user in case he does not care what in under. In
>> >case he cares, he can specify master or self to achieve exactly what he
>> >needs. I like it that way.
>> >
>> >
>> It would be nice to have switch driver implementation that could work
>> Consistently with and without the bridge driver. I expect use case where a
>> bridge is only used when L3 is needed or to leverage L2 protocols that are
>> implemented by the bridge driver (e.g. STP, IGMP snooping).
>
>
>>
>> If my driver can process setlink requests using SELF flag today, I'd like
>> it
>> to work the same when setlink is propagated down from a bridge master or
>> from a team/bond master.
>
>
>>
>>
>> There is current issue with notification.
>> When SELF flag is set, the bridge driver does not offload to the port
>> driver
>> and notification is issued by rtnetlink.c by calling the port getlink ndo.
>
>
>
>>
>> This call, however, is done with zero filter_mask such that VLAN
>> information
>> is not included in the notification.
>
>
>
>>
>> When SELF flag is not set, bridge driver offloads to the port and issues
>> the
>> notification. In that case it sets the filter to VLAN_COMPRESSED.
>> I don't see how I can get my driver to behave consistently with and
>> without
>> a bridge.
>> The closest I can get notification with and without a bridge is for the
>> driver to examine the flags. If SELF is set, the driver knows it got
>> invoked
>> directly from rtnetlink and it should notify VLAN setting as the
>> subsequent
>> notification triggered by rtnetlink won't.
>> When the switch driver does not see SELF set it knows that it was invoked
>> by
>> The bridge driver which already takes care of notification including VLAN
>> information.
>>
>
> You are right about self being handled from rtnetlink.c and the notification
> triggered from rtnetlink.c
> can be different from the one sent from the bridge driver.
> In the specific case of vlan information not being present in the self
> notifications generated from rtnetlink.c, that is
> something that will need to be fixed eventually.
> Since rtnetlink.c generates these notifications and not the port driver,
> like you say, port driver could generate the appropriate notification or
> rtnetlink.c will have to get the size of the skb from the port driver before
> doing a bridge_getlink call into the port driver.
>
> This is another good example, where the port driver might need to look at
> the self flag after-all.
>
> Thanks,
> Roopa
>
>
>
>
>
