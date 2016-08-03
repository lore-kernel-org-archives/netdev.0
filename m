From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH 1/1] rps: Inspect PPTP encapsulated by GRE to get flow hash
Date: Wed, 3 Aug 2016 08:22:13 +0800
Message-ID: <CA+6hz4pJ6WySV5Nww7o0=6n0a-oLByujDirkG_nEPFWaP7-VNw@mail.gmail.com>
References: <1469690081-32122-1-git-send-email-fgao@ikuai8.com>
 <050ccbd6-5a10-575d-28d7-17c4df788b84@redfish-solutions.com>
 <CA+6hz4p2Z+Va2GNuRpcp3MRc5V_Yf0Bf7ut7QsAxTRBtFg9u9Q@mail.gmail.com> <29507597-6977-cbe1-3983-1e8e30c94f0b@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: fgao@48lvckh6395k16k5.yundunddos.com,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Tom Herbert <tom@herbertland.com>,
	Alex Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Philp Prindeville <philipp@redfish-solutions.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f47.google.com ([209.85.213.47]:34719 "EHLO
	mail-vk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753725AbcHCAWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2016 20:22:14 -0400
Received: by mail-vk0-f47.google.com with SMTP id s189so134775219vkh.1
        for <netdev@vger.kernel.org>; Tue, 02 Aug 2016 17:22:14 -0700 (PDT)
In-Reply-To: <29507597-6977-cbe1-3983-1e8e30c94f0b@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Philp.

I get it, then i will send another update v3 patch soon.

On Wed, Aug 3, 2016 at 1:33 AM, Philp Prindeville
<philipp@redfish-solutions.com> wrote:
> Inline...
>
>
> On 08/02/2016 12:10 AM, Feng Gao wrote:
>>
>> Thanks.
>> Because the original GRE uses the literal number directly, so I follow
>> this style.
>>
>> Then I have two questions.
>> 1. pptp_gre_header is defined in "drivers/net/ppp/pptp.c"; If we want
>> to use it, need to create one new header file, is it ok ?
>
>
> Yes, I would move the relevant constants and packet structures into
> include/net/pptp.h ...
>
> While you're at it, there are places like:
>
>     islcp = ((data[0] << 8) + data[1]) == PPP_LCP && 1 <= data[2] && data[2]
> <= 7;
>
> that should be written as:
>
>     islcp = PPP_PROTOCOL(data-2) == PPP_LCP && CP_CONF_REQ <= data[2] &&
> data[2] <= CP_CODE_REJ;
>
> Similarly for:
>
>                 data[0] = PPP_ALLSTATIONS;
>                 data[1] = PPP_UI;
>
> that should be using:
>
>         PPP_ADDRESS(data) = PPP_ALLSTATIONS;
>         PPP_CONTROL(data) = PPP_UI;
>
> etc. but this cleanup can go in a 2nd patch.  The definitions for CONFREQ
> and CONFACK and CP_CONF_REQ and CP_CONF_ACK and PPP_LCP_ECHOREQ and
> PPP_LCP_ECHOREP are redundant and probably should all go into ppp_defs.h as
> well (which would require refactoring drivers/net/ppp/ppp_async.c).
>
>
>> 2. The GRE version 0 patch could use the sizeof pptp_gre_header.seq ?
>
>
> Actually, since you're going to be doing the pptp.h header anyway, I'd add a
> v0 as well as a v1 struct just to be more clear/concise.
>
> -Philip
>
>> Best Regards
>> Feng
>>
>>
> [snip]
