From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next.git 1/7] stmmac: review napi gro support
Date: Wed, 03 Apr 2013 06:39:34 -0700
Message-ID: <1364996374.13853.15.camel@edumazet-glaptop>
References: <1364967689-11155-1-git-send-email-peppe.cavallaro@st.com>
	 <1364972715.5113.197.camel@edumazet-glaptop> <515BDD1C.5010306@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:48381 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759440Ab3DCNji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 09:39:38 -0400
Received: by mail-pd0-f170.google.com with SMTP id 10so856408pdi.15
        for <netdev@vger.kernel.org>; Wed, 03 Apr 2013 06:39:37 -0700 (PDT)
In-Reply-To: <515BDD1C.5010306@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-03 at 09:41 +0200, Giuseppe CAVALLARO wrote:

> Hmm, I'm in trouble on this :-). Indeed I can understand the (fatal)
> race and why napi_complete should be used. Sorry! So my fault and this 
> patch has to be discarded. I don't understand why I have not seen any
> problems while running/stressing on SMP system. Have you got any idea?
> 

So because you don't hit the race on your machine and your tests, we can
remove all the needed spinlock() and various hard irq masking, and
introduce all sort of races ?

Try to use a combination of two NICS, and you'll hit the bug even on UP.

There is a single poll_list per cpu, and we insert new elements in this
list under hard irq.

So deleting elements _must_ be done under the protection of hard irq
masking.
