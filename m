From: Edward Cree <ecree@solarflare.com>
Subject: Re: [RFC PATCH net-next 2/2] sfc: report 4-tuple UDP hashing to
 ethtool, if it's enabled
Date: Wed, 28 Sep 2016 15:56:52 +0100
Message-ID: <e517e28f-9737-59cd-5e0b-96849ab3b198@solarflare.com>
References: <cc07d60a-189c-8475-ecb3-b612ff13bd5a@solarflare.com>
 <8341c601-674a-74ff-c6dd-689c19b3ce7f@solarflare.com>
 <063D6719AE5E284EB5DD2968C1650D6DB010CF9F@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "bkenward@solarflare.com" <bkenward@solarflare.com>
To: David Laight <David.Laight@ACULAB.COM>,
        "linux-net-drivers@solarflare.com" <linux-net-drivers@solarflare.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:5726 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932848AbcI1O5L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 10:57:11 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB010CF9F@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/09/16 10:12, David Laight wrote:
> If you invert the above and add a goto...
> 			if (!efx->rx_hash_udp_4tuple)
> 				goto set_ip;
I don't mind gotos...
>>  		case SCTP_V4_FLOW:
>>  		case AH_ESP_V4_FLOW:
>>  		case IPV4_FLOW:
>     set_ip:
...but this adds a label where we effectively already have one.
I wish C allowed goto case labels.
> It might look better.
> 	David

It just bugs me that it would have this unnecessary goto and label.

Alternate ways to maybe make it look better, or not:

* Remove the /* else fall further */ comment, does this make the
  indentation more or less confusing?
* Include braces on the if, even though there's only one statement
  inside.

Also, how strong are people's reaction to this?  If it's just "I
personally wouldn't do it that way", then I'm tempted to go ahead
anyway.  But if it's "NAK NAK NAK burn the heretic", that's
another matter.

-Ed
