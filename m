From: "Justin Mattock" <justinmattock@gmail.com>
Subject: Re: stuck tcp connections 2.6.26-rc7
Date: Thu, 26 Jun 2008 22:40:14 +0000
Message-ID: <dd18b0c30806261540l56d68868p1d32597b2f5cb171@mail.gmail.com>
References: <dd18b0c30806241303g755e3881y4ea7d403eb2922fc@mail.gmail.com>
	 <dd18b0c30806242325j4f6d1b1bw1cdde7ea08ad12e2@mail.gmail.com>
	 <2c0942db0806250816r123affb4x4ef17f4773180a10@mail.gmail.com>
	 <20080625.152447.178284093.davem@davemloft.net>
	 <dd18b0c30806251629q78abef79sb5b3d5a1ab17a004@mail.gmail.com>
	 <dd18b0c30806260054p654e4ca9o57bf3e9b20f75907@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ray-lk@madrabbit.org, didier@raboud.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.251]:6689 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753865AbYFZWkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 18:40:15 -0400
Received: by an-out-0708.google.com with SMTP id d40so53823and.103
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2008 15:40:14 -0700 (PDT)
In-Reply-To: <dd18b0c30806260054p654e4ca9o57bf3e9b20f75907@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 26, 2008 at 7:54 AM, Justin Mattock <justinmattock@gmail.com> wrote:
> On Wed, Jun 25, 2008 at 11:29 PM, Justin Mattock
> <justinmattock@gmail.com> wrote:
>> On Wed, Jun 25, 2008 at 10:24 PM, David Miller <davem@davemloft.net> wrote:
>>> From: "Ray Lee" <ray-lk@madrabbit.org>
>>> Date: Wed, 25 Jun 2008 08:16:20 -0700
>>>
>>>> On my system, I've noticed that the flashplugin can manage to starve
>>>> other processes in a pure scheduler sort of way, so you might try
>>>> running latencytop to see if there's some sort of issue there. OTOH,
>>>> I've noticed firefox itself hang for 3-15 seconds in the middle of a
>>>> read (just as you describe), with nothing else going on in the system,
>>>> so <shrug>. I've been blaming firefox, but I could be wrong.
>>>
>>> See if firefox is stuck in disk wait when things get wedged like
>>> this.
>>>
>>
>> Hello; Thanks for the response. I must admit I need to figure out how
>> to do that(disk wait mode with firefox).
>> Aside from that, it seems there are reports of this with the latest
>> and so forth. As a note
>> This explains why and when I plugged in an older kernel that had no
>> problems at all,
>> was suddenly giving me problems, leading me to believe  that my
>> service provider(was bandwidth limiting), or a script kiddie
>> was messing with the line, but this did not seem to be the case; Thankfully.
>> I'll look into it and let you know.
>> regards;
>>
>> --
>> Justin P. Mattock
>>
>
> Hello;
> I must be mature too admit when I'm wrong, (I'm very wrong, and stupid);
>  I was too quick to judge. : (          (apologize firefox)
> I had overlooked one aspect of the situation: "wpa_supplicant",
> After watching wpa_supplicant do it's job, I had noticed that it keeps
> CTRL-EVENT-DISCONNECT - Disconnect event - remove keys,
> and CTRL-EVENT-SCAN-RESULTS and trying to associate with
> XX:XX:XX:XX:XX (SSID= XX freq= 2462 MHz).
> anyways despite the manual jargon of wpa_supplicant; basically
> whenever wpa_supplicant disconnects  and reconnects  the keys
> I had noticed flash player, and any other connection's to stop or even
> pause during the playback, depending on how well the transmission was.
> So for now as for what I can see: wpa_supplicant is the main cause of
> my troubles.
> regards,
>
>
>
> --
> Justin P. Mattock
>

Yep that resolved the issue. i.e. madwifi latest svn and previous
versions has a bug in it to where it is causing wpa_supplicant
to constantly disconnect and connect (re keying event) under heavy
loads resulting in horrible internet connections.
loaded an older version prior to march 08 and voila no problems(knock on wood)
I'll monitor this for a few days, and see what results of it.
-- 
Justin P. Mattock
