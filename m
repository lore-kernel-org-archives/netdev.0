From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [RFC] Mobile IPv6 introduction
Date: Wed, 02 Aug 2006 12:24:30 +0900
Message-ID: <44D01AEE.3030606@linux-ipv6.org>
References: <44CB2914.9010803@linux-ipv6.org> <20060729141244.GJ8334@innerghost.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi,
	vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:63121 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S1751101AbWHBDYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 23:24:33 -0400
To: hsantos@av.it.pt
In-Reply-To: <20060729141244.GJ8334@innerghost.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Hugo,

Please fine my comment inline:

Hugo Santos wrote:
[snip]
>    - In general, lot's of places in the IPv6 stack don't take the source
>      address into consideration and generically only use destination as
>      key, i think this is a major setback that should be approached
>      individually.

As David answered, the policy routing is it.


>    - I don't like having the individual MIPv6-specific messages checking
>      in the kernel because feature-wise this is not scalable. Only
>      data-path specific processing should be done in the kernel IMO (RT2
>      hdr processing, HOA DSTopt processing with address swapping, etc)
>      Introducing new mobility header message type would involve modify-
>      ing the kernel when there would be no other reason to do so (you
>      would then need NEMO-specific code in the kernel, FMIPv6-specific
>      code, etc). Taking the error reporting as an example, what i would
>      prefer would be a way of either signaling the kernel ICMPv6
>      component to send ParamProb or other types of errors (difficult to
>      support), or instead introducing a new datagram control message
>      that would enable the control application to retrieve the original
>      network headers (although possibly modified) and send the ICMPv6
>      message itself (which was my choice).

Our patch is similar as you said.  Our design is that kernel does nothing
as possible about validation which can be done by user-space.
As you mentioned ICMPv6 error is hard to be sent by user-space because it carries
original packet causing error. MIPv6 RFC says when mobility header length is too short
ICMPv6 error (parameter problem) is sent. We also discussed about design like your choice.
but we have not taken it because ICMPv6 sending mechanism is already in kernel
then it is reasonable to use it. We MIPL developers concluded that kernel should
know mobility header types and their minimum length at least. I guess when we would
support NEMO and FMIPv6, we just add their defines at that time.
(Actually, their implementations based on MIPL2 exists.)
If somebody would feel that such defines should be removed from kernel we have another
idea to make new socket interface like ICMP filter to store mobility header type and its
minimum length to kernel by user-space.


>    - Maybe others disagree, but i don't like having a "Route
>      optimization" mode in XFRM. From my POV, "Route optimization" is
>      one kind of transformation specific to MIPv6. Other protocols
>      require other kind of transformations. I think XFRM should be
>      instead extended to support generic transformations, where the
>      Mobile IPv6-specific one would implement a RO transform in order to
>      support it's binding cache. Also, these new modes are not
>      "advanced" but instead "Mobile IPv6 specific".

I agree XFRM should be generic transformation.

XFRM_ADVANCED will be removed from my patch because some comments are sent.


-- 
Masahide NAKAMURA
