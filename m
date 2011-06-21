From: Prarit Bhargava <prarit@redhat.com>
Subject: Re: [PATCH]: Add Network Sysrq Support
Date: Tue, 21 Jun 2011 18:26:30 -0400
Message-ID: <4E011A96.7050509@redhat.com>
References: <20110621130040.12035.62533.sendpatchset@prarit.bos.redhat.com> <4E0115B3.2030802@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, agospoda@redhat.com,
	nhorman@redhat.com, lwoodman@redhat.com
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50378 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752903Ab1FUW0c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 18:26:32 -0400
In-Reply-To: <4E0115B3.2030802@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>> + * Note that the network sysrq automatically disables after the receipt of
>> + * *ANY* ping.  If you want to use this again, you must complete the
>> + * above four steps again.
>>     
>   

Hi Flavio,

> why not leave it running? perhaps disable it for some time to
> filter any ping retransmission, for instance netsysrq_reenable=10 seconds. 
> and then do if (time_after(jiffies, last_ping + netsysrq_reenable))...
>
>   

To be honest I have no objection to that, except that I thought the
community's objection would be about the security of this code -- I
specifically set out to make this as secure as I could (multiple
enabling steps, 30 digit hash, single-shot mode).

With your method someone *theoretically* could ping -p a system and
eventually crash it.  Of course anyone using this in production is crazy
and probably would end up getting what they deserved ;)

I'm certainly willing to consider your proposal -- but I have a feeling
that people would want this in single-shot mode over a rearming-mode.

> I have an USB KVM console, so often when testing workload, the USB takes
> ages to register the keyboard and I'd like to shot some sysrq+t or w,
> so if it disables after the first one, I can't get more traces because
> I simply can't enable it again.
>
>   

Yup.  One of the thoughts was to have the enable sysfs file take a
number from 1 to 5, which would become a countdown.  I thought it better
to get the base code in than muddy the waters with a potentially risky
(security-wise) proposal. (see later comment on ping flooding)

>   
>>     
>
> What about a whitelist of source MAC or IP addresses to accept the sysrq?
>   

Oh ... that's a great idea :).  I'll think about that for a later
enhancement if that's okay.  One of the other ideas that came up during
discussion was a maskfile of some sort that indicated what sysrq options
were available (maybe you *don't* want a sysrq-c to be executed).

> I'm thinking on a situation where we leave the systems with this enabled
> and then an ordinary user starts pinging the network guessing the hexa to
> cause reboots.
>
>   

Good point Flavio, but that's *exactly* why I wrote this in single-shot
mode.  I really think the code might be a bit too risky for most people
to deploy in production environments.  It's too risky for me to let
someone ping and ping and ping until they luckily hit the magic number
and figure out how to bring *all* of my systems down.  What are the
chances that a lab admin is smart enough to set the password to
different numbers across different machines in a single lab?

P.
