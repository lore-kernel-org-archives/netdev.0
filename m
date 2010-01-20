From: "Simon Arlott" <simon@fire.lp0.eu>
Subject: Re: [PATCH] xt_TCPMSS: SYN packets are allowed to contain data
Date: Wed, 20 Jan 2010 12:59:16 -0000
Message-ID: <710ab0ca79305c82013982d43250b0a1fd45824d@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>
References: <4B54CDE5.3070100@simon.arlott.org.uk> <4B5578A5.50705@gmail.com>
    <dad314e12c5750b1b5d70c3ea3c6f6134b8fa0f3@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>
    <4B55D372.4020807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "netdev" <netdev@vger.kernel.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: "William Allen Simpson" <william.allen.simpson@gmail.com>,
	"Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([81.2.80.65]:36136 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750976Ab0ATM7T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 07:59:19 -0500
In-Reply-To: <4B55D372.4020807@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, January 19, 2010 15:44, William Allen Simpson wrote:
> Simon Arlott wrote:
>> On Tue, January 19, 2010 09:17, William Allen Simpson wrote:
>> I could change the comment too, but the same logic applies when
>> there is data and no MSS option - the packet can't be increased
>> in size if it would then exceed 576 bytes and/or the destination
>> MTU.
>>
> Please change the comment.

I've made a new version of the patch which I'll be able to test
tonight.

> If there is no MSS option, it should *not* be added, under *ANY*
> circumstances.  That violates the end-to-end arguments (some call
> them principles).

Agreed. The added MSS is likely to be larger than 536 too... I've
removed this code.

> MSS isn't about the _destination_ MTU, it's about the *source*.
> If you cannot guarantee you know the source MTU, there's no basis
> for deciding the MSS.

I was referring to the SYN packet itself. It wouldn't always be
possible to add an option without exceeding the MTU of that packet's
destination if it had data.


On 19/01/10 12:53, Patrick McHardy wrote:
> Simon Arlott wrote:
>> If this is 20 (IPv4 Header) + 20 (TCP Header) = 40 bytes, then
>> there is no data and the header offset is wrong so it hasn't been
>> checked.
>
> That's odd. If the packet is really only 40 bytes large, then there
> are no TCP options, so your patch shouldn't have any effect.

Except to remove the printk which fills up my serial console (because
the header offset is wrong).

-- 
Simon Arlott
