From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH -next 0/3] tc state machinery cleanups
Date: Fri, 15 May 2015 07:36:40 -0400
Message-ID: <5555DA48.6010208@mojatatu.com>
References: <1431679850-31896-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:37474 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933295AbbEOLgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 07:36:48 -0400
Received: by igbsb11 with SMTP id sb11so121018579igb.0
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 04:36:48 -0700 (PDT)
In-Reply-To: <1431679850-31896-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On 05/15/15 04:50, Florian Westphal wrote:
> This series prepares removal of tc_verd member from sk_buff.
>
> It simplifies tc state machinery to what is required to keep current
> mirred/ifb combinations working.
>
> I tested a few scenarios, namely:
>
> 1 - htb based shaping on egress
> 2 - netem attached to ifb with mirred redirect from ingress qdisc
> 3 - mirred to different egress device
> 4 - mirred to ifb egress device with qdiscs set up on ifb
>      to provide illusion of 'single' transmit interface for traffic shaping
>
> After this series tc_verd is only used by ifb to skip actions on egress.
>
> Part #2 of this series will remove tc_verd completely.
>

The major goal here is to release some of the bits that are
no longer in use. I am for that but struggling with the unintended
consequence of changing readability or subtle meanings.
I brought this up last time when you removed the 1-bit macro.
Think of someone who read the code 6  months ago.
It would be useful to keep readability for the rest of the code the
way it was - change the definition of the macros.
This sounds doable because 8 contigous bits are going to be available.
Note: The macros are fugly - but there are better tools these days to
make them easier to read so de-uglifying could be part of the goal.
Therefore, I suggest the initial effort should be to find ways to
co-locate the bits and save the 8  bits and unless necessary keep
the code readability.

More on readability and subtle meanings:
A noun like "skb_tc_state" is not a good choice. Those two bits
carry location indicators and are intended to define source
and destination endpoints.

Also note: ifb and mirred are using the location metadata
bits - they are _not_ the owners of those bits or the only
potential users. Any of the blocks can consume or produce the metadatum
in order to aid policy traversal. You can use those two as examples
of existing blocks that do so - but annotating the code as such is
inaccurate.

cheers,
jamal
