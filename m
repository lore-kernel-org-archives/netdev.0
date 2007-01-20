From: "kalash nainwal" <nirvana.code@gmail.com>
Subject: wake_up() takes long time to return
Date: Sat, 20 Jan 2007 15:54:00 +0530
Message-ID: <e92e3a770701200224n42c948d5oe75aa5eb907e9786@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.224]:11465 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965242AbXATKYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jan 2007 05:24:01 -0500
Received: by wx-out-0506.google.com with SMTP id h31so769187wxd
        for <netdev@vger.kernel.org>; Sat, 20 Jan 2007 02:24:00 -0800 (PST)
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi there,

We've a kernel (n/w) module, which sits over ethernet. Whenever a pkt
is received (in softirq), after doing some minimal processing,
wake_up() is called to wake up another kernel thread which does rest
(bulk) of the processing.

We notice that this wake_up() call is sometimes taking as long as 48
milli-seconds to return. This happens around 10 times out of 10M. We
earlier thought its possibly because of the contention on rq->lock,
but we see the same phenomenon even on a uniprocessor box. So obviosly
thats not the case.

We can't figure out any other reason for wake_up() to take this much
time? As this call comes directly in our (receive) hotpath, we're very
concerned. Any help would be greatly appreciated.

Thanks and regards,
-Kalash
