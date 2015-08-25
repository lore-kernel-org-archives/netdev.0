From: Christophe Ricard <christophe.ricard@gmail.com>
Subject: Re: [RFC] netlink: netlink_ack send a capped message in case of error
Date: Tue, 25 Aug 2015 21:22:28 +0200
Message-ID: <55DCC074.3060907@gmail.com>
References: <CAE4R7bAYUhbUoGK_M=USJW8pgWmBrKsNuzLFmY70aBzti53Vxg@mail.gmail.com>	<CALD+uuz7NHdWU0qqogu6_cs81Ng6gpcCPFUr4WUF+hpQPMaysg@mail.gmail.com>	<20150824185637.GA19923@salvia> <20150824.211921.944778094161045642.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jbenc@redhat.com, sameo@linux.intel.com,
	netdev@vger.kernel.org, christophe-h.ricard@st.com
To: David Miller <davem@davemloft.net>, pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:37222 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751854AbbHYTWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 15:22:31 -0400
Received: by widdq5 with SMTP id dq5so24099678wid.0
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 12:22:30 -0700 (PDT)
In-Reply-To: <20150824.211921.944778094161045642.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, Pablo,

I gave try to your proposed patch.
Changes in netlink_getsockopt and netlink_setsockopt are working fine.

Changes in netlink_ack looks not to be addressing the correct socket.

I will send an updated version in few minutes.

Best Regards
Christophe

On 25/08/2015 06:19, David Miller wrote:
> From: Pablo Neira Ayuso <pablo@netfilter.org>
> Date: Mon, 24 Aug 2015 20:56:37 +0200
>
>> On Mon, Aug 24, 2015 at 10:08:22AM +0200, Christophe Ricard wrote:
>>> Hi Scott,
>>>
>>> I think i understand the potential limitation of my solution.
>>> I saw something was proposed by Jiri Benc who pushed an additional flag to
>>> tell if the payload can be ignored in case of an error.
>>> http://patchwork.ozlabs.org/patch/290976/
>>>
>>> Do you think this one is acceptable ? I am not sure to understand David
>>> last comment.
>> I think David suggests something like the (completely untested)
>> attached patch.
> Yes, echo'ing the entire message back in an ACK is really pointless.
>
> Especially since if the user really is interested in noticing ACKs
> it can very easily keep the original request around and match on
> sequence number, as Pablo's patch's commit message suggests.
>
> We're stuck with the current behavior by default, but we can add the
> new ACK feature to deal with the issue in the long term.
