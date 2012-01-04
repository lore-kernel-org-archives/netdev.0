From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [PATCH] netfilter: Fix br_nf_pre_routing() in conjunction with
 bridge-nf-call-ip(6)tables=0
Date: Wed, 04 Jan 2012 18:55:28 +0100
Message-ID: <4F049290.3090803@pandora.be>
References: <4F025A07.2000304@nod.at> <1325597164-13459-1-git-send-email-richard@nod.at> <1325597164-13459-2-git-send-email-richard@nod.at> <20120103081521.2fec3a29@nehalam.linuxnetplumber.net> <4F033E11.5060707@nod.at> <4F0361D7.3000602@pandora.be> <4F03650D.8050200@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, davem@davemloft.net,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Richard Weinberger <richard@nod.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F03650D.8050200@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Op 3/01/2012 21:29, Richard Weinberger schreef:
> Am 03.01.2012 21:15, schrieb Bart De Schuymer:
>> The documentation is probably not explicit enough, but I would keep the
>> behavior as it is now. Setting bridge-nf-call-iptables to 0 makes
>> iptables behave as if bridge-netfilter was not enabled at compilation.
>> Anyway, your patch is almost certainly flawed since the fact that
>> skb->nf_bridge can be NULL is used as part of the logic in
>> br_netfilter.c: it indicates that bridge-nf-call-iptables was 0 when the
>> packet was first processed by bridge-netfilter and should therefore not
>> be given to iptables in any other netfilter hook.
> Thanks for the explanation!
>
> Wouldn't it make sense to check for bridge-nf-call-iptables in xt_physdev?
> So that the user gets warned that his iptables rule will never match...

We don't want to introduce module dependencies between the bridge module 
and the iptables physdev match.
We could add a message to the syslog whenever these proc settings are 
changed (in br_netfilter.c::brnf_sysctl_call_tables()).

cheers,
Bart


-- 
Bart De Schuymer
www.artinalgorithms.be
