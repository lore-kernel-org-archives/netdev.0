From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] ipv4: fib: check forwarding before checking send_redirects
Date: Tue, 8 Apr 2014 14:17:08 -0700
Message-ID: <CAM_iQpXrmRNhQCWjiRSKwzxvtcq9XuT-cWS4vRxYVYxpUEN3qQ@mail.gmail.com>
References: <1396985482-30886-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140408.164356.557108616710530006.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Julian Anastasov <ja@ssi.bg>,
	Cong Wang <cwang@twopensource.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f44.google.com ([209.85.219.44]:49142 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756627AbaDHVRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 17:17:08 -0400
Received: by mail-oa0-f44.google.com with SMTP id n16so1723271oag.17
        for <netdev@vger.kernel.org>; Tue, 08 Apr 2014 14:17:08 -0700 (PDT)
In-Reply-To: <20140408.164356.557108616710530006.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 8, 2014 at 1:43 PM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Tue,  8 Apr 2014 12:31:22 -0700
>
>> From: Cong Wang <cwang@twopensource.com>
>>
>> We have seen in a weird case we had to disable send_redirects in order
>> to pass rp filter check even though we don't set forwarding at all.
>> This looks wrong, at least according to ip-sysctl.txt send_redirects should
>> only make sense when we enable forwarding.
>>
>> Cc: Eric Biederman <ebiederm@xmission.com>
>> Cc: Julian Anastasov <ja@ssi.bg>
>> Cc: David S. Miller <davem@davemloft.net>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> Signed-off-by: Cong Wang <cwang@twopensource.com>
>
> I'm not so sure about this.
>
> This test here is just an optimization, which bypasses the long path
> processing of FIB source address validation if certain strict
> conditions are met.
>
> __fib_validate_source() should do the right thing if it is executed,
> it is just the slow path, and you should determine why it is rejecting
> your traffic instead.
>
> Your change is a valid optimization perhaps, but not a bug fix.

In our case, we have the following setting:

1) rp_filter = 0 (set manually)
2) forwarding = 0 (default)
3) send_redirects = 1 (default)

We are not supposed even to execute __fib_validate_source() in such case,
are we? :)
