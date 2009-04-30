From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [BUG] perf_counter: change cpu frequencies
Date: Thu, 30 Apr 2009 18:07:44 +0200
Message-ID: <49F9CCD0.2080005@cosmosbay.com>
References: <49F71B63.8010503@cosmosbay.com> <alpine.DEB.1.10.0904281501300.13862@qirst.com> <49F76174.6060009@cosmosbay.com> <alpine.DEB.1.10.0904281612560.13862@qirst.com> <49F767FD.2040205@cosmosbay.com> <alpine.DEB.1.10.0904281629090.15947@qirst.com> <49F76F6C.80005@cosmosbay.com> <49F77108.7060509@cosmosbay.com> <20090429091130.GA27857@elte.hu> <49F9821C.5010802@cosmosbay.com> <20090430115736.GA24349@elte.hu> <49F9B0F0.40306@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux.com>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, haoki@redhat.com, mchan@broadcom.com,
	davidel@xmailserver.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55318 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756798AbZD3QI6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 12:08:58 -0400
In-Reply-To: <49F9B0F0.40306@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
=20
> But if I use plain "perf stat -a sleep 10"
> it seems I get wrong values again (16 G cycles/sec) for all next perf=
 sessions
>=20

Well, I confirm all my cpus switched from 3GHz to 2GHz, after

"perf stat -a sleep 10"

(but "perf stat -e instructions -e cycles -a sleep 10" doesnt trigger t=
his problem)

Nothing logged, and /proc/cpuinfo stills reports 3 GHz frequencies

# cat unit.c
main() {
  int i;
  for (i =3D 0 ; i < 10000000; i++)
        getppid();
}
# time ./unit

real    0m0.818s
user    0m0.289s
sys     0m0.529s
# perf stat -a sleep 10 2>/dev/null
# time ./unit

real    0m1.122s
user    0m0.482s
sys     0m0.640s

# tail -n 27 /proc/cpuinfo
processor       : 7
vendor_id       : GenuineIntel
cpu family      : 6
model           : 23
model name      : Intel(R) Xeon(R) CPU           E5450  @ 3.00GHz
stepping        : 6
cpu MHz         : 3000.102
cache size      : 6144 KB
physical id     : 1
siblings        : 1
core id         : 3
cpu cores       : 4
apicid          : 7
initial apicid  : 7
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 10
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge =
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe lm c=
onstant_tsc arch_perfmon pebs bts pni dtes64 monitor ds_cpl vmx est tm2=
 ssse3 cx16 xtpr pdcm dca sse4_1 lahf_lm tpr_shadow vnmi flexpriority
bogomips        : 6000.01
clflush size    : 64
power management:

# grep CPU_FREQ .config
# CONFIG_CPU_FREQ is not set


perf_counter seems promising, but still... needs some bug hunting :)

Thank you

