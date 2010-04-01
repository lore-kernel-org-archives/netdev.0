From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/5] netfilter: xt_TEE: have cloned packet travel through
 Xtables too
Date: Thu, 01 Apr 2010 13:09:30 +0200
Message-ID: <4BB47EEA.4020809@trash.net>
References: <1270031934-15940-1-git-send-email-jengelh@medozas.de> <1270031934-15940-6-git-send-email-jengelh@medozas.de> <4BB47768.1050405@trash.net> <alpine.LSU.2.01.1004011258060.17429@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1004011258060.17429@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> On Thursday 2010-04-01 12:37, Patrick McHardy wrote:
> 
>> Jan Engelhardt wrote:
>>> Since Xtables is now reentrant/nestable, the cloned packet can also go
>>> through Xtables and be subject to rules itself.
>> That sounds dangerous if conntrack isn't used to prevent loops.
> 
> Conntrack loops are prevented by using a dummy conntrack, just as 
> NOTRACK does.

My question was about the case without conntrack.

>> Is that really useful? For filtering, you can simply apply the
>> rules before deciding to TEE the packet.
> 
> I can think of a handful of applications:
>  - CLASSIFY

Good point, you should probably reset a couple of skb members
after the skb_copy().

>  - When the cloned packets gets XFRMed or tunneled, its status switches 
>    from "special" to "plain". Doing policy routing on them does not seem 
>    so far-fetched.

Fair enough, provided we can also handle loops when conntrack
isn't used.
