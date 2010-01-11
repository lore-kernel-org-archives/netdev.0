From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 1/1] rps: core implementation
Date: Mon, 11 Jan 2010 10:00:53 +0100
Message-ID: <4B4AE8C5.9010406@gmail.com>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>	 <20091120154046.67252d23@nehalam>	 <65634d660912171304p751e1698mbc9de50dade4317d@mail.gmail.com>	 <65634d661001051732qd64e79dt37e6247f8b0dc863@mail.gmail.com>	 <4B44258C.2050302@gmail.com> <4B44D89B.8070006@gmail.com>	 <65634d661001061454v389d311fjb245de21e0ab8092@mail.gmail.com>	 <4B45A623.7070507@gmail.com> <65634d661001102225t226c07bfg2ff0482150b4a18a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60492 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752432Ab0AKJBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 04:01:01 -0500
In-Reply-To: <65634d661001102225t226c07bfg2ff0482150b4a18a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 11/01/2010 07:25, Tom Herbert a =E9crit :
> Eric, patch below has some more minor fixes per your latest comments.
>=20
> - added variables for rps_map_size and rps_cpus_in_map for efficiency
> - added preempt_disable/enable around __smp_call_function_single to
> prevent CPUs from being removed during this action (hotplug fix)
> - check cpu_online before calling __smp_call_function_single (also
> hotplug related)
> - do rcu_read_lock instead of rcu_read_lock_bh in store_rps_cpus
> - don't do rcu_derefence in store_rps_cpus
>=20
> Thanks,
> Tom

Tom, I am currently running one production server with this version,
everything seems fine so far.

(Only problem is with your mail program, some lines were folded, and
I had to manually adjust your patch to apply it...)

I also did one small change :

Since struct softnet_data is now aligned to a cache line boundary, its =
better
to move it to appropriate section (to avoid adding holes in percpu sect=
ion,
because linker is not very smart)

-DEFINE_PER_CPU(struct softnet_data, softnet_data);
+DEFINE_PER_CPU_ALIGNED(struct softnet_data, softnet_data);


I believe its ready for inclusion, but of course David should take
a look before :)

Could you post it formally with the appropriate ChangeLog with a nice
RPS description, so that other people can ack it ?

Thanks !
