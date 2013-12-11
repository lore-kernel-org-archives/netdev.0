From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: NAPI rescheduling and the delay caused by it
Date: Wed, 11 Dec 2013 18:52:21 +0000
Message-ID: <52A8B465.60304@citrix.com>
References: <529F7A87.5080303@citrix.com>	 <1386189718.30495.131.camel@edumazet-glaptop2.roam.corp.google.com>	 <529F9D4B.1020208@citrix.com>	 <1386199931.30495.139.camel@edumazet-glaptop2.roam.corp.google.com>	 <6F39C955CEA9D14BAA91CC78568B93012D5039@AMSPEX01CL02.citrite.net> <1386638065.30495.338.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	Malcolm Crossley <malcolm.crossley@citrix.com>,
	Jonathan Davies <Jonathan.Davies@citrix.com>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:24638 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750800Ab3LKSwY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Dec 2013 13:52:24 -0500
In-Reply-To: <1386638065.30495.338.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/13 01:14, Eric Dumazet wrote:
> On Mon, 2013-12-09 at 23:39 +0000, Zoltan Kiss wrote:
>> I found another suspect however: my grant mapping patches do the
>> unmapping from the NAPI instance where otherwise we receive the
>> packets from the guest. But this means we call napi_schedule from the
>> zerocopy callback, which can be run by anyone who free up that skb,
>> including an another VIF's RX thread (which actually does the transmit
>> TO the guest). I guess that might be bad.
>
> Same problem : napi_schedule() is meant to be used from interrupt
> context.

Indeed, avoiding napi_schedule seems to solve the issue. Thanks for the 
advices!

Zoli
