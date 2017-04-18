From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Case for reusing netlink PADs WAS(Re: [PATCH net-next 1/1] net
 sched actions: dump more than TCA_ACT_MAX_PRIO actions per batch
Date: Tue, 18 Apr 2017 15:16:56 +0200
Message-ID: <20170418131656.GG1871@nanopsycho.orion>
References: <1492346070-6002-1-git-send-email-jhs@emojatatu.com>
 <20170417081936.GA1892@nanopsycho.orion>
 <dfc1485f-7d7e-f52e-f62e-273063a59abc@mojatatu.com>
 <1492434659.10587.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170417153133.GA1895@nanopsycho.orion>
 <0bd1e885-cdf3-60fc-783b-a075b777560b@mojatatu.com>
 <1492448905.10587.109.camel@edumazet-glaptop3.roam.corp.google.com>
 <560eeb0b-7a34-484a-e4a1-c637b31eba59@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
        netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34288 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751520AbdDRNQ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 09:16:59 -0400
Received: by mail-wm0-f65.google.com with SMTP id z129so12036214wmb.1
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 06:16:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <560eeb0b-7a34-484a-e4a1-c637b31eba59@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Apr 18, 2017 at 02:48:57PM CEST, jhs@mojatatu.com wrote:
>On 17-04-17 01:08 PM, Eric Dumazet wrote:
>> On Mon, 2017-04-17 at 12:46 -0400, Jamal Hadi Salim wrote:
>> 
>> > Of course it is trivial to add this as attributes and 32 bits
>> > for this case is not a big deal because it is done once. I want to talk
>> > about the pads instead ;-> What do you suggest we do with pads?
>> 
>> We do nothing with pads. Just leave them.
>> 
>> Or, you need something to make sure to not break old user applications.
>> 
>> Something like a version.
>> 
>> 
>
>Dave is not fond of version fields - they tend to be abused
>although looking at the idiag and tpacket stuff there is a case
>to be made for versioning ;->
>
>
>For the patches I posted, I will work on getting an attribute based
>variant of the patches out - but i wanted to have this discussion a
>little more if you bear with me.
>
>Netlink is a wire protocol. When a protocol is defined with rules such
>as alignment (which lead to explicit padding) then those are equivalent
>to "reserved bits" in standard wire protocols. Good practise is:
>all sender zero those bits(MBZ); and all receivers must ignore them
>unless they wish to interpret them. Not everyone follows these rules
>(I remember the havoc ECN caused when TCP/IP started using the different
>reserved fields).
>
>For our case it is _very sad_ that someone actually explicitly defined
>pads - in my opinion for no other purpose other than reuse and then
>we say we cant use them after.
>
>I believe you understand what I was saying, but to clarify, here is
>what i meant:
>---
>struct tcamsg {
>        unsigned char   tca_family;
>        union {
>                unsigned char   tca__pad1;
>                unsigned char   tca_flags;
>        };
>        union {
>                unsigned short  tca__pad2;
>                unsigned char   tca_foobar;
>        };
>};
>---
>
>This should work with old binaries and kernels.
>It will work with someone referencing sizeof tcamsg.
>It will work with unchanged source that memsets the struct.
>It will work with things that explicitly set the pad1 and pad2.
>
>What is the downside?

It's ugly. Plus user may pass garbage in pads from current apps.
Why you don't just use new attributes? I don't get it.
I still don't understand why people feel need to do struct style message
passing in TLV-designed Netlink interface...
