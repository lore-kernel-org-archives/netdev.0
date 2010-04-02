From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 5/5] netfilter: xt_TEE: have cloned packet travel through
 Xtables too
Date: Fri, 2 Apr 2010 20:15:21 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1004022013230.14322@obet.zrqbmnf.qr>
References: <1270031934-15940-1-git-send-email-jengelh@medozas.de> <1270031934-15940-6-git-send-email-jengelh@medozas.de> <4BB47768.1050405@trash.net> <alpine.LSU.2.01.1004011258060.17429@obet.zrqbmnf.qr> <4BB47EEA.4020809@trash.net>
 <alpine.LSU.2.01.1004011511180.1174@obet.zrqbmnf.qr> <4BB49E10.8080608@trash.net> <alpine.LSU.2.01.1004011543260.1174@obet.zrqbmnf.qr> <4BB4A41C.7030107@trash.net> <alpine.LSU.2.01.1004011557270.5368@obet.zrqbmnf.qr> <4BB4A796.8010708@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4BB4A796.8010708@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thursday 2010-04-01 16:03, Patrick McHardy wrote:
>>>>[detecting teed packets getting teed again by means of
>>>> iptables -A OUTPUT -j TEE]
>>>
>>> What's wrong with adding a reentrancy counter?
>> 
>> Sounds like a plan.

Should we be using a percpu variable, or is a simplistic
array ok too?

static bool tee_active;

target(...)
{
	if (tee_active[smp_processor_id()])
		return XT_CONTINUE;
	...
	if (tee_tg4_route(...)) {
		tee_active[cpu] = true;
		ip_local_out(skb);
		tee_active[cpu] = false;
	}
}


