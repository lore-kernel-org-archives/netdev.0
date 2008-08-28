From: "Tomas Winkler" <tomasw@gmail.com>
Subject: Re: pull request: wireless-2.6 2008-08-26
Date: Thu, 28 Aug 2008 03:19:35 +0300
Message-ID: <1ba2fa240808271719o2a3617e7re0499670de785b2f@mail.gmail.com>
References: <20080827013009.GA15781@tuxdriver.com>
	 <1ba2fa240808271226i95a7789k481a68b09dc60164@mail.gmail.com>
	 <200808272225.10557.mb@bu3sch.de>
	 <1ba2fa240808271611v382631ecn2a24e2816562d434@mail.gmail.com>
	 <20080827233103.GE5927@tesla>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael Buesch" <mb@bu3sch.de>,
	"John W. Linville" <linville@tuxdriver.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Bruno Randolf" <bruno@thinktube.com>
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:27726 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751976AbYH1ATg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 20:19:36 -0400
Received: by fg-out-1718.google.com with SMTP id 19so107047fgg.17
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2008 17:19:35 -0700 (PDT)
In-Reply-To: <20080827233103.GE5927@tesla>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 28, 2008 at 2:31 AM, Luis R. Rodriguez
<lrodriguez@atheros.com> wrote:
> On Wed, Aug 27, 2008 at 04:11:15PM -0700, Tomas Winkler wrote:
>> if (beacon_timestamp > rx_timestamp)
>>     merge
>>
>> The patch from Assaf just disable reporting RX timestamp to mac and
>> thus disabling merging which gives incorrect spec behavior but smooth
>> traffic.
>
> We *should follow the spec*.

I prefer to be able transfer files over blindly following spec. This
doesn't really break interoperability in practice.

>> Actually we've checked few cards including broadcom and various
>> windows NICs
>
> What are windows NICs?
>
>> and non of them implements this correctly so this WA is
>> probably the solution.
>
> Disagreed! If there is hardware which is not capable of handling this
> we should simply have a HW flag which specifies this to handle this as a
> work around (WA). Just because some cards are not capable it doesn't
> mean it should impose that on the rest.

This is w/a in the specific driver not in the mac so this is de facto
what you have suggested. This patch is marked as W/A and should have
probably
some cleaner solution in 2.6.28

>> Other solution would be to mark leader with highest TSF and not
>> reconnecting to the same station again and again.
>>
>> Last solution would be to remove this merging all together but then
>> I'm not sure if Bruno added this code just implement the spec or
>> really tested it with any hardware. I'm not sure if any vendor
>> implements PS in IBSS so this merging is probably not important
>> anyway.
>
> Absolutely not! IBSS merge is per spec, otherwise you don't really have
> a real IBSS.

I'm all for following spec and we've tried really hard to make it work.
Anyhow I'm not sure what you call real IBSS. nobody has checked it for
1.5 year this patch  is in and now is suddenly so important...
b43 was effected and probably also something that John worked with (as
he issued his anti-chatty patch)
I would like to see if there is any  HW under mac80211 that actually
work with this.

Tomas


>  Luis
>
