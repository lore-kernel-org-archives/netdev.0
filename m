From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [RFC] SPD basic actions per netdev
Date: Thu, 01 Apr 2010 07:52:34 +0300
Message-ID: <4BB42692.9010105@iki.fi>
References: <1270053478.26743.111.camel@bigi> <20100401003352.GA19147@gondor.apana.org.au> <1270089323.26743.138.camel@bigi> <20100401025247.GA19994@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:3845 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752483Ab0DAEwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 00:52:38 -0400
Received: by ey-out-2122.google.com with SMTP id d26so51808eyd.19
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 21:52:36 -0700 (PDT)
In-Reply-To: <20100401025247.GA19994@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Wed, Mar 31, 2010 at 10:35:23PM -0400, jamal wrote:
>> On Thu, 2010-04-01 at 08:33 +0800, Herbert Xu wrote:
>>
>>> If we're going to change this then we should just add a second
>>> interface field to the selector, rather than trying to overload
>>> the existing one.
>> Do you mean to have a selector->iif/oif? Sure that makes sense - but is
>> a much larger surgery and user space will need to be taught.
>>
>> Did you look at the patch i sent? i tried to retain current behavior
>> except for the input check path. output path was working in classifying
>> with specific netdevs. 
> 
> OK, I guess the chances of an existing app breaking is slim.
> 
> BTW, you should treat FLOW_DIR_FWD as FLOW_DIR_IN.

I think we need iif and oif. The separation is clear in in/fwd policies,
as each is matched properly. But 'out' policies are used for both:
locally generated, and forwarded traffic.

Basically it goes like:
 in - for policy_check for traffic that is received locally
 fwd - for policy_check for traffic that is forwarded
 out - all (local and forwarded) traffic that goes out of box

IMHO, it's slightly confusing that in/fwd is split, but out is not.
But that's the way it works. If you now override the how interface
is checked for 'out' policy, it'll break current behaviour.

- Timo

