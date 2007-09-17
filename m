From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000 driver and samba
Date: Mon, 17 Sep 2007 11:51:23 -0700
Message-ID: <46EECCAB.1020103@intel.com>
References: <780b6f780709131904j41148fb4p827e87530b15d6e9@mail.gmail.com>	<46EAC25B.2060404@intel.com>	<780b6f780709141140l1fd586c9p2aa8efe6ed803d38@mail.gmail.com>	<46EAF644.1040006@intel.com> <46EC1A00.2000304@katalix.com>	<46EC2D5A.7080504@intel.com>	<780b6f780709152106q3d7f1042t72126c1be16ed1fd@mail.gmail.com> <46ECB95F.2090100@intel.com> <46EEC152.8090005@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: L F <lfabio.linux@gmail.com>, James Chapman <jchapman@katalix.com>,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:61179 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759532AbXIQSva (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2007 14:51:30 -0400
In-Reply-To: <46EEC152.8090005@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> Kok, Auke wrote:
>> L F wrote:
>>
>>>>>>> tx_deferred_ok: 486
>>>>
>>>> this one I wonder about, and might cause delays, I'll have to look
>>>> up what it exactly could implicate though.
>>>
>>> Please do and let me know. samba 3.0.26 helped, but the issue is
>>> still there.
>>
>>
>> ok, from the spec: tx_deferred_ok is what is in the DC stats register.
>> DC stands
>> for "Deferred Count". This initially is meant to track how often the
>> TX unit cannot
>> send because the medium is busy in a Half-Duplex link state.
>>
>> To me it suggests that your speed is not full-duplex. Check `ethtool
>> eth0` output
>> and see if your link is full duplex or not. also check previous kernel
>> messages
>> and see what the e1000 driver posted there for link speed messages (as
>> in "e1000:
>>  Link is UP speed XXX duplex YYY")
> 
> Shouldn't there then have been at least _some_ collisions reported in
> the stats?  And perhaps some late collisions?

well, from the documentation it sounds like the link was half-duplex, but
LF reported that it's not. This then points towards a medium issue (bad
cable) and after he replaced the cable, the issue went away (?).

I still don't fully grasp the reason why this counter would increment and
will investigate possibilities for that. My current suspicion is a physical
problem, most likely cable-related.

Auke
