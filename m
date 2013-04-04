From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next.git 1/7] stmmac: review napi gro support
Date: Thu, 04 Apr 2013 08:16:56 +0200
Message-ID: <515D1AD8.409@st.com>
References: <1364967689-11155-1-git-send-email-peppe.cavallaro@st.com>  <1364972715.5113.197.camel@edumazet-glaptop> <515BDD1C.5010306@st.com> <1364996374.13853.15.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:40573 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756023Ab3DDGRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 02:17:00 -0400
In-Reply-To: <1364996374.13853.15.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/3/2013 3:39 PM, Eric Dumazet wrote:
> On Wed, 2013-04-03 at 09:41 +0200, Giuseppe CAVALLARO wrote:
>
>> Hmm, I'm in trouble on this :-). Indeed I can understand the (fatal)
>> race and why napi_complete should be used. Sorry! So my fault and this
>> patch has to be discarded. I don't understand why I have not seen any
>> problems while running/stressing on SMP system. Have you got any idea?
>>
>
> So because you don't hit the race on your machine and your tests, we can
> remove all the needed spinlock() and various hard irq masking, and
> introduce all sort of races ?

No, no this was not my intention. If fact, I asked to discard the patch
;-) ... it is clear to me the race that can happen in that case.

I'll rework the patch to only add the GRO in the feature.

peppe

>
> Try to use a combination of two NICS, and you'll hit the bug even on UP.
>
> There is a single poll_list per cpu, and we insert new elements in this
> list under hard irq.
>
> So deleting elements _must_ be done under the protection of hard irq
> masking.
>
>
>
>
>
