From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: 32 core net-next stack/netfilter "scaling"
Date: Tue, 27 Jan 2009 23:17:11 +0100
Message-ID: <497F87E7.2000304@cosmosbay.com>
References: <497E361B.30909@hp.com>	<497E42F4.7080201@cosmosbay.com>	<497E44F6.2010703@hp.com>	<497ECF84.1030308@cosmosbay.com>	<497ED0A2.6050707@trash.net>	<497F350A.9020509@cosmosbay.com>	<497F457F.2050802@trash.net> <497F4C2F.9000804@hp.com> <497F5BCD.9060807@hp.com> <497F5F86.9010101@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <497F5F86.9010101@hp.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones a =E9crit :
>>> I will give it a try and let folks know the results - unless told=20
>>> otherwise, I will ass-u-me I only need rerun the "full_iptables"=20
>>> test case.
>>
>>
>> The runemomniagg2.sh script is still running, but the initial cycles=
=20
>> profile suggests that the main change is converting the write_lock=20
>> time into spinlock contention time with 78.39% of the cycles spent i=
n=20
>> ia64_spinlock_contention. When the script completes I'll upload the=20
>> profiles and the netperf results to the same base URL as in the=20
>> basenote under "contrack01/"
>
> The script completed - although at some point I hit an fd limit - I=20
> think I have an fd leak in netperf somewhere :( .
>
> Anyhow, there are still some netperfs that end-up kicking the bucket=20
> during the run - I suspect starvation because where in the other=20
> configs (no iptables, and empty iptables) each netperf seems to=20
> consume about 50% of a CPU - stands to reason - 64 netperfs, 32 cores=
=20
> - in the "full" case I see many netperfs consuming 100% of a CPU.  My=
=20
> gut is thinking that one or more netperf contexts gets stuck doing=20
> something on behalf of others.  There is also ksoftirqd time for a fe=
w=20
> of those processes.
>
> Anyhow, the spread on trans/s/netperf is now 600 to 500 or 6000, whic=
h=20
> does represent an improvement.
>
> rick jones
>
> PS - just to be certain that running-out of fd's didn't skew the=20
> results I'm rerunning the script with ulimit -n 10240 and will see if=
=20
> that changes the results any.  And I suppose I need to go fd leak=20
> hunting in netperf omni code :(
> --=20
>

Thanks for the report

If you have so much contention on spinlocks, maybe hash function is not=
=20
good at all...

hash =3D (unsigned long)ct;
hash ^=3D hash >> 16;
hash ^=3D hash >> 8;

I ass-u-me you compiled your kernel with NR_CPUS=3D32 ?

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
