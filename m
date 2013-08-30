From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] openvswitch: fix sw_flow_key alignment
Date: Fri, 30 Aug 2013 16:20:25 -0700
Message-ID: <CAEP_g=-zgaKot6f5w=sqVjOauT9OtSd1sjrJSwc5AC7xR1s99g@mail.gmail.com>
References: <1377883940-8995-1-git-send-email-azhou@nicira.com>
 <CAEP_g=9y-HeG0vHS2v-dk7eDp=T0denddykDO3TJtk4UJ062Mg@mail.gmail.com> <20130830.144211.1550393719904034493.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Zhou <azhou@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:33788 "HELO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754235Ab3H3XUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 19:20:46 -0400
Received: by mail-lb0-f180.google.com with SMTP id q8so2382062lbi.11
        for <netdev@vger.kernel.org>; Fri, 30 Aug 2013 16:20:45 -0700 (PDT)
In-Reply-To: <20130830.144211.1550393719904034493.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 30, 2013 at 11:42 AM, David Miller <davem@davemloft.net> wrote:
> From: Jesse Gross <jesse@nicira.com>
> Date: Fri, 30 Aug 2013 11:22:11 -0700
>
>> The suggestion that Geert made was to just drop this entirely and
>> rely on the natural alignment from these values.
>
> Indeed, Geert's patch was 1,000 times superior to this one.

I looked through the struct definition and I think that the idea of
manually padding as Geert did in his patch will be difficult to
maintain over time (and actually there are a few that he missed) since
there are a number of different structs/unions contained in there.
Dropping the alignment specifier completely still has the same
potential problem on architectures where the size and alignment of
long are not the same.

Maybe the easiest thing to do at this point is just to always align it
to 8 bytes.
