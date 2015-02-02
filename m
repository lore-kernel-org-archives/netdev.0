From: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Mon, 2 Feb 2015 11:27:15 +0100
Message-ID: <CA+BoTQkV+mOZfe_Niz5101sMQeaV6muKCsShptjGQ1AgOHqqoQ@mail.gmail.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
	<1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQk2xT-8DqPuiiKG+kHAjLPrj8F9dLTb-rcGhvMq0u_2Qw@mail.gmail.com>
	<1422628835.21689.95.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	eyalpe-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1422628835.21689.95.camel-XN9IlZ5yJG9HTL0Zs8A6p/gx64E7kk8eUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 30 January 2015 at 15:40, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrot=
e:
> On Fri, 2015-01-30 at 14:39 +0100, Michal Kazior wrote:
>
>> I've briefly tried playing with this knob to no avail unfortunately.=
 I
>> tried 256K, 1M - it didn't improve TCP performance. When I tried to
>> make it smaller (e.g. 16K) the traffic dropped even more so it does
>> have an effect. It seems there's some other limiting factor in this
>> case.
>
> Interesting.
>
> Could you take some tcpdump/pcap with various tcp_limit_output_bytes
> values ?
>
> echo 131072 >/proc/sys/net/ipv4/tcp_limit_output_bytes
> tcpdump -p -i wlanX -s 128 -c 20000 -w 128k.pcap
>
> echo 262144 >/proc/sys/net/ipv4/tcp_limit_output_bytes
> tcpdump -p -i wlanX -s 128 -c 20000 -w 256k.pcap

I've run a couple of tests across different kernels. This got pretty
big so I decided to use an external file hosting:
 http://www.filedropper.com/testtar

Let me know if you can't access it (and perhaps you could suggest how
you prefer the logs to be delivered in that case).

The layout of logs is: $kernel/$limit-P$threads.pcap. I've also
included the test script and output of each test run.

While testing I've had my internal GRO patch for ath10k and no stretch
ack patches.

When I was trying to come up with a testing methodology I've noticed
something interesting:
 1. set 16k limit
 2. start iperf -P1
 3. observe 200mbps
 4. set 2048k limit (while iperf is running)
 5. observe 600mbps
 6. set 16limit back (while iperf is running)
 7. observe 500-600mbps (i.e. no drop to 200mbps)

Due to that I've decided to re-start iperf for each limit test.

If you want me to gather some other logs/dumps/configuration
permutations let me know, please.


Micha=C5=82
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
