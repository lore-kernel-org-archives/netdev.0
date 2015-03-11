From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [patch net-next] switchdev: select INET in Kconfig
Date: Wed, 11 Mar 2015 09:26:25 -0700
Message-ID: <CAADnVQJd2=TLTmzczSUOzwzqQ9Lanir-J5ektivqKABq-K7Fpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Randy Dunlap <rdunlap@infradead.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:35465 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750820AbbCKQ0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 12:26:46 -0400
Received: by qgfh3 with SMTP id h3so11301499qgf.2
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 09:26:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2015 at 9:20 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Wed, Mar 11, 2015 at 04:36:16PM CET, alexei.starovoitov@gmail.com wrote:
>>On Wed, Mar 11, 2015 at 2:49 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> This would fix randconfig compile error:
>>> net/built-in.o: In function `netdev_switch_fib_ipv4_abort':
>>> (.text+0xf7811): undefined reference to `fib_flush_external'
>>>
>>> Also it fixes following warning:
>>> warning: (NET_DSA) selects NET_SWITCHDEV which has unmet direct dependencies (NET && INET)
>>>
>>> Suggested-by: Randy Dunlap <rdunlap@infradead.org>
>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>> ---
>>>  net/switchdev/Kconfig | 2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/net/switchdev/Kconfig b/net/switchdev/Kconfig
>>> index 86a47e1..3487940 100644
>>> --- a/net/switchdev/Kconfig
>>> +++ b/net/switchdev/Kconfig
>>> @@ -4,7 +4,7 @@
>>>
>>>  config NET_SWITCHDEV
>>>         bool "Switch (and switch-ish) device support (EXPERIMENTAL)"
>>> -       depends on INET
>>> +       select INET
>>
>>I believe Dave mentioned few times that 'select' is highly
>>discouraged, since it doesn't work recursively.
>>In this case only crazy config KVMTOOL_TEST_ENABLE
>>is doing 'select INET' everything else in a tree is using
>>'depends on INET'.
>>Doing 'select NET_SWITCHDEV' was wrong in the first place.
>
> Ok, so you suggest just to change this to "depends on NET_SWITCHDEV" in
> DSA and we are good?

yes. that should work.
Probably combining that line with 'depends on HAVE_NET_DSA' line
