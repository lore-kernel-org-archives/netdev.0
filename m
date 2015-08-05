From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: veths often slow to come up
Date: Tue, 4 Aug 2015 20:26:28 -0700
Message-ID: <CAM_iQpV6ZjKWmy8ou6xM=fP8gfE19cS9r=YT4P2xW7rBJwAyZA@mail.gmail.com>
References: <D1E67FCC.3FA19%Shaun.Crampton@metaswitch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Shaun Crampton <Shaun.Crampton@metaswitch.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <D1E67FCC.3FA19%Shaun.Crampton@metaswitch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Cc'ing netdev for network issues)

On Tue, Aug 4, 2015 at 6:42 AM, Shaun Crampton
<Shaun.Crampton@metaswitch.com> wrote:
> Please CC me on any responses, thanks.
>
> Setting both ends of a veth to be oper UP completes very quickly but =
I
> find that pings only start flowing over the veth after about a second=
=2E
> This seems to correlate with the NO-CARRIER flag being set or the
> interface being in "state UNKNOWN" or "state DOWN=C2=B2 for about a s=
econd
> (demo script below).
>
> If I run the script repeatedly then sometimes it completes very quick=
ly on
> subsequent runs as if there=C2=B9s a hot cache somewhere.
>
> Could this be a bug or is there a configuration to speed this up?  Se=
ems
> odd that it=C2=B9s almost exactly 1s on the first run.
>
> Seen on these kernels:
> * 3.13.0-57-generic #95-Ubuntu SMP Fri Jun 19 09:28:15 UTC 2015 x86_6=
4
> x86_64 x86_64 GNU/Linux
> * 4.0.9-coreos #2 SMP Thu Jul 30 01:07:55 UTC 2015 x86_64 Intel(R) Xe=
on(R)
> CPU @ 2.50GHz GenuineIntel GNU/Linux
>
> Regards,
>
> -Shaun
>
>
> Running my test script below (Assumes veth0/1 do not already exist):
>
> $ sudo ./veth-test.sh
> Time to create veth:
>
> real    0m0.019s
> user    0m0.002s
> sys     0m0.010s
>
> Time to wait for carrier:
>
> real    0m1.005s
> user    0m0.007s
> sys     0m0.123s
>
>
>
> # veth-test.sh
>
> #!/bin/bash
> function create_veth {
>   ip link add type veth
>   ip link set veth0 up
>   ip link set veth1 up
> }
> function wait_for_carrier {
>   while ! ip link show | grep -qE 'veth[01]';
>   do
>     sleep 0.05
>   done
>   while ip link show | grep -E 'veth[01]=C2=B9 | \
>         grep -Eq 'NO-CARRIER|state DOWN|state UNKNOWN';
>   do
>     sleep 0.05
>   done
> }
> echo "Time to create veth:"
> time create_veth
> echo
> echo "Time to wait for carrier:"
> time wait_for_carrier
> ip link del veth0
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
