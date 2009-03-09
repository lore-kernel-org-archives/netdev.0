From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: MACVLANs really best solution? How about a bridge with multiple bridge virtual interfaces?
Date: Mon, 09 Mar 2009 09:34:02 -0700
Message-ID: <m1fxhm8xl1.fsf@fess.ebiederm.org>
References: <20090307211527.6e76d0b9.nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
	<49B51A42.6050507@trash.net> <m11vt6d9t6.fsf@fess.ebiederm.org>
	<49B52F73.7010508@trash.net> <m13admbsuk.fsf@fess.ebiederm.org>
	<49B53B6C.7060400@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Smith
	<nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>,
	greearb@candelatech.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, shemminger@linux-foundation.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:52226 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751288AbZCIQeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 12:34:09 -0400
In-Reply-To: <49B53B6C.7060400@trash.net> (Patrick McHardy's message of "Mon\, 09 Mar 2009 16\:53\:16 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> writes:

> Eric W. Biederman wrote:
>> There are two tricky parts.
>>
>> One problem is that macvlans and the primary hardware device share the
>> same transmit queue.  So when I have a broadcast packet on the primary
>> devices queue I don't know if I have already sent it out to the
>> macvlan devices or not.
>
> So its about receiving packets on macvlan when transmitting on the
> real device? That sounds like a really hard problem that would probably
> indeed be better solved by a bridge.

Yes.  My concern is that if we hook the real device we will
software broadcast packets twice.

Now that I think about it we could call ndo_start_xmit directly
from the macvlan code, and bypass whatever hook we use to
intercept packets going out the normal device it should not
be too difficult.

Operationally it would be very nice if arp worked between a macvlan
and the real device.

Eric
