From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [LKP] [net] 4ed2d765dfa:  ltp.recv01.4.TFAIL
Date: Wed, 1 Oct 2014 23:29:10 +0800
Message-ID: <20141001152910.GA4440@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="+HP7ph2BbKc20aGI"
Content-Transfer-Encoding: 8bit
Cc: Dave Hansen <dave.hansen@intel.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, lkp@01.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:4376 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751283AbaJAPa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2014 11:30:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--+HP7ph2BbKc20aGI
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

Hi Willem,

FYI, we noticed the below LTP failures on commit

4ed2d765dfaccff5ebdac68e2064b59125033a3b ("net-timestamp: TCP timestamping")

test case: nhm-white/ltp/syscalls
nhm-white is a Nehalem box with 6G memory.

e7fd2885385157d  4ed2d765dfaccff5ebdac68e2 
---------------  ------------------------- 
         0           +Inf%          1 ± 0%  TOTAL ltp.recv01.4.TFAIL
         0           +Inf%          1 ± 0%  TOTAL ltp.recvfrom01.4.TFAIL
         0           +Inf%          1 ± 0%  TOTAL ltp.recvfrom01.6.TFAIL
         0           +Inf%          1 ± 0%  TOTAL ltp.recvmsg01.9.TFAIL


                               ltp.recvmsg01.9.TFAIL

    1 O+-O-O--O-O--O--O-O--O-O--O----O--O-O--O-O--O----O--O-O--O--O-O--O-O--O
      |                                                                     |
      |                                                                     |
  0.8 ++                                                                    |
      |                                                                     |
      |                                                                     |
  0.6 ++                                                                    |
      |                                                                     |
  0.4 ++                                                                    |
      |                                                                     |
      |                                                                     |
  0.2 ++                                                                    |
      |                                                                     |
      |                                                                     |
    0 ++---------------------------O-----------------O----------------------+

	[*] bisect-good sample
	[O] bisect-bad  sample

To reproduce:

	apt-get install ruby ruby-oj
	git clone git://git.kernel.org/pub/scm/linux/kernel/git/wfg/lkp-tests.git
	cd lkp-tests
	bin/setup-local job.yaml # the job file attached in this email
	bin/run-local   job.yaml

Thanks,
Fengguang

--+HP7ph2BbKc20aGI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="job.yaml"

---
testcase: ltp
default_monitors:
  wait: pre-test
  vmstat: 
commit: 0f33be009b89d2268e94194dc4fd01a7851b6d51
cpufreq_governor: 
model: Nehalem
memory: 6G
hdd_partitions: "/dev/disk/by-id/ata-Hitachi_HDT721050SLA360_STH3D7ME0YEM5Y-part5
  /dev/disk/by-id/ata-Hitachi_HDT721050SLA360_STH3D7ME0YEM5Y-part6 /dev/disk/by-id/ata-Hitachi_HDT721050SLA360_STH3D7ME0YEM5Y-part7
  /dev/disk/by-id/ata-Hitachi_HDT721050SLA360_STH3D7ME0YEM5Y-part8"
swap_partitions: 
rootfs_partition: "/dev/disk/by-id/ata-Hitachi_HDT721050SLA360_STH3D7ME0YEM5Y-part2"
ltp:
  test:
  - syscalls
enqueue_time: 2014-09-27 14:15:30.529287140 +08:00
testbox: nhm-white
kconfig: x86_64-rhel
head_commit: 3ec2e1eb7329693596b4732dbf8e022891e38e20
base_commit: 0f33be009b89d2268e94194dc4fd01a7851b6d51
branch: linux-devel/devel-hourly-2014092716
kernel: "/kernel/x86_64-rhel/0f33be009b89d2268e94194dc4fd01a7851b6d51/vmlinuz-3.17.0-rc6-dirty"
user: lkp
queue: cyclic
result_root: "/result/nhm-white/ltp/syscalls/debian-x86_64.cgz/x86_64-rhel/0f33be009b89d2268e94194dc4fd01a7851b6d51/0"
job_file: "/lkp/scheduled/nhm-white/cyclic_ltp-syscalls-x86_64-rhel-BASE-0f33be009b89d2268e94194dc4fd01a7851b6d51-0.yaml"
dequeue_time: 2014-09-27 19:17:52.999461520 +08:00
job_state: finished
loadavg: 8.07 14.80 7.38 1/129 30421
start_time: '1411816704'
end_time: '1411817214'
version: "/lkp/lkp/.src-20140927-095204"

--+HP7ph2BbKc20aGI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=reproduce

./runltp -f syscalls

--+HP7ph2BbKc20aGI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=ltp

2014-09-28 17:08:48 ./runltp -f syscalls
INFO: creating /lkp/benchmarks/ltp/output directory
INFO: creating /lkp/benchmarks/ltp/results directory
Checking for required user/group ids

'nobody' user id and group found.
'bin' user id and group found.
'daemon' user id and group found.
Users group found.
Sys group found.
Required users/groups exist.
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.
 
PRETTY_NAME="Debian GNU/Linux jessie/sid"
NAME="Debian GNU/Linux"
ID=debian
ANSI_COLOR="1;31"
HOME_URL="http://www.debian.org/"
SUPPORT_URL="http://www.debian.org/support/"
BUG_REPORT_URL="http://bugs.debian.org/"
Linux nhm-white 3.17.0-rc6-dirty #1 SMP Thu Sep 25 13:22:59 CST 2014 x86_64 GNU/Linux
 
Gnu C                 
Gnu make               4.0
util-linux             linux 2.20.1
mount                  linux 2.20.1 (with libblkid and selinux support)
modutils               9
e2fsprogs              1.42.8
Linux C Library        > libc.2.17
Dynamic linker (ldd)   2.17
Procps                 3.3.8
Net-tools              1.60
iproute2              iproute2-ss120521
Kbd                    69:
Sh-utils               8.21
Modules Loaded         ipmi_watchdog ipmi_msghandler nfsd auth_rpcgss dm_mod fuse sd_mod crct10dif_generic crc_t10dif crct10dif_common sg sr_mod cdrom dcdbas ata_generic pata_acpi serio_raw pcspkr ata_piix i7core_edac libata usb_storage edac_core i2c_i801 snd_hda_codec_realtek snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_controller firewire_ohci snd_hda_codec firewire_core snd_hwdep crc_itu_t snd_pcm snd_timer snd soundcore broadcom

free reports:
             total       used       free     shared    buffers     cached
Mem:       6100504     724796    5375708          0          0     588300
-/+ buffers/cache:     136496    5964008
Swap:            0          0          0

/proc/cpuinfo
processor	: 0
vendor_id	: GenuineIntel
cpu family	: 6
model		: 30
model name	: Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz
stepping	: 5
microcode	: 0x3
cpu MHz		: 2925.998
cache size	: 8192 KB
physical id	: 0
siblings	: 8
core id		: 0
cpu cores	: 4
apicid		: 0
initial apicid	: 0
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm dtherm tpr_shadow vnmi flexpriority ept vpid
bugs		:
bogomips	: 5851.99
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 1
vendor_id	: GenuineIntel
cpu family	: 6
model		: 30
model name	: Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz
stepping	: 5
microcode	: 0x3
cpu MHz		: 2925.998
cache size	: 8192 KB
physical id	: 0
siblings	: 8
core id		: 1
cpu cores	: 4
apicid		: 2
initial apicid	: 2
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm dtherm tpr_shadow vnmi flexpriority ept vpid
bugs		:
bogomips	: 5851.99
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 2
vendor_id	: GenuineIntel
cpu family	: 6
model		: 30
model name	: Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz
stepping	: 5
microcode	: 0x3
cpu MHz		: 2925.998
cache size	: 8192 KB
physical id	: 0
siblings	: 8
core id		: 2
cpu cores	: 4
apicid		: 4
initial apicid	: 4
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm dtherm tpr_shadow vnmi flexpriority ept vpid
bugs		:
bogomips	: 5851.99
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 3
vendor_id	: GenuineIntel
cpu family	: 6
model		: 30
model name	: Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz
stepping	: 5
microcode	: 0x3
cpu MHz		: 2925.998
cache size	: 8192 KB
physical id	: 0
siblings	: 8
core id		: 3
cpu cores	: 4
apicid		: 6
initial apicid	: 6
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm dtherm tpr_shadow vnmi flexpriority ept vpid
bugs		:
bogomips	: 5851.99
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 4
vendor_id	: GenuineIntel
cpu family	: 6
model		: 30
model name	: Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz
stepping	: 5
microcode	: 0x3
cpu MHz		: 2925.998
cache size	: 8192 KB
physical id	: 0
siblings	: 8
core id		: 0
cpu cores	: 4
apicid		: 1
initial apicid	: 1
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm dtherm tpr_shadow vnmi flexpriority ept vpid
bugs		:
bogomips	: 5851.99
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 5
vendor_id	: GenuineIntel
cpu family	: 6
model		: 30
model name	: Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz
stepping	: 5
microcode	: 0x3
cpu MHz		: 2925.998
cache size	: 8192 KB
physical id	: 0
siblings	: 8
core id		: 1
cpu cores	: 4
apicid		: 3
initial apicid	: 3
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm dtherm tpr_shadow vnmi flexpriority ept vpid
bugs		:
bogomips	: 5851.99
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 6
vendor_id	: GenuineIntel
cpu family	: 6
model		: 30
model name	: Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz
stepping	: 5
microcode	: 0x3
cpu MHz		: 2925.998
cache size	: 8192 KB
physical id	: 0
siblings	: 8
core id		: 2
cpu cores	: 4
apicid		: 5
initial apicid	: 5
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm dtherm tpr_shadow vnmi flexpriority ept vpid
bugs		:
bogomips	: 5851.99
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

processor	: 7
vendor_id	: GenuineIntel
cpu family	: 6
model		: 30
model name	: Intel(R) Core(TM) i7 CPU         870  @ 2.93GHz
stepping	: 5
microcode	: 0x3
cpu MHz		: 2925.998
cache size	: 8192 KB
physical id	: 0
siblings	: 8
core id		: 3
cpu cores	: 4
apicid		: 7
initial apicid	: 7
fpu		: yes
fpu_exception	: yes
cpuid level	: 11
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 popcnt lahf_lm dtherm tpr_shadow vnmi flexpriority ept vpid
bugs		:
bogomips	: 5851.99
clflush size	: 64
cache_alignment	: 64
address sizes	: 36 bits physical, 48 bits virtual
power management:

no big block device was specified on commandline.
Tests which require a big block device are disabled.
You can specify it with option -z
COMMAND:    /lkp/benchmarks/ltp/bin/ltp-pan  -e -S   -a 1855     -n 1855  -p  -f /tmp/ltp-EAlAM7imVE/alltests -l /lkp/benchmarks/ltp/results/LTP_RUN_ON-2014_09_28-17h_08m_48s.log  -C /lkp/benchmarks/ltp/output/LTP_RUN_ON-2014_09_28-17h_08m_48s.failed -T /lkp/benchmarks/ltp/output/LTP_RUN_ON-2014_09_28-17h_08m_48s.tconf
LOG File: /lkp/benchmarks/ltp/results/LTP_RUN_ON-2014_09_28-17h_08m_48s.log
FAILED COMMAND File: /lkp/benchmarks/ltp/output/LTP_RUN_ON-2014_09_28-17h_08m_48s.failed
TCONF COMMAND File: /lkp/benchmarks/ltp/output/LTP_RUN_ON-2014_09_28-17h_08m_48s.tconf
Running tests.......
<<<test_start>>>
tag=abort01 stime=1411895329
cmdline="abort01"
contacts=""
analysis=exit
<<<test_output>>>
abort01     0  TINFO  :  Adjusting RLIMIT_CORE to 1048576
abort01     1  TPASS  :  abort dumped core
abort01     2  TPASS  :  abort raised SIGIOT
abort01     3  TPASS  :  abort dumped core
abort01     4  TPASS  :  abort raised SIGIOT
abort01     5  TPASS  :  abort dumped core
abort01     6  TPASS  :  abort raised SIGIOT
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=accept01 stime=1411895329
cmdline="accept01"
contacts=""
analysis=exit
<<<test_output>>>
accept01    1  TPASS  :  bad file descriptor successful
accept01    2  TPASS  :  bad file descriptor successful
accept01    3  TPASS  :  invalid socket buffer successful
accept01    4  TPASS  :  invalid salen successful
accept01    5  TPASS  :  invalid salen successful
accept01    6  TPASS  :  no queued connections successful
accept01    7  TPASS  :  UDP accept successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=accept4_01 stime=1411895329
cmdline="accept4_01"
contacts=""
analysis=exit
<<<test_output>>>
accept04_01    1  TPASS  :  Test passed
accept04_01    2  TPASS  :  Test passed
accept04_01    3  TPASS  :  Test passed
accept04_01    4  TPASS  :  Test passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=access01 stime=1411895329
cmdline="access01"
contacts=""
analysis=exit
<<<test_output>>>
access01    1  TPASS  :  access(accessfile, F_OK) returned 0
access01    2  TPASS  :  access(accessfile, X_OK) returned 0
access01    3  TPASS  :  access(accessfile, W_OK) returned 0
access01    4  TPASS  :  access(accessfile, R_OK) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=access02 stime=1411895329
cmdline="access02"
contacts=""
analysis=exit
<<<test_output>>>
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=access03 stime=1411895329
cmdline="access03"
contacts=""
analysis=exit
<<<test_output>>>
access03    1  TPASS  :  access(0x7f2706497000, R_OK) failed as expected with EFAULT
access03    2  TPASS  :  access(0x7f2706497000, W_OK) failed as expected with EFAULT
access03    3  TPASS  :  access(0x7f2706497000, X_OK) failed as expected with EFAULT
access03    4  TPASS  :  access(0x7f2706497000, F_OK) failed as expected with EFAULT
access03    5  TPASS  :  access(0x1a5b001, R_OK) failed as expected with EFAULT
access03    6  TPASS  :  access(0x1a5b001, W_OK) failed as expected with EFAULT
access03    7  TPASS  :  access(0x1a5b001, X_OK) failed as expected with EFAULT
access03    8  TPASS  :  access(0x1a5b001, F_OK) failed as expected with EFAULT
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=access04 stime=1411895329
cmdline="access04"
contacts=""
analysis=exit
<<<test_output>>>
access04    1  TPASS  :  functionality of access(testdir/testfile, F_OK) ok
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=access05 stime=1411895329
cmdline="access05"
contacts=""
analysis=exit
<<<test_output>>>
access05    1  TPASS  :  access failed as expected: TEST_ERRNO=EACCES(13): Permission denied
access05    2  TPASS  :  access failed as expected: TEST_ERRNO=EACCES(13): Permission denied
access05    3  TPASS  :  access failed as expected: TEST_ERRNO=EACCES(13): Permission denied
access05    4  TPASS  :  access failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
access05    5  TPASS  :  access failed as expected: TEST_ERRNO=EFAULT(14): Bad address
access05    6  TPASS  :  access failed as expected: TEST_ERRNO=EFAULT(14): Bad address
access05    7  TPASS  :  access failed as expected: TEST_ERRNO=ENOENT(2): No such file or directory
access05    8  TPASS  :  access failed as expected: TEST_ERRNO=ENAMETOOLONG(36): File name too long
access05    9  TPASS  :  access failed as expected: TEST_ERRNO=ENOTDIR(20): Not a directory
access05   10  TPASS  :  access failed as expected: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=access06 stime=1411895329
cmdline="access06"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
access06    0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
access06    0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
access06    1  TPASS  :  access failed as expected: TEST_ERRNO=EROFS(30): Read-only file system
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=acct01 stime=1411895329
cmdline="acct01"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
acct01      0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
acct01      0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
acct01      1  TPASS  :  acct failed as expected: TEST_ERRNO=EISDIR(21): Is a directory
acct01      2  TPASS  :  acct failed as expected: TEST_ERRNO=EACCES(13): Permission denied
acct01      3  TPASS  :  acct failed as expected: TEST_ERRNO=ENOENT(2): No such file or directory
acct01      4  TPASS  :  acct failed as expected: TEST_ERRNO=ENOTDIR(20): Not a directory
acct01      5  TPASS  :  acct failed as expected: TEST_ERRNO=EPERM(1): Operation not permitted
acct01      6  TPASS  :  acct failed as expected: TEST_ERRNO=EPERM(1): Operation not permitted
acct01      7  TPASS  :  acct failed as expected: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
acct01      8  TPASS  :  acct failed as expected: TEST_ERRNO=ENAMETOOLONG(36): File name too long
acct01      9  TPASS  :  acct failed as expected: TEST_ERRNO=EROFS(30): Read-only file system
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=add_key01 stime=1411895329
cmdline="add_key01"
contacts=""
analysis=exit
<<<test_output>>>
add_key01    1  TPASS  :  add_key call succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=add_key02 stime=1411895329
cmdline="add_key02"
contacts=""
analysis=exit
<<<test_output>>>
add_key02    1  TPASS  :  called add_key() with wrong args got EXPECTED errno: TEST_ERRNO=EINVAL(22): Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=adjtimex01 stime=1411895329
cmdline="adjtimex01"
contacts=""
analysis=exit
<<<test_output>>>
adjtimex01    1  TPASS  :  adjtimex() with mode 16447 returned 5
adjtimex01    2  TPASS  :  adjtimex() with mode 32769 returned 5
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=adjtimex02 stime=1411895329
cmdline="adjtimex02"
contacts=""
analysis=exit
<<<test_output>>>
adjtimex02    1  TPASS  :  Test Passed, adjtimex() returned -1: TEST_ERRNO=EFAULT(14): Bad address
adjtimex02    2  TPASS  :  Test Passed, adjtimex() returned -1: TEST_ERRNO=EINVAL(22): Invalid argument
adjtimex02    3  TPASS  :  Test Passed, adjtimex() returned -1: TEST_ERRNO=EINVAL(22): Invalid argument
adjtimex02    4  TCONF  :  adjtimex02.c:165: this kernel normalizes buf.offset value if it is outside the acceptable range.
adjtimex02    5  TCONF  :  adjtimex02.c:165: this kernel normalizes buf.offset value if it is outside the acceptable range.
adjtimex02    6  TPASS  :  Test Passed, adjtimex() returned -1: TEST_ERRNO=EPERM(1): Operation not permitted
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=alarm01 stime=1411895329
cmdline="alarm01"
contacts=""
analysis=exit
<<<test_output>>>
alarm01     1  TPASS  :  alarm(1) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=alarm02 stime=1411895329
cmdline="alarm02"
contacts=""
analysis=exit
<<<test_output>>>
alarm02     1  TPASS  :  alarm(18446744073709551615) returned 0 as expected for value -1
alarm02     2  TPASS  :  alarm(18446744073709551615) returned 0 as expected for value ULONG_MAX
alarm02     3  TPASS  :  alarm(0) returned 0 as expected for value ULONG_MAX+1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=alarm03 stime=1411895329
cmdline="alarm03"
contacts=""
analysis=exit
<<<test_output>>>
2009: alarm(100), fork, alarm(0) child's alarm returned 0
alarm03     2  TPASS  :  alarm(100), fork, alarm(0) parent's alarm returned 100
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=alarm05 stime=1411895329
cmdline="alarm05"
contacts=""
analysis=exit
<<<test_output>>>
alarm05     1  TPASS  :  Functionality of alarm(5) successful
<<<execution_status>>>
initiation_status="ok"
duration=8 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=alarm06 stime=1411895337
cmdline="alarm06"
contacts=""
analysis=exit
<<<test_output>>>
alarm06     1  TPASS  :  Functionality of alarm(0) successful
<<<execution_status>>>
initiation_status="ok"
duration=15 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=alarm07 stime=1411895352
cmdline="alarm07"
contacts=""
analysis=exit
<<<test_output>>>
<<<execution_status>>>
initiation_status="ok"
duration=5 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=asyncio02 stime=1411895357
cmdline="asyncio02"
contacts=""
analysis=exit
<<<test_output>>>
asyncio02    1  TPASS  :  More than BUFSIZE bytes multiple synchronous writes to a file check out ok
asyncio02    2  TPASS  :  BUFSIZE bytes multiple synchronous writes to a file checks out ok
asyncio02    3  TPASS  :  Less than BUFSIZE bytes multiple synchronous writes to a file checks out ok
asyncio02    4  TPASS  :  More than BUFSIZE bytes multiple synchronous writes to a file check out ok
asyncio02    5  TPASS  :  BUFSIZE bytes multiple synchronous writes to a file checks out ok
asyncio02    6  TPASS  :  Less than BUFSIZE bytes multiple synchronous writes to a file checks out ok
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=bind01 stime=1411895357
cmdline="bind01"
contacts=""
analysis=exit
<<<test_output>>>
bind01      1  TPASS  :  invalid sockaddr successful
bind01      2  TPASS  :  invalid salen successful
bind01      3  TPASS  :  invalid socket successful
bind01      4  TPASS  :  INADDR_ANYPORT successful
bind01      5  TPASS  :  UNIX-domain of current directory successful
bind01      6  TPASS  :  non-local address successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=bind02 stime=1411895357
cmdline="bind02"
contacts=""
analysis=exit
<<<test_output>>>
bind02      0  TINFO  :  Defaulting to user nobody
bind02      0  TINFO  :  Socket will try to be bind by user: nobody, group: nogroup
bind02      1  TPASS  :  correct error
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=bdflush01 stime=1411895357
cmdline="bdflush01"
contacts=""
analysis=exit
<<<test_output>>>
bdflush01    2  TCONF  :  bdflush01.c:123: syscall __NR_bdflush not supported on your arch
bdflush01    3  TCONF  :  bdflush01.c:123: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=brk01 stime=1411895357
cmdline="brk01"
contacts=""
analysis=exit
<<<test_output>>>
brk01       1  TPASS  :  brk(26143472) returned 0, new size verified by sbrk
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=capget01 stime=1411895357
cmdline="capget01"
contacts=""
analysis=exit
<<<test_output>>>
capget01    1  TPASS  :  capget() returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=capget02 stime=1411895357
cmdline="capget02"
contacts=""
analysis=exit
<<<test_output>>>
capget02    1  TPASS  :  capget failed as expected: TEST_ERRNO=EFAULT(14): Bad address
capget02    2  TPASS  :  capget failed as expected: TEST_ERRNO=EFAULT(14): Bad address
capget02    3  TPASS  :  capget failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
capget02    4  TPASS  :  capget failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
capget02    5  TPASS  :  capget failed as expected: TEST_ERRNO=ESRCH(3): No such process
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=capset01 stime=1411895357
cmdline="capset01"
contacts=""
analysis=exit
<<<test_output>>>
capset01    1  TPASS  :  capset() returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=capset02 stime=1411895357
cmdline="capset02"
contacts=""
analysis=exit
<<<test_output>>>
capset02    1  TPASS  :  capset() returned -1, errno: EFAULT
capset02    2  TPASS  :  capset() returned -1, errno: EFAULT
capset02    3  TPASS  :  capset() returned -1, errno: EINVAL
capset02    4  TPASS  :  capset() returned -1, errno: EPERM
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=cacheflush01 stime=1411895357
cmdline="cacheflush01"
contacts=""
analysis=exit
<<<test_output>>>
cacheflush01    1  TCONF  :  cacheflush01.c:140: syscall __NR_cacheflush not supported on your arch
cacheflush01    2  TCONF  :  cacheflush01.c:140: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=chdir01 stime=1411895357
cmdline="chdir01"
contacts=""
analysis=exit
<<<test_output>>>
chdir01     0  TINFO  :  Found file .
chdir01     0  TINFO  :  Found file ..
chdir01     0  TINFO  :  Found file chdirtest
chdir01     1  TPASS  :  failed as expected with ENOTDIR
chdir01     2  TPASS  :  failed as expected with ELOOP
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=chdir01A stime=1411895357
cmdline="symlink01 -T chdir01"
contacts=""
analysis=exit
<<<test_output>>>
chdir01     1  TPASS  :  chdir(2) to object file location through symbolic link file is ok
chdir01     2  TPASS  :  chdir(2) to non-existent object file location through symbolic link file failed as expected
chdir01     3  TPASS  :  Nested symbolic link access condition caught.  ELOOP is returned
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=chdir02 stime=1411895357
cmdline="chdir02"
contacts=""
analysis=exit
<<<test_output>>>
chdir02     1  TPASS  :  chdir(/) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=chdir03 stime=1411895357
cmdline="chdir03"
contacts=""
analysis=exit
<<<test_output>>>
got EACCES as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=chdir04 stime=1411895357
cmdline="chdir04"
contacts=""
analysis=exit
<<<test_output>>>
chdir04     1  TPASS  :  failed as expected: TEST_ERRNO=ENAMETOOLONG(36): File name too long
chdir04     2  TPASS  :  failed as expected: TEST_ERRNO=ENOENT(2): No such file or directory
chdir04     3  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=chmod01 stime=1411895357
cmdline="chmod01"
contacts=""
analysis=exit
<<<test_output>>>
chmod01     1  TPASS  :  Functionality of chmod(testfile, 0) successful
chmod01     2  TPASS  :  Functionality of chmod(testfile, 07) successful
chmod01     3  TPASS  :  Functionality of chmod(testfile, 070) successful
chmod01     4  TPASS  :  Functionality of chmod(testfile, 0700) successful
chmod01     5  TPASS  :  Functionality of chmod(testfile, 0777) successful
chmod01     6  TPASS  :  Functionality of chmod(testfile, 02777) successful
chmod01     7  TPASS  :  Functionality of chmod(testfile, 04777) successful
chmod01     8  TPASS  :  Functionality of chmod(testfile, 06777) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=chmod01A stime=1411895357
cmdline="symlink01 -T chmod01"
contacts=""
analysis=exit
<<<test_output>>>
chmod01     1  TPASS  :  chmod(2) of object file permissions through symbolic link file is ok
chmod01     2  TPASS  :  chmod(2) error when accessing non-existent object through symbolic link is caught
chmod01     3  TPASS  :  Nested symbolic link access condition caught.  ELOOP is returned
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=chmod02 stime=1411895357
cmdline="chmod02"
contacts=""
analysis=exit
<<<test_output>>>
chmod02     1  TPASS  :  chmod(test_file, 0) returned 0
chmod02     2  TPASS  :  chmod(test_file, 07) returned 0
chmod02     3  TPASS  :  chmod(test_file, 070) returned 0
chmod02     4  TPASS  :  chmod(test_file, 0700) returned 0
chmod02     5  TPASS  :  chmod(test_file, 0777) returned 0
chmod02     6  TPASS  :  chmod(test_file, 02777) returned 0
chmod02     7  TPASS  :  chmod(test_file, 04777) returned 0
chmod02     8  TPASS  :  chmod(test_file, 06777) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=chmod03 stime=1411895357
cmdline="chmod03"
contacts=""
analysis=exit
<<<test_output>>>
chmod03     1  TPASS  :  Functionality of chmod(testfile, 01777) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=chmod04 stime=1411895357
cmdline="chmod04"
contacts=""
analysis=exit
<<<test_output>>>
chmod04     1  TPASS  :  Functionality of chmod(testdir_4, 01777) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=chmod05 stime=1411895357
cmdline="chmod05"
contacts=""
analysis=exit
<<<test_output>>>
chmod05     1  TPASS  :  Functionality of chmod(testdir, 043777) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=chmod06 stime=1411895357
cmdline="chmod06"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
chmod06     0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
chmod06     0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
chmod06     1  TPASS  :  chmod failed as expected: TEST_ERRNO=EPERM(1): Operation not permitted
chmod06     2  TPASS  :  chmod failed as expected: TEST_ERRNO=EACCES(13): Permission denied
chmod06     3  TPASS  :  chmod failed as expected: TEST_ERRNO=EFAULT(14): Bad address
chmod06     4  TPASS  :  chmod failed as expected: TEST_ERRNO=EFAULT(14): Bad address
chmod06     5  TPASS  :  chmod failed as expected: TEST_ERRNO=ENAMETOOLONG(36): File name too long
chmod06     6  TPASS  :  chmod failed as expected: TEST_ERRNO=ENOENT(2): No such file or directory
chmod06     7  TPASS  :  chmod failed as expected: TEST_ERRNO=ENOTDIR(20): Not a directory
chmod06     8  TPASS  :  chmod failed as expected: TEST_ERRNO=EROFS(30): Read-only file system
chmod06     9  TPASS  :  chmod failed as expected: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=chmod07 stime=1411895357
cmdline="chmod07"
contacts=""
analysis=exit
<<<test_output>>>
chmod07     1  TPASS  :  Functionality of chmod(testfile, 01777) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=chown01 stime=1411895357
cmdline="chown01"
contacts=""
analysis=exit
<<<test_output>>>
chown01     1  TPASS  :  chown(t_2043, 0,0) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=chown01_16 stime=1411895357
cmdline="chown01_16"
contacts=""
analysis=exit
<<<test_output>>>
chown01     1  TPASS  :  chown(t_2044, 0,0) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=chown02 stime=1411895357
cmdline="chown02"
contacts=""
analysis=exit
<<<test_output>>>
chown02     1  TPASS  :  chown(testfile1, ..) succeeded
chown02     2  TPASS  :  chown(testfile2, ..) succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=chown02_16 stime=1411895357
cmdline="chown02_16"
contacts=""
analysis=exit
<<<test_output>>>
chown02     1  TPASS  :  chown(testfile1, ..) succeeded
chown02     2  TPASS  :  chown(testfile2, ..) succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=chown03 stime=1411895357
cmdline="chown03"
contacts=""
analysis=exit
<<<test_output>>>
chown03     1  TPASS  :  chown(testfile, ..) was successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=chown03_16 stime=1411895357
cmdline="chown03_16"
contacts=""
analysis=exit
<<<test_output>>>
chown03     1  TPASS  :  chown(testfile, ..) was successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=chown04 stime=1411895357
cmdline="chown04"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
chown04     0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
chown04     0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
chown04     1  TPASS  :  chown failed: TEST_ERRNO=EPERM(1): Operation not permitted
chown04     2  TPASS  :  chown failed: TEST_ERRNO=EACCES(13): Permission denied
chown04     3  TPASS  :  chown failed: TEST_ERRNO=EFAULT(14): Bad address
chown04     4  TPASS  :  chown failed: TEST_ERRNO=ENAMETOOLONG(36): File name too long
chown04     5  TPASS  :  chown failed: TEST_ERRNO=ENOENT(2): No such file or directory
chown04     6  TPASS  :  chown failed: TEST_ERRNO=ENOTDIR(20): Not a directory
chown04     7  TPASS  :  chown failed: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
chown04     8  TPASS  :  chown failed: TEST_ERRNO=EROFS(30): Read-only file system
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=chown04_16 stime=1411895357
cmdline="chown04_16"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
chown04     0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
chown04     0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
chown04     1  TPASS  :  chown failed: TEST_ERRNO=EPERM(1): Operation not permitted
chown04     2  TPASS  :  chown failed: TEST_ERRNO=EACCES(13): Permission denied
chown04     3  TPASS  :  chown failed: TEST_ERRNO=EFAULT(14): Bad address
chown04     4  TPASS  :  chown failed: TEST_ERRNO=ENAMETOOLONG(36): File name too long
chown04     5  TPASS  :  chown failed: TEST_ERRNO=ENOENT(2): No such file or directory
chown04     6  TPASS  :  chown failed: TEST_ERRNO=ENOTDIR(20): Not a directory
chown04     7  TPASS  :  chown failed: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
chown04     8  TPASS  :  chown failed: TEST_ERRNO=EROFS(30): Read-only file system
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=chown05 stime=1411895357
cmdline="chown05"
contacts=""
analysis=exit
<<<test_output>>>
chown05     1  TPASS  :  chown succeeded
chown05     2  TPASS  :  chown succeeded
chown05     3  TPASS  :  chown succeeded
chown05     4  TPASS  :  chown succeeded
chown05     5  TPASS  :  chown succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=chown05_16 stime=1411895357
cmdline="chown05_16"
contacts=""
analysis=exit
<<<test_output>>>
chown05     1  TPASS  :  chown succeeded
chown05     2  TPASS  :  chown succeeded
chown05     3  TPASS  :  chown succeeded
chown05     4  TPASS  :  chown succeeded
chown05     5  TPASS  :  chown succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=chroot01 stime=1411895357
cmdline="chroot01"
contacts=""
analysis=exit
<<<test_output>>>
chroot01    1  TPASS  :  chroot set errno to EPERM.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=chroot02 stime=1411895357
cmdline="chroot02"
contacts=""
analysis=exit
<<<test_output>>>
chroot02    1  TPASS  :  chroot functionality correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=chroot03 stime=1411895357
cmdline="chroot03"
contacts=""
analysis=exit
<<<test_output>>>
chroot03    1  TPASS  :  failed as expected: TEST_ERRNO=ENAMETOOLONG(36): File name too long
chroot03    2  TPASS  :  failed as expected: TEST_ERRNO=ENOTDIR(20): Not a directory
chroot03    3  TPASS  :  failed as expected: TEST_ERRNO=ENOENT(2): No such file or directory
chroot03    4  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
chroot03    5  TPASS  :  failed as expected: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=chroot04 stime=1411895357
cmdline="chroot04"
contacts=""
analysis=exit
<<<test_output>>>
chroot04    1  TPASS  :  got EACCESS as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=clock_getres01 stime=1411895357
cmdline="clock_getres01"
contacts=""
analysis=exit
<<<test_output>>>
clock_getres01    1  TPASS  :  clock_getres REALTIME succeeded
clock_getres01    2  TPASS  :  clock_getres MONOTONIC succeeded
clock_getres01    3  TPASS  :  clock_getres PROCESS_CPUTIME_ID succeeded
clock_getres01    4  TPASS  :  clock_getres THREAD_CPUTIME_ID succeeded
clock_getres01    5  TPASS  :  clock_getres REALTIME succeeded
clock_getres01    6  TPASS  :  clock_getres CLOCK_MONOTONIC_RAW succeeded
clock_getres01    7  TPASS  :  clock_getres CLOCK_REALTIME_COARSE succeeded
clock_getres01    8  TPASS  :  clock_getres CLOCK_MONOTONIC_COARSE succeeded
clock_getres01    9  TPASS  :  clock_getres CLOCK_BOOTTIME succeeded
clock_getres01   10  TPASS  :  clock_getres CLOCK_REALTIME_ALARM succeeded
clock_getres01   11  TPASS  :  clock_getres CLOCK_BOOTTIME_ALARM succeeded
clock_getres01   12  TPASS  :  clock_getres -1 succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=clock_nanosleep01 stime=1411895357
cmdline="clock_nanosleep01"
contacts=""
analysis=exit
<<<test_output>>>
EXPECT: return value(ret)=0 errno=0 (Success)
RESULT: return value(ret)=0 errno=0 (Success)
EXPECT: return value(ret)=0 errno=0 (Success)
RESULT: return value(ret)=0 errno=0 (Success)
EXPECT: return value(ret)=22 errno=0 (Success)
RESULT: return value(ret)=22 errno=0 (Success)
EXPECT: return value(ret)=22 errno=0 (Success)
RESULT: return value(ret)=22 errno=0 (Success)
EXPECT: return value(ret)=22 errno=0 (Success)
RESULT: return value(ret)=22 errno=0 (Success)
EXPECT: return value(ret)=4 errno=0 (Success)
RESULT: return value(ret)=4 errno=0 (Success)
clock_nanosleep01    0  TINFO  :  (case00) START
clock_nanosleep01    0  TINFO  :  check sleep time: (min:480) < 500 < (max:520) (msec)
clock_nanosleep01    0  TINFO  :  remain time: 1 4217117
clock_nanosleep01    0  TINFO  :  (case00) END => OK
clock_nanosleep01    0  TINFO  :  (case01) START
clock_nanosleep01    0  TINFO  :  check sleep time: (min:480) < 500 < (max:520) (msec)
clock_nanosleep01    0  TINFO  :  remain time: 1 4217117
clock_nanosleep01    0  TINFO  :  (case01) END => OK
clock_nanosleep01    0  TINFO  :  (case02) START
clock_nanosleep01    0  TINFO  :  remain time: 1 4217117
clock_nanosleep01    0  TINFO  :  (case02) END => OK
clock_nanosleep01    0  TINFO  :  (case03) START
clock_nanosleep01    0  TINFO  :  remain time: 1 4217117
clock_nanosleep01    0  TINFO  :  (case03) END => OK
clock_nanosleep01    0  TINFO  :  (case04) START
clock_nanosleep01    0  TINFO  :  remain time: 1 4217117
clock_nanosleep01    0  TINFO  :  (case04) END => OK
clock_nanosleep01    0  TINFO  :  (case05) START
clock_nanosleep01    0  TINFO  :  remain time: 9 499783238
clock_nanosleep01    0  TINFO  :  (case05) END => OK
clock_nanosleep01    1  TPASS  :  clock_nanosleep call succeeded
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=clock_nanosleep2_01 stime=1411895358
cmdline="clock_nanosleep2_01"
contacts=""
analysis=exit
<<<test_output>>>
clock_nanosleep2_01    0  TINFO  :  Iteration = 0
clock_nanosleep2_01    0  TINFO  :  Iteration = 1
clock_nanosleep2_01    0  TINFO  :  Iteration = 2
clock_nanosleep2_01    0  TINFO  :  Iteration = 3
clock_nanosleep2_01    0  TINFO  :  Iteration = 4
clock_nanosleep2_01    0  TINFO  :  Iteration = 5
clock_nanosleep2_01    0  TINFO  :  Iteration = 6
clock_nanosleep2_01    0  TINFO  :  Iteration = 7
clock_nanosleep2_01    0  TINFO  :  Iteration = 8
clock_nanosleep2_01    0  TINFO  :  Iteration = 9
clock_nanosleep2_01    0  TINFO  :  Iteration = 10
clock_nanosleep2_01    0  TINFO  :  Iteration = 11
clock_nanosleep2_01    0  TINFO  :  Iteration = 12
clock_nanosleep2_01    0  TINFO  :  Iteration = 13
clock_nanosleep2_01    0  TINFO  :  Iteration = 14
clock_nanosleep2_01    0  TINFO  :  Iteration = 15
clock_nanosleep2_01    0  TINFO  :  Iteration = 16
clock_nanosleep2_01    0  TINFO  :  Iteration = 17
clock_nanosleep2_01    0  TINFO  :  Iteration = 18
clock_nanosleep2_01    0  TINFO  :  Iteration = 19
clock_nanosleep2_01    0  TINFO  :  Iteration = 20
clock_nanosleep2_01    0  TINFO  :  Iteration = 21
clock_nanosleep2_01    0  TINFO  :  Iteration = 22
clock_nanosleep2_01    0  TINFO  :  Iteration = 23
clock_nanosleep2_01    0  TINFO  :  Iteration = 24
clock_nanosleep2_01    0  TINFO  :  Iteration = 25
clock_nanosleep2_01    0  TINFO  :  Iteration = 26
clock_nanosleep2_01    0  TINFO  :  Iteration = 27
clock_nanosleep2_01    0  TINFO  :  Iteration = 28
clock_nanosleep2_01    0  TINFO  :  Iteration = 29
clock_nanosleep2_01    0  TINFO  :  Iteration = 30
clock_nanosleep2_01    0  TINFO  :  Iteration = 31
clock_nanosleep2_01    0  TINFO  :  Iteration = 32
clock_nanosleep2_01    0  TINFO  :  Iteration = 33
clock_nanosleep2_01    0  TINFO  :  Iteration = 34
clock_nanosleep2_01    0  TINFO  :  Iteration = 35
clock_nanosleep2_01    0  TINFO  :  Iteration = 36
clock_nanosleep2_01    0  TINFO  :  Iteration = 37
clock_nanosleep2_01    0  TINFO  :  Iteration = 38
clock_nanosleep2_01    0  TINFO  :  Iteration = 39
clock_nanosleep2_01    0  TINFO  :  Iteration = 40
clock_nanosleep2_01    0  TINFO  :  Iteration = 41
clock_nanosleep2_01    0  TINFO  :  Iteration = 42
clock_nanosleep2_01    0  TINFO  :  Iteration = 43
clock_nanosleep2_01    0  TINFO  :  Iteration = 44
clock_nanosleep2_01    0  TINFO  :  Iteration = 45
clock_nanosleep2_01    0  TINFO  :  Iteration = 46
clock_nanosleep2_01    0  TINFO  :  Iteration = 47
clock_nanosleep2_01    0  TINFO  :  Iteration = 48
clock_nanosleep2_01    0  TINFO  :  Iteration = 49
clock_nanosleep2_01    0  TINFO  :  Iteration = 50
clock_nanosleep2_01    1  TPASS  :  clock_nanosleep2() passed
<<<execution_status>>>
initiation_status="ok"
duration=51 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=clone01 stime=1411895409
cmdline="clone01"
contacts=""
analysis=exit
<<<test_output>>>
clone01     1  TPASS  :  clone returned 2069
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=clone02 stime=1411895409
cmdline="clone02"
contacts=""
analysis=exit
<<<test_output>>>
clone02     1  TPASS  :  Test Passed
clone02     1  TPASS  :  Test Passed
clone02     2  TPASS  :  Test Passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=clone03 stime=1411895409
cmdline="clone03"
contacts=""
analysis=exit
<<<test_output>>>
clone03     1  TPASS  :  Test passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=clone04 stime=1411895409
cmdline="clone04"
contacts=""
analysis=exit
<<<test_output>>>
clone04     1  TPASS  :  expected failure; Got EINVAL
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=clone05 stime=1411895409
cmdline="clone05"
contacts=""
analysis=exit
<<<test_output>>>
clone05     1  TPASS  :  Test Passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=clone06 stime=1411895409
cmdline="clone06"
contacts=""
analysis=exit
<<<test_output>>>
clone06     1  TPASS  :  Test Passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=clone07 stime=1411895409
cmdline="clone07"
contacts=""
analysis=exit
<<<test_output>>>
clone07     1  TPASS  :  Use of return() in child did not cause SIGSEGV
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=clone08 stime=1411895409
cmdline="clone08"
contacts=""
analysis=exit
<<<test_output>>>
clone08     0  TINFO  :  running CLONE_PARENT
clone08     1  TPASS  :  test CLONE_PARENT
clone08     0  TINFO  :  running CLONE_CHILD_SETTID
clone08     2  TPASS  :  test CLONE_CHILD_SETTID
clone08     0  TINFO  :  running CLONE_PARENT_SETTID
clone08     3  TPASS  :  test CLONE_PARENT_SETTID
clone08     0  TINFO  :  running CLONE_THREAD
clone08     4  TPASS  :  test CLONE_THREAD
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=close01 stime=1411895409
cmdline="close01"
contacts=""
analysis=exit
<<<test_output>>>
close01     1  TPASS  :  file appears closed
close01     2  TPASS  :  pipe appears closed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=close02 stime=1411895409
cmdline="close02"
contacts=""
analysis=exit
<<<test_output>>>
close02     1  TPASS  :  call returned EBADF
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=close08 stime=1411895409
cmdline="close08"
contacts=""
analysis=exit
<<<test_output>>>
close08     1  TPASS  :  close(tfile_2091) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=confstr01 stime=1411895409
cmdline="confstr01"
contacts=""
analysis=exit
<<<test_output>>>
confstr01    1  TPASS  :  confstr PATH = '/bin:/usr/bin'
confstr01    2  TPASS  :  confstr XBS5_ILP32_OFF32_CFLAGS = ''
confstr01    3  TPASS  :  confstr XBS5_ILP32_OFF32_LDFLAGS = ''
confstr01    4  TPASS  :  confstr XBS5_ILP32_OFF32_LIBS = ''
confstr01    5  TPASS  :  confstr XBS5_ILP32_OFF32_LINTFLAGS = ''
confstr01    6  TPASS  :  confstr XBS5_ILP32_OFFBIG_CFLAGS = ''
confstr01    7  TPASS  :  confstr XBS5_ILP32_OFFBIG_LDFLAGS = ''
confstr01    8  TPASS  :  confstr XBS5_ILP32_OFFBIG_LIBS = ''
confstr01    9  TPASS  :  confstr XBS5_ILP32_OFFBIG_LINTFLAGS = ''
confstr01   10  TPASS  :  confstr XBS5_LP64_OFF64_CFLAGS = '-m64'
confstr01   11  TPASS  :  confstr XBS5_LP64_OFF64_LDFLAGS = '-m64'
confstr01   12  TPASS  :  confstr XBS5_LP64_OFF64_LIBS = ''
confstr01   13  TPASS  :  confstr XBS5_LP64_OFF64_LINTFLAGS = ''
confstr01   14  TPASS  :  confstr XBS5_LPBIG_OFFBIG_CFLAGS = ''
confstr01   15  TPASS  :  confstr XBS5_LPBIG_OFFBIG_LDFLAGS = ''
confstr01   16  TPASS  :  confstr XBS5_LPBIG_OFFBIG_LIBS = ''
confstr01   17  TPASS  :  confstr XBS5_LPBIG_OFFBIG_LINTFLAGS = ''
confstr01   18  TPASS  :  confstr GNU_LIBC_VERSION = 'glibc 2.17'
confstr01   19  TPASS  :  confstr GNU_LIBPTHREAD_VERSION = 'NPTL 2.17'
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=connect01 stime=1411895409
cmdline="connect01"
contacts=""
analysis=exit
<<<test_output>>>
connect01    1  TPASS  :  bad file descriptor successful
connect01    2  TPASS  :  invalid socket buffer successful
connect01    3  TPASS  :  invalid salen successful
connect01    4  TPASS  :  invalid socket successful
connect01    5  TPASS  :  already connected successful
connect01    6  TPASS  :  connection refused successful
connect01    7  TPASS  :  invalid address family successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=creat01 stime=1411895409
cmdline="creat01"
contacts=""
analysis=exit
<<<test_output>>>
creat01     1  TPASS  :  file was created and written to successfully
creat01     2  TPASS  :  creat truncated existing file to 0 bytes
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=creat03 stime=1411895409
cmdline="creat03"
contacts=""
analysis=exit
<<<test_output>>>
creat03     0  TINFO  :  Created file has mode = 0100444
creat03     1  TPASS  :  save text bit cleared
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=creat04 stime=1411895409
cmdline="creat04"
contacts=""
analysis=exit
<<<test_output>>>
creat04     1  TPASS  :  call failed with EACCES as expected
creat04     2  TPASS  :  call failed with EACCES as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=creat05 stime=1411895409
cmdline="creat05"
contacts=""
analysis=exit
<<<test_output>>>
creat05     0  TINFO  :  first file is #7
creat05     0  TINFO  :  could not creat file #1025
creat05     1  TPASS  :  call failed with expected error - EMFILE
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=creat06 stime=1411895409
cmdline="creat06"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
creat06     0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
creat06     0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
creat06     1  TPASS  :  got expected failure: TEST_ERRNO=EISDIR(21): Is a directory
creat06     2  TPASS  :  got expected failure: TEST_ERRNO=ENAMETOOLONG(36): File name too long
creat06     3  TPASS  :  got expected failure: TEST_ERRNO=ENOENT(2): No such file or directory
creat06     4  TPASS  :  got expected failure: TEST_ERRNO=ENOTDIR(20): Not a directory
creat06     5  TPASS  :  got expected failure: TEST_ERRNO=EFAULT(14): Bad address
creat06     6  TPASS  :  got expected failure: TEST_ERRNO=EACCES(13): Permission denied
creat06     7  TPASS  :  got expected failure: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
creat06     8  TPASS  :  got expected failure: TEST_ERRNO=EROFS(30): Read-only file system
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=creat07 stime=1411895409
cmdline="creat07"
contacts=""
analysis=exit
<<<test_output>>>
creat07     1  TPASS  :  creat received EXTBSY
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=creat08 stime=1411895409
cmdline="creat08"
contacts=""
analysis=exit
<<<test_output>>>
creat08     1  TPASS  :  Test passed in block0.
creat08     2  TPASS  :  Test passed in block1.
creat08     3  TPASS  :  Test passed in block2.
creat08     4  TPASS  :  Test passed in block3
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=creat09 stime=1411895409
cmdline="creat09"
contacts=""
analysis=exit
<<<test_output>>>
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=dup01 stime=1411895409
cmdline="dup01"
contacts=""
analysis=exit
<<<test_output>>>
dup01       1  TPASS  :  dup(dupfile) returned 8
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=dup02 stime=1411895409
cmdline="dup02"
contacts=""
analysis=exit
<<<test_output>>>
dup02       1  TPASS  :  dup failed as expected with EBADF
dup02       2  TPASS  :  dup failed as expected with EBADF
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=dup03 stime=1411895409
cmdline="dup03"
contacts=""
analysis=exit
<<<test_output>>>
dup03       1  TPASS  :  dup failed as expected with EMFILE
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=dup04 stime=1411895409
cmdline="dup04"
contacts=""
analysis=exit
<<<test_output>>>
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=dup05 stime=1411895409
cmdline="dup05"
contacts=""
analysis=exit
<<<test_output>>>
dup05       1  TPASS  :  dup returned 8
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=dup06 stime=1411895409
cmdline="dup06"
contacts=""
analysis=exit
<<<test_output>>>
dup06       1  TPASS  :  Test passed.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=dup07 stime=1411895409
cmdline="dup07"
contacts=""
analysis=exit
<<<test_output>>>
dup07       1  TPASS  :  Passed in read mode.
dup07       2  TPASS  :  Passed in write mode.
dup07       3  TPASS  :  Passed in read/write mode.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=dup201 stime=1411895409
cmdline="dup201"
contacts=""
analysis=exit
<<<test_output>>>
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=dup202 stime=1411895409
cmdline="dup202"
contacts=""
analysis=exit
<<<test_output>>>
dup202      1  TPASS  :  fstat shows new and old modes are the same
dup202      2  TPASS  :  fstat shows new and old modes are the same
dup202      3  TPASS  :  fstat shows new and old modes are the same
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=dup203 stime=1411895409
cmdline="dup203"
contacts=""
analysis=exit
<<<test_output>>>
dup203      0  TINFO  :  Enter block 1
dup203      0  TINFO  :  Test duping over an open fd
dup203      1  TPASS  :  dup2 test 1 functionality is correct
dup203      0  TINFO  :  Exit block 1
dup203      0  TINFO  :  Enter block 2
dup203      0  TINFO  :  Test close on exec flag
dup203      2  TPASS  :  dup2 test 2 functionality is correct
dup203      0  TINFO  :  Exit block 2
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=dup204 stime=1411895409
cmdline="dup204"
contacts=""
analysis=exit
<<<test_output>>>
dup204      1  TPASS  :  original and duped inodes are the same
dup204      2  TPASS  :  original and duped inodes are the same
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=dup205 stime=1411895409
cmdline="dup205"
contacts=""
analysis=exit
<<<test_output>>>
dup205      1  TPASS  :  Test passed.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=dup3_01 stime=1411895409
cmdline="dup3_01"
contacts=""
analysis=exit
<<<test_output>>>
dup3_01     1  TPASS  :  dup3(O_CLOEXEC) PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=dup3_02 stime=1411895409
cmdline="dup3_02"
contacts=""
analysis=exit
<<<test_output>>>
dup3_02     1  TPASS  :  dup3 failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
dup3_02     2  TPASS  :  dup3 failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
dup3_02     3  TPASS  :  dup3 failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=epoll_create1_01 stime=1411895409
cmdline="epoll_create1_01"
contacts=""
analysis=exit
<<<test_output>>>
epoll_create1_01    1  TPASS  :  epoll_create1(EPOLL_CLOEXEC) PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=epoll01 stime=1411895409
cmdline="epoll-ltp"
contacts=""
analysis=exit
<<<test_output>>>
epoll01     0  TINFO  :  testing if epoll() system call works
epoll01     0  TINFO  :  gettimeofday() works
epoll01     0  TINFO  :  random number seeded with gettimeofday() [seed = 884422] works
epoll01     0  TINFO  :  Testing epoll_create
epoll01     1  TPASS  :  epoll_create with negative set size
epoll01     2  TPASS  :  epoll_create with large set size (size = 2147483647)
epoll01     3  TPASS  :  epoll_create with large set size (size = 2147483646)
epoll01     4  TPASS  :  epoll_create with large set size (size = 2147483645)
epoll01     5  TPASS  :  epoll_create with large set size (size = 2147483644)
epoll01     6  TPASS  :  epoll_create with large set size (size = 2147483643)
epoll01     7  TPASS  :  epoll_create with large set size (size = 2147483642)
epoll01     8  TPASS  :  epoll_create with large set size (size = 2147483641)
epoll01     9  TPASS  :  epoll_create with large set size (size = 2147483640)
epoll01    10  TPASS  :  epoll_create with large set size (size = 2147483639)
epoll01    11  TPASS  :  epoll_create with large set size (size = 2147483638)
epoll01    12  TPASS  :  epoll_create with large set size (size = 2147483637)
epoll01    13  TPASS  :  epoll_create with large set size (size = 2147483636)
epoll01    14  TPASS  :  epoll_create with large set size (size = 2147483635)
epoll01    15  TPASS  :  epoll_create with large set size (size = 2147483634)
epoll01    16  TPASS  :  epoll_create with large set size (size = 2147483633)
epoll01    17  TPASS  :  epoll_create with large set size (size = 2147483632)
epoll01    18  TPASS  :  epoll_create with random large set size (size = 1885104701)
epoll01    19  TPASS  :  epoll_create with random large set size (size = 1569737504)
epoll01    20  TPASS  :  epoll_create with random large set size (size = 2058494179)
epoll01    21  TPASS  :  epoll_create with random large set size (size = 334420942)
epoll01    22  TPASS  :  epoll_create with random large set size (size = 1319947408)
epoll01    23  TPASS  :  epoll_create with random large set size (size = 335001766)
epoll01    24  TPASS  :  epoll_create with random large set size (size = 635968117)
epoll01    25  TPASS  :  epoll_create with random large set size (size = 85899626)
epoll01    26  TPASS  :  epoll_create with random large set size (size = 315801105)
epoll01    27  TPASS  :  epoll_create with random large set size (size = 1855160551)
epoll01    28  TPASS  :  epoll_create with random large set size (size = 1176023307)
epoll01    29  TPASS  :  epoll_create with random large set size (size = 1796141097)
epoll01    30  TPASS  :  epoll_create with random large set size (size = 1222469992)
epoll01    31  TPASS  :  epoll_create with random large set size (size = 268501127)
epoll01    32  TPASS  :  epoll_create with random large set size (size = 696007402)
epoll01    33  TPASS  :  epoll_create with random large set size (size = 1802714659)
epoll01     0  TINFO  :  Summary: Of 33 tests, epoll_create failed 0 (100% passed).
epoll01     0  TINFO  :  Testing epoll_ctl
epoll01     0  TINFO  :  Summary: Of 13824 tests, epoll_ctl failed 0 (100% passed).
<<<execution_status>>>
initiation_status="ok"
duration=2 termination_type=exited termination_id=0 corefile=no
cutime=2 cstime=122
<<<test_end>>>
<<<test_start>>>
tag=eventfd01 stime=1411895411
cmdline="eventfd01"
contacts=""
analysis=exit
<<<test_output>>>
eventfd01    1  TPASS  :  counter value matches required
eventfd01    2  TPASS  :  read failed with EAGAIN as expected
eventfd01    3  TPASS  :  counter value matches required
eventfd01    4  TPASS  :  write failed with EAGAIN as expected
eventfd01    5  TPASS  :  read failed with EINVAL as expected
eventfd01    6  TPASS  :  write failed with EINVAL as expected
eventfd01    7  TPASS  :  write failed with EINVAL as expected
eventfd01    8  TPASS  :  fd is set in readfds
eventfd01    9  TPASS  :  fd is not set in readfds
eventfd01   10  TPASS  :  fd is set in writefds
eventfd01   11  TPASS  :  fd is not set in writefds
eventfd01    1  TPASS  :  counter value matches required
eventfd01    2  TPASS  :  read failed with EAGAIN as expected
eventfd01    3  TPASS  :  counter value matches required
eventfd01    4  TPASS  :  write failed with EAGAIN as expected
eventfd01    5  TPASS  :  read failed with EINVAL as expected
eventfd01    6  TPASS  :  write failed with EINVAL as expected
eventfd01    7  TPASS  :  write failed with EINVAL as expected
eventfd01    8  TPASS  :  fd is set in readfds
eventfd01    9  TPASS  :  fd is not set in readfds
eventfd01   10  TPASS  :  fd is set in writefds
eventfd01   11  TPASS  :  fd is not set in writefds
eventfd01   12  TPASS  :  counter value write from child successful
eventfd01   13  TPASS  :  read fd set as expected
eventfd01   14  TPASS  :  POLLERR occurred as expected
eventfd01   15  TPASS  :  overflow occurred as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=eventfd2_01 stime=1411895411
cmdline="eventfd2_01"
contacts=""
analysis=exit
<<<test_output>>>
eventfd2_01    1  TPASS  :  eventfd2(EFD_CLOEXEC) Passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=eventfd2_02 stime=1411895411
cmdline="eventfd2_02"
contacts=""
analysis=exit
<<<test_output>>>
eventfd2_02    1  TPASS  :  eventfd2(EFD_NONBLOCK) PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=eventfd2_03 stime=1411895411
cmdline="eventfd2_03"
contacts=""
analysis=exit
<<<test_output>>>
[15958] posting 1 on 8
[15958] waiting on 7
[15958] wait completed on 7: count=1
[15958] posting 1 on 8
[15958] waiting on 7
[15958] wait completed on 7: count=1
[15958] posting 5 on 8
[15958] waiting 5 times on 7
[15958] wait completed on 7: count=1
[15958] wait completed on 7: count=1
[15958] wait completed on 7: count=1
[15958] wait completed on 7: count=1
[15958] wait completed on 7: count=1
[15957] posting 1 on 7
[15957] waiting on 8
[15957] wait completed on 8: count=1
[15957] posting 1 on 7
[15957] waiting on 8
[15957] wait completed on 8: count=1
[15957] posting 5 on 7
[15957] waiting 5 times on 8
[15957] wait completed on 8: count=1
[15957] wait completed on 8: count=1
[15957] wait completed on 8: count=1
[15957] wait completed on 8: count=1
[15957] wait completed on 8: count=1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=execl01 stime=1411895411
cmdline="execl01"
contacts=""
analysis=exit
<<<test_output>>>
execl01     1  TPASS  :  execl - properly exec's a simple program..
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=execle01 stime=1411895411
cmdline="execle01"
contacts=""
analysis=exit
<<<test_output>>>
execle01    1  TPASS  :  execle - properly exec's a simple program..
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=execlp01 stime=1411895411
cmdline="execlp01"
contacts=""
analysis=exit
<<<test_output>>>
execlp01    1  TPASS  :  execlp - properly exec's a simple program..
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=execv01 stime=1411895411
cmdline="execv01"
contacts=""
analysis=exit
<<<test_output>>>
execv01     1  TPASS  :  execv - properly exec's a simple program..
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=execve01 stime=1411895411
cmdline="execve01"
contacts=""
analysis=exit
<<<test_output>>>
execve01    1  TPASS  :  execve - properly exec's a simple program..
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=execve02 stime=1411895411
cmdline="execve02 -F $LTPROOT/testcases/bin/test3"
contacts=""
analysis=exit
<<<test_output>>>
execve failed with EACCES as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=execve03 stime=1411895411
cmdline="execve03"
contacts=""
analysis=exit
<<<test_output>>>
execve03    1  TPASS  :  execve failed as expected: TEST_ERRNO=ENAMETOOLONG(36): File name too long
execve03    2  TPASS  :  execve failed as expected: TEST_ERRNO=ENOENT(2): No such file or directory
execve03    3  TPASS  :  execve failed as expected: TEST_ERRNO=ENOTDIR(20): Not a directory
execve03    4  TPASS  :  execve failed as expected: TEST_ERRNO=EFAULT(14): Bad address
execve03    5  TPASS  :  execve failed as expected: TEST_ERRNO=EACCES(13): Permission denied
execve03    6  TPASS  :  execve failed as expected: TEST_ERRNO=ENOEXEC(8): Exec format error
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=execve04 stime=1411895411
cmdline="execve04 -F $LTPROOT/testcases/bin/test3"
contacts=""
analysis=exit
<<<test_output>>>
execve failed with ETXTBSY as expected
execve04    1  TPASS  :  execve failed as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=execve05 stime=1411895411
cmdline="execve05 20 $LTPROOT/testcases/bin/execve05 $LTPROOT/testcases/bin/execve05 4"
contacts=""
analysis=exit
<<<test_output>>>
execve05    1  TPASS  :  Test DONE, pid 15981, -- /lkp/benchmarks/ltp/testcases/bin/execve05 0 /lkp/benchmarks/ltp/testcases/bin/execve05 /lkp/benchmarks/ltp/testcases/bin/execve05
execve05    1  TPASS  :  Test DONE, pid 15982, -- /lkp/benchmarks/ltp/testcases/bin/execve05 0 /lkp/benchmarks/ltp/testcases/bin/execve05 /lkp/benchmarks/ltp/testcases/bin/execve05
execve05    1  TPASS  :  Test DONE, pid 15983, -- /lkp/benchmarks/ltp/testcases/bin/execve05 0 /lkp/benchmarks/ltp/testcases/bin/execve05 /lkp/benchmarks/ltp/testcases/bin/execve05
execve05    1  TPASS  :  Test DONE, pid 15984, -- /lkp/benchmarks/ltp/testcases/bin/execve05 0 /lkp/benchmarks/ltp/testcases/bin/execve05 /lkp/benchmarks/ltp/testcases/bin/execve05
execve05    1  TPASS  :  Test DONE, pid 15985, -- /lkp/benchmarks/ltp/testcases/bin/execve05 0 /lkp/benchmarks/ltp/testcases/bin/execve05 /lkp/benchmarks/ltp/testcases/bin/execve05
execve05    1  TPASS  :  Test DONE, pid 15986, -- /lkp/benchmarks/ltp/testcases/bin/execve05 0 /lkp/benchmarks/ltp/testcases/bin/execve05 /lkp/benchmarks/ltp/testcases/bin/execve05
execve05    1  TPASS  :  Test DONE, pid 15987, -- /lkp/benchmarks/ltp/testcases/bin/execve05 0 /lkp/benchmarks/ltp/testcases/bin/execve05 /lkp/benchmarks/ltp/testcases/bin/execve05
execve05    1  TPASS  :  Test DONE, pid 15988, -- /lkp/benchmarks/ltp/testcases/bin/execve05 0 /lkp/benchmarks/ltp/testcases/bin/execve05 /lkp/benchmarks/ltp/testcases/bin/execve05
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=2 cstime=5
<<<test_end>>>
<<<test_start>>>
tag=execvp01 stime=1411895411
cmdline="execvp01"
contacts=""
analysis=exit
<<<test_output>>>
execvp01    1  TPASS  :  execvp - properly exec's a simple program..
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=exit01 stime=1411895411
cmdline="exit01"
contacts=""
analysis=exit
<<<test_output>>>
exit01      1  TPASS  :  exit() test PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=exit02 stime=1411895411
cmdline="exit02"
contacts=""
analysis=exit
<<<test_output>>>
exit02      1  TPASS  :  exit() test PASSED
<<<execution_status>>>
initiation_status="ok"
duration=3 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=exit_group01 stime=1411895414
cmdline="exit_group01"
contacts=""
analysis=exit
<<<test_output>>>
exit_group01    1  TPASS  :  exit_group succeeded
<<<execution_status>>>
initiation_status="ok"
duration=5 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=faccessat01 stime=1411895419
cmdline="faccessat01"
contacts=""
analysis=exit
<<<test_output>>>
faccessat01    1  TPASS  :  faccessat() returned the expected  errno 0: Success
faccessat01    2  TPASS  :  faccessat() returned the expected  errno 0: Success
faccessat01    3  TPASS  :  faccessat() returned the expected  errno 20: Not a directory
faccessat01    4  TPASS  :  faccessat() returned the expected  errno 9: Bad file descriptor
faccessat01    5  TPASS  :  faccessat() returned the expected  errno 0: Success
faccessat01    6  TPASS  :  faccessat() returned the expected  errno 0: Success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fallocate01 stime=1411895419
cmdline="fallocate01"
contacts=""
analysis=exit
<<<test_output>>>
fallocate01    1  TPASS  :  fallocate(7, 0, 49152, 4096) returned 0
fallocate01    2  TPASS  :  write operation on fallocated(7, 0, 49152, 4096) returned 1
fallocate01    3  TPASS  :  fallocate(8, 1, 49152, 4096) returned 0
fallocate01    4  TPASS  :  write operation on fallocated(8, 1, 49152, 4096) returned 1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fallocate02 stime=1411895419
cmdline="fallocate02"
contacts=""
analysis=exit
<<<test_output>>>
fallocate02    1  TPASS  :  fallocate(test_file1:7, 1, 0, 1024) returned 9: TEST_ERRNO=EBADF(9): Bad file descriptor
fallocate02    2  TPASS  :  fallocate(test_file2:8, 1, -1024, 1024) returned 22: TEST_ERRNO=EINVAL(22): Invalid argument
fallocate02    3  TPASS  :  fallocate(test_file2:8, 1, 1024, -1024) returned 22: TEST_ERRNO=EINVAL(22): Invalid argument
fallocate02    4  TPASS  :  fallocate(test_file2:8, 1, 12288, 0) returned 22: TEST_ERRNO=EINVAL(22): Invalid argument
fallocate02    5  TPASS  :  fallocate(test_file2:8, 1, 12288, -1024) returned 22: TEST_ERRNO=EINVAL(22): Invalid argument
fallocate02    6  TPASS  :  fallocate(test_file2:8, 1, -24576, 1024) returned 22: TEST_ERRNO=EINVAL(22): Invalid argument
fallocate02    7  TPASS  :  fallocate(test_file2:8, 1, 9223372036854774784, 1024) returned 27: TEST_ERRNO=EFBIG(27): File too large
fallocate02    8  TPASS  :  fallocate(test_file2:8, 1, 1024, 9223372036854774784) returned 27: TEST_ERRNO=EFBIG(27): File too large
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fallocate03 stime=1411895419
cmdline="fallocate03"
contacts=""
analysis=exit
<<<test_output>>>
fallocate03    1  TPASS  :  fallocate(tfile_sparse_16000, 0, 8192, 4096) returned 0
fallocate03    2  TPASS  :  fallocate(tfile_sparse_16000, 0, 49152, 4096) returned 0
fallocate03    3  TPASS  :  fallocate(tfile_sparse_16000, 0, 69632, 4096) returned 0
fallocate03    4  TPASS  :  fallocate(tfile_sparse_16000, 0, 102400, 4096) returned 0
fallocate03    5  TPASS  :  fallocate(tfile_sparse_16000, 1, 8192, 4096) returned 0
fallocate03    6  TPASS  :  fallocate(tfile_sparse_16000, 1, 49152, 4096) returned 0
fallocate03    7  TPASS  :  fallocate(tfile_sparse_16000, 1, 77824, 4096) returned 0
fallocate03    8  TPASS  :  fallocate(tfile_sparse_16000, 1, 106496, 4096) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=posix_fadvise01 stime=1411895419
cmdline="                     posix_fadvise01"
contacts=""
analysis=exit
<<<test_output>>>
posix_fadvise01    1  TPASS  :  call succeeded expectedly
posix_fadvise01    2  TPASS  :  call succeeded expectedly
posix_fadvise01    3  TPASS  :  call succeeded expectedly
posix_fadvise01    4  TPASS  :  call succeeded expectedly
posix_fadvise01    5  TPASS  :  call succeeded expectedly
posix_fadvise01    6  TPASS  :  call succeeded expectedly
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=posix_fadvise01_64 stime=1411895419
cmdline="               posix_fadvise01_64"
contacts=""
analysis=exit
<<<test_output>>>
posix_fadvise01_64    1  TPASS  :  call succeeded expectedly
posix_fadvise01_64    2  TPASS  :  call succeeded expectedly
posix_fadvise01_64    3  TPASS  :  call succeeded expectedly
posix_fadvise01_64    4  TPASS  :  call succeeded expectedly
posix_fadvise01_64    5  TPASS  :  call succeeded expectedly
posix_fadvise01_64    6  TPASS  :  call succeeded expectedly
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=posix_fadvise02 stime=1411895419
cmdline="                     posix_fadvise02"
contacts=""
analysis=exit
<<<test_output>>>
posix_fadvise02    1  TPASS  :  expected failure - returned value = 9 : Bad file descriptor
posix_fadvise02    2  TPASS  :  expected failure - returned value = 9 : Bad file descriptor
posix_fadvise02    3  TPASS  :  expected failure - returned value = 9 : Bad file descriptor
posix_fadvise02    4  TPASS  :  expected failure - returned value = 9 : Bad file descriptor
posix_fadvise02    5  TPASS  :  expected failure - returned value = 9 : Bad file descriptor
posix_fadvise02    6  TPASS  :  expected failure - returned value = 9 : Bad file descriptor
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=posix_fadvise02_64 stime=1411895419
cmdline="               posix_fadvise02_64"
contacts=""
analysis=exit
<<<test_output>>>
posix_fadvise02_64    1  TPASS  :  expected failure - returned value = 9 : Bad file descriptor
posix_fadvise02_64    2  TPASS  :  expected failure - returned value = 9 : Bad file descriptor
posix_fadvise02_64    3  TPASS  :  expected failure - returned value = 9 : Bad file descriptor
posix_fadvise02_64    4  TPASS  :  expected failure - returned value = 9 : Bad file descriptor
posix_fadvise02_64    5  TPASS  :  expected failure - returned value = 9 : Bad file descriptor
posix_fadvise02_64    6  TPASS  :  expected failure - returned value = 9 : Bad file descriptor
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=posix_fadvise03 stime=1411895419
cmdline="                     posix_fadvise03"
contacts=""
analysis=exit
<<<test_output>>>
posix_fadvise03    1  TPASS  :  expected failure - returned value = 22, advise = 6 : Invalid argument
posix_fadvise03    2  TPASS  :  expected failure - returned value = 22, advise = 7 : Invalid argument
posix_fadvise03    3  TPASS  :  expected failure - returned value = 22, advise = 8 : Invalid argument
posix_fadvise03    4  TPASS  :  expected failure - returned value = 22, advise = 9 : Invalid argument
posix_fadvise03    5  TPASS  :  expected failure - returned value = 22, advise = 10 : Invalid argument
posix_fadvise03    6  TPASS  :  expected failure - returned value = 22, advise = 11 : Invalid argument
posix_fadvise03    7  TPASS  :  expected failure - returned value = 22, advise = 12 : Invalid argument
posix_fadvise03    8  TPASS  :  expected failure - returned value = 22, advise = 13 : Invalid argument
posix_fadvise03    9  TPASS  :  expected failure - returned value = 22, advise = 14 : Invalid argument
posix_fadvise03   10  TPASS  :  expected failure - returned value = 22, advise = 15 : Invalid argument
posix_fadvise03   11  TPASS  :  expected failure - returned value = 22, advise = 16 : Invalid argument
posix_fadvise03   12  TPASS  :  expected failure - returned value = 22, advise = 17 : Invalid argument
posix_fadvise03   13  TPASS  :  expected failure - returned value = 22, advise = 18 : Invalid argument
posix_fadvise03   14  TPASS  :  expected failure - returned value = 22, advise = 19 : Invalid argument
posix_fadvise03   15  TPASS  :  expected failure - returned value = 22, advise = 20 : Invalid argument
posix_fadvise03   16  TPASS  :  expected failure - returned value = 22, advise = 21 : Invalid argument
posix_fadvise03   17  TPASS  :  expected failure - returned value = 22, advise = 22 : Invalid argument
posix_fadvise03   18  TPASS  :  expected failure - returned value = 22, advise = 23 : Invalid argument
posix_fadvise03   19  TPASS  :  expected failure - returned value = 22, advise = 24 : Invalid argument
posix_fadvise03   20  TPASS  :  expected failure - returned value = 22, advise = 25 : Invalid argument
posix_fadvise03   21  TPASS  :  expected failure - returned value = 22, advise = 26 : Invalid argument
posix_fadvise03   22  TPASS  :  expected failure - returned value = 22, advise = 27 : Invalid argument
posix_fadvise03   23  TPASS  :  expected failure - returned value = 22, advise = 28 : Invalid argument
posix_fadvise03   24  TPASS  :  expected failure - returned value = 22, advise = 29 : Invalid argument
posix_fadvise03   25  TPASS  :  expected failure - returned value = 22, advise = 30 : Invalid argument
posix_fadvise03   26  TPASS  :  expected failure - returned value = 22, advise = 31 : Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=posix_fadvise03_64 stime=1411895419
cmdline="               posix_fadvise03_64"
contacts=""
analysis=exit
<<<test_output>>>
posix_fadvise03_64    1  TPASS  :  expected failure - returned value = 22, advise = 6 : Invalid argument
posix_fadvise03_64    2  TPASS  :  expected failure - returned value = 22, advise = 7 : Invalid argument
posix_fadvise03_64    3  TPASS  :  expected failure - returned value = 22, advise = 8 : Invalid argument
posix_fadvise03_64    4  TPASS  :  expected failure - returned value = 22, advise = 9 : Invalid argument
posix_fadvise03_64    5  TPASS  :  expected failure - returned value = 22, advise = 10 : Invalid argument
posix_fadvise03_64    6  TPASS  :  expected failure - returned value = 22, advise = 11 : Invalid argument
posix_fadvise03_64    7  TPASS  :  expected failure - returned value = 22, advise = 12 : Invalid argument
posix_fadvise03_64    8  TPASS  :  expected failure - returned value = 22, advise = 13 : Invalid argument
posix_fadvise03_64    9  TPASS  :  expected failure - returned value = 22, advise = 14 : Invalid argument
posix_fadvise03_64   10  TPASS  :  expected failure - returned value = 22, advise = 15 : Invalid argument
posix_fadvise03_64   11  TPASS  :  expected failure - returned value = 22, advise = 16 : Invalid argument
posix_fadvise03_64   12  TPASS  :  expected failure - returned value = 22, advise = 17 : Invalid argument
posix_fadvise03_64   13  TPASS  :  expected failure - returned value = 22, advise = 18 : Invalid argument
posix_fadvise03_64   14  TPASS  :  expected failure - returned value = 22, advise = 19 : Invalid argument
posix_fadvise03_64   15  TPASS  :  expected failure - returned value = 22, advise = 20 : Invalid argument
posix_fadvise03_64   16  TPASS  :  expected failure - returned value = 22, advise = 21 : Invalid argument
posix_fadvise03_64   17  TPASS  :  expected failure - returned value = 22, advise = 22 : Invalid argument
posix_fadvise03_64   18  TPASS  :  expected failure - returned value = 22, advise = 23 : Invalid argument
posix_fadvise03_64   19  TPASS  :  expected failure - returned value = 22, advise = 24 : Invalid argument
posix_fadvise03_64   20  TPASS  :  expected failure - returned value = 22, advise = 25 : Invalid argument
posix_fadvise03_64   21  TPASS  :  expected failure - returned value = 22, advise = 26 : Invalid argument
posix_fadvise03_64   22  TPASS  :  expected failure - returned value = 22, advise = 27 : Invalid argument
posix_fadvise03_64   23  TPASS  :  expected failure - returned value = 22, advise = 28 : Invalid argument
posix_fadvise03_64   24  TPASS  :  expected failure - returned value = 22, advise = 29 : Invalid argument
posix_fadvise03_64   25  TPASS  :  expected failure - returned value = 22, advise = 30 : Invalid argument
posix_fadvise03_64   26  TPASS  :  expected failure - returned value = 22, advise = 31 : Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=posix_fadvise04 stime=1411895419
cmdline="                     posix_fadvise04"
contacts=""
analysis=exit
<<<test_output>>>
posix_fadvise04    1  TPASS  :  expected failure - returned value = 29 : Illegal seek
posix_fadvise04    2  TPASS  :  expected failure - returned value = 29 : Illegal seek
posix_fadvise04    3  TPASS  :  expected failure - returned value = 29 : Illegal seek
posix_fadvise04    4  TPASS  :  expected failure - returned value = 29 : Illegal seek
posix_fadvise04    5  TPASS  :  expected failure - returned value = 29 : Illegal seek
posix_fadvise04    6  TPASS  :  expected failure - returned value = 29 : Illegal seek
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=posix_fadvise04_64 stime=1411895419
cmdline="               posix_fadvise04_64"
contacts=""
analysis=exit
<<<test_output>>>
posix_fadvise04_64    1  TPASS  :  expected failure - returned value = 29 : Illegal seek
posix_fadvise04_64    2  TPASS  :  expected failure - returned value = 29 : Illegal seek
posix_fadvise04_64    3  TPASS  :  expected failure - returned value = 29 : Illegal seek
posix_fadvise04_64    4  TPASS  :  expected failure - returned value = 29 : Illegal seek
posix_fadvise04_64    5  TPASS  :  expected failure - returned value = 29 : Illegal seek
posix_fadvise04_64    6  TPASS  :  expected failure - returned value = 29 : Illegal seek
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fchdir01 stime=1411895419
cmdline="fchdir01"
contacts=""
analysis=exit
<<<test_output>>>
fchdir01    1  TPASS  :  fchdir call succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fchdir02 stime=1411895419
cmdline="fchdir02"
contacts=""
analysis=exit
<<<test_output>>>
fchdir02    1  TPASS  :  failed as expected with EBADF
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fchdir03 stime=1411895419
cmdline="fchdir03"
contacts=""
analysis=exit
<<<test_output>>>
Got EACCES as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fchmod01 stime=1411895419
cmdline="fchmod01"
contacts=""
analysis=exit
<<<test_output>>>
fchmod01    1  TPASS  :  fchmod(tfile_16013, 0700) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fchmod02 stime=1411895419
cmdline="fchmod02"
contacts=""
analysis=exit
<<<test_output>>>
fchmod02    1  TPASS  :  Functionality of fchmod(7, 01777) Successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fchmod03 stime=1411895419
cmdline="fchmod03"
contacts=""
analysis=exit
<<<test_output>>>
fchmod03    1  TPASS  :  Functionality of fchmod(7, 01777) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fchmod04 stime=1411895419
cmdline="fchmod04"
contacts=""
analysis=exit
<<<test_output>>>
fchmod04    1  TPASS  :  Functionality of fchmod(7, 01777) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fchmod05 stime=1411895419
cmdline="fchmod05"
contacts=""
analysis=exit
<<<test_output>>>
fchmod05    1  TPASS  :  Functionality of fchmod(7, 041777) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fchmod06 stime=1411895419
cmdline="fchmod06"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
fchmod06    0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
fchmod06    0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
fchmod06    1  TPASS  :  fchmod: test EPERM success: TEST_ERRNO=EPERM(1): Operation not permitted
fchmod06    2  TPASS  :  fchmod: test EBADF success: TEST_ERRNO=EBADF(9): Bad file descriptor
fchmod06    3  TPASS  :  fchmod: test EROFS success: TEST_ERRNO=EROFS(30): Read-only file system
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=fchmod07 stime=1411895419
cmdline="fchmod07"
contacts=""
analysis=exit
<<<test_output>>>
fchmod07    1  TPASS  :  Functionality of fchmod(7, 0) successful
fchmod07    2  TPASS  :  Functionality of fchmod(7, 07) successful
fchmod07    3  TPASS  :  Functionality of fchmod(7, 070) successful
fchmod07    4  TPASS  :  Functionality of fchmod(7, 0700) successful
fchmod07    5  TPASS  :  Functionality of fchmod(7, 0777) successful
fchmod07    6  TPASS  :  Functionality of fchmod(7, 02777) successful
fchmod07    7  TPASS  :  Functionality of fchmod(7, 04777) successful
fchmod07    8  TPASS  :  Functionality of fchmod(7, 06777) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fchmodat01 stime=1411895419
cmdline="fchmodat01"
contacts=""
analysis=exit
<<<test_output>>>
fchmodat01    1  TPASS  :  fchmodat() returned the expected  errno 0: Success
fchmodat01    2  TPASS  :  fchmodat() returned the expected  errno 0: Success
fchmodat01    3  TPASS  :  fchmodat() returned the expected  errno 20: Not a directory
fchmodat01    4  TPASS  :  fchmodat() returned the expected  errno 9: Bad file descriptor
fchmodat01    5  TPASS  :  fchmodat() returned the expected  errno 0: Success
fchmodat01    6  TPASS  :  fchmodat() returned the expected  errno 0: Success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fchown01 stime=1411895419
cmdline="fchown01"
contacts=""
analysis=exit
<<<test_output>>>
fchown01    1  TPASS  :  fchown(fd, geteuid(), getegid()) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fchown01_16 stime=1411895419
cmdline="fchown01_16"
contacts=""
analysis=exit
<<<test_output>>>
fchown01    1  TPASS  :  fchown(fd, geteuid(), getegid()) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fchown02 stime=1411895419
cmdline="fchown02"
contacts=""
analysis=exit
<<<test_output>>>
fchown02    1  TPASS  :  fchown() on testfile1 succeeds : Setuid/Setgid bits cleared
fchown02    2  TPASS  :  fchown() on testfile2 succeeds : Setgid bit not cleared
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fchown02_16 stime=1411895419
cmdline="fchown02_16"
contacts=""
analysis=exit
<<<test_output>>>
fchown02    1  TPASS  :  fchown() on testfile1 succeeds : Setuid/Setgid bits cleared
fchown02    2  TPASS  :  fchown() on testfile2 succeeds : Setgid bit not cleared
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fchown03 stime=1411895419
cmdline="fchown03"
contacts=""
analysis=exit
<<<test_output>>>
fchown03    1  TPASS  :  fchown() on testfile succeeds: Setuid/gid bits cleared
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fchown03_16 stime=1411895419
cmdline="fchown03_16"
contacts=""
analysis=exit
<<<test_output>>>
fchown03    1  TPASS  :  fchown() on testfile succeeds: Setuid/gid bits cleared
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fchown04 stime=1411895419
cmdline="fchown04"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
fchown04    0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
fchown04    0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
fchown04    1  TPASS  :  fchown failed as expected: TEST_ERRNO=EPERM(1): Operation not permitted
fchown04    2  TPASS  :  fchown failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
fchown04    3  TPASS  :  fchown failed as expected: TEST_ERRNO=EROFS(30): Read-only file system
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fchown04_16 stime=1411895419
cmdline="fchown04_16"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
fchown04    0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
fchown04    0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
fchown04    1  TPASS  :  fchown failed as expected: TEST_ERRNO=EPERM(1): Operation not permitted
fchown04    2  TPASS  :  fchown failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
fchown04    3  TPASS  :  fchown failed as expected: TEST_ERRNO=EROFS(30): Read-only file system
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=fchown05 stime=1411895419
cmdline="fchown05"
contacts=""
analysis=exit
<<<test_output>>>
fchown05    1  TPASS  :  fchown() succeeds to Change Owner/Group ids of testfile
fchown05    2  TPASS  :  fchown() succeeds to Change Owner id only of testfile
fchown05    3  TPASS  :  fchown() succeeds to Change Owner id only of testfile
fchown05    4  TPASS  :  fchown() succeeds to Change Group id only of testfile
fchown05    5  TPASS  :  fchown() succeeds to Change Group id only of testfile
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fchown05_16 stime=1411895419
cmdline="fchown05_16"
contacts=""
analysis=exit
<<<test_output>>>
fchown05    1  TPASS  :  fchown() succeeds to Change Owner/Group ids of testfile
fchown05    2  TPASS  :  fchown() succeeds to Change Owner id only of testfile
fchown05    3  TPASS  :  fchown() succeeds to Change Owner id only of testfile
fchown05    4  TPASS  :  fchown() succeeds to Change Group id only of testfile
fchown05    5  TPASS  :  fchown() succeeds to Change Group id only of testfile
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fchownat01 stime=1411895419
cmdline="fchownat01"
contacts=""
analysis=exit
<<<test_output>>>
fchownat01    1  TPASS  :  fchownat() returned the expected errno 0: Success: TEST_ERRNO=SUCCESS(0): Success
fchownat01    2  TPASS  :  fchownat() returned the expected errno -1: Not a directory: TEST_ERRNO=ENOTDIR(20): Not a directory
fchownat01    3  TPASS  :  fchownat() returned the expected errno -1: Bad file descriptor: TEST_ERRNO=EBADF(9): Bad file descriptor
fchownat01    4  TPASS  :  fchownat() returned the expected errno -1: Invalid argument: TEST_ERRNO=EINVAL(22): Invalid argument
fchownat01    5  TPASS  :  fchownat() returned the expected errno 0: Success: TEST_ERRNO=SUCCESS(0): Success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fchownat02 stime=1411895419
cmdline="fchownat02"
contacts=""
analysis=exit
<<<test_output>>>
fchownat02    1  TPASS  :  fchownat() test AT_SYMLINK_NOFOLLOW success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl01 stime=1411895419
cmdline="fcntl01"
contacts=""
analysis=exit
<<<test_output>>>
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl01_64 stime=1411895419
cmdline="fcntl01_64"
contacts=""
analysis=exit
<<<test_output>>>
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl02 stime=1411895419
cmdline="fcntl02"
contacts=""
analysis=exit
<<<test_output>>>
fcntl02     1  TPASS  :  fcntl(tfile_16044, F_DUPFD, 0) returned 8
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl02_64 stime=1411895419
cmdline="fcntl02_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl02     1  TPASS  :  fcntl(tfile_16045, F_DUPFD, 0) returned 8
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl03 stime=1411895419
cmdline="fcntl03"
contacts=""
analysis=exit
<<<test_output>>>
fcntl03     1  TPASS  :  fcntl(tfile_16046, F_GETFD, 0) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl03_64 stime=1411895419
cmdline="fcntl03_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl03     1  TPASS  :  fcntl(tfile_16047, F_GETFD, 0) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl04 stime=1411895419
cmdline="fcntl04"
contacts=""
analysis=exit
<<<test_output>>>
fcntl04     1  TPASS  :  fcntl returned 32770
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl04_64 stime=1411895419
cmdline="fcntl04_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl04     1  TPASS  :  fcntl returned 32770
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl05 stime=1411895419
cmdline="fcntl05"
contacts=""
analysis=exit
<<<test_output>>>
fcntl05     1  TPASS  :  fcntl returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=fcntl05_64 stime=1411895419
cmdline="fcntl05_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl05     1  TPASS  :  fcntl returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl06 stime=1411895419
cmdline="fcntl06"
contacts=""
analysis=exit
<<<test_output>>>
fcntl06     1  TCONF  :  fcntl06.c:113: system doesn't have LINUX_LOCK_FILE_REGION support
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl06_64 stime=1411895419
cmdline="fcntl06_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl06     1  TCONF  :  fcntl06.c:113: system doesn't have LINUX_LOCK_FILE_REGION support
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl07 stime=1411895419
cmdline="fcntl07"
contacts=""
analysis=exit
<<<test_output>>>
fcntl07     1  TPASS  :  regular file CLOEXEC fd was closed after exec()
fcntl07     2  TPASS  :  pipe (write end) CLOEXEC fd was closed after exec()
fcntl07     3  TPASS  :  pipe (read end) CLOEXEC fd was closed after exec()
fcntl07     4  TPASS  :  fifo CLOEXEC fd was closed after exec()
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl07_64 stime=1411895419
cmdline="fcntl07_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl07     1  TPASS  :  regular file CLOEXEC fd was closed after exec()
fcntl07     2  TPASS  :  pipe (write end) CLOEXEC fd was closed after exec()
fcntl07     3  TPASS  :  pipe (read end) CLOEXEC fd was closed after exec()
fcntl07     4  TPASS  :  fifo CLOEXEC fd was closed after exec()
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl08 stime=1411895419
cmdline="fcntl08"
contacts=""
analysis=exit
<<<test_output>>>
fcntl08     1  TPASS  :  fcntl returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl08_64 stime=1411895419
cmdline="fcntl08_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl08     1  TPASS  :  fcntl returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl09 stime=1411895419
cmdline="fcntl09"
contacts=""
analysis=exit
<<<test_output>>>
fcntl09     1  TPASS  :  fcntl(./file_16066, F_SETLK, &flocks) flocks.l_type = F_WRLCK returned 0
fcntl09     2  TPASS  :  fcntl(./file_16066, F_SETLK, &flocks) flocks.l_type = F_UNLCK returned 0
fcntl09     1  TPASS  :  fcntl(./file_16066, F_SETLK, &flocks) flocks.l_type = F_RDLCK returned 0
fcntl09     2  TPASS  :  fcntl(./file_16066, F_SETLK, &flocks) flocks.l_type = F_UNLCK returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl09_64 stime=1411895419
cmdline="fcntl09_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl09     1  TPASS  :  fcntl(./file_16067, F_SETLK, &flocks) flocks.l_type = F_WRLCK returned 0
fcntl09     2  TPASS  :  fcntl(./file_16067, F_SETLK, &flocks) flocks.l_type = F_UNLCK returned 0
fcntl09     1  TPASS  :  fcntl(./file_16067, F_SETLK, &flocks) flocks.l_type = F_RDLCK returned 0
fcntl09     2  TPASS  :  fcntl(./file_16067, F_SETLK, &flocks) flocks.l_type = F_UNLCK returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl10 stime=1411895419
cmdline="fcntl10"
contacts=""
analysis=exit
<<<test_output>>>
fcntl10     1  TPASS  :  fcntl(tfile_16068, F_SETLKW, &flocks) flocks.l_type = F_WRLCK returned 0
fcntl10     2  TPASS  :  fcntl(tfile_16068, F_SETLKW, &flocks) flocks.l_type = F_UNLCK returned 0
fcntl10     1  TPASS  :  fcntl(tfile_16068, F_SETLKW, &flocks) flocks.l_type = F_RDLCK returned 0
fcntl10     2  TPASS  :  fcntl(tfile_16068, F_SETLKW, &flocks) flocks.l_type = F_UNLCK returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl10_64 stime=1411895419
cmdline="fcntl10_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl10     1  TPASS  :  fcntl(tfile_16069, F_SETLKW, &flocks) flocks.l_type = F_WRLCK returned 0
fcntl10     2  TPASS  :  fcntl(tfile_16069, F_SETLKW, &flocks) flocks.l_type = F_UNLCK returned 0
fcntl10     1  TPASS  :  fcntl(tfile_16069, F_SETLKW, &flocks) flocks.l_type = F_RDLCK returned 0
fcntl10     2  TPASS  :  fcntl(tfile_16069, F_SETLKW, &flocks) flocks.l_type = F_UNLCK returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl11 stime=1411895419
cmdline="fcntl11"
contacts=""
analysis=exit
<<<test_output>>>
fcntl11     0  TINFO  :  Enter block 1
fcntl11     0  TINFO  :  Exit block 1
fcntl11     0  TINFO  :  Enter block 2
fcntl11     0  TINFO  :  Exit block 2
fcntl11     0  TINFO  :  Enter block 3
fcntl11     0  TINFO  :  Exit block 3
fcntl11     0  TINFO  :  Enter block 4
fcntl11     0  TINFO  :  Exit block 4
fcntl11     0  TINFO  :  Enter block 5
fcntl11     0  TINFO  :  Exit block 5
fcntl11     0  TINFO  :  Enter block 6
fcntl11     0  TINFO  :  Exit block 6
fcntl11     0  TINFO  :  Enter block 7
fcntl11     0  TINFO  :  Exit block 7
fcntl11     0  TINFO  :  Enter block 8
fcntl11     0  TINFO  :  Exit block 8
fcntl11     0  TINFO  :  Enter block 9
fcntl11     0  TINFO  :  Exit block 9
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=fcntl11_64 stime=1411895419
cmdline="fcntl11_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl11     0  TINFO  :  Enter block 1
fcntl11     0  TINFO  :  Exit block 1
fcntl11     0  TINFO  :  Enter block 2
fcntl11     0  TINFO  :  Exit block 2
fcntl11     0  TINFO  :  Enter block 3
fcntl11     0  TINFO  :  Exit block 3
fcntl11     0  TINFO  :  Enter block 4
fcntl11     0  TINFO  :  Exit block 4
fcntl11     0  TINFO  :  Enter block 5
fcntl11     0  TINFO  :  Exit block 5
fcntl11     0  TINFO  :  Enter block 6
fcntl11     0  TINFO  :  Exit block 6
fcntl11     0  TINFO  :  Enter block 7
fcntl11     0  TINFO  :  Exit block 7
fcntl11     0  TINFO  :  Enter block 8
fcntl11     0  TINFO  :  Exit block 8
fcntl11     0  TINFO  :  Enter block 9
fcntl11     0  TINFO  :  Exit block 9
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl12 stime=1411895419
cmdline="fcntl12"
contacts=""
analysis=exit
<<<test_output>>>
fcntl12     0  TINFO  :  Enter block 1
fcntl12     0  TINFO  :  Test for errno EMFILE
fcntl12     0  TINFO  :  block 1 PASSED
fcntl12     0  TINFO  :  Exit block 1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl12_64 stime=1411895419
cmdline="fcntl12_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl12     0  TINFO  :  Enter block 1
fcntl12     0  TINFO  :  Test for errno EMFILE
fcntl12     0  TINFO  :  block 1 PASSED
fcntl12     0  TINFO  :  Exit block 1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl13 stime=1411895419
cmdline="fcntl13"
contacts=""
analysis=exit
<<<test_output>>>
fcntl13     0  TINFO  :  Enter block 1
fcntl13     0  TINFO  :  Test for errno EINVAL
fcntl13     0  TINFO  :  block 1 PASSED
fcntl13     0  TINFO  :  Exit block 1
fcntl13     0  TINFO  :  Enter block 2
fcntl13     0  TINFO  :  Test for errno EFAULT
fcntl13     0  TINFO  :  block 2 PASSED
fcntl13     0  TINFO  :  Exit block 2
fcntl13     0  TINFO  :  Enter block 3
fcntl13     0  TINFO  :  Test for errno EINVAL
fcntl13     0  TINFO  :  block 3 PASSED
fcntl13     0  TINFO  :  Exit block 3
fcntl13     0  TINFO  :  Enter block 4
fcntl13     0  TINFO  :  Test for errno EBADF
fcntl13     0  TINFO  :  block 4 PASSED
fcntl13     0  TINFO  :  Exit block 4
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl13_64 stime=1411895419
cmdline="fcntl13_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl13     0  TINFO  :  Enter block 1
fcntl13     0  TINFO  :  Test for errno EINVAL
fcntl13     0  TINFO  :  block 1 PASSED
fcntl13     0  TINFO  :  Exit block 1
fcntl13     0  TINFO  :  Enter block 2
fcntl13     0  TINFO  :  Test for errno EFAULT
fcntl13     0  TINFO  :  block 2 PASSED
fcntl13     0  TINFO  :  Exit block 2
fcntl13     0  TINFO  :  Enter block 3
fcntl13     0  TINFO  :  Test for errno EINVAL
fcntl13     0  TINFO  :  block 3 PASSED
fcntl13     0  TINFO  :  Exit block 3
fcntl13     0  TINFO  :  Enter block 4
fcntl13     0  TINFO  :  Test for errno EBADF
fcntl13     0  TINFO  :  block 4 PASSED
fcntl13     0  TINFO  :  Exit block 4
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl14 stime=1411895419
cmdline="fcntl14"
contacts=""
analysis=exit
<<<test_output>>>
fcntl14     0  TINFO  :  Enter block 1: without mandatory locking
fcntl14     1  TPASS  :  testcase:1 PASSED
fcntl14     2  TPASS  :  testcase:2 PASSED
fcntl14     3  TPASS  :  testcase:3 PASSED
fcntl14     4  TPASS  :  testcase:4 PASSED
fcntl14     5  TPASS  :  testcase:5 PASSED
fcntl14     6  TPASS  :  testcase:6 PASSED
fcntl14     7  TPASS  :  testcase:7 PASSED
fcntl14     8  TPASS  :  testcase:8 PASSED
fcntl14     9  TPASS  :  testcase:9 PASSED
fcntl14    10  TPASS  :  testcase:10 PASSED
fcntl14    11  TPASS  :  testcase:11 PASSED
fcntl14    12  TPASS  :  testcase:12 PASSED
fcntl14    13  TPASS  :  testcase:13 PASSED
fcntl14    14  TPASS  :  testcase:14 PASSED
fcntl14    15  TPASS  :  testcase:15 PASSED
fcntl14    16  TPASS  :  testcase:16 PASSED
fcntl14    17  TPASS  :  testcase:17 PASSED
fcntl14    18  TPASS  :  testcase:18 PASSED
fcntl14    19  TPASS  :  testcase:19 PASSED
fcntl14    20  TPASS  :  testcase:20 PASSED
fcntl14    21  TPASS  :  testcase:21 PASSED
fcntl14    22  TPASS  :  testcase:22 PASSED
fcntl14    23  TPASS  :  testcase:23 PASSED
fcntl14    24  TPASS  :  testcase:24 PASSED
fcntl14    25  TPASS  :  testcase:25 PASSED
fcntl14    26  TPASS  :  testcase:26 PASSED
fcntl14    27  TPASS  :  testcase:27 PASSED
fcntl14    28  TPASS  :  testcase:28 PASSED
fcntl14    29  TPASS  :  testcase:29 PASSED
fcntl14    30  TPASS  :  testcase:30 PASSED
fcntl14    31  TPASS  :  testcase:31 PASSED
fcntl14    32  TPASS  :  testcase:32 PASSED
fcntl14    33  TPASS  :  testcase:33 PASSED
fcntl14    34  TPASS  :  testcase:34 PASSED
fcntl14    35  TPASS  :  testcase:35 PASSED
fcntl14    36  TPASS  :  testcase:36 PASSED
fcntl14    37  TPASS  :  Block 1, test 1 PASSED
fcntl14    38  TPASS  :  testcase:37 PASSED
fcntl14    39  TPASS  :  testcase:38 PASSED
fcntl14    40  TPASS  :  testcase:39 PASSED
fcntl14    41  TPASS  :  testcase:40 PASSED
fcntl14    42  TPASS  :  testcase:41 PASSED
fcntl14    43  TPASS  :  testcase:42 PASSED
fcntl14    44  TPASS  :  testcase:43 PASSED
fcntl14    45  TPASS  :  testcase:44 PASSED
fcntl14    46  TPASS  :  testcase:45 PASSED
fcntl14    47  TPASS  :  Block 1, test 2 PASSED
fcntl14     0  TINFO  :  Exit block 1
fcntl14     0  TINFO  :  Enter block 2: with mandatory locking
fcntl14    48  TPASS  :  testcase:1 PASSED
fcntl14    49  TPASS  :  testcase:2 PASSED
fcntl14    50  TPASS  :  testcase:3 PASSED
fcntl14    51  TPASS  :  testcase:4 PASSED
fcntl14    52  TPASS  :  testcase:5 PASSED
fcntl14    53  TPASS  :  testcase:6 PASSED
fcntl14    54  TPASS  :  testcase:7 PASSED
fcntl14    55  TPASS  :  testcase:8 PASSED
fcntl14    56  TPASS  :  testcase:9 PASSED
fcntl14    57  TPASS  :  testcase:10 PASSED
fcntl14    58  TPASS  :  testcase:11 PASSED
fcntl14    59  TPASS  :  testcase:12 PASSED
fcntl14    60  TPASS  :  testcase:13 PASSED
fcntl14    61  TPASS  :  testcase:14 PASSED
fcntl14    62  TPASS  :  testcase:15 PASSED
fcntl14    63  TPASS  :  testcase:16 PASSED
fcntl14    64  TPASS  :  testcase:17 PASSED
fcntl14    65  TPASS  :  testcase:18 PASSED
fcntl14    66  TPASS  :  testcase:19 PASSED
fcntl14    67  TPASS  :  testcase:20 PASSED
fcntl14    68  TPASS  :  testcase:21 PASSED
fcntl14    69  TPASS  :  testcase:22 PASSED
fcntl14    70  TPASS  :  testcase:23 PASSED
fcntl14    71  TPASS  :  testcase:24 PASSED
fcntl14    72  TPASS  :  testcase:25 PASSED
fcntl14    73  TPASS  :  testcase:26 PASSED
fcntl14    74  TPASS  :  testcase:27 PASSED
fcntl14    75  TPASS  :  testcase:28 PASSED
fcntl14    76  TPASS  :  testcase:29 PASSED
fcntl14    77  TPASS  :  testcase:30 PASSED
fcntl14    78  TPASS  :  testcase:31 PASSED
fcntl14    79  TPASS  :  testcase:32 PASSED
fcntl14    80  TPASS  :  testcase:33 PASSED
fcntl14    81  TPASS  :  testcase:34 PASSED
fcntl14    82  TPASS  :  testcase:35 PASSED
fcntl14    83  TPASS  :  testcase:36 PASSED
fcntl14    84  TPASS  :  Block 2, test 1 PASSED
fcntl14    85  TPASS  :  testcase:37 PASSED
fcntl14    86  TPASS  :  testcase:38 PASSED
fcntl14    87  TPASS  :  testcase:39 PASSED
fcntl14    88  TPASS  :  testcase:40 PASSED
fcntl14    89  TPASS  :  testcase:41 PASSED
fcntl14    90  TPASS  :  testcase:42 PASSED
fcntl14    91  TPASS  :  testcase:43 PASSED
fcntl14    92  TPASS  :  testcase:44 PASSED
fcntl14    93  TPASS  :  testcase:45 PASSED
fcntl14    94  TPASS  :  Block 2, test 2 PASSED
fcntl14     0  TINFO  :  Exit block 2
fcntl14     0  TINFO  :  Enter block 3
fcntl14     0  TINFO  :  Test with mandatory locking PASSED
fcntl14     0  TINFO  :  Exit block 3
fcntl14     0  TINFO  :  Enter block 4
fcntl14     0  TINFO  :  Test of locks on file PASSED
fcntl14     0  TINFO  :  Exit block 4
<<<execution_status>>>
initiation_status="ok"
duration=5 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=6
<<<test_end>>>
<<<test_start>>>
tag=fcntl14_64 stime=1411895424
cmdline="fcntl14_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl14     0  TINFO  :  Enter block 1: without mandatory locking
fcntl14     1  TPASS  :  testcase:1 PASSED
fcntl14     2  TPASS  :  testcase:2 PASSED
fcntl14     3  TPASS  :  testcase:3 PASSED
fcntl14     4  TPASS  :  testcase:4 PASSED
fcntl14     5  TPASS  :  testcase:5 PASSED
fcntl14     6  TPASS  :  testcase:6 PASSED
fcntl14     7  TPASS  :  testcase:7 PASSED
fcntl14     8  TPASS  :  testcase:8 PASSED
fcntl14     9  TPASS  :  testcase:9 PASSED
fcntl14    10  TPASS  :  testcase:10 PASSED
fcntl14    11  TPASS  :  testcase:11 PASSED
fcntl14    12  TPASS  :  testcase:12 PASSED
fcntl14    13  TPASS  :  testcase:13 PASSED
fcntl14    14  TPASS  :  testcase:14 PASSED
fcntl14    15  TPASS  :  testcase:15 PASSED
fcntl14    16  TPASS  :  testcase:16 PASSED
fcntl14    17  TPASS  :  testcase:17 PASSED
fcntl14    18  TPASS  :  testcase:18 PASSED
fcntl14    19  TPASS  :  testcase:19 PASSED
fcntl14    20  TPASS  :  testcase:20 PASSED
fcntl14    21  TPASS  :  testcase:21 PASSED
fcntl14    22  TPASS  :  testcase:22 PASSED
fcntl14    23  TPASS  :  testcase:23 PASSED
fcntl14    24  TPASS  :  testcase:24 PASSED
fcntl14    25  TPASS  :  testcase:25 PASSED
fcntl14    26  TPASS  :  testcase:26 PASSED
fcntl14    27  TPASS  :  testcase:27 PASSED
fcntl14    28  TPASS  :  testcase:28 PASSED
fcntl14    29  TPASS  :  testcase:29 PASSED
fcntl14    30  TPASS  :  testcase:30 PASSED
fcntl14    31  TPASS  :  testcase:31 PASSED
fcntl14    32  TPASS  :  testcase:32 PASSED
fcntl14    33  TPASS  :  testcase:33 PASSED
fcntl14    34  TPASS  :  testcase:34 PASSED
fcntl14    35  TPASS  :  testcase:35 PASSED
fcntl14    36  TPASS  :  testcase:36 PASSED
fcntl14    37  TPASS  :  Block 1, test 1 PASSED
fcntl14    38  TPASS  :  testcase:37 PASSED
fcntl14    39  TPASS  :  testcase:38 PASSED
fcntl14    40  TPASS  :  testcase:39 PASSED
fcntl14    41  TPASS  :  testcase:40 PASSED
fcntl14    42  TPASS  :  testcase:41 PASSED
fcntl14    43  TPASS  :  testcase:42 PASSED
fcntl14    44  TPASS  :  testcase:43 PASSED
fcntl14    45  TPASS  :  testcase:44 PASSED
fcntl14    46  TPASS  :  testcase:45 PASSED
fcntl14    47  TPASS  :  Block 1, test 2 PASSED
fcntl14     0  TINFO  :  Exit block 1
fcntl14     0  TINFO  :  Enter block 2: with mandatory locking
fcntl14    48  TPASS  :  testcase:1 PASSED
fcntl14    49  TPASS  :  testcase:2 PASSED
fcntl14    50  TPASS  :  testcase:3 PASSED
fcntl14    51  TPASS  :  testcase:4 PASSED
fcntl14    52  TPASS  :  testcase:5 PASSED
fcntl14    53  TPASS  :  testcase:6 PASSED
fcntl14    54  TPASS  :  testcase:7 PASSED
fcntl14    55  TPASS  :  testcase:8 PASSED
fcntl14    56  TPASS  :  testcase:9 PASSED
fcntl14    57  TPASS  :  testcase:10 PASSED
fcntl14    58  TPASS  :  testcase:11 PASSED
fcntl14    59  TPASS  :  testcase:12 PASSED
fcntl14    60  TPASS  :  testcase:13 PASSED
fcntl14    61  TPASS  :  testcase:14 PASSED
fcntl14    62  TPASS  :  testcase:15 PASSED
fcntl14    63  TPASS  :  testcase:16 PASSED
fcntl14    64  TPASS  :  testcase:17 PASSED
fcntl14    65  TPASS  :  testcase:18 PASSED
fcntl14    66  TPASS  :  testcase:19 PASSED
fcntl14    67  TPASS  :  testcase:20 PASSED
fcntl14    68  TPASS  :  testcase:21 PASSED
fcntl14    69  TPASS  :  testcase:22 PASSED
fcntl14    70  TPASS  :  testcase:23 PASSED
fcntl14    71  TPASS  :  testcase:24 PASSED
fcntl14    72  TPASS  :  testcase:25 PASSED
fcntl14    73  TPASS  :  testcase:26 PASSED
fcntl14    74  TPASS  :  testcase:27 PASSED
fcntl14    75  TPASS  :  testcase:28 PASSED
fcntl14    76  TPASS  :  testcase:29 PASSED
fcntl14    77  TPASS  :  testcase:30 PASSED
fcntl14    78  TPASS  :  testcase:31 PASSED
fcntl14    79  TPASS  :  testcase:32 PASSED
fcntl14    80  TPASS  :  testcase:33 PASSED
fcntl14    81  TPASS  :  testcase:34 PASSED
fcntl14    82  TPASS  :  testcase:35 PASSED
fcntl14    83  TPASS  :  testcase:36 PASSED
fcntl14    84  TPASS  :  Block 2, test 1 PASSED
fcntl14    85  TPASS  :  testcase:37 PASSED
fcntl14    86  TPASS  :  testcase:38 PASSED
fcntl14    87  TPASS  :  testcase:39 PASSED
fcntl14    88  TPASS  :  testcase:40 PASSED
fcntl14    89  TPASS  :  testcase:41 PASSED
fcntl14    90  TPASS  :  testcase:42 PASSED
fcntl14    91  TPASS  :  testcase:43 PASSED
fcntl14    92  TPASS  :  testcase:44 PASSED
fcntl14    93  TPASS  :  testcase:45 PASSED
fcntl14    94  TPASS  :  Block 2, test 2 PASSED
fcntl14     0  TINFO  :  Exit block 2
fcntl14     0  TINFO  :  Enter block 3
fcntl14     0  TINFO  :  Test with mandatory locking PASSED
fcntl14     0  TINFO  :  Exit block 3
fcntl14     0  TINFO  :  Enter block 4
fcntl14     0  TINFO  :  Test of locks on file PASSED
fcntl14     0  TINFO  :  Exit block 4
<<<execution_status>>>
initiation_status="ok"
duration=6 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=5
<<<test_end>>>
<<<test_start>>>
tag=fcntl15 stime=1411895430
cmdline="fcntl15"
contacts=""
analysis=exit
<<<test_output>>>
fcntl15     0  TINFO  :  Entering block 1
fcntl15     0  TINFO  :  Test 1: test with "dup" PASSED
fcntl15     0  TINFO  :  Exiting block 1
fcntl15     0  TINFO  :  Entering block 2
fcntl15     0  TINFO  :  Failed to record test working dir
fcntl15     0  TINFO  :  Test 2: test with "open" PASSED
fcntl15     0  TINFO  :  Exiting block 2
fcntl15     0  TINFO  :  Entering block 3
fcntl15     0  TINFO  :  Failed to record test working dir
fcntl15     0  TINFO  :  Test 3: test with "fork" PASSED
fcntl15     0  TINFO  :  Exiting block 3
<<<execution_status>>>
initiation_status="ok"
duration=10 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl15_64 stime=1411895440
cmdline="fcntl15_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl15     0  TINFO  :  Entering block 1
fcntl15     0  TINFO  :  Test 1: test with "dup" PASSED
fcntl15     0  TINFO  :  Exiting block 1
fcntl15     0  TINFO  :  Entering block 2
fcntl15     0  TINFO  :  Failed to record test working dir
fcntl15     0  TINFO  :  Test 2: test with "open" PASSED
fcntl15     0  TINFO  :  Exiting block 2
fcntl15     0  TINFO  :  Entering block 3
fcntl15     0  TINFO  :  Failed to record test working dir
fcntl15     0  TINFO  :  Test 3: test with "fork" PASSED
fcntl15     0  TINFO  :  Exiting block 3
<<<execution_status>>>
initiation_status="ok"
duration=10 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl16 stime=1411895450
cmdline="fcntl16"
contacts=""
analysis=exit
<<<test_output>>>
fcntl16     0  TINFO  :  Entering block 1
fcntl16     0  TINFO  :  Test case 1: without manadatory locking PASSED
fcntl16     0  TINFO  :  Exiting block 1
fcntl16     0  TINFO  :  Entering block 2
fcntl16     0  TINFO  :  Test case 2: with mandatory record locking PASSED
fcntl16     0  TINFO  :  Exiting block 2
fcntl16     0  TINFO  :  Entering block 3
fcntl16     0  TINFO  :  Test case 3: mandatory locking with NODELAY PASSED
fcntl16     0  TINFO  :  Exiting block 3
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl16_64 stime=1411895450
cmdline="fcntl16_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl16     0  TINFO  :  Entering block 1
fcntl16     0  TINFO  :  Test case 1: without manadatory locking PASSED
fcntl16     0  TINFO  :  Exiting block 1
fcntl16     0  TINFO  :  Entering block 2
fcntl16     0  TINFO  :  Test case 2: with mandatory record locking PASSED
fcntl16     0  TINFO  :  Exiting block 2
fcntl16     0  TINFO  :  Entering block 3
fcntl16     0  TINFO  :  Test case 3: mandatory locking with NODELAY PASSED
fcntl16     0  TINFO  :  Exiting block 3
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl17 stime=1411895450
cmdline="fcntl17"
contacts=""
analysis=exit
<<<test_output>>>
fcntl17     0  TINFO  :  Enter preparation phase
fcntl17     0  TINFO  :  child 3 starting
fcntl17     0  TINFO  :  child 3 pid 16385 locked
fcntl17     0  TINFO  :  child 3 resuming
fcntl17     0  TINFO  :  child 3 lockw err 35
fcntl17     0  TINFO  :  child 3 exiting
fcntl17     0  TINFO  :  child 1 starting
fcntl17     0  TINFO  :  child 1 pid 16383 locked
fcntl17     0  TINFO  :  child 1 resuming
fcntl17     0  TINFO  :  child 1 unlocked
fcntl17     0  TINFO  :  child 1 exiting
fcntl17     0  TINFO  :  child 2 starting
fcntl17     0  TINFO  :  child 2 pid 16384 locked
fcntl17     0  TINFO  :  child 2 resuming
fcntl17     0  TINFO  :  child 2 lockw locked
fcntl17     0  TINFO  :  child 2 exiting
fcntl17     0  TINFO  :  Exit preparation phase
fcntl17     0  TINFO  :  Enter block 1
fcntl17     0  TINFO  :  Block 1 PASSED
fcntl17     0  TINFO  :  Exit block 1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl17_64 stime=1411895450
cmdline="fcntl17_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl17     0  TINFO  :  Enter preparation phase
fcntl17     0  TINFO  :  child 1 starting
fcntl17     0  TINFO  :  child 1 pid 16387 locked
fcntl17     0  TINFO  :  child 1 resuming
fcntl17     0  TINFO  :  child 1 unlocked
fcntl17     0  TINFO  :  child 1 exiting
fcntl17     0  TINFO  :  child 2 starting
fcntl17     0  TINFO  :  child 2 pid 16388 locked
fcntl17     0  TINFO  :  child 2 resuming
fcntl17     0  TINFO  :  child 2 lockw err 35
fcntl17     0  TINFO  :  child 2 exiting
fcntl17     0  TINFO  :  child 3 starting
fcntl17     0  TINFO  :  child 3 pid 16389 locked
fcntl17     0  TINFO  :  child 3 resuming
fcntl17     0  TINFO  :  child 3 lockw locked
fcntl17     0  TINFO  :  child 3 exiting
fcntl17     0  TINFO  :  Exit preparation phase
fcntl17     0  TINFO  :  Enter block 1
fcntl17     0  TINFO  :  Block 1 PASSED
fcntl17     0  TINFO  :  Exit block 1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl18 stime=1411895450
cmdline="fcntl18"
contacts=""
analysis=exit
<<<test_output>>>
fcntl18     0  TINFO  :  Enter block 1
fcntl18     1  TPASS  :  Test F_GETLK: for errno EFAULT PASSED
fcntl18     0  TINFO  :  Block 1 PASSED
fcntl18     0  TINFO  :  Exit block 1
fcntl18     0  TINFO  :  Enter block 2
fcntl18     2  TPASS  :  Test F_GETLK64: for errno EFAULT PASSED
fcntl18     0  TINFO  :  Block 2 PASSED
fcntl18     0  TINFO  :  Exit block 2
fcntl18     0  TINFO  :  Enter block 3
fcntl18     3  TPASS  :  Test for errno EINVAL PASSED
fcntl18     0  TINFO  :  Block 3 PASSED
fcntl18     0  TINFO  :  Exit block 3
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=fcntl18_64 stime=1411895450
cmdline="fcntl18_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl18     0  TINFO  :  Enter block 1
fcntl18     1  TPASS  :  Test F_GETLK: for errno EFAULT PASSED
fcntl18     0  TINFO  :  Block 1 PASSED
fcntl18     0  TINFO  :  Exit block 1
fcntl18     0  TINFO  :  Enter block 2
fcntl18     2  TPASS  :  Test F_GETLK64: for errno EFAULT PASSED
fcntl18     0  TINFO  :  Block 2 PASSED
fcntl18     0  TINFO  :  Exit block 2
fcntl18     0  TINFO  :  Enter block 3
fcntl18     3  TPASS  :  Test for errno EINVAL PASSED
fcntl18     0  TINFO  :  Block 3 PASSED
fcntl18     0  TINFO  :  Exit block 3
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl19 stime=1411895450
cmdline="fcntl19"
contacts=""
analysis=exit
<<<test_output>>>
fcntl19     0  TINFO  :  Enter block 1
fcntl19     0  TINFO  :  Test block 1: PASSED
fcntl19     0  TINFO  :  Exit block 1
fcntl19     0  TINFO  :  Enter block 2
fcntl19     0  TINFO  :  Test block 2: PASSED
fcntl19     0  TINFO  :  Exit block 2
fcntl19     0  TINFO  :  Enter block 3
fcntl19     0  TINFO  :  Test block 3: PASSED
fcntl19     0  TINFO  :  Exit block 3
fcntl19     0  TINFO  :  Enter blcok 4
fcntl19     0  TINFO  :  Test block 4: PASSED
fcntl19     0  TINFO  :  Exit block 4
fcntl19     0  TINFO  :  Enter block 5
fcntl19     0  TINFO  :  Test block 5: PASSED
fcntl19     0  TINFO  :  Exit block 5
fcntl19     0  TINFO  :  Enter block 6
fcntl19     0  TINFO  :  Test block 6: PASSED
fcntl19     0  TINFO  :  Exit block 6
fcntl19     0  TINFO  :  Enter block 7
fcntl19     0  TINFO  :  Test block 7: PASSED
fcntl19     0  TINFO  :  Exit block 7
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl19_64 stime=1411895450
cmdline="fcntl19_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl19     0  TINFO  :  Enter block 1
fcntl19     0  TINFO  :  Test block 1: PASSED
fcntl19     0  TINFO  :  Exit block 1
fcntl19     0  TINFO  :  Enter block 2
fcntl19     0  TINFO  :  Test block 2: PASSED
fcntl19     0  TINFO  :  Exit block 2
fcntl19     0  TINFO  :  Enter block 3
fcntl19     0  TINFO  :  Test block 3: PASSED
fcntl19     0  TINFO  :  Exit block 3
fcntl19     0  TINFO  :  Enter blcok 4
fcntl19     0  TINFO  :  Test block 4: PASSED
fcntl19     0  TINFO  :  Exit block 4
fcntl19     0  TINFO  :  Enter block 5
fcntl19     0  TINFO  :  Test block 5: PASSED
fcntl19     0  TINFO  :  Exit block 5
fcntl19     0  TINFO  :  Enter block 6
fcntl19     0  TINFO  :  Test block 6: PASSED
fcntl19     0  TINFO  :  Exit block 6
fcntl19     0  TINFO  :  Enter block 7
fcntl19     0  TINFO  :  Test block 7: PASSED
fcntl19     0  TINFO  :  Exit block 7
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl20 stime=1411895450
cmdline="fcntl20"
contacts=""
analysis=exit
<<<test_output>>>
fcntl20     0  TINFO  :  Enter block 1
fcntl20     0  TINFO  :  Test block 1: PASSED
fcntl20     0  TINFO  :  Exit block 1
fcntl20     0  TINFO  :  Enter block 2
fcntl20     0  TINFO  :  Test block 2: PASSED
fcntl20     0  TINFO  :  Exit block 2
fcntl20     0  TINFO  :  Enter block 3
fcntl20     0  TINFO  :  Test block 3: PASSED
fcntl20     0  TINFO  :  Exit block 3
fcntl20     0  TINFO  :  Enter blcok 4
fcntl20     0  TINFO  :  Test block 4: PASSED
fcntl20     0  TINFO  :  Exit block 4
fcntl20     0  TINFO  :  Enter block 5
fcntl20     0  TINFO  :  Test block 5: PASSED
fcntl20     0  TINFO  :  Exit block 5
fcntl20     0  TINFO  :  Enter block 6
fcntl20     0  TINFO  :  Test block 6: PASSED
fcntl20     0  TINFO  :  Exit block 6
fcntl20     0  TINFO  :  Enter block 7
fcntl20     0  TINFO  :  Test block 7: PASSED
fcntl20     0  TINFO  :  Exit block 7
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl20_64 stime=1411895450
cmdline="fcntl20_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl20     0  TINFO  :  Enter block 1
fcntl20     0  TINFO  :  Test block 1: PASSED
fcntl20     0  TINFO  :  Exit block 1
fcntl20     0  TINFO  :  Enter block 2
fcntl20     0  TINFO  :  Test block 2: PASSED
fcntl20     0  TINFO  :  Exit block 2
fcntl20     0  TINFO  :  Enter block 3
fcntl20     0  TINFO  :  Test block 3: PASSED
fcntl20     0  TINFO  :  Exit block 3
fcntl20     0  TINFO  :  Enter blcok 4
fcntl20     0  TINFO  :  Test block 4: PASSED
fcntl20     0  TINFO  :  Exit block 4
fcntl20     0  TINFO  :  Enter block 5
fcntl20     0  TINFO  :  Test block 5: PASSED
fcntl20     0  TINFO  :  Exit block 5
fcntl20     0  TINFO  :  Enter block 6
fcntl20     0  TINFO  :  Test block 6: PASSED
fcntl20     0  TINFO  :  Exit block 6
fcntl20     0  TINFO  :  Enter block 7
fcntl20     0  TINFO  :  Test block 7: PASSED
fcntl20     0  TINFO  :  Exit block 7
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl21 stime=1411895450
cmdline="fcntl21"
contacts=""
analysis=exit
<<<test_output>>>
fcntl21     0  TINFO  :  Enter block 1
fcntl21     0  TINFO  :  Test block 1: PASSED
fcntl21     0  TINFO  :  Exit block 1
fcntl21     0  TINFO  :  Enter block 2
fcntl21     0  TINFO  :  Test block 2: PASSED
fcntl21     0  TINFO  :  Exit block 2
fcntl21     0  TINFO  :  Enter block 3
fcntl21     0  TINFO  :  Test block 3 : PASSED
fcntl21     0  TINFO  :  Exit block 3
fcntl21     0  TINFO  :  Enter block 4
fcntl21     0  TINFO  :  Test block 4: PASSED
fcntl21     0  TINFO  :  Exit block 4
fcntl21     0  TINFO  :  Enter block 5
fcntl21     0  TINFO  :  Test block 5: PASSED
fcntl21     0  TINFO  :  Exit block 5
fcntl21     0  TINFO  :  Enter block 6
fcntl21     0  TINFO  :  Test block 6 PASSED
fcntl21     0  TINFO  :  Exit block 6
fcntl21     0  TINFO  :  Enter block 7
fcntl21     0  TINFO  :  Test block 7: PASSED
fcntl21     0  TINFO  :  Exit block 7
fcntl21     0  TINFO  :  Enter block 8
fcntl21     0  TINFO  :  Test block 8: PASSED
fcntl21     0  TINFO  :  Exit block 8
fcntl21     0  TINFO  :  Enter block 9
fcntl21     0  TINFO  :  Test block 9: PASSED
fcntl21     0  TINFO  :  Exit block 9
fcntl21     0  TINFO  :  Enter block 10
fcntl21     0  TINFO  :  Test block 10: PASSED
fcntl21     0  TINFO  :  Exit block 10
fcntl21     0  TINFO  :  Enter block 11
fcntl21     0  TINFO  :  Test block 11: PASSED
fcntl21     0  TINFO  :  Exit block 11
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl21_64 stime=1411895450
cmdline="fcntl21_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl21     0  TINFO  :  Enter block 1
fcntl21     0  TINFO  :  Test block 1: PASSED
fcntl21     0  TINFO  :  Exit block 1
fcntl21     0  TINFO  :  Enter block 2
fcntl21     0  TINFO  :  Test block 2: PASSED
fcntl21     0  TINFO  :  Exit block 2
fcntl21     0  TINFO  :  Enter block 3
fcntl21     0  TINFO  :  Test block 3 : PASSED
fcntl21     0  TINFO  :  Exit block 3
fcntl21     0  TINFO  :  Enter block 4
fcntl21     0  TINFO  :  Test block 4: PASSED
fcntl21     0  TINFO  :  Exit block 4
fcntl21     0  TINFO  :  Enter block 5
fcntl21     0  TINFO  :  Test block 5: PASSED
fcntl21     0  TINFO  :  Exit block 5
fcntl21     0  TINFO  :  Enter block 6
fcntl21     0  TINFO  :  Test block 6 PASSED
fcntl21     0  TINFO  :  Exit block 6
fcntl21     0  TINFO  :  Enter block 7
fcntl21     0  TINFO  :  Test block 7: PASSED
fcntl21     0  TINFO  :  Exit block 7
fcntl21     0  TINFO  :  Enter block 8
fcntl21     0  TINFO  :  Test block 8: PASSED
fcntl21     0  TINFO  :  Exit block 8
fcntl21     0  TINFO  :  Enter block 9
fcntl21     0  TINFO  :  Test block 9: PASSED
fcntl21     0  TINFO  :  Exit block 9
fcntl21     0  TINFO  :  Enter block 10
fcntl21     0  TINFO  :  Test block 10: PASSED
fcntl21     0  TINFO  :  Exit block 10
fcntl21     0  TINFO  :  Enter block 11
fcntl21     0  TINFO  :  Test block 11: PASSED
fcntl21     0  TINFO  :  Exit block 11
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl22 stime=1411895450
cmdline="fcntl22"
contacts=""
analysis=exit
<<<test_output>>>
fcntl22     1  TPASS  :  fcntl() fails with expected error EAGAIN errno:11
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl22_64 stime=1411895450
cmdline="fcntl22_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl22     1  TPASS  :  fcntl() fails with expected error EAGAIN errno:11
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=fcntl23 stime=1411895450
cmdline="fcntl23"
contacts=""
analysis=exit
<<<test_output>>>
fcntl23     1  TPASS  :  fcntl(tfile_16410, F_SETLEASE, F_RDLCK)
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl23_64 stime=1411895450
cmdline="fcntl23_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl23     1  TPASS  :  fcntl(tfile_16411, F_SETLEASE, F_RDLCK)
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl24 stime=1411895450
cmdline="fcntl24"
contacts=""
analysis=exit
<<<test_output>>>
fcntl24     1  TCONF  :  fcntl24.c:133: Cannot do fcntl on a file on TMPFS filesystem
fcntl24     2  TCONF  :  fcntl24.c:133: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl24_64 stime=1411895450
cmdline="fcntl24_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl24     1  TCONF  :  fcntl24.c:133: Cannot do fcntl on a file on TMPFS filesystem
fcntl24     2  TCONF  :  fcntl24.c:133: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl25 stime=1411895450
cmdline="fcntl25"
contacts=""
analysis=exit
<<<test_output>>>
fcntl25     1  TCONF  :  fcntl25.c:134: Cannot do fcntl on a file on TMPFS filesystem
fcntl25     2  TCONF  :  fcntl25.c:134: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl25_64 stime=1411895450
cmdline="fcntl25_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl25     1  TCONF  :  fcntl25.c:134: Cannot do fcntl on a file on TMPFS filesystem
fcntl25     2  TCONF  :  fcntl25.c:134: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl26 stime=1411895450
cmdline="fcntl26"
contacts=""
analysis=exit
<<<test_output>>>
fcntl26     1  TCONF  :  fcntl26.c:134: Cannot do fcntl on a file on TMPFS filesystem
fcntl26     2  TCONF  :  fcntl26.c:134: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl26_64 stime=1411895450
cmdline="fcntl26_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl26     1  TCONF  :  fcntl26.c:134: Cannot do fcntl on a file on TMPFS filesystem
fcntl26     2  TCONF  :  fcntl26.c:134: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl27 stime=1411895450
cmdline="fcntl27"
contacts=""
analysis=exit
<<<test_output>>>
fcntl27     1  TPASS  :  fcntl(fd, F_SETLEASE, F_RDLCK) succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl27_64 stime=1411895450
cmdline="fcntl27_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl27     1  TPASS  :  fcntl(fd, F_SETLEASE, F_RDLCK) succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl28 stime=1411895450
cmdline="fcntl28"
contacts=""
analysis=exit
<<<test_output>>>
fcntl28     1  TPASS  :  fcntl(fd, F_SETLEASE, F_RDLCK) succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl28_64 stime=1411895450
cmdline="fcntl28_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl28     1  TPASS  :  fcntl(fd, F_SETLEASE, F_RDLCK) succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl29 stime=1411895450
cmdline="fcntl29"
contacts=""
analysis=exit
<<<test_output>>>
fcntl29     1  TPASS  :  fcntl test F_DUPFD_CLOEXEC success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl29_64 stime=1411895450
cmdline="fcntl29_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl29     1  TPASS  :  fcntl test F_DUPFD_CLOEXEC success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl30 stime=1411895450
cmdline="fcntl30"
contacts=""
analysis=exit
<<<test_output>>>
fcntl30     0  TINFO  :  orig_pipe_size: 65536 new_pipe_size: 131072
fcntl30     1  TPASS  :  fcntl test F_GETPIPE_SZand F_SETPIPE_SZ success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl30_64 stime=1411895450
cmdline="fcntl30_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl30     0  TINFO  :  orig_pipe_size: 65536 new_pipe_size: 131072
fcntl30     1  TPASS  :  fcntl test F_GETPIPE_SZand F_SETPIPE_SZ success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl31 stime=1411895450
cmdline="fcntl31"
contacts=""
analysis=exit
<<<test_output>>>
fcntl31     0  TINFO  :  default io events signal is SIGIO
fcntl31     1  TPASS  :  fcntl test F_GETOWN, F_SETOWN for process ID success
fcntl31     0  TINFO  :  default io events signal is SIGIO
fcntl31     2  TPASS  :  fcntl test F_GETOWN, F_SETOWN for process group ID success
fcntl31     0  TINFO  :  default io events signal is SIGIO
fcntl31     3  TPASS  :  fcntl test F_GETOWN_EX, F_SETOWN_EX for thread ID success
fcntl31     0  TINFO  :  default io events signal is SIGIO
fcntl31     4  TPASS  :  fcntl test F_GETOWN_EX, F_SETOWN_EX for process ID success
fcntl31     0  TINFO  :  default io events signal is SIGIO
fcntl31     5  TPASS  :  fcntl test F_GETOWN_EX, F_SETOWN_EX for process group ID success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fcntl31_64 stime=1411895450
cmdline="fcntl31_64"
contacts=""
analysis=exit
<<<test_output>>>
fcntl31     0  TINFO  :  default io events signal is SIGIO
fcntl31     1  TPASS  :  fcntl test F_GETOWN, F_SETOWN for process ID success
fcntl31     0  TINFO  :  default io events signal is SIGIO
fcntl31     2  TPASS  :  fcntl test F_GETOWN, F_SETOWN for process group ID success
fcntl31     0  TINFO  :  default io events signal is SIGIO
fcntl31     3  TPASS  :  fcntl test F_GETOWN_EX, F_SETOWN_EX for thread ID success
fcntl31     0  TINFO  :  default io events signal is SIGIO
fcntl31     4  TPASS  :  fcntl test F_GETOWN_EX, F_SETOWN_EX for process ID success
fcntl31     0  TINFO  :  default io events signal is SIGIO
fcntl31     5  TPASS  :  fcntl test F_GETOWN_EX, F_SETOWN_EX for process group ID success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fdatasync01 stime=1411895450
cmdline="fdatasync01"
contacts=""
analysis=exit
<<<test_output>>>
fdatasync01    1  TPASS  :  fdatasync() successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=fdatasync02 stime=1411895450
cmdline="fdatasync02"
contacts=""
analysis=exit
<<<test_output>>>
fdatasync02    1  TPASS  :  Expected failure for invalid file descriptor, errno: 9
fdatasync02    2  TPASS  :  Expected failure for file descriptor to a special file, errno: 22
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=flock01 stime=1411895450
cmdline="flock01"
contacts=""
analysis=exit
<<<test_output>>>
flock01     1  TPASS  :  flock() succeeded with Shared Lock, returned error number=0
flock01     2  TPASS  :  flock() succeeded with Unlock, returned error number=0
flock01     3  TPASS  :  flock() succeeded with Exclusive Lock, returned error number=0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=flock02 stime=1411895450
cmdline="flock02"
contacts=""
analysis=exit
<<<test_output>>>
flock02     1  TPASS  :  flock failed as expected with EBADF
flock02     2  TPASS  :  flock failed as expected with EINVAL
flock02     3  TPASS  :  flock failed as expected with EINVAL
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=flock03 stime=1411895450
cmdline="flock03"
contacts=""
analysis=exit
<<<test_output>>>
CHILD: File locked by parent unlocked
CHILD: Locking after unlock passed
flock03     1  TPASS  :  Parent: Initial attempt to flock() passed
flock03     2  TPASS  :  flock03 Passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=flock04 stime=1411895450
cmdline="flock04"
contacts=""
analysis=exit
<<<test_output>>>
flock04     1  TPASS  :  flock() PASSED in acquiring shared lock on Share Locked file
flock04     1  TPASS  :  flock() failed to acquire exclusive lock on existing share locked file as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=flock05 stime=1411895450
cmdline="flock05"
contacts=""
analysis=exit
<<<test_output>>>
flock05     1  TPASS  :  flock() failed to acquire shared lock on an alreadyexclusive locked file as expected
flock05     1  TPASS  :  flock() failed to acquire exclusive lock on existing  exclusive locked file as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=flock06 stime=1411895450
cmdline="flock06"
contacts=""
analysis=exit
<<<test_output>>>
flock06     1  TPASS  :  First attempt to flock() passed
flock06     2  TPASS  :  Second attempt to flock() denied
flock06     3  TPASS  :  Unlocked fd1
flock06     4  TPASS  :  Third attempt to flock() succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fmtmsg01 stime=1411895450
cmdline="fmtmsg01"
contacts=""
analysis=exit
<<<test_output>>>
fmtms01     1  TPASS  :  Test passed
fmtms01     2  TPASS  :  Test passed
fmtms01     3  TPASS  :  Test passed
fmtms01     4  TPASS  :  Test passed
fmtms01     5  TPASS  :  Test passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fork01 stime=1411895450
cmdline="fork01"
contacts=""
analysis=exit
<<<test_output>>>
fork01      1  TPASS  :  fork() returned 16453
fork01      2  TPASS  :  child pid and fork() return agree: 16453
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fork02 stime=1411895450
cmdline="fork02"
contacts=""
analysis=exit
<<<test_output>>>
fork02      0  TINFO  :  Inside parent
fork02      0  TINFO  :  exit status of wait 0
fork02      1  TPASS  :  test 1 PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fork03 stime=1411895450
cmdline="fork03"
contacts=""
analysis=exit
<<<test_output>>>
fork03      0  TINFO  :  process id in parent of child from fork : 16457
fork03      1  TPASS  :  test 1 PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fork04 stime=1411895450
cmdline="fork04"
contacts=""
analysis=exit
<<<test_output>>>
fork04      1  TPASS  :  Env var TERM unchanged after fork(): linux
fork04      2  TPASS  :  Env var NoTSetzWq unchanged after fork(): getenv() does not find variable set
fork04      3  TPASS  :  Env var TESTPROG unchanged after fork(): FRKTCS04
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fork05 stime=1411895450
cmdline="fork05"
contacts=""
analysis=exit
<<<test_output>>>
fork05      0  TINFO  :  %fs test only for ix86
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fork06 stime=1411895450
cmdline="fork06"
contacts=""
analysis=exit
<<<test_output>>>
fork06      0  TINFO  :  tries 1000
fork06      0  TINFO  :  successes 1000
fork06      0  TINFO  :  failures 0
fork06      0  TINFO  :  There were no children to wait for
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=8
<<<test_end>>>
<<<test_start>>>
tag=fork07 stime=1411895450
cmdline="fork07"
contacts=""
analysis=exit
<<<test_output>>>
fork07      0  TINFO  :  Forking 100 children
fork07      0  TINFO  :  Forked all 100 children, now collecting
fork07      0  TINFO  :  Collected all 100 children
fork07      1  TPASS  :  100/100 children read correctly from an inheritted fd
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=fork08 stime=1411895451
cmdline="fork08"
contacts=""
analysis=exit
<<<test_output>>>
fork08      0  TINFO  :  parent forksval: 1
fork08      0  TINFO  :  second child got char: b
fork08      1  TPASS  :  Test passed in childnumber 2
fork08      0  TINFO  :  parent forksval: 1
fork08      0  TINFO  :  parent forksval: 2
fork08      0  TINFO  :  exit status of wait  expected 0 got 0
fork08      1  TPASS  :  parent test PASSED
fork08      0  TINFO  :  exit status of wait  expected 0 got 0
fork08      2  TPASS  :  parent test PASSED
fork08      0  TINFO  :  exit status of wait  expected 0 got 0
fork08      3  TPASS  :  parent test PASSED
fork08      0  TINFO  :  Number of processes forked is 2
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fork09 stime=1411895452
cmdline="fork09"
contacts=""
analysis=exit
<<<test_output>>>
fork09      0  TINFO  :  OPEN_MAX is 1024
fork09      0  TINFO  :  first file descriptor is 7 
fork09      0  TINFO  :  Parent reporting 1023 files open
fork09      0  TINFO  :  Child opened new file #1023
fork09      0  TINFO  :  OPEN_MAX is 1024
fork09      0  TINFO  :  first file descriptor is 7 
fork09      0  TINFO  :  Parent reporting 1023 files open
fork09      1  TPASS  :  test 1 PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=fork10 stime=1411895452
cmdline="fork10"
contacts=""
analysis=exit
<<<test_output>>>
fork10      0  TINFO  :  fork child A
fork10      1  TPASS  :  test 1 PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fork11 stime=1411895452
cmdline="fork11"
contacts=""
analysis=exit
<<<test_output>>>
fork11      1  TPASS  :  fork test passed, 100 processes
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=fork13 stime=1411895452
cmdline="fork13 -i 1000000"
contacts=""
analysis=exit
<<<test_output>>>
fork13      1  TPASS  :  1000000 pids forked, all passed
<<<execution_status>>>
initiation_status="ok"
duration=78 termination_type=exited termination_id=0 corefile=no
cutime=118 cstime=8506
<<<test_end>>>
<<<test_start>>>
tag=fork14 stime=1411895530
cmdline="fork14"
contacts=""
analysis=exit
<<<test_output>>>
fork14      1  TPASS  :  fork failed as expected.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=2 cstime=18
<<<test_end>>>
<<<test_start>>>
tag=fpathconf01 stime=1411895530
cmdline="fpathconf01"
contacts=""
analysis=exit
<<<test_output>>>
fpathconf01    1  TPASS  :  fpathconf(fd, _PC_MAX_CANON) returned 255
fpathconf01    2  TPASS  :  fpathconf(fd, _PC_MAX_INPUT) returned 255
fpathconf01    3  TPASS  :  fpathconf(fd, _PC_VDISABLE) returned 0
fpathconf01    4  TPASS  :  fpathconf(fd, _PC_LINK_MAX) returned 127
fpathconf01    5  TPASS  :  fpathconf(fd, _PC_NAME_MAX) returned 255
fpathconf01    6  TPASS  :  fpathconf(fd, _PC_PATH_MAX) returned 4096
fpathconf01    7  TPASS  :  fpathconf(fd, _PC_PIPE_BUF) returned 4096
fpathconf01    8  TPASS  :  fpathconf(fd, _PC_CHOWN_RESTRICTED) returned 1
fpathconf01    9  TPASS  :  fpathconf(fd, _PC_NO_TRUNC) returned 1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=fstat01 stime=1411895530
cmdline="fstat01"
contacts=""
analysis=exit
<<<test_output>>>
fstat01     1  TPASS  :  fstat returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fstat01_64 stime=1411895530
cmdline="fstat01_64"
contacts=""
analysis=exit
<<<test_output>>>
fstat01     1  TPASS  :  fstat returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fstat02 stime=1411895530
cmdline="fstat02"
contacts=""
analysis=exit
<<<test_output>>>
fstat02     1  TPASS  :  functionality of fstat correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fstat02_64 stime=1411895530
cmdline="fstat02_64"
contacts=""
analysis=exit
<<<test_output>>>
fstat02     1  TPASS  :  functionality of fstat correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fstat03 stime=1411895530
cmdline="fstat03"
contacts=""
analysis=exit
<<<test_output>>>
fstat03     1  TPASS  :  fstat() fails with expected error EBADF
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fstat03_64 stime=1411895530
cmdline="fstat03_64"
contacts=""
analysis=exit
<<<test_output>>>
fstat03     1  TPASS  :  fstat() fails with expected error EBADF
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fstat04 stime=1411895530
cmdline="fstat04"
contacts=""
analysis=exit
<<<test_output>>>
fstat04     1  TPASS  :  fstat functionality correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fstat04_64 stime=1411895530
cmdline="fstat04_64"
contacts=""
analysis=exit
<<<test_output>>>
fstat04     1  TPASS  :  fstat functionality correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fstat05 stime=1411895530
cmdline="fstat05"
contacts=""
analysis=exit
<<<test_output>>>
fstat05     1  TPASS  :  fstat failed with EFAULT as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fstat05_64 stime=1411895530
cmdline="fstat05_64"
contacts=""
analysis=exit
<<<test_output>>>
fstat05     1  TPASS  :  fstat failed with EFAULT as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fstatat01 stime=1411895530
cmdline="fstatat01"
contacts=""
analysis=exit
<<<test_output>>>
fstatat01    1  TCONF  :  fstatat01.c:96: syscall __NR_fstatat64 not supported on your arch
fstatat01    2  TCONF  :  fstatat01.c:96: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fstatat01_64 stime=1411895530
cmdline="fstatat01_64"
contacts=""
analysis=exit
<<<test_output>>>
fstatat01    1  TCONF  :  fstatat01.c:96: syscall __NR_fstatat64 not supported on your arch
fstatat01    2  TCONF  :  fstatat01.c:96: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fstatfs01 stime=1411895530
cmdline="fstatfs01"
contacts=""
analysis=exit
<<<test_output>>>
fstatfs01    1  TPASS  :  fstatfs() on a file - f_type=1021994
fstatfs01    2  TPASS  :  fstatfs() on a pipe - f_type=50495045
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fstatfs01_64 stime=1411895530
cmdline="fstatfs01_64"
contacts=""
analysis=exit
<<<test_output>>>
fstatfs01    1  TPASS  :  fstatfs() on a file - f_type=1021994
fstatfs01    2  TPASS  :  fstatfs() on a pipe - f_type=50495045
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fstatfs02 stime=1411895530
cmdline="fstatfs02"
contacts=""
analysis=exit
<<<test_output>>>
fstatfs02    1  TPASS  :  expected failure - errno = 9 : Bad file descriptor
fstatfs02    2  TPASS  :  expected failure - errno = 14 : Bad address
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fstatfs02_64 stime=1411895530
cmdline="fstatfs02_64"
contacts=""
analysis=exit
<<<test_output>>>
fstatfs02    1  TPASS  :  expected failure - errno = 9 : Bad file descriptor
fstatfs02    2  TPASS  :  expected failure - errno = 14 : Bad address
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fsync01 stime=1411895530
cmdline="fsync01"
contacts=""
analysis=exit
<<<test_output>>>
fsync01     1  TPASS  :  fsync returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=fsync02 stime=1411895530
cmdline="fsync02"
contacts=""
analysis=exit
<<<test_output>>>
fsync02     1  TPASS  :  fsync succeeded in an acceptable amount of time
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fsync03 stime=1411895530
cmdline="fsync03"
contacts=""
analysis=exit
<<<test_output>>>
fsync03     1  TPASS  :  expected failure - errno = 9 : Bad file descriptor
fsync03     2  TPASS  :  expected failure - errno = 22 : Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=ftruncate01 stime=1411895530
cmdline="ftruncate01"
contacts=""
analysis=exit
<<<test_output>>>
ftruncate01    1  TPASS  :  Functionality of ftruncate() on testfile successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=ftruncate01_64 stime=1411895530
cmdline="ftruncate01_64"
contacts=""
analysis=exit
<<<test_output>>>
ftruncate01_64    1  TPASS  :  Functionality of ftruncate() on testfile successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=ftruncate02 stime=1411895530
cmdline="ftruncate02"
contacts=""
analysis=exit
<<<test_output>>>
ftruncate02    1  TPASS  :  Functionality of ftruncate(2) on testfile successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=ftruncate02_64 stime=1411895530
cmdline="ftruncate02_64"
contacts=""
analysis=exit
<<<test_output>>>
ftruncate02_64    1  TPASS  :  Functionality of ftruncate(2) on testfile successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=ftruncate03 stime=1411895530
cmdline="ftruncate03"
contacts=""
analysis=exit
<<<test_output>>>
ftruncate03    1  TPASS  :  Test Passed
ftruncate03    2  TPASS  :  Test Passed
ftruncate03    3  TPASS  :  Test Passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=ftruncate03_64 stime=1411895530
cmdline="ftruncate03_64"
contacts=""
analysis=exit
<<<test_output>>>
ftruncate03_64    1  TPASS  :  Test Passed
ftruncate03_64    2  TPASS  :  Test Passed
ftruncate03_64    3  TPASS  :  Test Passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=ftruncate04 stime=1411895530
cmdline="ftruncate04.sh"
contacts=""
analysis=exit
<<<test_output>>>
ftruncate04    1  TCONF  :  ltpapicmd.c:190: backend mountpoint for /tmp/ltp-EAlAM7imVE does not correspond to a real device:
Filesystem     1024-blocks  Used Available Capacity Mounted on
tmpfs              1220100  1524   1218576       1% /tmp
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=ftruncate04_64 stime=1411895530
cmdline="ftruncate04.sh 64"
contacts=""
analysis=exit
<<<test_output>>>
ftruncate04_64    1  TCONF  :  ltpapicmd.c:190: backend mountpoint for /tmp/ltp-EAlAM7imVE does not correspond to a real device:
Filesystem     1024-blocks  Used Available Capacity Mounted on
tmpfs              1220100  1524   1218576       1% /tmp
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=futimesat01 stime=1411895530
cmdline="futimesat01"
contacts=""
analysis=exit
<<<test_output>>>
futimesat01    1  TPASS  :  futimesat() returned the expected  errno 0: Success
futimesat01    2  TPASS  :  futimesat() returned the expected  errno 0: Success
futimesat01    3  TPASS  :  futimesat() returned the expected  errno 20: Not a directory
futimesat01    4  TPASS  :  futimesat() returned the expected  errno 9: Bad file descriptor
futimesat01    5  TPASS  :  futimesat() returned the expected  errno 0: Success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getcontext01 stime=1411895530
cmdline="getcontext01"
contacts=""
analysis=exit
<<<test_output>>>
getcontext01    1  TPASS  :  getcontext passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getcpu01 stime=1411895530
cmdline="getcpu01"
contacts=""
analysis=exit
<<<test_output>>>
getcpu01    1  TPASS  :  getcpu() returned proper cpuid:7, node id:0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getcwd01 stime=1411895530
cmdline="getcwd01"
contacts=""
analysis=exit
<<<test_output>>>
getcwd01    0  TINFO  :  Test for EFAULT
getcwd01    1  TPASS  :  Test case 1 PASSED
getcwd01    0  TINFO  :  Test for ENOMEM
getcwd01    2  TPASS  :  Test case 2 PASSED
getcwd01    0  TINFO  :  Test for EINVAL
getcwd01    3  TPASS  :  Test case 3 PASSED
getcwd01    0  TINFO  :  Test for ERANGE
getcwd01    4  TPASS  :  Test case 4 PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getcwd02 stime=1411895530
cmdline="getcwd02"
contacts=""
analysis=exit
<<<test_output>>>
getcwd02    0  TINFO  :  Enter Block 1
getcwd02    0  TINFO  :  Exit Block 1
getcwd02    1  TPASS  :  Block 1 PASSED
getcwd02    0  TINFO  :  Enter Block 2
getcwd02    0  TINFO  :  Exit Block 2
getcwd02    2  TPASS  :  Block 2 PASSED
getcwd02    0  TINFO  :  Enter Block 3
getcwd02    0  TINFO  :  Exit Block 3
getcwd02    3  TPASS  :  Block 3 PASSED
getcwd02    0  TINFO  :  Enter Block 4
getcwd02    0  TINFO  :  Exit Block 4
getcwd02    4  TPASS  :  Block 4 PASSED
getcwd02    0  TINFO  :  Enter Block 5
getcwd02    0  TINFO  :  Exit Block 5
getcwd02    5  TPASS  :  Block 5 PASSED
getcwd02    0  TINFO  :  Enter Block 6
getcwd02    0  TINFO  :  Exit Block 6
getcwd02    6  TPASS  :  Block 6 PASSED
getcwd02    0  TINFO  :  Enter Block 7
getcwd02    0  TINFO  :  Exit Block 7
getcwd02    7  TPASS  :  Block 7 PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getcwd03 stime=1411895530
cmdline="getcwd03"
contacts=""
analysis=exit
<<<test_output>>>
getcwd03    0  TINFO  :  getcwd(2) succeeded in returning correct path for dir1
getcwd03    0  TINFO  :  getcwd(2) succeeded in returning correct path for symbolic link dir2 -> dir1
getcwd03    1  TPASS  :  Test PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getcwd04 stime=1411895530
cmdline="getcwd04"
contacts=""
analysis=exit
<<<test_output>>>
getcwd04    1  TPASS  :  Bug is not reproduced!
<<<execution_status>>>
initiation_status="ok"
duration=5 termination_type=exited termination_id=0 corefile=no
cutime=163 cstime=838
<<<test_end>>>
<<<test_start>>>
tag=getdents01 stime=1411895535
cmdline="getdents01"
contacts=""
analysis=exit
<<<test_output>>>
getdents01    0  TINFO  :  Found '.'
getdents01    0  TINFO  :  Found '..'
getdents01    0  TINFO  :  Found 'symlink'
getdents01    0  TINFO  :  Found 'file'
getdents01    0  TINFO  :  Found 'dir'
getdents01    1  TPASS  :  All entires found
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getdents02 stime=1411895535
cmdline="getdents02"
contacts=""
analysis=exit
<<<test_output>>>
getdents02    1  TPASS  :  getdents failed as expected: Bad file descriptor
getdents02    2  TPASS  :  getdents failed as expected: Invalid argument
getdents02    3  TPASS  :  getdents failed as expected: Not a directory
getdents02    4  TPASS  :  getdents failed as expected: No such file or directory
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getdents01_64 stime=1411895535
cmdline="getdents01 -l"
contacts=""
analysis=exit
<<<test_output>>>
getdents01    0  TINFO  :  Found '.'
getdents01    0  TINFO  :  Found '..'
getdents01    0  TINFO  :  Found 'symlink'
getdents01    0  TINFO  :  Found 'file'
getdents01    0  TINFO  :  Found 'dir'
getdents01    1  TPASS  :  All entires found
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getdents02_64 stime=1411895535
cmdline="getdents02 -l"
contacts=""
analysis=exit
<<<test_output>>>
getdents02    1  TPASS  :  getdents failed as expected: Bad file descriptor
getdents02    2  TPASS  :  getdents failed as expected: Invalid argument
getdents02    3  TPASS  :  getdents failed as expected: Not a directory
getdents02    4  TPASS  :  getdents failed as expected: No such file or directory
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getdomainname01 stime=1411895535
cmdline="getdomainname01"
contacts=""
analysis=exit
<<<test_output>>>
getdomainname01    1  TPASS  :  getdomainname() returned 0 
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getdtablesize01 stime=1411895535
cmdline="getdtablesize01"
contacts=""
analysis=exit
<<<test_output>>>
getdtablesize01    0  TINFO  :  Maximum number of files a process can have opened is 1024
getdtablesize01    0  TINFO  :  Checking with the value returned by getrlimit...RLIMIT_NOFILE
getdtablesize01    1  TPASS  :  got correct dtablesize, value is 1024
getdtablesize01    0  TINFO  :  Checking Max num of files that can be opened by a process.Should be: RLIMIT_NOFILE - 1
getdtablesize01    2  TPASS  :  1023 = 1023
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getegid01 stime=1411895535
cmdline="getegid01"
contacts=""
analysis=exit
<<<test_output>>>
getegid01    1  TPASS  :  getegid returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getegid01_16 stime=1411895535
cmdline="getegid01_16"
contacts=""
analysis=exit
<<<test_output>>>
getegid01_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/getegid/../utils/compat_16.h:108: 16-bit version of getegid() is not supported on your platform
getegid01_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/getegid/../utils/compat_16.h:108: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getegid02 stime=1411895535
cmdline="getegid02"
contacts=""
analysis=exit
<<<test_output>>>
getegid02    1  TPASS  :  effective group id 0 is correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getegid02_16 stime=1411895535
cmdline="getegid02_16"
contacts=""
analysis=exit
<<<test_output>>>
getegid02_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/getegid/../utils/compat_16.h:108: 16-bit version of getegid() is not supported on your platform
getegid02_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/getegid/../utils/compat_16.h:108: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=geteuid01 stime=1411895535
cmdline="geteuid01"
contacts=""
analysis=exit
<<<test_output>>>
geteuid01    1  TPASS  :  geteuid returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=geteuid01_16 stime=1411895535
cmdline="geteuid01_16"
contacts=""
analysis=exit
<<<test_output>>>
geteuid01_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/geteuid/../utils/compat_16.h:103: 16-bit version of geteuid() is not supported on your platform
geteuid01_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/geteuid/../utils/compat_16.h:103: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=geteuid02 stime=1411895535
cmdline="geteuid02"
contacts=""
analysis=exit
<<<test_output>>>
geteuid02    1  TPASS  :  values from geteuid and getpwuid match
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=geteuid02_16 stime=1411895535
cmdline="geteuid02_16"
contacts=""
analysis=exit
<<<test_output>>>
geteuid02_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/geteuid/../utils/compat_16.h:103: 16-bit version of geteuid() is not supported on your platform
geteuid02_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/geteuid/../utils/compat_16.h:103: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getgid01 stime=1411895535
cmdline="getgid01"
contacts=""
analysis=exit
<<<test_output>>>
getgid01    1  TPASS  :  getgid returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getgid01_16 stime=1411895535
cmdline="getgid01_16"
contacts=""
analysis=exit
<<<test_output>>>
getgid01_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/getgid/../utils/compat_16.h:98: 16-bit version of getgid() is not supported on your platform
getgid01_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/getgid/../utils/compat_16.h:98: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getgid03 stime=1411895535
cmdline="getgid03"
contacts=""
analysis=exit
<<<test_output>>>
getgid03    1  TPASS  :  values from getuid and getpwuid match
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getgid03_16 stime=1411895535
cmdline="getgid03_16"
contacts=""
analysis=exit
<<<test_output>>>
getgid03_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/getgid/../utils/compat_16.h:98: 16-bit version of getgid() is not supported on your platform
getgid03_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/getgid/../utils/compat_16.h:98: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getgroups01 stime=1411895535
cmdline="getgroups01"
contacts=""
analysis=exit
<<<test_output>>>
getgroups01    1  TPASS  :  getgroups failed as expected with EINVAL
getgroups01    2  TPASS  :  getgroups did not modify the gidset array
getgroups01    3  TPASS  :  getgroups failed as expected with EINVAL
getgroups01    4  TPASS  :  getgroups(NGROUPS,gidset) returned 2 contains gid 0 (from getgid)
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getgroups01_16 stime=1411895535
cmdline="getgroups01_16"
contacts=""
analysis=exit
<<<test_output>>>
getgroups01_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/getgroups/../utils/compat_16.h:78: 16-bit version of getgroups() is not supported on your platform
getgroups01_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/getgroups/../utils/compat_16.h:78: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getgroups03 stime=1411895535
cmdline="getgroups03"
contacts=""
analysis=exit
<<<test_output>>>
getgroups03    1  TPASS  :  getgroups functionality correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getgroups03_16 stime=1411895535
cmdline="getgroups03_16"
contacts=""
analysis=exit
<<<test_output>>>
getgroups03_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/getgroups/../utils/compat_16.h:73: 16-bit version of setgroups() is not supported on your platform
getgroups03_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/getgroups/../utils/compat_16.h:73: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=gethostid01 stime=1411895535
cmdline="gethostid01"
contacts=""
analysis=exit
<<<test_output>>>
gethostid01    1  TPASS  :  Hostid command and gethostid both report hostid is 007f0100
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=gethostname01 stime=1411895535
cmdline="gethostname01"
contacts=""
analysis=exit
<<<test_output>>>
gethostname01    1  TPASS  :  gethostname returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getitimer01 stime=1411895535
cmdline="getitimer01"
contacts=""
analysis=exit
<<<test_output>>>
getitimer01    1  TPASS  :  functionality is ok
getitimer01    2  TPASS  :  functionality is ok
getitimer01    3  TPASS  :  functionality is ok
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getitimer02 stime=1411895535
cmdline="getitimer02"
contacts=""
analysis=exit
<<<test_output>>>
getitimer02    1  TPASS  :  expected failure - errno = 14 - Bad address
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=getitimer03 stime=1411895535
cmdline="getitimer03"
contacts=""
analysis=exit
<<<test_output>>>
getitimer03    1  TPASS  :  expected failure - errno = 22 - Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getpagesize01 stime=1411895535
cmdline="getpagesize01"
contacts=""
analysis=exit
<<<test_output>>>
getpagesize01    0  TINFO  :  Page Size is 4096
getpagesize01    1  TPASS  :  getpagesize - Page size returned 4096
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getpeername01 stime=1411895535
cmdline="getpeername01"
contacts=""
analysis=exit
<<<test_output>>>
getpeername01    1  TPASS  :  test getpeername() EBADF successful
getpeername01    2  TPASS  :  test getpeername() ENOTSOCK successful
getpeername01    3  TPASS  :  test getpeername() ENOTCONN successful
getpeername01    4  TPASS  :  test getpeername() EINVAL successful
getpeername01    5  TPASS  :  test getpeername() EFAULT successful
getpeername01    6  TPASS  :  test getpeername() EFAULT successful
getpeername01    7  TPASS  :  test getpeername() EFAULT successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getpgid01 stime=1411895535
cmdline="getpgid01"
contacts=""
analysis=exit
<<<test_output>>>
getpgid01    0  TINFO  :  Enter block 1
getpgid01    1  TPASS  :  Test block 1: getpgid(0) PASSED
getpgid01    0  TINFO  :  Exit block 1
getpgid01    0  TINFO  :  Enter block 2
getpgid01    2  TPASS  :  Test block 2: getpgid(getpid()) PASSED
getpgid01    0  TINFO  :  Exit block 2
getpgid01    0  TINFO  :  Enter block 3
getpgid01    3  TPASS  :  Test block 3: getpgid(getppid()) PASSED
getpgid01    0  TINFO  :  Exit block 3
getpgid01    0  TINFO  :  Enter block 4
getpgid01    4  TPASS  :  Test block 4: getpgid(1) PASSED
getpgid01    0  TINFO  :  Exit block 4
getpgid01    0  TINFO  :  Enter block 5
getpgid01    5  TPASS  :  Test block 5: getpgid(1) PASSED
getpgid01    0  TINFO  :  Exit block 5
getpgid01    0  TINFO  :  getpgid01 PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getpgid02 stime=1411895535
cmdline="getpgid02"
contacts=""
analysis=exit
<<<test_output>>>
getpgid02    1  TPASS  :  expected failure - errno = 3 : No such process
getpgid02    2  TPASS  :  expected failure - errno = 3 : No such process
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getpgrp01 stime=1411895535
cmdline="getpgrp01"
contacts=""
analysis=exit
<<<test_output>>>
getpgrp01    1  TPASS  :  getpgrp returned 13051
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getpid01 stime=1411895535
cmdline="getpid01"
contacts=""
analysis=exit
<<<test_output>>>
getpid01    1  TPASS  :  getpid returned 13052
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getpid02 stime=1411895535
cmdline="getpid02"
contacts=""
analysis=exit
<<<test_output>>>
getpid02    1  TPASS  :  getpid functionality is correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getppid01 stime=1411895535
cmdline="getppid01"
contacts=""
analysis=exit
<<<test_output>>>
getppid01    1  TPASS  :  getppid returned 1978
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getppid02 stime=1411895535
cmdline="getppid02"
contacts=""
analysis=exit
<<<test_output>>>
return value and parent's pid value match
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getpriority01 stime=1411895535
cmdline="getpriority01"
contacts=""
analysis=exit
<<<test_output>>>
getpriority01    1  TPASS  :  getpriority(0, 0) returned 0 priority value
getpriority01    2  TPASS  :  getpriority(1, 0) returned 0 priority value
getpriority01    3  TPASS  :  getpriority(2, 0) returned -20 priority value
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getpriority02 stime=1411895535
cmdline="getpriority02"
contacts=""
analysis=exit
<<<test_output>>>
getpriority02    1  TPASS  :  getpriority(2) fails, Invalid 'which' value specified, errno:22
getpriority02    2  TPASS  :  getpriority(2) fails, Invalid 'who' value specified, errno:3
getpriority02    3  TPASS  :  getpriority(2) fails, Invalid 'who' value specified, errno:3
getpriority02    4  TPASS  :  getpriority(2) fails, Invalid 'who' value specified, errno:3
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getresgid01 stime=1411895535
cmdline="getresgid01"
contacts=""
analysis=exit
<<<test_output>>>
getresgid01    1  TPASS  :  Functionality of getresgid() successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getresgid02 stime=1411895535
cmdline="getresgid02"
contacts=""
analysis=exit
<<<test_output>>>
getresgid02    1  TPASS  :  Functionality of getresgid() successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getresgid03 stime=1411895535
cmdline="getresgid03"
contacts=""
analysis=exit
<<<test_output>>>
getresgid03    1  TPASS  :  Functionality of getresgid() successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getresuid01 stime=1411895535
cmdline="getresuid01"
contacts=""
analysis=exit
<<<test_output>>>
getresuid01    1  TPASS  :  Functionality of getresuid() successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getresuid02 stime=1411895535
cmdline="getresuid02"
contacts=""
analysis=exit
<<<test_output>>>
getresuid02    1  TPASS  :  Functionality of getresuid() successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getresuid03 stime=1411895535
cmdline="getresuid03"
contacts=""
analysis=exit
<<<test_output>>>
getresuid03    1  TPASS  :  Functionality of getresuid() successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getrlimit01 stime=1411895535
cmdline="getrlimit01"
contacts=""
analysis=exit
<<<test_output>>>
getrlimit01    1  TPASS  :  getrlimit() test RLIMIT_CPU success
getrlimit01    2  TPASS  :  getrlimit() test RLIMIT_FSIZE success
getrlimit01    3  TPASS  :  getrlimit() test RLIMIT_DATA success
getrlimit01    4  TPASS  :  getrlimit() test RLIMIT_STACK success
getrlimit01    5  TPASS  :  getrlimit() test RLIMIT_CORE success
getrlimit01    6  TPASS  :  getrlimit() test RLIMIT_RSS success
getrlimit01    7  TPASS  :  getrlimit() test RLIMIT_NPROC success
getrlimit01    8  TPASS  :  getrlimit() test RLIMIT_NOFILE success
getrlimit01    9  TPASS  :  getrlimit() test RLIMIT_MEMLOCK success
getrlimit01   10  TPASS  :  getrlimit() test RLIMIT_AS success
getrlimit01   11  TPASS  :  getrlimit() test RLIMIT_LOCKS success
getrlimit01   12  TPASS  :  getrlimit() test RLIMIT_MSGQUEUE success
getrlimit01   13  TPASS  :  getrlimit() test RLIMIT_NICE success
getrlimit01   14  TPASS  :  getrlimit() test RLIMIT_RTPRIO success
getrlimit01   15  TPASS  :  getrlimit() test RLIMIT_SIGPENDING success
getrlimit01   16  TPASS  :  getrlimit() test RLIMIT_RTTIME success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getrlimit02 stime=1411895535
cmdline="getrlimit02"
contacts=""
analysis=exit
<<<test_output>>>
getrlimit02    1  TPASS  :  expected failure; got EFAULT
getrlimit02    2  TPASS  :  expected failure; got EINVAL
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=get_mempolicy01 stime=1411895535
cmdline="get_mempolicy01"
contacts=""
analysis=exit
<<<test_output>>>
EXPECT: return value(ret)=0 errno=0 (Success)
RESULT: return value(ret)=0 errno=0 (Success)
EXPECT: return value(ret)=0 errno=0 (Success)
RESULT: return value(ret)=0 errno=0 (Success)
EXPECT: return value(ret)=0 errno=0 (Success)
RESULT: return value(ret)=0 errno=0 (Success)
EXPECT: return value(ret)=0 errno=0 (Success)
RESULT: return value(ret)=0 errno=0 (Success)
EXPECT: return value(ret)=0 errno=0 (Success)
RESULT: return value(ret)=0 errno=0 (Success)
EXPECT: return value(ret)=0 errno=0 (Success)
RESULT: return value(ret)=0 errno=0 (Success)
EXPECT: return value(ret)=0 errno=0 (Success)
RESULT: return value(ret)=0 errno=0 (Success)
EXPECT: return value(ret)=0 errno=0 (Success)
RESULT: return value(ret)=0 errno=0 (Success)
EXPECT: return value(ret)=0 errno=0 (Success)
RESULT: return value(ret)=0 errno=0 (Success)
EXPECT: return value(ret)=0 errno=0 (Success)
RESULT: return value(ret)=0 errno=0 (Success)
EXPECT: return value(ret)=-1 errno=14 (Bad address)
RESULT: return value(ret)=-1 errno=14 (Bad address)
EXPECT: return value(ret)=-1 errno=22 (Invalid argument)
RESULT: return value(ret)=-1 errno=22 (Invalid argument)
get_mempolicy01    0  TINFO  :  (case00) START
get_mempolicy01    1  TPASS  :  (case00) END
get_mempolicy01    0  TINFO  :  (case01) START
get_mempolicy01    2  TPASS  :  (case01) END
get_mempolicy01    0  TINFO  :  (case02) START
get_mempolicy01    3  TPASS  :  (case02) END
get_mempolicy01    0  TINFO  :  (case03) START
get_mempolicy01    4  TPASS  :  (case03) END
get_mempolicy01    0  TINFO  :  (case04) START
get_mempolicy01    5  TPASS  :  (case04) END
get_mempolicy01    0  TINFO  :  (case05) START
get_mempolicy01    6  TPASS  :  (case05) END
get_mempolicy01    0  TINFO  :  (case06) START
get_mempolicy01    7  TPASS  :  (case06) END
get_mempolicy01    0  TINFO  :  (case07) START
get_mempolicy01    8  TPASS  :  (case07) END
get_mempolicy01    0  TINFO  :  (case08) START
get_mempolicy01    9  TPASS  :  (case08) END
get_mempolicy01    0  TINFO  :  (case09) START
get_mempolicy01   10  TPASS  :  (case09) END
get_mempolicy01    0  TINFO  :  (case10) START
get_mempolicy01   11  TPASS  :  (case10) END
get_mempolicy01    0  TINFO  :  (case11) START
get_mempolicy01   12  TPASS  :  (case11) END
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=2
<<<test_end>>>
<<<test_start>>>
tag=get_robust_list01 stime=1411895535
cmdline="get_robust_list01"
contacts=""
analysis=exit
<<<test_output>>>
get_robust_list01    1  TPASS  :  get_robust_list failed as expected with EFAULT
get_robust_list01    2  TPASS  :  get_robust_list failed as expected with EFAULT
get_robust_list01    3  TPASS  :  get_robust_list failed as expected with ESRCH
get_robust_list01    4  TPASS  :  get_robust_list succeeded
get_robust_list01    5  TPASS  :  get_robust_list failed as expected with EPERM
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getrusage01 stime=1411895535
cmdline="getrusage01"
contacts=""
analysis=exit
<<<test_output>>>
getrusage01    1  TPASS  :  getrusage passed
getrusage01    2  TPASS  :  getrusage passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getrusage02 stime=1411895535
cmdline="getrusage02"
contacts=""
analysis=exit
<<<test_output>>>
getrusage02    1  TPASS  :  getrusage failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
getrusage02    2  TPASS  :  getrusage failed as expected: TEST_ERRNO=EFAULT(14): Bad address
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getrusage03 stime=1411895535
cmdline="getrusage03"
contacts=""
analysis=exit
<<<test_output>>>
getrusage03    0  TINFO  :  allocate 100MB
getrusage03    0  TINFO  :  Testcase #01: fork inherit
getrusage03    0  TINFO  :  initial.self = 103732
getrusage03    0  TINFO  :  child.self = 102532
getrusage03    0  TINFO  :  allocate 100MB
getrusage03    0  TINFO  :  Testcase #01: fork inherit
getrusage03    0  TINFO  :  initial.self = 103732
getrusage03    1  TPASS  :  initial.self ~= child.self
getrusage03    0  TINFO  :  Testcase #02: fork inherit(cont.)
getrusage03    0  TINFO  :  initial.children = 103632
getrusage03    2  TPASS  :  initial.children ~= 100MB
getrusage03    0  TINFO  :  child.children = 0
getrusage03    0  TINFO  :  allocate 100MB
getrusage03    0  TINFO  :  Testcase #01: fork inherit
getrusage03    0  TINFO  :  initial.self = 103732
getrusage03    1  TPASS  :  initial.self ~= child.self
getrusage03    0  TINFO  :  Testcase #02: fork inherit(cont.)
getrusage03    0  TINFO  :  initial.children = 103632
getrusage03    2  TPASS  :  initial.children ~= 100MB
getrusage03    3  TPASS  :  child.children == 0
getrusage03    0  TINFO  :  Testcase #03: fork + malloc
getrusage03    0  TINFO  :  initial.self = 103952
getrusage03    0  TINFO  :  child allocate +50MB
getrusage03    0  TINFO  :  child.self = 154280
getrusage03_child    0  TINFO  :  grandchild allocate 300MB
getrusage03_child    0  TINFO  :  grandchild allocate 300MB
getrusage03    0  TINFO  :  allocate 100MB
getrusage03    0  TINFO  :  Testcase #01: fork inherit
getrusage03    0  TINFO  :  initial.self = 103732
getrusage03    1  TPASS  :  initial.self ~= child.self
getrusage03    0  TINFO  :  Testcase #02: fork inherit(cont.)
getrusage03    0  TINFO  :  initial.children = 103632
getrusage03    2  TPASS  :  initial.children ~= 100MB
getrusage03    3  TPASS  :  child.children == 0
getrusage03    0  TINFO  :  Testcase #03: fork + malloc
getrusage03    0  TINFO  :  initial.self = 103952
getrusage03    4  TPASS  :  initial.self + 50MB ~= child.self
getrusage03    0  TINFO  :  Testcase #04: grandchild maxrss
getrusage03    0  TINFO  :  initial.children = 154836
getrusage03_child    0  TINFO  :  child allocate 400MB
getrusage03    0  TINFO  :  allocate 100MB
getrusage03    0  TINFO  :  Testcase #01: fork inherit
getrusage03    0  TINFO  :  initial.self = 103732
getrusage03    1  TPASS  :  initial.self ~= child.self
getrusage03    0  TINFO  :  Testcase #02: fork inherit(cont.)
getrusage03    0  TINFO  :  initial.children = 103632
getrusage03    2  TPASS  :  initial.children ~= 100MB
getrusage03    3  TPASS  :  child.children == 0
getrusage03    0  TINFO  :  Testcase #03: fork + malloc
getrusage03    0  TINFO  :  initial.self = 103952
getrusage03    4  TPASS  :  initial.self + 50MB ~= child.self
getrusage03    0  TINFO  :  Testcase #04: grandchild maxrss
getrusage03    0  TINFO  :  initial.children = 154836
getrusage03    0  TINFO  :  post_wait.children = 308276
getrusage03    5  TPASS  :  child.children ~= 300MB
getrusage03    0  TINFO  :  Testcase #05: zombie
getrusage03    0  TINFO  :  initial.children = 308276
getrusage03_child    0  TINFO  :  child allocate 500MB
getrusage03    0  TINFO  :  allocate 100MB
getrusage03    0  TINFO  :  Testcase #01: fork inherit
getrusage03    0  TINFO  :  initial.self = 103732
getrusage03    1  TPASS  :  initial.self ~= child.self
getrusage03    0  TINFO  :  Testcase #02: fork inherit(cont.)
getrusage03    0  TINFO  :  initial.children = 103632
getrusage03    2  TPASS  :  initial.children ~= 100MB
getrusage03    3  TPASS  :  child.children == 0
getrusage03    0  TINFO  :  Testcase #03: fork + malloc
getrusage03    0  TINFO  :  initial.self = 103952
getrusage03    4  TPASS  :  initial.self + 50MB ~= child.self
getrusage03    0  TINFO  :  Testcase #04: grandchild maxrss
getrusage03    0  TINFO  :  initial.children = 154836
getrusage03    0  TINFO  :  post_wait.children = 308276
getrusage03    5  TPASS  :  child.children ~= 300MB
getrusage03    0  TINFO  :  Testcase #05: zombie
getrusage03    0  TINFO  :  initial.children = 308276
getrusage03    0  TINFO  :  pre_wait.children = 308276
getrusage03    6  TPASS  :  initial.children ~= pre_wait.children
getrusage03    0  TINFO  :  post_wait.children = 411152
getrusage03    7  TPASS  :  post_wait.children ~= 400MB
getrusage03    0  TINFO  :  Testcase #06: SIG_IGN
getrusage03    0  TINFO  :  initial.children = 411152
getrusage03_child    0  TINFO  :  exec.self = 103964, exec.children = 411152
getrusage03_child    1  TPASS  :  initial.self ~= exec.self
getrusage03_child    2  TPASS  :  initial.children ~= exec.children
<<<execution_status>>>
initiation_status="ok"
duration=2 termination_type=exited termination_id=0 corefile=no
cutime=10 cstime=9
<<<test_end>>>
<<<test_start>>>
tag=getrusage04 stime=1411895537
cmdline="getrusage04"
contacts=""
analysis=exit
<<<test_output>>>
getrusage04    0  TINFO  :  Expected timers granularity is 1000 us
getrusage04    0  TINFO  :  Using 1 as multiply factor for max [us]time increment (1000+1000us)!
getrusage04    0  TINFO  :  utime:           0us; stime:         169us
getrusage04    0  TINFO  :  utime:           0us; stime:         986us
getrusage04    0  TINFO  :  utime:           0us; stime:        1030us
getrusage04    0  TINFO  :  utime:           0us; stime:        2029us
getrusage04    0  TINFO  :  utime:           0us; stime:        3029us
getrusage04    0  TINFO  :  utime:         805us; stime:        3223us
getrusage04    0  TINFO  :  utime:         838us; stime:        4191us
getrusage04    0  TINFO  :  utime:         861us; stime:        5168us
getrusage04    0  TINFO  :  utime:         878us; stime:        6151us
getrusage04    0  TINFO  :  utime:         892us; stime:        7138us
getrusage04    0  TINFO  :  utime:         903us; stime:        8127us
getrusage04    0  TINFO  :  utime:        1823us; stime:        8206us
getrusage04    0  TINFO  :  utime:        1838us; stime:        9192us
getrusage04    0  TINFO  :  utime:        1850us; stime:       10179us
getrusage04    0  TINFO  :  utime:        1861us; stime:       11169us
getrusage04    0  TINFO  :  utime:        1870us; stime:       12160us
getrusage04    0  TINFO  :  utime:        1878us; stime:       13151us
getrusage04    0  TINFO  :  utime:        1885us; stime:       14144us
getrusage04    0  TINFO  :  utime:        1892us; stime:       15138us
getrusage04    0  TINFO  :  utime:        1897us; stime:       16132us
getrusage04    0  TINFO  :  utime:        2854us; stime:       16176us
getrusage04    1  TPASS  :  Test Passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=2
<<<test_end>>>
<<<test_start>>>
tag=getsid01 stime=1411895537
cmdline="getsid01"
contacts=""
analysis=exit
<<<test_output>>>
getsid01    1  TPASS  :  session ID is correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getsid02 stime=1411895537
cmdline="getsid02"
contacts=""
analysis=exit
<<<test_output>>>
getsid02    1  TPASS  :  expected failure - errno = 3 - No such process
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getsockname01 stime=1411895537
cmdline="getsockname01"
contacts=""
analysis=exit
<<<test_output>>>
getsockname01    1  TPASS  :  bad file descriptor successful
getsockname01    2  TPASS  :  bad file descriptor successful
getsockname01    3  TPASS  :  invalid socket buffer successful
getsockname01    4  TPASS  :  invalid aligned salen successful
getsockname01    5  TPASS  :  invalid unaligned salen successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getsockopt01 stime=1411895537
cmdline="getsockopt01"
contacts=""
analysis=exit
<<<test_output>>>
getsockopt01    1  TPASS  :  bad file descriptor successful
getsockopt01    2  TPASS  :  bad file descriptor successful
getsockopt01    3  TPASS  :  invalid option buffer successful
getsockopt01    4  TPASS  :  invalid optlen successful
getsockopt01    5  TPASS  :  invalid level successful
getsockopt01    6  TPASS  :  invalid option name successful
getsockopt01    7  TPASS  :  invalid option name (UDP) successful
getsockopt01    8  TPASS  :  invalid option name (IP) successful
getsockopt01    9  TPASS  :  invalid option name (TCP) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=gettid01 stime=1411895537
cmdline="gettid01"
contacts=""
analysis=exit
<<<test_output>>>
gettid01    1  TPASS  :  gettid() returned 13089
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=gettimeofday01 stime=1411895537
cmdline="gettimeofday01"
contacts=""
analysis=exit
<<<test_output>>>
gettimeofday01    1  TPASS  :  gettimeofday(2) set the errno EFAULT correctly
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=gettimeofday02 stime=1411895537
cmdline="gettimeofday02"
contacts=""
analysis=exit
<<<test_output>>>
gettimeofday02    0  TINFO  :  checking if gettimeofday is monotonous, takes 30s
gettimeofday02    1  TPASS  :  gettimeofday monotonous in 30 seconds
<<<execution_status>>>
initiation_status="ok"
duration=30 termination_type=exited termination_id=0 corefile=no
cutime=896 cstime=2104
<<<test_end>>>
<<<test_start>>>
tag=getuid01 stime=1411895567
cmdline="getuid01"
contacts=""
analysis=exit
<<<test_output>>>
getuid01    1  TPASS  :  getuid returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getuid01_16 stime=1411895567
cmdline="getuid01_16"
contacts=""
analysis=exit
<<<test_output>>>
getuid01_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/getuid/../utils/compat_16.h:88: 16-bit version of getuid() is not supported on your platform
getuid01_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/getuid/../utils/compat_16.h:88: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getuid03 stime=1411895567
cmdline="getuid03"
contacts=""
analysis=exit
<<<test_output>>>
getuid03    1  TPASS  :  values from getuid and getpwuid match
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getuid03_16 stime=1411895567
cmdline="getuid03_16"
contacts=""
analysis=exit
<<<test_output>>>
getuid03_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/getuid/../utils/compat_16.h:88: 16-bit version of getuid() is not supported on your platform
getuid03_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/getuid/../utils/compat_16.h:88: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getxattr01 stime=1411895567
cmdline="getxattr01"
contacts=""
analysis=exit
<<<test_output>>>
getxattr01    1  TCONF  :  getxattr01.c:158: No xattr support in fs or mount without user_xattr option
getxattr01    2  TCONF  :  getxattr01.c:158: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getxattr02 stime=1411895567
cmdline="getxattr02"
contacts=""
analysis=exit
<<<test_output>>>
getxattr02    1  TCONF  :  getxattr02.c:138: No xattr support in fs or mount without user_xattr option
getxattr02    2  TCONF  :  getxattr02.c:138: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=getxattr03 stime=1411895567
cmdline="getxattr03"
contacts=""
analysis=exit
<<<test_output>>>
getxattr03    1  TCONF  :  getxattr03.c:104: No xattr support in fs or fs mounted without user_xattr option
getxattr03    2  TCONF  :  getxattr03.c:104: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=ioctl01_02 stime=1411895567
cmdline="  test_ioctl"
contacts=""
analysis=exit
<<<test_output>>>
ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty0
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty0

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty1
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty1

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty10
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty10

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty11
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty11

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty12
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty12

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty13
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty13

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty14
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty14

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty15
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty15

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty16
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty16

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty17
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty17

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty18
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty18

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty19
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty19

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty2
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty2

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty20
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty20

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty21
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty21

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty22
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty22

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty23
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty23

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty24
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty24

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty25
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty25

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty26
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty26

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty27
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty27

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty28
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty28

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty29
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty29

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty3
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty3

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty30
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty30

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty31
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty31

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty32
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty32

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty33
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty33

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty34
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty34

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty35
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty35

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty36
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty36

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty37
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty37

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty38
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty38

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty39
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty39

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty4
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty4

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty40
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty40

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty41
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty41

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty42
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty42

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty43
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty43

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty44
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty44

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty45
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty45

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty46
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty46

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty47
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty47

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty48
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty48

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty49
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty49

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty5
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty5

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty50
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty50

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty51
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty51

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty52
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty52

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty53
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty53

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty54
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty54

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty55
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty55

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty56
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty56

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty57
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty57

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty58
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty58

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty59
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty59

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty6
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty6

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty60
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty60

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty61
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty61

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty62
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty62

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty63
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty63

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty7
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty7

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty8
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty8

ioctl01_02    0  TINFO  :  Testing ioctl01 with /dev/tty9
ioctl01     1  TPASS  :  failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
ioctl01     2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01     3  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     4  TPASS  :  failed as expected: TEST_ERRNO=ENOTTY(25): Inappropriate ioctl for device
ioctl01     5  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
ioctl01_02    1  TPASS  :  ioctl01 Passed with /dev/tty9

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty0
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty0

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty1
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty1

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty10
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty10

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty11
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty11

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty12
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty12

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty13
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty13

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty14
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty14

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty15
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty15

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty16
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty16

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty17
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty17

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty18
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty18

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty19
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty19

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty2
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty2

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty20
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty20

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty21
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty21

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty22
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty22

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty23
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty23

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty24
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty24

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty25
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty25

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty26
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty26

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty27
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty27

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty28
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty28

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty29
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty29

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty3
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty3

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty30
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty30

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty31
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty31

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty32
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty32

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty33
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty33

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty34
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty34

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty35
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty35

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty36
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty36

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty37
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty37

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty38
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty38

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty39
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty39

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty4
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty4

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty40
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty40

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty41
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty41

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty42
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty42

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty43
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty43

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty44
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty44

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty45
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty45

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty46
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty46

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty47
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty47

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty48
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty48

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty49
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty49

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty5
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty5

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty50
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty50

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty51
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty51

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty52
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty52

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty53
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty53

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty54
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty54

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty55
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty55

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty56
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty56

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty57
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty57

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty58
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty58

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty59
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty59

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty6
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty6

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty60
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty60

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty61
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty61

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty62
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty62

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty63
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty63

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty7
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty7

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty8
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty8

ioctl01_02    0  TINFO  :  Testing ioctl02 with /dev/tty9
ioctl02     0  TINFO  :  termio values are set as expected
ioctl02     1  TPASS  :  TCGETA/TCSETA tests SUCCEEDED
ioctl01_02    1  TPASS  :  ioctl02 Passed with /dev/tty9

<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=10 cstime=38
<<<test_end>>>
<<<test_start>>>
tag=ioctl03 stime=1411895568
cmdline="     ioctl03"
contacts=""
analysis=exit
<<<test_output>>>
ioctl03     0  TINFO  :  Available features are: 0x7103
ioctl03     0  TINFO  :  TUN 0x1
ioctl03     0  TINFO  :  TAP 0x2
ioctl03     0  TINFO  :  NO_PI 0x1000
ioctl03     0  TINFO  :  ONE_QUEUE 0x2000
ioctl03     0  TINFO  :  VNET_HDR 0x4000
ioctl03     0  TINFO  :  MULTI_QUEUE 0x100
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=inotify_init1_01 stime=1411895568
cmdline="inotify_init1_01"
contacts=""
analysis=exit
<<<test_output>>>
inotify_init1_01    1  TPASS  :  inotify_init1(O_CLOEXEC) PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=inotify_init1_02 stime=1411895568
cmdline="inotify_init1_02"
contacts=""
analysis=exit
<<<test_output>>>
inotify_init1_02    1  TPASS  :  inotify_init1(IN_NONBLOCK) PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=inotify01 stime=1411895568
cmdline="inotify01"
contacts=""
analysis=exit
<<<test_output>>>
inotify01    1  TPASS  :  get event: wd=1 mask=4 cookie=0 len=0
inotify01    2  TPASS  :  get event: wd=1 mask=20 cookie=0 len=0
inotify01    3  TPASS  :  get event: wd=1 mask=1 cookie=0 len=0
inotify01    4  TPASS  :  get event: wd=1 mask=10 cookie=0 len=0
inotify01    5  TPASS  :  get event: wd=1 mask=20 cookie=0 len=0
inotify01    6  TPASS  :  get event: wd=1 mask=2 cookie=0 len=0
inotify01    7  TPASS  :  get event: wd=1 mask=8 cookie=0 len=0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=inotify02 stime=1411895568
cmdline="inotify02"
contacts=""
analysis=exit
<<<test_output>>>
inotify02    1  TPASS  :  get event: wd=1 mask=40000004 cookie=0 len=0 name=""
inotify02    2  TPASS  :  get event: wd=1 mask=100 cookie=0 len=16 name="test_file1"
inotify02    3  TPASS  :  get event: wd=1 mask=20 cookie=0 len=16 name="test_file1"
inotify02    4  TPASS  :  get event: wd=1 mask=8 cookie=0 len=16 name="test_file1"
inotify02    5  TPASS  :  get event: wd=1 mask=40 cookie=2443026 len=16 name="test_file1"
inotify02    6  TPASS  :  get event: wd=1 mask=80 cookie=2443026 len=16 name="test_file2"
inotify02    7  TPASS  :  get event: wd=1 mask=800 cookie=0 len=0 name=""
inotify02    8  TPASS  :  get event: wd=1 mask=200 cookie=0 len=16 name="test_file2"
inotify02    9  TPASS  :  get event: wd=1 mask=800 cookie=0 len=0 name=""
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=inotify03 stime=1411895568
cmdline="inotify03"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
inotify03    0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
inotify03    0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
inotify03    0  TINFO  :  mount /dev/loop0 to mntpoint fs_type=ext2
inotify03    0  TINFO  :  umount /dev/loop0
inotify03    1  TPASS  :  get event: wd=1 mask=2000 cookie=0 len=0
inotify03    2  TPASS  :  get event: wd=1 mask=8000 cookie=0 len=0
inotify03    3  TPASS  :  inotify_rm_watch (7, 1) returned EINVAL
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=inotify04 stime=1411895568
cmdline="inotify04"
contacts=""
analysis=exit
<<<test_output>>>
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=inotify05 stime=1411895568
cmdline="inotify05"
contacts=""
analysis=exit
<<<test_output>>>
inotify05    1  TPASS  :  get event: wd=-1 mask=4000 cookie=0 len=0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=2
<<<test_end>>>
<<<test_start>>>
tag=fanotify01 stime=1411895568
cmdline="fanotify01"
contacts=""
analysis=exit
<<<test_output>>>
fanotify01    1  TPASS  :  get event: mask=31 pid=13692 fd=8
fanotify01    2  TPASS  :  get event: mask=11 pid=13692 fd=4294967294
fanotify01    3  TPASS  :  get event: mask=10 pid=13692 fd=4294967294
fanotify01    4  TPASS  :  get event: mask=2a pid=13692 fd=9
fanotify01    5  TPASS  :  get event: mask=a pid=13692 fd=4294967294
fanotify01    6  TPASS  :  get event: mask=8 pid=13692 fd=4294967294
fanotify01    7  TPASS  :  get event: mask=20 pid=13692 fd=11
fanotify01    8  TPASS  :  get event: mask=b pid=13692 fd=10
fanotify01    9  TPASS  :  get event: mask=9 pid=13692 fd=4294967294
fanotify01   10  TPASS  :  get event: mask=8 pid=13692 fd=4294967294
fanotify01   11  TPASS  :  get event: mask=2 pid=13692 fd=13
fanotify01   12  TPASS  :  get event: mask=8 pid=13692 fd=12
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fanotify02 stime=1411895568
cmdline="fanotify02"
contacts=""
analysis=exit
<<<test_output>>>
fanotify02    1  TPASS  :  get event: mask=2a pid=13693 fd=8
fanotify02    2  TPASS  :  get event: mask=a pid=13693 fd=8
fanotify02    3  TPASS  :  get event: mask=8 pid=13693 fd=8
fanotify02    4  TPASS  :  get event: mask=31 pid=13693 fd=9
fanotify02    5  TPASS  :  get event: mask=11 pid=13693 fd=9
fanotify02    6  TPASS  :  get event: mask=10 pid=13693 fd=9
fanotify02    7  TPASS  :  get event: mask=30 pid=13693 fd=10
fanotify02    8  TPASS  :  get event: mask=10 pid=13693 fd=10
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fanotify03 stime=1411895568
cmdline="fanotify03"
contacts=""
analysis=exit
<<<test_output>>>
fanotify03    1  TPASS  :  get event: mask=10000 pid=13695 fd=9
fanotify03    2  TPASS  :  get event: mask=20000 pid=13695 fd=9
fanotify03    3  TPASS  :  child exited correctly
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fanotify04 stime=1411895568
cmdline="fanotify04"
contacts=""
analysis=exit
<<<test_output>>>
fanotify04    1  TPASS  :  fanotify_mark (7, FAN_MARK_ADD | FAN_MARK_ONLYDIR, FAN_OPEN, AT_FDCWD, '.') succeeded
fanotify04    2  TPASS  :  fanotify_mark (7, FAN_MARK_ADD | FAN_MARK_ONLYDIR, FAN_OPEN, AT_FDCWD, 'fname_13696') failed
fanotify04    3  TPASS  :  fanotify_mark (7, FAN_MARK_ADD | FAN_MARK_DONT_FOLLOW, FAN_OPEN, AT_FDCWD, 'symlink_13696') succeeded
fanotify04    4  TPASS  :  No event as expected
fanotify04    5  TPASS  :  fanotify_mark (7, FAN_MARK_ADD | 0, FAN_OPEN, AT_FDCWD, 'symlink_13696') succeeded
fanotify04    6  TPASS  :  event generated properly for type 100000
fanotify04    7  TPASS  :  event generated properly for type 100000
fanotify04    8  TPASS  :  event generated properly for type 40000
fanotify04    9  TPASS  :  No event as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=fanotify05 stime=1411895568
cmdline="fanotify05"
contacts=""
analysis=exit
<<<test_output>>>
fanotify05    1  TPASS  :  get event: mask=4000 pid=13697 fd=-1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=2 cstime=68
<<<test_end>>>
<<<test_start>>>
tag=ioperm01 stime=1411895568
cmdline="ioperm01"
contacts=""
analysis=exit
<<<test_output>>>
ioperm01    1  TPASS  :  ioperm() passed for port address 1021, returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=ioperm02 stime=1411895568
cmdline="ioperm02"
contacts=""
analysis=exit
<<<test_output>>>
ioperm02    1  TPASS  :  Expected failure for Invalid I/O address, errno: 22
ioperm02    2  TPASS  :  Expected failure for Non super-user, errno: 1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=iopl01 stime=1411895568
cmdline="iopl01"
contacts=""
analysis=exit
<<<test_output>>>
iopl01      1  TPASS  :  iopl() passed for level 0, returned 0
iopl01      2  TPASS  :  iopl() passed for level 1, returned 0
iopl01      3  TPASS  :  iopl() passed for level 2, returned 0
iopl01      4  TPASS  :  iopl() passed for level 3, returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=iopl02 stime=1411895568
cmdline="iopl02"
contacts=""
analysis=exit
<<<test_output>>>
iopl02      1  TPASS  :  Expected failure for Invalid privilege level, errno: 22
iopl02      2  TPASS  :  Expected failure for Non super-user, errno: 1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=io_cancel01 stime=1411895568
cmdline="io_cancel01"
contacts=""
analysis=exit
<<<test_output>>>
io_cancel01    1  TPASS  :  expected failure - returned value = -14 : Bad address
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=io_destroy01 stime=1411895568
cmdline="io_destroy01"
contacts=""
analysis=exit
<<<test_output>>>
io_destroy01    1  TPASS  :  expected failure - returned value = -22 : Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=io_getevents01 stime=1411895568
cmdline="io_getevents01"
contacts=""
analysis=exit
<<<test_output>>>
io_getevents01    1  TPASS  :  expected failure - returned value = -22 : Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=io_setup01 stime=1411895568
cmdline="io_setup01"
contacts=""
analysis=exit
<<<test_output>>>
io_setup01    1  TPASS  :  call succeeded expectedly
io_setup01    2  TPASS  :  expected failure - returned value = -22 : Invalid argument
io_setup01    3  TPASS  :  expected failure - returned value = -22 : Invalid argument
io_setup01    4  TPASS  :  expected failure - returned value = -14 : Bad address
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=io_submit01 stime=1411895569
cmdline="io_submit01"
contacts=""
analysis=exit
<<<test_output>>>
io_submit01    1  TPASS  :  expected failure - returned value = -22 : Invalid argument
io_submit01    2  TPASS  :  expected failure - returned value = -22 : Invalid argument
io_submit01    3  TPASS  :  expected failure - returned value = -22 : Invalid argument
io_submit01    4  TPASS  :  expected failure - returned value = -14 : Bad address
io_submit01    5  TPASS  :  expected failure - returned value = -22 : Invalid argument
io_submit01    6  TPASS  :  expected failure - returned value = -9 : Bad file descriptor
io_submit01    7  TPASS  :  expected success - returned value = 0
io_submit01    8  TPASS  :  expected success - returned value = 1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=keyctl01 stime=1411895569
cmdline="keyctl01"
contacts=""
analysis=exit
<<<test_output>>>
keyctl01    1  TPASS  :  KEYCTL_GET_KEYRING_ID succeeded
keyctl01    2  TPASS  :  KEYCTL_REVOKE got expected errno: errno=ENOKEY(126): Required key not available
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=kill01 stime=1411895569
cmdline="kill01"
contacts=""
analysis=exit
<<<test_output>>>
kill01      1  TPASS  :  received expected signal 9
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=kill02 stime=1411895569
cmdline="kill02"
contacts=""
analysis=exit
<<<test_output>>>
kill02      1  TPASS  :  The signal was sent to all processes in the process group.
kill02      2  TPASS  :  The signal was not sent to selective processes that were not in the process group.
<<<execution_status>>>
initiation_status="ok"
duration=10 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=kill03 stime=1411895579
cmdline="kill03"
contacts=""
analysis=exit
<<<test_output>>>
kill03      1  TPASS  :  errno set to 22 : Invalid argument, as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=kill04 stime=1411895579
cmdline="kill04"
contacts=""
analysis=exit
<<<test_output>>>
kill04      1  TPASS  :  errno set to 3 : No such process, as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=kill05 stime=1411895579
cmdline="kill05"
contacts=""
analysis=exit
<<<test_output>>>
kill failed with EPERM
kill05      1  TPASS  :  received expected errno(EPERM)
<<<execution_status>>>
initiation_status="ok"
duration=2 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=kill06 stime=1411895581
cmdline="kill06"
contacts=""
analysis=exit
<<<test_output>>>
kill06      1  TPASS  :  received expected signal 9
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=kill07 stime=1411895581
cmdline="kill07"
contacts=""
analysis=exit
<<<test_output>>>
kill07      0  TINFO  :  received expected signal 9
kill07      1  TPASS  :  Did not catch signal as expected
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=kill08 stime=1411895582
cmdline="kill08"
contacts=""
analysis=exit
<<<test_output>>>
kill08      1  TPASS  :  received expected signal 9
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=kill09 stime=1411895582
cmdline="kill09"
contacts=""
analysis=exit
<<<test_output>>>
kill09      1  TPASS  :  kill(13738, SIGKILL) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=kill10 stime=1411895582
cmdline="kill10"
contacts=""
analysis=exit
<<<test_output>>>
13740: All 10 children reported in
13741: All 10 children reported in
kill10      1  TPASS  :  All 2 pgrps received their signals
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=kill11 stime=1411895583
cmdline="kill11"
contacts=""
analysis=exit
<<<test_output>>>
kill11      0  TINFO  :  Adjusting RLIMIT_CORE to 1048576
kill11      1  TPASS  :  signal SIGHUP          
kill11      2  TPASS  :  signal SIGINT          
kill11      3  TPASS  :  signal SIGQUIT          dumped core
kill11      4  TPASS  :  signal SIGILL           dumped core
kill11      5  TPASS  :  signal SIGTRAP          dumped core
kill11      6  TPASS  :  signal SIGIOT/SIGABRT   dumped core
kill11      7  TPASS  :  signal SIGIOT/SIGABRT   dumped core
kill11      8  TPASS  :  signal SIGBUS           dumped core
kill11      9  TPASS  :  signal SIGFPE           dumped core
kill11     10  TPASS  :  signal SIGKILL         
kill11     11  TPASS  :  signal SIGUSR1         
kill11     12  TPASS  :  signal SIGSEGV          dumped core
kill11     13  TPASS  :  signal SIGUSR2         
kill11     14  TPASS  :  signal SIGPIPE         
kill11     15  TPASS  :  signal SIGALRM         
kill11     16  TPASS  :  signal SIGTERM         
kill11     17  TPASS  :  signal SIGXCPU          dumped core
kill11     18  TPASS  :  signal SIGXFSZ          dumped core
kill11     19  TPASS  :  signal SIGVTALRM       
kill11     20  TPASS  :  signal SIGPROF         
kill11     21  TPASS  :  signal SIGIO/SIGPOLL   
kill11     22  TPASS  :  signal SIGPWR          
kill11     23  TPASS  :  signal SIGSYS/SIGUNUSED dumped core
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=kill12 stime=1411895583
cmdline="kill12"
contacts=""
analysis=exit
<<<test_output>>>
kill12      1  TPASS  :  Test passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=lchown01 stime=1411895583
cmdline="lchown01"
contacts=""
analysis=exit
<<<test_output>>>
lchown01    1  TPASS  :  lchown() succeeds to Change Owner/Group ids of slink_file
lchown01    2  TPASS  :  lchown() succeeds to Change Owner id only of slink_file
lchown01    3  TPASS  :  lchown() succeeds to Change Owner/Group ids of slink_file
lchown01    4  TPASS  :  lchown() succeeds to Change Group id only of slink_file
lchown01    5  TPASS  :  lchown() succeeds to Change Group/Group ids of slink_file
lchown01    6  TPASS  :  lchown() succeeds to Change none of slink_file
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=lchown01_16 stime=1411895583
cmdline="lchown01_16"
contacts=""
analysis=exit
<<<test_output>>>
lchown01_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/lchown/../utils/compat_16.h:132: 16-bit version of lchown() is not supported on your platform
lchown01_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/lchown/../utils/compat_16.h:132: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=lchown02 stime=1411895583
cmdline=" lchown02"
contacts=""
analysis=exit
<<<test_output>>>
lchown02    1  TPASS  :  lchown(2) fails, Process is not owner/root, errno:1
lchown02    2  TPASS  :  lchown(2) fails, Search permission denied, errno:13
lchown02    3  TPASS  :  lchown(2) fails, Address beyond address space, errno:14
lchown02    4  TPASS  :  lchown(2) fails, Unaccessible address space, errno:14
lchown02    5  TPASS  :  lchown(2) fails, Pathname too long, errno:36
lchown02    6  TPASS  :  lchown(2) fails, Path contains regular file, errno:20
lchown02    7  TPASS  :  lchown(2) fails, Pathname is empty, errno:2
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=lchown03 stime=1411895583
cmdline=" lchown03"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
lchown03    0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
lchown03    0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
lchown03    1  TPASS  :  lchown() failed as expected: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
lchown03    2  TPASS  :  lchown() failed as expected: TEST_ERRNO=EROFS(30): Read-only file system
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=lchown02_16 stime=1411895583
cmdline="lchown02_16"
contacts=""
analysis=exit
<<<test_output>>>
lchown02_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/lchown/../utils/compat_16.h:132: 16-bit version of lchown() is not supported on your platform
lchown02_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/lchown/../utils/compat_16.h:132: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=lchown03_16 stime=1411895583
cmdline="lchown03_16"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
lchown03    0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
lchown03    0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
lchown03    1  TPASS  :  lchown() failed as expected: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
lchown03    2  TPASS  :  lchown() failed as expected: TEST_ERRNO=EROFS(30): Read-only file system
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=link01 stime=1411895583
cmdline="symlink01 -T link01"
contacts=""
analysis=exit
<<<test_output>>>
link01      1  TPASS  :  link(2) to a symbolic link, which is pointing to an existing object file worked - file created and link count adjusted
link01      2  TPASS  :  link(2) to a symbolic link, which is pointing to a non-existing object file worked ok - file created and link count adjusted.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=link02 stime=1411895583
cmdline="link02"
contacts=""
analysis=exit
<<<test_output>>>
link02      1  TPASS  :  link(oldpath,newpath) returned 0 and link counts match
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=link03 stime=1411895583
cmdline="link03"
contacts=""
analysis=exit
<<<test_output>>>
link03      1  TPASS  :  link() passed and linkcounts=10 match
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=link04 stime=1411895583
cmdline="link04"
contacts=""
analysis=exit
<<<test_output>>>
link04      1  TPASS  :  link(<non-existent file>, <nefile>): TEST_ERRNO=ENOENT(2): No such file or directory
link04      2  TPASS  :  link(<path is empty string>, <nefile>): TEST_ERRNO=ENOENT(2): No such file or directory
link04      3  TPASS  :  link(<path contains a non-existent file>, <nefile>): TEST_ERRNO=ENOENT(2): No such file or directory
link04      4  TPASS  :  link(<path contains a regular file>, <nefile>): TEST_ERRNO=ENOTDIR(20): Not a directory
link04      5  TPASS  :  link(<pathname too long>, <nefile>): TEST_ERRNO=ENAMETOOLONG(36): File name too long
link04      6  TPASS  :  link(<address beyond address space>, <nefile>): TEST_ERRNO=EFAULT(14): Bad address
link04      7  TPASS  :  link(<negative address>, <nefile>): TEST_ERRNO=EFAULT(14): Bad address
link04      8  TPASS  :  link(<regfile>, <empty string>): TEST_ERRNO=ENOENT(2): No such file or directory
link04      9  TPASS  :  link(<regfile>, <path contains a non-existent file>): TEST_ERRNO=ENOENT(2): No such file or directory
link04     10  TPASS  :  link(<regfile>, <path contains a regular file>): TEST_ERRNO=ENOENT(2): No such file or directory
link04     11  TPASS  :  link(<regfile>, <pathname too long>): TEST_ERRNO=ENAMETOOLONG(36): File name too long
link04     12  TPASS  :  link(<regfile>, <address beyond address space>): TEST_ERRNO=EFAULT(14): Bad address
link04     13  TPASS  :  link(<regfile>, <negative address>): TEST_ERRNO=EFAULT(14): Bad address
link04     14  TPASS  :  link(<regfile>, <regfile2>): TEST_ERRNO=EEXIST(17): File exists
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=link05 stime=1411895583
cmdline="link05"
contacts=""
analysis=exit
<<<test_output>>>
link05      1  TPASS  :  link(lkfile_13816, lkfile_13816[1-1000]) ret 0 for 1000 files,stat linkcounts match 1000
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=link06 stime=1411895583
cmdline="link06"
contacts=""
analysis=exit
<<<test_output>>>
link06      1  TPASS  :  link() fails with expected error EACCES errno:13
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=link07 stime=1411895583
cmdline="link07"
contacts=""
analysis=exit
<<<test_output>>>
link07      1  TPASS  :  link() fails with expected error: TEST_ERRNO=EACCES(13): Permission denied
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=link08 stime=1411895583
cmdline="link08"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
link08      0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
link08      0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
link08      1  TPASS  :  link failed as expected: TEST_ERRNO=EPERM(1): Operation not permitted
link08      2  TPASS  :  link failed as expected: TEST_ERRNO=EXDEV(18): Invalid cross-device link
link08      3  TPASS  :  link failed as expected: TEST_ERRNO=EROFS(30): Read-only file system
link08      4  TPASS  :  link failed as expected: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=linkat01 stime=1411895583
cmdline="linkat01"
contacts=""
analysis=exit
<<<test_output>>>
linkat01    1  TPASS  :  linkat is functionality correct
linkat01    2  TPASS  :  linkat succeeded as expected
linkat01    3  TPASS  :  linkat is functionality correct
linkat01    4  TPASS  :  linkat is functionality correct
linkat01    5  TPASS  :  linkat is functionality correct
linkat01    6  TPASS  :  linkat succeeded as expected
linkat01    7  TPASS  :  linkat is functionality correct
linkat01    8  TPASS  :  linkat failed as expected: TEST_ERRNO=ENOTDIR(20): Not a directory
linkat01    9  TPASS  :  linkat failed as expected: TEST_ERRNO=ENOTDIR(20): Not a directory
linkat01   10  TPASS  :  linkat succeeded as expected
linkat01   11  TPASS  :  linkat is functionality correct
linkat01   12  TPASS  :  linkat failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
linkat01   13  TPASS  :  linkat failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
linkat01   14  TPASS  :  linkat succeeded as expected
linkat01   15  TPASS  :  linkat is functionality correct
linkat01   16  TPASS  :  linkat failed as expected: TEST_ERRNO=ENOENT(2): No such file or directory
linkat01   17  TPASS  :  linkat failed as expected: TEST_ERRNO=ENOENT(2): No such file or directory
linkat01   18  TPASS  :  linkat succeeded as expected
linkat01   19  TPASS  :  linkat is functionality correct
linkat01   20  TPASS  :  linkat failed as expected: TEST_ERRNO=EXDEV(18): Invalid cross-device link
linkat01   21  TPASS  :  linkat failed as expected: TEST_ERRNO=EPERM(1): Operation not permitted
linkat01   22  TPASS  :  linkat failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=linkat02 stime=1411895583
cmdline="linkat02"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
linkat02    0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
linkat02    0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
linkat02    0  TINFO  :  Failed reach the hardlinks limit
linkat02    1  TPASS  :  linkat failed as expected: TEST_ERRNO=ENAMETOOLONG(36): File name too long
linkat02    2  TPASS  :  linkat failed as expected: TEST_ERRNO=ENAMETOOLONG(36): File name too long
linkat02    3  TPASS  :  linkat failed as expected: TEST_ERRNO=EEXIST(17): File exists
linkat02    4  TPASS  :  linkat failed as expected: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
linkat02    5  TPASS  :  linkat failed as expected: TEST_ERRNO=EACCES(13): Permission denied
linkat02    6  TPASS  :  linkat failed as expected: TEST_ERRNO=EROFS(30): Read-only file system
linkat02    7  TCONF  :  linkat02.c:118: EMLINK test is not appropriate
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=5 cstime=13
<<<test_end>>>
<<<test_start>>>
tag=listen01 stime=1411895583
cmdline="listen01"
contacts=""
analysis=exit
<<<test_output>>>
listen01    1  TPASS  :  bad file descriptor successful
listen01    2  TPASS  :  not a socket successful
listen01    3  TPASS  :  UDP listen successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=llseek01 stime=1411895583
cmdline="llseek01"
contacts=""
analysis=exit
<<<test_output>>>
llseek01    1  TPASS  :  Functionality of llseek() on tmp_file successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=llseek02 stime=1411895583
cmdline="llseek02"
contacts=""
analysis=exit
<<<test_output>>>
llseek02    1  TPASS  :  llseek() fails, 'whence' argument is not valid, errno:22
llseek02    2  TPASS  :  llseek() fails, 'fd' is not an open file descriptor, errno:9
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=llseek03 stime=1411895583
cmdline="llseek03"
contacts=""
analysis=exit
<<<test_output>>>
llseek03    1  TPASS  :  test SEEK_SET for llseek success
llseek03    2  TPASS  :  test SEEK_END for llseek success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=lseek01 stime=1411895583
cmdline="lseek01"
contacts=""
analysis=exit
<<<test_output>>>
lseek01     1  TPASS  :  lseek(tfile_13832, 0, 0) returned 0
lseek01     2  TPASS  :  lseek(tfile_13832, 0, 1) returned 0
lseek01     3  TPASS  :  lseek(tfile_13832, 0, 2) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=lseek02 stime=1411895583
cmdline="lseek02"
contacts=""
analysis=exit
<<<test_output>>>
lseek02     1  TPASS  :  lseek(-1, 1, SEEK_SET) Failed, errno=9 : Bad file descriptor
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=lseek03 stime=1411895583
cmdline="lseek03"
contacts=""
analysis=exit
<<<test_output>>>
lseek03     1  TPASS  :  lseek(tfile_13834, 1, 5) Failed, errno=22 : Invalid argument
lseek03     2  TPASS  :  lseek(tfile_13834, 1, -1) Failed, errno=22 : Invalid argument
lseek03     3  TPASS  :  lseek(tfile_13834, 1, 7) Failed, errno=22 : Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=lseek04 stime=1411895583
cmdline="lseek04"
contacts=""
analysis=exit
<<<test_output>>>
lseek04     1  TPASS  :  lseek(fifofd, 1, SEEK_SET) Failed, errno=29 : Illegal seek
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=lseek05 stime=1411895583
cmdline="lseek05"
contacts=""
analysis=exit
<<<test_output>>>
lseek05     1  TPASS  :  lseek(pipefd, 1, SEEK_SET) Failed, errno=29 : Illegal seek
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=lseek06 stime=1411895583
cmdline="lseek06"
contacts=""
analysis=exit
<<<test_output>>>
lseek06     1  TPASS  :  Functionality of lseek() on tmp_file successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=lseek07 stime=1411895583
cmdline="lseek07"
contacts=""
analysis=exit
<<<test_output>>>
lseek07     1  TPASS  :  Functionality of lseek() on tmp_file successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=lseek08 stime=1411895583
cmdline="lseek08"
contacts=""
analysis=exit
<<<test_output>>>
lseek08     1  TPASS  :  Functionality of lseek() on tmp_file successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=lseek09 stime=1411895583
cmdline="lseek09"
contacts=""
analysis=exit
<<<test_output>>>
lseek09     1  TPASS  :  Functionality of lseek() on tmp_file successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=lseek10 stime=1411895583
cmdline="lseek10"
contacts=""
analysis=exit
<<<test_output>>>
lseek10     1  TPASS  :  lseek() fails, 'fd' associated with a pipe/fifo, errno:29
lseek10     2  TPASS  :  lseek() fails, 'whence' argument is not valid, errno:22
lseek10     3  TPASS  :  lseek() fails, 'fd' is not an open file descriptor, errno:9
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=lstat01A stime=1411895583
cmdline="symlink01 -T lstat01"
contacts=""
analysis=exit
<<<test_output>>>
lstat01     1  TPASS  :  lstat(2) of symbolic link file which points to no object file is ok
lstat01     2  TPASS  :  lstat(2) of symbolic link file which points at an object file is ok
lstat01     3  TPASS  :  lstat(2) of object file returns object file inode information
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=lstat01A_64 stime=1411895583
cmdline="symlink01 -T lstat01_64"
contacts=""
analysis=exit
<<<test_output>>>
lstat01_64    1  TPASS  :  lstat(2) of symbolic link file which points to no object file is ok
lstat01_64    2  TPASS  :  lstat(2) of symbolic link file which points at an object file is ok
lstat01_64    3  TPASS  :  lstat(2) of object file returns object file inode information
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=lstat01 stime=1411895583
cmdline="lstat01"
contacts=""
analysis=exit
<<<test_output>>>
lstat01     1  TPASS  :  lstat(lnfile_13844, &statter) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=lstat01_64 stime=1411895583
cmdline="lstat01_64"
contacts=""
analysis=exit
<<<test_output>>>
lstat01     1  TPASS  :  lstat(lnfile_13845, &statter) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=lstat02 stime=1411895583
cmdline="lstat02"
contacts=""
analysis=exit
<<<test_output>>>
lstat02     1  TPASS  :  lstat() failed as expected: TEST_ERRNO=EACCES(13): Permission denied
lstat02     2  TPASS  :  lstat() failed as expected: TEST_ERRNO=ENOENT(2): No such file or directory
lstat02     3  TPASS  :  lstat() failed as expected: TEST_ERRNO=EFAULT(14): Bad address
lstat02     4  TPASS  :  lstat() failed as expected: TEST_ERRNO=EFAULT(14): Bad address
lstat02     5  TPASS  :  lstat() failed as expected: TEST_ERRNO=ENAMETOOLONG(36): File name too long
lstat02     6  TPASS  :  lstat() failed as expected: TEST_ERRNO=ENOTDIR(20): Not a directory
lstat02     7  TPASS  :  lstat() failed as expected: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=lstat02_64 stime=1411895583
cmdline="lstat02_64"
contacts=""
analysis=exit
<<<test_output>>>
lstat02     1  TPASS  :  lstat() failed as expected: TEST_ERRNO=EACCES(13): Permission denied
lstat02     2  TPASS  :  lstat() failed as expected: TEST_ERRNO=ENOENT(2): No such file or directory
lstat02     3  TPASS  :  lstat() failed as expected: TEST_ERRNO=EFAULT(14): Bad address
lstat02     4  TPASS  :  lstat() failed as expected: TEST_ERRNO=EFAULT(14): Bad address
lstat02     5  TPASS  :  lstat() failed as expected: TEST_ERRNO=ENAMETOOLONG(36): File name too long
lstat02     6  TPASS  :  lstat() failed as expected: TEST_ERRNO=ENOTDIR(20): Not a directory
lstat02     7  TPASS  :  lstat() failed as expected: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=lstat03 stime=1411895583
cmdline="lstat03"
contacts=""
analysis=exit
<<<test_output>>>
lstat03     1  TPASS  :  Functionality of lstat(2) on 'sfile' Succcessful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=lstat03_64 stime=1411895583
cmdline="lstat03_64"
contacts=""
analysis=exit
<<<test_output>>>
lstat03     1  TPASS  :  Functionality of lstat(2) on 'sfile' Succcessful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mallopt01 stime=1411895583
cmdline="mallopt01"
contacts=""
analysis=exit
<<<test_output>>>
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mbind01 stime=1411895583
cmdline="mbind01"
contacts=""
analysis=exit
<<<test_output>>>
EXPECT: return value(ret)=0 errno=0 (Success)
RESULT: return value(ret)=0 errno=0 (Success)
EXPECT: return value(ret)=-1 errno=22 (Invalid argument)
RESULT: return value(ret)=-1 errno=22 (Invalid argument)
EXPECT: return value(ret)=-1 errno=22 (Invalid argument)
RESULT: return value(ret)=-1 errno=22 (Invalid argument)
EXPECT: return value(ret)=0 errno=0 (Success)
RESULT: return value(ret)=0 errno=0 (Success)
EXPECT: return value(ret)=-1 errno=22 (Invalid argument)
RESULT: return value(ret)=-1 errno=22 (Invalid argument)
EXPECT: return value(ret)=0 errno=0 (Success)
RESULT: return value(ret)=0 errno=0 (Success)
EXPECT: return value(ret)=0 errno=0 (Success)
RESULT: return value(ret)=0 errno=0 (Success)
EXPECT: return value(ret)=0 errno=0 (Success)
RESULT: return value(ret)=0 errno=0 (Success)
EXPECT: return value(ret)=-1 errno=22 (Invalid argument)
RESULT: return value(ret)=-1 errno=22 (Invalid argument)
EXPECT: return value(ret)=-1 errno=22 (Invalid argument)
RESULT: return value(ret)=-1 errno=22 (Invalid argument)
EXPECT: return value(ret)=-1 errno=14 (Bad address)
RESULT: return value(ret)=-1 errno=14 (Bad address)
mbind01     0  TINFO  :  (case00) START
mbind01     1  TPASS  :  (case00) END
mbind01     0  TINFO  :  (case01) START
mbind01     2  TPASS  :  (case01) END
mbind01     0  TINFO  :  (case02) START
mbind01     3  TPASS  :  (case02) END
mbind01     0  TINFO  :  (case03) START
mbind01     4  TPASS  :  (case03) END
mbind01     0  TINFO  :  (case04) START
mbind01     5  TPASS  :  (case04) END
mbind01     0  TINFO  :  (case05) START
mbind01     6  TPASS  :  (case05) END
mbind01     0  TINFO  :  (case06) START
mbind01     7  TPASS  :  (case06) END
mbind01     0  TINFO  :  (case07) START
mbind01     8  TPASS  :  (case07) END
mbind01     0  TINFO  :  (case08) START
mbind01     9  TPASS  :  (case08) END
mbind01     0  TINFO  :  (case09) START
mbind01    10  TPASS  :  (case09) END
mbind01     0  TINFO  :  (case10) START
mbind01    11  TPASS  :  (case10) END
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=2
<<<test_end>>>
<<<test_start>>>
tag=memset01 stime=1411895583
cmdline="memset01"
contacts=""
analysis=exit
<<<test_output>>>
memset01    1  TPASS  :  Test passed
memset01    2  TPASS  :  Test passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=memcmp01 stime=1411895583
cmdline="memcmp01"
contacts=""
analysis=exit
<<<test_output>>>
memcmp1     1  TPASS  :  Test passed
memcmp1     2  TPASS  :  Test passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=memcpy01 stime=1411895583
cmdline="memcpy01"
contacts=""
analysis=exit
<<<test_output>>>
memcpy1     1  TPASS  :  Test passed
memcpy1     2  TPASS  :  Test passed
memcpy1     3  TPASS  :  Test passed
memcpy1     4  TPASS  :  Test passed
memcpy1     5  TPASS  :  Test passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=migrate_pages01 stime=1411895583
cmdline="migrate_pages01"
contacts=""
analysis=exit
<<<test_output>>>
migrate_pages01    0  TINFO  :  test_empty_mask
migrate_pages01    1  TPASS  :  expected ret success: returned value = 0
migrate_pages01    0  TINFO  :  test_invalid_pid -1
migrate_pages01    2  TPASS  :  expected ret success: returned value = -1
migrate_pages01    3  TPASS  :  expected failure: TEST_ERRNO=ESRCH(3): No such process
migrate_pages01    0  TINFO  :  test_invalid_pid unused pid
migrate_pages01    4  TPASS  :  expected ret success: returned value = -1
migrate_pages01    5  TPASS  :  expected failure: TEST_ERRNO=ESRCH(3): No such process
migrate_pages01    0  TINFO  :  test_invalid_masksize
migrate_pages01    6  TPASS  :  expected ret success: returned value = -1
migrate_pages01    7  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
migrate_pages01    0  TINFO  :  test_invalid_mem -1
migrate_pages01    8  TPASS  :  expected ret success: returned value = -1
migrate_pages01    9  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
migrate_pages01    0  TINFO  :  test_invalid_mem invalid prot
migrate_pages01   10  TPASS  :  expected ret success: returned value = -1
migrate_pages01   11  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
migrate_pages01    0  TINFO  :  test_invalid_mem unmmaped
migrate_pages01   12  TPASS  :  expected ret success: returned value = -1
migrate_pages01   13  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
migrate_pages01    0  TINFO  :  test_invalid_nodes
migrate_pages01   14  TPASS  :  expected ret success: returned value = -1
migrate_pages01   15  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
migrate_pages01    0  TINFO  :  test_invalid_perm
migrate_pages01   16  TPASS  :  expected ret success: returned value = -1
migrate_pages01   17  TPASS  :  expected failure: TEST_ERRNO=EPERM(1): Operation not permitted
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=migrate_pages02 stime=1411895583
cmdline="migrate_pages02"
contacts=""
analysis=exit
<<<test_output>>>
migrate_pages02    1  TCONF  :  migrate_pages02.c:358: at least 2 allowed NUMA nodes are required
migrate_pages02    2  TCONF  :  migrate_pages02.c:358: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mlockall01 stime=1411895583
cmdline="mlockall01"
contacts=""
analysis=exit
<<<test_output>>>
mlockall01    1  TPASS  :  mlockall test passed for MCL_CURRENT
mlockall01    2  TPASS  :  mlockall test passed for MCL_FUTURE
mlockall01    3  TPASS  :  mlockall test passed for MCL_CURRENT|MCL_FUTURE
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mlockall02 stime=1411895583
cmdline="mlockall02"
contacts=""
analysis=exit
<<<test_output>>>
mlockall02    1  TPASS  :  expected failure - errno = 12 : Cannot allocate memory
mlockall02    2  TPASS  :  expected failure - errno = 1 : Operation not permitted
mlockall02    3  TPASS  :  expected failure - errno = 22 : Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mlockall03 stime=1411895583
cmdline="mlockall03"
contacts=""
analysis=exit
<<<test_output>>>
mlockall03    1  TPASS  :  expected failure - errno = 12 : Cannot allocate memory
mlockall03    2  TPASS  :  expected failure - errno = 1 : Operation not permitted
mlockall03    3  TPASS  :  expected failure - errno = 22 : Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mkdir01 stime=1411895583
cmdline="mkdir01"
contacts=""
analysis=exit
<<<test_output>>>
mkdir01     1  TPASS  :  mkdir - path argument pointing below allocated address space failed as expected with errno 14 : Bad address
mkdir01     2  TPASS  :  mkdir - path argument pointing above allocated address space failed as expected with errno 14 : Bad address
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mkdir02 stime=1411895583
cmdline="mkdir02"
contacts=""
analysis=exit
<<<test_output>>>
mkdir02     1  TPASS  :  Test to attempt to make a directory inherits group ID SUCCEEDED 
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mkdir03 stime=1411895583
cmdline="mkdir03"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
mkdir03     0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
mkdir03     0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
mkdir03     1  TPASS  :  mkdir() failed as expected: TEST_ERRNO=EFAULT(14): Bad address
mkdir03     2  TPASS  :  mkdir() failed as expected: TEST_ERRNO=ENAMETOOLONG(36): File name too long
mkdir03     3  TPASS  :  mkdir() failed as expected: TEST_ERRNO=EEXIST(17): File exists
mkdir03     4  TPASS  :  mkdir() failed as expected: TEST_ERRNO=ENOENT(2): No such file or directory
mkdir03     5  TPASS  :  mkdir() failed as expected: TEST_ERRNO=ENOTDIR(20): Not a directory
mkdir03     6  TPASS  :  mkdir() failed as expected: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
mkdir03     7  TPASS  :  mkdir() failed as expected: TEST_ERRNO=EROFS(30): Read-only file system
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=mkdir04 stime=1411895583
cmdline="mkdir04"
contacts=""
analysis=exit
<<<test_output>>>
mkdir04     1  TPASS  :  Test to attempt to creat a directory in a directory having no permissions SUCCEEDED in setting errno to EACCES
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mkdir05 stime=1411895583
cmdline="mkdir05"
contacts=""
analysis=exit
<<<test_output>>>
mkdir05     1  TPASS  :  mkdir() functionality is correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mkdir05A stime=1411895583
cmdline="symlink01 -T mkdir05"
contacts=""
analysis=exit
<<<test_output>>>
mkdir05     1  TPASS  :  mkdir(2) of object file through symbolic link file failed as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mkdir08 stime=1411895583
cmdline="mkdir08"
contacts=""
analysis=exit
<<<test_output>>>
mkdir08     1  TPASS  :  mkdir(./dir_13874) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mkdir09 stime=1411895583
cmdline="mkdir09"
contacts=""
analysis=exit
<<<test_output>>>
mkdir09     1  TPASS  :  PASS
<<<execution_status>>>
initiation_status="ok"
duration=10 termination_type=exited termination_id=0 corefile=no
cutime=373 cstime=3768
<<<test_end>>>
<<<test_start>>>
tag=mkdirat01 stime=1411895593
cmdline="mkdirat01"
contacts=""
analysis=exit
<<<test_output>>>
mkdirat01    1  TPASS  :  mkdirat() returned 0: TEST_ERRNO=SUCCESS(0): Success
mkdirat01    2  TPASS  :  mkdirat() returned 0: TEST_ERRNO=SUCCESS(0): Success
mkdirat01    3  TPASS  :  mkdirat() returned 0: TEST_ERRNO=SUCCESS(0): Success
mkdirat01    4  TPASS  :  mkdirat() returned -1: TEST_ERRNO=ENOTDIR(20): Not a directory
mkdirat01    5  TPASS  :  mkdirat() returned -1: TEST_ERRNO=EBADF(9): Bad file descriptor
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mkdirat02 stime=1411895593
cmdline="mkdirat02"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
mkdirat02    0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
mkdirat02    0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
mkdirat02    1  TPASS  :  mkdirat() failed as expected: TEST_ERRNO=EROFS(30): Read-only file system
mkdirat02    2  TPASS  :  mkdirat() failed as expected: TEST_ERRNO=EROFS(30): Read-only file system
mkdirat02    3  TPASS  :  mkdirat() failed as expected: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
mkdirat02    4  TPASS  :  mkdirat() failed as expected: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mknod01 stime=1411895593
cmdline="mknod01"
contacts=""
analysis=exit
<<<test_output>>>
mknod01     1  TPASS  :  mknod(test_node, 0100777, 0) returned 0
mknod01     2  TPASS  :  mknod(test_node, 010777, 0) returned 0
mknod01     3  TPASS  :  mknod(test_node, 020777, 0) returned 0
mknod01     4  TPASS  :  mknod(test_node, 060777, 0) returned 0
mknod01     5  TPASS  :  mknod(test_node, 0104700, 0) returned 0
mknod01     6  TPASS  :  mknod(test_node, 0102700, 0) returned 0
mknod01     7  TPASS  :  mknod(test_node, 0106700, 0) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mknod02 stime=1411895593
cmdline="mknod02"
contacts=""
analysis=exit
<<<test_output>>>
mknod02     1  TPASS  :  Functionality of mknod(tnode_13888, 012777, 0) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mknod03 stime=1411895593
cmdline="mknod03"
contacts=""
analysis=exit
<<<test_output>>>
mknod03     1  TPASS  :  Functionality of mknod(tnode_13889, 012777, 0) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mknod04 stime=1411895593
cmdline="mknod04"
contacts=""
analysis=exit
<<<test_output>>>
mknod04     1  TPASS  :  Functionality of mknod(tnode_13890, 010777, 0) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mknod05 stime=1411895593
cmdline="mknod05"
contacts=""
analysis=exit
<<<test_output>>>
mknod05     1  TPASS  :  Functionality of mknod(tnode_13891, 012777, 0) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mknod06 stime=1411895593
cmdline="mknod06"
contacts=""
analysis=exit
<<<test_output>>>
mknod06     1  TPASS  :  mknod() fails, Specified node already exists, errno:17
mknod06     2  TPASS  :  mknod() fails, Negative address, errno:14
mknod06     3  TPASS  :  mknod() fails, Address beyond address space, errno:14
mknod06     4  TPASS  :  mknod() fails, Non-existent file, errno:2
mknod06     5  TPASS  :  mknod() fails, Pathname is empty, errno:2
mknod06     6  TPASS  :  mknod() fails, Pathname too long, errno:36
mknod06     7  TPASS  :  mknod() fails, Path contains regular file, errno:20
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mknod07 stime=1411895593
cmdline="mknod07"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
mknod07     0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
mknod07     0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
mknod07     1  TPASS  :  mknod failed as expected: TEST_ERRNO=EACCES(13): Permission denied
mknod07     2  TPASS  :  mknod failed as expected: TEST_ERRNO=EACCES(13): Permission denied
mknod07     3  TPASS  :  mknod failed as expected: TEST_ERRNO=EPERM(1): Operation not permitted
mknod07     4  TPASS  :  mknod failed as expected: TEST_ERRNO=EPERM(1): Operation not permitted
mknod07     5  TPASS  :  mknod failed as expected: TEST_ERRNO=EROFS(30): Read-only file system
mknod07     6  TPASS  :  mknod failed as expected: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=mknod08 stime=1411895593
cmdline="mknod08"
contacts=""
analysis=exit
<<<test_output>>>
mknod08     1  TPASS  :  Functionality of mknod(tnode_13897, 010777, 0) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mknod09 stime=1411895593
cmdline="mknod09"
contacts=""
analysis=exit
<<<test_output>>>
mknod09     1  TPASS  :  mknod() fails with expected error EINVAL errno:22
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mknodat01 stime=1411895593
cmdline="mknodat01"
contacts=""
analysis=exit
<<<test_output>>>
mknodat01    1  TPASS  :  mknodat() returned 0: TEST_ERRNO=SUCCESS(0): Success
mknodat01    2  TPASS  :  mknodat() returned 0: TEST_ERRNO=SUCCESS(0): Success
mknodat01    3  TPASS  :  mknodat() returned -1: TEST_ERRNO=ENOTDIR(20): Not a directory
mknodat01    4  TPASS  :  mknodat() returned -1: TEST_ERRNO=EBADF(9): Bad file descriptor
mknodat01    5  TPASS  :  mknodat() returned 0: TEST_ERRNO=SUCCESS(0): Success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mknodat02 stime=1411895593
cmdline="mknodat02"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
mknodat     0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
mknodat     0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
mknodat     1  TPASS  :  mknodat() returned the expected value: TEST_ERRNO=SUCCESS(0): Success
mknodat     2  TPASS  :  mknodat() returned the expected value: TEST_ERRNO=SUCCESS(0): Success
mknodat     3  TPASS  :  mknodat() returned the expected value: TEST_ERRNO=SUCCESS(0): Success
mknodat     4  TPASS  :  mknodat() returned the expected value: TEST_ERRNO=EROFS(30): Read-only file system
mknodat     5  TPASS  :  mknodat() returned the expected value: TEST_ERRNO=EROFS(30): Read-only file system
mknodat     6  TPASS  :  mknodat() returned the expected value: TEST_ERRNO=EROFS(30): Read-only file system
mknodat     7  TPASS  :  mknodat() returned the expected value: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
mknodat     8  TPASS  :  mknodat() returned the expected value: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
mknodat     9  TPASS  :  mknodat() returned the expected value: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mlock01 stime=1411895593
cmdline="mlock01"
contacts=""
analysis=exit
<<<test_output>>>
mlock01     1  TPASS  :  mlock passed
mlock01     2  TPASS  :  mlock passed
mlock01     3  TPASS  :  mlock passed
mlock01     4  TPASS  :  mlock passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mlock02 stime=1411895593
cmdline="mlock02"
contacts=""
analysis=exit
<<<test_output>>>
mlock02     1  TPASS  :  mlock failed as expected: TEST_ERRNO=ENOMEM(12): Cannot allocate memory
mlock02     2  TPASS  :  mlock failed as expected: TEST_ERRNO=ENOMEM(12): Cannot allocate memory
mlock02     3  TPASS  :  mlock failed as expected: TEST_ERRNO=EPERM(1): Operation not permitted
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mlock03 stime=1411895593
cmdline="mlock03 -i 20"
contacts=""
analysis=exit
<<<test_output>>>
mlock03     0  TINFO  :  mlock from 400000 to 407000
mlock03     0  TINFO  :  mlock from 607000 to 608000
mlock03     0  TINFO  :  mlock from 608000 to 60c000
mlock03     0  TINFO  :  mlock from 9c9000 to 9ea000
mlock03     0  TINFO  :  mlock from 7f74ae59f000 to 7f74ae742000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from 7f74ae742000 to 7f74ae941000
mlock03     0  TINFO  :  mlock from 7f74ae941000 to 7f74ae945000
mlock03     0  TINFO  :  mlock from 7f74ae945000 to 7f74ae947000
mlock03     0  TINFO  :  mlock from 7f74ae947000 to 7f74ae94b000
mlock03     0  TINFO  :  mlock from 7f74ae94b000 to 7f74ae96c000
mlock03     0  TINFO  :  mlock from 7f74aeb62000 to 7f74aeb65000
mlock03     0  TINFO  :  mlock from 7f74aeb69000 to 7f74aeb6c000
mlock03     0  TINFO  :  mlock from 7f74aeb6c000 to 7f74aeb6d000
mlock03     0  TINFO  :  mlock from 7f74aeb6d000 to 7f74aeb6f000
mlock03     0  TINFO  :  mlock from 7fff3d3a0000 to 7fff3d3c1000
mlock03     0  TINFO  :  mlock from 7fff3d3fc000 to 7fff3d3fe000
mlock03     0  TINFO  :  mlock from 7fff3d3fe000 to 7fff3d400000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  mlock from 7fff3d3fe000 to 7fff3d400000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  munlock from 400000 to 407000
mlock03     0  TINFO  :  munlock from 607000 to 608000
mlock03     0  TINFO  :  munlock from 608000 to 60c000
mlock03     0  TINFO  :  munlock from 9c9000 to 9ea000
mlock03     0  TINFO  :  munlock from 7f74ae59f000 to 7f74ae742000
mlock03     0  TINFO  :  munlock from 7f74ae742000 to 7f74ae941000
mlock03     0  TINFO  :  munlock from 7f74ae941000 to 7f74ae945000
mlock03     0  TINFO  :  munlock from 7f74ae945000 to 7f74ae947000
mlock03     0  TINFO  :  munlock from 7f74ae947000 to 7f74ae94b000
mlock03     0  TINFO  :  munlock from 7f74ae94b000 to 7f74ae96c000
mlock03     0  TINFO  :  munlock from 7f74aeb62000 to 7f74aeb65000
mlock03     0  TINFO  :  munlock from 7f74aeb68000 to 7f74aeb6a000
mlock03     0  TINFO  :  munlock from 7f74aeb6a000 to 7f74aeb6c000
mlock03     0  TINFO  :  munlock from 7f74aeb6c000 to 7f74aeb6d000
mlock03     0  TINFO  :  munlock from 7f74aeb6d000 to 7f74aeb6f000
mlock03     0  TINFO  :  munlock from 7fff3d3a0000 to 7fff3d3a0000
mlock03     0  TINFO  :  munlock from 7fff3d3a0000 to 7fff3d3c1000
mlock03     0  TINFO  :  munlock from 7fff3d3fc000 to 7fff3d3fe000
mlock03     0  TINFO  :  munlock from 7fff3d3fe000 to 7fff3d400000
mlock03     0  TINFO  :  munlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  munlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  mlock from 400000 to 407000
mlock03     0  TINFO  :  mlock from 607000 to 608000
mlock03     0  TINFO  :  mlock from 608000 to 60c000
mlock03     0  TINFO  :  mlock from 9c9000 to 9ea000
mlock03     0  TINFO  :  mlock from 7f74ae59f000 to 7f74ae742000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from 7f74ae742000 to 7f74ae941000
mlock03     0  TINFO  :  mlock from 7f74ae941000 to 7f74ae945000
mlock03     0  TINFO  :  mlock from 7f74ae945000 to 7f74ae947000
mlock03     0  TINFO  :  mlock from 7f74ae947000 to 7f74ae94b000
mlock03     0  TINFO  :  mlock from 7f74ae94b000 to 7f74ae96c000
mlock03     0  TINFO  :  mlock from 7f74aeb62000 to 7f74aeb65000
mlock03     0  TINFO  :  mlock from 7f74aeb68000 to 7f74aeb6c000
mlock03     0  TINFO  :  mlock from 7f74aeb6c000 to 7f74aeb6d000
mlock03     0  TINFO  :  mlock from 7f74aeb6d000 to 7f74aeb6f000
mlock03     0  TINFO  :  mlock from 7fff3d3a0000 to 7fff3d3c1000
mlock03     0  TINFO  :  mlock from 7fff3d3fc000 to 7fff3d3fe000
mlock03     0  TINFO  :  mlock from 7fff3d3fe000 to 7fff3d400000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  munlock from 400000 to 407000
mlock03     0  TINFO  :  munlock from 607000 to 608000
mlock03     0  TINFO  :  munlock from 608000 to 60c000
mlock03     0  TINFO  :  munlock from 9c9000 to 9ea000
mlock03     0  TINFO  :  munlock from 7f74ae59f000 to 7f74ae742000
mlock03     0  TINFO  :  munlock from 7f74ae742000 to 7f74ae941000
mlock03     0  TINFO  :  munlock from 7f74ae941000 to 7f74ae945000
mlock03     0  TINFO  :  munlock from 7f74ae945000 to 7f74ae947000
mlock03     0  TINFO  :  munlock from 7f74ae947000 to 7f74ae94b000
mlock03     0  TINFO  :  munlock from 7f74ae94b000 to 7f74ae96c000
mlock03     0  TINFO  :  munlock from 7f74aeb62000 to 7f74aeb65000
mlock03     0  TINFO  :  munlock from 7f74aeb68000 to 7f74aeb69000
mlock03     0  TINFO  :  munlock from 7f74aeb69000 to 7f74aeb6a000
mlock03     0  TINFO  :  munlock from 7f74aeb6a000 to 7f74aeb6c000
mlock03     0  TINFO  :  munlock from 7f74aeb6c000 to 7f74aeb6d000
mlock03     0  TINFO  :  munlock from 7f74aeb6d000 to 7f74aeb6f000
mlock03     0  TINFO  :  munlock from 7fff3d3a0000 to 7fff3d3a0000
mlock03     0  TINFO  :  munlock from 7fff3d3a0000 to 7fff3d3c1000
mlock03     0  TINFO  :  munlock from 7fff3d3fc000 to 7fff3d3fe000
mlock03     0  TINFO  :  munlock from 7fff3d3fe000 to 7fff3d400000
mlock03     0  TINFO  :  munlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  munlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  mlock from 400000 to 407000
mlock03     0  TINFO  :  mlock from 607000 to 608000
mlock03     0  TINFO  :  mlock from 608000 to 60c000
mlock03     0  TINFO  :  mlock from 9c9000 to 9ea000
mlock03     0  TINFO  :  mlock from 7f74ae59f000 to 7f74ae742000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from 7f74ae742000 to 7f74ae941000
mlock03     0  TINFO  :  mlock from 7f74ae941000 to 7f74ae945000
mlock03     0  TINFO  :  mlock from 7f74ae945000 to 7f74ae947000
mlock03     0  TINFO  :  mlock from 7f74ae947000 to 7f74ae94b000
mlock03     0  TINFO  :  mlock from 7f74ae94b000 to 7f74ae96c000
mlock03     0  TINFO  :  mlock from 7f74aeb62000 to 7f74aeb65000
mlock03     0  TINFO  :  mlock from 7f74aeb68000 to 7f74aeb6c000
mlock03     0  TINFO  :  mlock from 7f74aeb6c000 to 7f74aeb6d000
mlock03     0  TINFO  :  mlock from 7f74aeb6d000 to 7f74aeb6f000
mlock03     0  TINFO  :  mlock from 7fff3d3a0000 to 7fff3d3c1000
mlock03     0  TINFO  :  mlock from 7fff3d3fc000 to 7fff3d3fe000
mlock03     0  TINFO  :  mlock from 7fff3d3fe000 to 7fff3d400000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  munlock from 400000 to 407000
mlock03     0  TINFO  :  munlock from 607000 to 608000
mlock03     0  TINFO  :  munlock from 608000 to 60c000
mlock03     0  TINFO  :  munlock from 9c9000 to 9ea000
mlock03     0  TINFO  :  munlock from 7f74ae59f000 to 7f74ae742000
mlock03     0  TINFO  :  munlock from 7f74ae742000 to 7f74ae941000
mlock03     0  TINFO  :  munlock from 7f74ae941000 to 7f74ae945000
mlock03     0  TINFO  :  munlock from 7f74ae945000 to 7f74ae947000
mlock03     0  TINFO  :  munlock from 7f74ae947000 to 7f74ae94b000
mlock03     0  TINFO  :  munlock from 7f74ae94b000 to 7f74ae96c000
mlock03     0  TINFO  :  munlock from 7f74aeb62000 to 7f74aeb65000
mlock03     0  TINFO  :  munlock from 7f74aeb68000 to 7f74aeb69000
mlock03     0  TINFO  :  munlock from 7f74aeb69000 to 7f74aeb6a000
mlock03     0  TINFO  :  munlock from 7f74aeb6a000 to 7f74aeb6c000
mlock03     0  TINFO  :  munlock from 7f74aeb6c000 to 7f74aeb6d000
mlock03     0  TINFO  :  munlock from 7f74aeb6d000 to 7f74aeb6f000
mlock03     0  TINFO  :  munlock from 7fff3d3a0000 to 7fff3d3a0000
mlock03     0  TINFO  :  munlock from 7fff3d3a0000 to 7fff3d3c1000
mlock03     0  TINFO  :  munlock from 7fff3d3fc000 to 7fff3d3fe000
mlock03     0  TINFO  :  munlock from 7fff3d3fe000 to 7fff3d400000
mlock03     0  TINFO  :  munlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  munlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  mlock from 400000 to 407000
mlock03     0  TINFO  :  mlock from 607000 to 608000
mlock03     0  TINFO  :  mlock from 608000 to 60c000
mlock03     0  TINFO  :  mlock from 9c9000 to 9ea000
mlock03     0  TINFO  :  mlock from 7f74ae59f000 to 7f74ae742000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from 7f74ae742000 to 7f74ae941000
mlock03     0  TINFO  :  mlock from 7f74ae941000 to 7f74ae945000
mlock03     0  TINFO  :  mlock from 7f74ae945000 to 7f74ae947000
mlock03     0  TINFO  :  mlock from 7f74ae947000 to 7f74ae94b000
mlock03     0  TINFO  :  mlock from 7f74ae94b000 to 7f74ae96c000
mlock03     0  TINFO  :  mlock from 7f74aeb62000 to 7f74aeb65000
mlock03     0  TINFO  :  mlock from 7f74aeb68000 to 7f74aeb6c000
mlock03     0  TINFO  :  mlock from 7f74aeb6c000 to 7f74aeb6d000
mlock03     0  TINFO  :  mlock from 7f74aeb6d000 to 7f74aeb6f000
mlock03     0  TINFO  :  mlock from 7fff3d3a0000 to 7fff3d3c1000
mlock03     0  TINFO  :  mlock from 7fff3d3fc000 to 7fff3d3fe000
mlock03     0  TINFO  :  mlock from 7fff3d3fe000 to 7fff3d400000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  munlock from 400000 to 407000
mlock03     0  TINFO  :  munlock from 607000 to 608000
mlock03     0  TINFO  :  munlock from 608000 to 60c000
mlock03     0  TINFO  :  munlock from 9c9000 to 9ea000
mlock03     0  TINFO  :  munlock from 7f74ae59f000 to 7f74ae742000
mlock03     0  TINFO  :  munlock from 7f74ae742000 to 7f74ae941000
mlock03     0  TINFO  :  munlock from 7f74ae941000 to 7f74ae945000
mlock03     0  TINFO  :  munlock from 7f74ae945000 to 7f74ae947000
mlock03     0  TINFO  :  munlock from 7f74ae947000 to 7f74ae94b000
mlock03     0  TINFO  :  munlock from 7f74ae94b000 to 7f74ae96c000
mlock03     0  TINFO  :  munlock from 7f74aeb62000 to 7f74aeb65000
mlock03     0  TINFO  :  munlock from 7f74aeb68000 to 7f74aeb69000
mlock03     0  TINFO  :  munlock from 7f74aeb69000 to 7f74aeb6a000
mlock03     0  TINFO  :  munlock from 7f74aeb6a000 to 7f74aeb6c000
mlock03     0  TINFO  :  munlock from 7f74aeb6c000 to 7f74aeb6d000
mlock03     0  TINFO  :  munlock from 7f74aeb6d000 to 7f74aeb6f000
mlock03     0  TINFO  :  munlock from 7fff3d3a0000 to 7fff3d3a0000
mlock03     0  TINFO  :  munlock from 7fff3d3a0000 to 7fff3d3c1000
mlock03     0  TINFO  :  munlock from 7fff3d3fc000 to 7fff3d3fe000
mlock03     0  TINFO  :  munlock from 7fff3d3fe000 to 7fff3d400000
mlock03     0  TINFO  :  munlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  munlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  mlock from 400000 to 407000
mlock03     0  TINFO  :  mlock from 607000 to 608000
mlock03     0  TINFO  :  mlock from 608000 to 60c000
mlock03     0  TINFO  :  mlock from 9c9000 to 9ea000
mlock03     0  TINFO  :  mlock from 7f74ae59f000 to 7f74ae742000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from 7f74ae742000 to 7f74ae941000
mlock03     0  TINFO  :  mlock from 7f74ae941000 to 7f74ae945000
mlock03     0  TINFO  :  mlock from 7f74ae945000 to 7f74ae947000
mlock03     0  TINFO  :  mlock from 7f74ae947000 to 7f74ae94b000
mlock03     0  TINFO  :  mlock from 7f74ae94b000 to 7f74ae96c000
mlock03     0  TINFO  :  mlock from 7f74aeb62000 to 7f74aeb65000
mlock03     0  TINFO  :  mlock from 7f74aeb68000 to 7f74aeb6c000
mlock03     0  TINFO  :  mlock from 7f74aeb6c000 to 7f74aeb6d000
mlock03     0  TINFO  :  mlock from 7f74aeb6d000 to 7f74aeb6f000
mlock03     0  TINFO  :  mlock from 7fff3d3a0000 to 7fff3d3c1000
mlock03     0  TINFO  :  mlock from 7fff3d3fc000 to 7fff3d3fe000
mlock03     0  TINFO  :  mlock from 7fff3d3fe000 to 7fff3d400000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  munlock from 400000 to 407000
mlock03     0  TINFO  :  munlock from 607000 to 608000
mlock03     0  TINFO  :  munlock from 608000 to 60c000
mlock03     0  TINFO  :  munlock from 9c9000 to 9ea000
mlock03     0  TINFO  :  munlock from 7f74ae59f000 to 7f74ae742000
mlock03     0  TINFO  :  munlock from 7f74ae742000 to 7f74ae941000
mlock03     0  TINFO  :  munlock from 7f74ae941000 to 7f74ae945000
mlock03     0  TINFO  :  munlock from 7f74ae945000 to 7f74ae947000
mlock03     0  TINFO  :  munlock from 7f74ae947000 to 7f74ae94b000
mlock03     0  TINFO  :  munlock from 7f74ae94b000 to 7f74ae96c000
mlock03     0  TINFO  :  munlock from 7f74aeb62000 to 7f74aeb65000
mlock03     0  TINFO  :  munlock from 7f74aeb68000 to 7f74aeb69000
mlock03     0  TINFO  :  munlock from 7f74aeb69000 to 7f74aeb6a000
mlock03     0  TINFO  :  munlock from 7f74aeb6a000 to 7f74aeb6c000
mlock03     0  TINFO  :  munlock from 7f74aeb6c000 to 7f74aeb6d000
mlock03     0  TINFO  :  munlock from 7f74aeb6d000 to 7f74aeb6f000
mlock03     0  TINFO  :  munlock from 7fff3d3a0000 to 7fff3d3a0000
mlock03     0  TINFO  :  munlock from 7fff3d3a0000 to 7fff3d3c1000
mlock03     0  TINFO  :  munlock from 7fff3d3fc000 to 7fff3d3fe000
mlock03     0  TINFO  :  munlock from 7fff3d3fe000 to 7fff3d400000
mlock03     0  TINFO  :  munlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  munlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  mlock from 400000 to 407000
mlock03     0  TINFO  :  mlock from 607000 to 608000
mlock03     0  TINFO  :  mlock from 608000 to 60c000
mlock03     0  TINFO  :  mlock from 9c9000 to 9ea000
mlock03     0  TINFO  :  mlock from 7f74ae59f000 to 7f74ae742000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from 7f74ae742000 to 7f74ae941000
mlock03     0  TINFO  :  mlock from 7f74ae941000 to 7f74ae945000
mlock03     0  TINFO  :  mlock from 7f74ae945000 to 7f74ae947000
mlock03     0  TINFO  :  mlock from 7f74ae947000 to 7f74ae94b000
mlock03     0  TINFO  :  mlock from 7f74ae94b000 to 7f74ae96c000
mlock03     0  TINFO  :  mlock from 7f74aeb62000 to 7f74aeb65000
mlock03     0  TINFO  :  mlock from 7f74aeb68000 to 7f74aeb6c000
mlock03     0  TINFO  :  mlock from 7f74aeb6c000 to 7f74aeb6d000
mlock03     0  TINFO  :  mlock from 7f74aeb6d000 to 7f74aeb6f000
mlock03     0  TINFO  :  mlock from 7fff3d3a0000 to 7fff3d3c1000
mlock03     0  TINFO  :  mlock from 7fff3d3fc000 to 7fff3d3fe000
mlock03     0  TINFO  :  mlock from 7fff3d3fe000 to 7fff3d400000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  munlock from 400000 to 407000
mlock03     0  TINFO  :  munlock from 607000 to 608000
mlock03     0  TINFO  :  munlock from 608000 to 60c000
mlock03     0  TINFO  :  munlock from 9c9000 to 9ea000
mlock03     0  TINFO  :  munlock from 7f74ae59f000 to 7f74ae742000
mlock03     0  TINFO  :  munlock from 7f74ae742000 to 7f74ae941000
mlock03     0  TINFO  :  munlock from 7f74ae941000 to 7f74ae945000
mlock03     0  TINFO  :  munlock from 7f74ae945000 to 7f74ae947000
mlock03     0  TINFO  :  munlock from 7f74ae947000 to 7f74ae94b000
mlock03     0  TINFO  :  munlock from 7f74ae94b000 to 7f74ae96c000
mlock03     0  TINFO  :  munlock from 7f74aeb62000 to 7f74aeb65000
mlock03     0  TINFO  :  munlock from 7f74aeb68000 to 7f74aeb69000
mlock03     0  TINFO  :  munlock from 7f74aeb69000 to 7f74aeb6a000
mlock03     0  TINFO  :  munlock from 7f74aeb6a000 to 7f74aeb6c000
mlock03     0  TINFO  :  munlock from 7f74aeb6c000 to 7f74aeb6d000
mlock03     0  TINFO  :  munlock from 7f74aeb6d000 to 7f74aeb6f000
mlock03     0  TINFO  :  munlock from 7fff3d3a0000 to 7fff3d3a0000
mlock03     0  TINFO  :  munlock from 7fff3d3a0000 to 7fff3d3c1000
mlock03     0  TINFO  :  munlock from 7fff3d3fc000 to 7fff3d3fe000
mlock03     0  TINFO  :  munlock from 7fff3d3fe000 to 7fff3d400000
mlock03     0  TINFO  :  munlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  munlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  mlock from 400000 to 407000
mlock03     0  TINFO  :  mlock from 607000 to 608000
mlock03     0  TINFO  :  mlock from 608000 to 60c000
mlock03     0  TINFO  :  mlock from 9c9000 to 9ea000
mlock03     0  TINFO  :  mlock from 7f74ae59f000 to 7f74ae742000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from 7f74ae742000 to 7f74ae941000
mlock03     0  TINFO  :  mlock from 7f74ae941000 to 7f74ae945000
mlock03     0  TINFO  :  mlock from 7f74ae945000 to 7f74ae947000
mlock03     0  TINFO  :  mlock from 7f74ae947000 to 7f74ae94b000
mlock03     0  TINFO  :  mlock from 7f74ae94b000 to 7f74ae96c000
mlock03     0  TINFO  :  mlock from 7f74aeb62000 to 7f74aeb65000
mlock03     0  TINFO  :  mlock from 7f74aeb68000 to 7f74aeb6c000
mlock03     0  TINFO  :  mlock from 7f74aeb6c000 to 7f74aeb6d000
mlock03     0  TINFO  :  mlock from 7f74aeb6d000 to 7f74aeb6f000
mlock03     0  TINFO  :  mlock from 7fff3d3a0000 to 7fff3d3c1000
mlock03     0  TINFO  :  mlock from 7fff3d3fc000 to 7fff3d3fe000
mlock03     0  TINFO  :  mlock from 7fff3d3fe000 to 7fff3d400000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  munlock from 400000 to 407000
mlock03     0  TINFO  :  munlock from 607000 to 608000
mlock03     0  TINFO  :  munlock from 608000 to 60c000
mlock03     0  TINFO  :  munlock from 9c9000 to 9ea000
mlock03     0  TINFO  :  munlock from 7f74ae59f000 to 7f74ae742000
mlock03     0  TINFO  :  munlock from 7f74ae742000 to 7f74ae941000
mlock03     0  TINFO  :  munlock from 7f74ae941000 to 7f74ae945000
mlock03     0  TINFO  :  munlock from 7f74ae945000 to 7f74ae947000
mlock03     0  TINFO  :  munlock from 7f74ae947000 to 7f74ae94b000
mlock03     0  TINFO  :  munlock from 7f74ae94b000 to 7f74ae96c000
mlock03     0  TINFO  :  munlock from 7f74aeb62000 to 7f74aeb65000
mlock03     0  TINFO  :  munlock from 7f74aeb68000 to 7f74aeb69000
mlock03     0  TINFO  :  munlock from 7f74aeb69000 to 7f74aeb6a000
mlock03     0  TINFO  :  munlock from 7f74aeb6a000 to 7f74aeb6c000
mlock03     0  TINFO  :  munlock from 7f74aeb6c000 to 7f74aeb6d000
mlock03     0  TINFO  :  munlock from 7f74aeb6d000 to 7f74aeb6f000
mlock03     0  TINFO  :  munlock from 7fff3d3a0000 to 7fff3d3a0000
mlock03     0  TINFO  :  munlock from 7fff3d3a0000 to 7fff3d3c1000
mlock03     0  TINFO  :  munlock from 7fff3d3fc000 to 7fff3d3fe000
mlock03     0  TINFO  :  munlock from 7fff3d3fe000 to 7fff3d400000
mlock03     0  TINFO  :  munlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  munlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  mlock from 400000 to 407000
mlock03     0  TINFO  :  mlock from 607000 to 608000
mlock03     0  TINFO  :  mlock from 608000 to 60c000
mlock03     0  TINFO  :  mlock from 9c9000 to 9ea000
mlock03     0  TINFO  :  mlock from 7f74ae59f000 to 7f74ae742000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from 7f74ae742000 to 7f74ae941000
mlock03     0  TINFO  :  mlock from 7f74ae941000 to 7f74ae945000
mlock03     0  TINFO  :  mlock from 7f74ae945000 to 7f74ae947000
mlock03     0  TINFO  :  mlock from 7f74ae947000 to 7f74ae94b000
mlock03     0  TINFO  :  mlock from 7f74ae94b000 to 7f74ae96c000
mlock03     0  TINFO  :  mlock from 7f74aeb62000 to 7f74aeb65000
mlock03     0  TINFO  :  mlock from 7f74aeb68000 to 7f74aeb6c000
mlock03     0  TINFO  :  mlock from 7f74aeb6c000 to 7f74aeb6d000
mlock03     0  TINFO  :  mlock from 7f74aeb6d000 to 7f74aeb6f000
mlock03     0  TINFO  :  mlock from 7fff3d3a0000 to 7fff3d3c1000
mlock03     0  TINFO  :  mlock from 7fff3d3fc000 to 7fff3d3fe000
mlock03     0  TINFO  :  mlock from 7fff3d3fe000 to 7fff3d400000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  munlock from 400000 to 407000
mlock03     0  TINFO  :  munlock from 607000 to 608000
mlock03     0  TINFO  :  munlock from 608000 to 60c000
mlock03     0  TINFO  :  munlock from 9c9000 to 9ea000
mlock03     0  TINFO  :  munlock from 7f74ae59f000 to 7f74ae742000
mlock03     0  TINFO  :  munlock from 7f74ae742000 to 7f74ae941000
mlock03     0  TINFO  :  munlock from 7f74ae941000 to 7f74ae945000
mlock03     0  TINFO  :  munlock from 7f74ae945000 to 7f74ae947000
mlock03     0  TINFO  :  munlock from 7f74ae947000 to 7f74ae94b000
mlock03     0  TINFO  :  munlock from 7f74ae94b000 to 7f74ae96c000
mlock03     0  TINFO  :  munlock from 7f74aeb62000 to 7f74aeb65000
mlock03     0  TINFO  :  munlock from 7f74aeb68000 to 7f74aeb69000
mlock03     0  TINFO  :  munlock from 7f74aeb69000 to 7f74aeb6a000
mlock03     0  TINFO  :  munlock from 7f74aeb6a000 to 7f74aeb6c000
mlock03     0  TINFO  :  munlock from 7f74aeb6c000 to 7f74aeb6d000
mlock03     0  TINFO  :  munlock from 7f74aeb6d000 to 7f74aeb6f000
mlock03     0  TINFO  :  munlock from 7fff3d3a0000 to 7fff3d3a0000
mlock03     0  TINFO  :  munlock from 7fff3d3a0000 to 7fff3d3c1000
mlock03     0  TINFO  :  munlock from 7fff3d3fc000 to 7fff3d3fe000
mlock03     0  TINFO  :  munlock from 7fff3d3fe000 to 7fff3d400000
mlock03     0  TINFO  :  munlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  munlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  mlock from 400000 to 407000
mlock03     0  TINFO  :  mlock from 607000 to 608000
mlock03     0  TINFO  :  mlock from 608000 to 60c000
mlock03     0  TINFO  :  mlock from 9c9000 to 9ea000
mlock03     0  TINFO  :  mlock from 7f74ae59f000 to 7f74ae742000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from 7f74ae742000 to 7f74ae941000
mlock03     0  TINFO  :  mlock from 7f74ae941000 to 7f74ae945000
mlock03     0  TINFO  :  mlock from 7f74ae945000 to 7f74ae947000
mlock03     0  TINFO  :  mlock from 7f74ae947000 to 7f74ae94b000
mlock03     0  TINFO  :  mlock from 7f74ae94b000 to 7f74ae96c000
mlock03     0  TINFO  :  mlock from 7f74aeb62000 to 7f74aeb65000
mlock03     0  TINFO  :  mlock from 7f74aeb68000 to 7f74aeb6c000
mlock03     0  TINFO  :  mlock from 7f74aeb6c000 to 7f74aeb6d000
mlock03     0  TINFO  :  mlock from 7f74aeb6d000 to 7f74aeb6f000
mlock03     0  TINFO  :  mlock from 7fff3d3a0000 to 7fff3d3c1000
mlock03     0  TINFO  :  mlock from 7fff3d3fc000 to 7fff3d3fe000
mlock03     0  TINFO  :  mlock from 7fff3d3fe000 to 7fff3d400000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  munlock from 400000 to 407000
mlock03     0  TINFO  :  munlock from 607000 to 608000
mlock03     0  TINFO  :  munlock from 608000 to 60c000
mlock03     0  TINFO  :  munlock from 9c9000 to 9ea000
mlock03     0  TINFO  :  munlock from 7f74ae59f000 to 7f74ae742000
mlock03     0  TINFO  :  munlock from 7f74ae742000 to 7f74ae941000
mlock03     0  TINFO  :  munlock from 7f74ae941000 to 7f74ae945000
mlock03     0  TINFO  :  munlock from 7f74ae945000 to 7f74ae947000
mlock03     0  TINFO  :  munlock from 7f74ae947000 to 7f74ae94b000
mlock03     0  TINFO  :  munlock from 7f74ae94b000 to 7f74ae96c000
mlock03     0  TINFO  :  munlock from 7f74aeb62000 to 7f74aeb65000
mlock03     0  TINFO  :  munlock from 7f74aeb68000 to 7f74aeb69000
mlock03     0  TINFO  :  munlock from 7f74aeb69000 to 7f74aeb6a000
mlock03     0  TINFO  :  munlock from 7f74aeb6a000 to 7f74aeb6c000
mlock03     0  TINFO  :  munlock from 7f74aeb6c000 to 7f74aeb6d000
mlock03     0  TINFO  :  munlock from 7f74aeb6d000 to 7f74aeb6f000
mlock03     0  TINFO  :  munlock from 7fff3d3a0000 to 7fff3d3a0000
mlock03     0  TINFO  :  munlock from 7fff3d3a0000 to 7fff3d3c1000
mlock03     0  TINFO  :  munlock from 7fff3d3fc000 to 7fff3d3fe000
mlock03     0  TINFO  :  munlock from 7fff3d3fe000 to 7fff3d400000
mlock03     0  TINFO  :  munlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  munlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  mlock from 400000 to 407000
mlock03     0  TINFO  :  mlock from 607000 to 608000
mlock03     0  TINFO  :  mlock from 608000 to 60c000
mlock03     0  TINFO  :  mlock from 9c9000 to 9ea000
mlock03     0  TINFO  :  mlock from 7f74ae59f000 to 7f74ae742000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from 7f74ae742000 to 7f74ae941000
mlock03     0  TINFO  :  mlock from 7f74ae941000 to 7f74ae945000
mlock03     0  TINFO  :  mlock from 7f74ae945000 to 7f74ae947000
mlock03     0  TINFO  :  mlock from 7f74ae947000 to 7f74ae94b000
mlock03     0  TINFO  :  mlock from 7f74ae94b000 to 7f74ae96c000
mlock03     0  TINFO  :  mlock from 7f74aeb62000 to 7f74aeb65000
mlock03     0  TINFO  :  mlock from 7f74aeb68000 to 7f74aeb6c000
mlock03     0  TINFO  :  mlock from 7f74aeb6c000 to 7f74aeb6d000
mlock03     0  TINFO  :  mlock from 7f74aeb6d000 to 7f74aeb6f000
mlock03     0  TINFO  :  mlock from 7fff3d3a0000 to 7fff3d3c1000
mlock03     0  TINFO  :  mlock from 7fff3d3fc000 to 7fff3d3fe000
mlock03     0  TINFO  :  mlock from 7fff3d3fe000 to 7fff3d400000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  mlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  mlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  munlock from 400000 to 407000
mlock03     0  TINFO  :  munlock from 607000 to 608000
mlock03     0  TINFO  :  munlock from 608000 to 60c000
mlock03     0  TINFO  :  munlock from 9c9000 to 9ea000
mlock03     0  TINFO  :  munlock from 7f74ae59f000 to 7f74ae742000
mlock03     0  TINFO  :  munlock from 7f74ae742000 to 7f74ae941000
mlock03     0  TINFO  :  munlock from 7f74ae941000 to 7f74ae945000
mlock03     0  TINFO  :  munlock from 7f74ae945000 to 7f74ae947000
mlock03     0  TINFO  :  munlock from 7f74ae947000 to 7f74ae94b000
mlock03     0  TINFO  :  munlock from 7f74ae94b000 to 7f74ae96c000
mlock03     0  TINFO  :  munlock from 7f74aeb62000 to 7f74aeb65000
mlock03     0  TINFO  :  munlock from 7f74aeb68000 to 7f74aeb69000
mlock03     0  TINFO  :  munlock from 7f74aeb69000 to 7f74aeb6a000
mlock03     0  TINFO  :  munlock from 7f74aeb6a000 to 7f74aeb6c000
mlock03     0  TINFO  :  munlock from 7f74aeb6c000 to 7f74aeb6d000
mlock03     0  TINFO  :  munlock from 7f74aeb6d000 to 7f74aeb6f000
mlock03     0  TINFO  :  munlock from 7fff3d3a0000 to 7fff3d3a0000
mlock03     0  TINFO  :  munlock from 7fff3d3a0000 to 7fff3d3c1000
mlock03     0  TINFO  :  munlock from 7fff3d3fc000 to 7fff3d3fe000
mlock03     0  TINFO  :  munlock from 7fff3d3fe000 to 7fff3d400000
mlock03     0  TINFO  :  munlock failed: errno=ENOMEM(12): Cannot allocate memory
mlock03     0  TINFO  :  munlock from ffffffffff600000 to ffffffffff601000
mlock03     0  TINFO  :  starting stack size is 132
mlock03     0  TINFO  :  final stack size is 132
mlock03     1  TPASS  :  stack size is not decreased.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=mlock04 stime=1411895593
cmdline="mlock04"
contacts=""
analysis=exit
<<<test_output>>>
mlock04     0  TINFO  :  locked 40960 bytes from 0x7f6cf7004000
mlock04     1  TPASS  :  test succeeded.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=qmm01 stime=1411895593
cmdline="mmap001 -m 1"
contacts=""
analysis=exit
<<<test_output>>>
mmap001     0  TINFO  :  mmap()ing file of 1 pages or 4096 bytes
mmap001     1  TPASS  :  mmap() completed successfully.
mmap001     0  TINFO  :  touching mmaped memory
mmap001     2  TPASS  :  we're still here, mmaped area must be good
mmap001     3  TPASS  :  synchronizing mmapped page passed
mmap001     4  TPASS  :  munmapping testfile.13908 successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=mmap01 stime=1411895593
cmdline="mmap01"
contacts=""
analysis=exit
<<<test_output>>>
mmap01      1  TPASS  :  Functionality of mmap() successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mmap02 stime=1411895593
cmdline="mmap02"
contacts=""
analysis=exit
<<<test_output>>>
mmap02      1  TPASS  :  Functionality of mmap() successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mmap03 stime=1411895593
cmdline="mmap03"
contacts=""
analysis=exit
<<<test_output>>>
mmap03      1  TPASS  :  mmap() functionality is correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mmap04 stime=1411895593
cmdline="mmap04"
contacts=""
analysis=exit
<<<test_output>>>
mmap04      1  TPASS  :  Functionality of mmap() successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mmap05 stime=1411895593
cmdline="mmap05"
contacts=""
analysis=exit
<<<test_output>>>
mmap05      1  TPASS  :  Got SIGSEGV as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mmap06 stime=1411895593
cmdline="mmap06"
contacts=""
analysis=exit
<<<test_output>>>
mmap06      1  TPASS  :  mmap failed with EACCES
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mmap07 stime=1411895593
cmdline="mmap07"
contacts=""
analysis=exit
<<<test_output>>>
mmap07      1  TPASS  :  mmap failed with EACCES
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mmap08 stime=1411895593
cmdline="mmap08"
contacts=""
analysis=exit
<<<test_output>>>
mmap08      1  TPASS  :  mmap failed with EBADF
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mmap09 stime=1411895593
cmdline="mmap09"
contacts=""
analysis=exit
<<<test_output>>>
mmap09      1  TPASS  :  ftruncate mmaped file to a smaller size
mmap09      2  TPASS  :  ftruncate mmaped file to a larger size
mmap09      3  TPASS  :  ftruncate mmaped file to 0 size
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mmap12 stime=1411895593
cmdline="mmap12"
contacts=""
analysis=exit
<<<test_output>>>
mmap12      1  TPASS  :  Functionality of mmap() successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mmap13 stime=1411895593
cmdline="mmap13"
contacts=""
analysis=exit
<<<test_output>>>
mmap13      1  TPASS  :  Got SIGBUS as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mmap14 stime=1411895593
cmdline="mmap14"
contacts=""
analysis=exit
<<<test_output>>>
mmap14      1  TPASS  :  Functionality of mmap() successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=mmap15 stime=1411895593
cmdline="mmap15"
contacts=""
analysis=exit
<<<test_output>>>
mmap15      1  TPASS  :  mmap into high region failed as expected: errno=ENOMEM(12): Cannot allocate memory
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=modify_ldt01 stime=1411895593
cmdline="modify_ldt01"
contacts=""
analysis=exit
<<<test_output>>>
modify_ldt01    1  TCONF  :  modify_ldt01.c:267: modify_ldt is available but not tested on the platform than __i386__
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=modify_ldt02 stime=1411895593
cmdline="modify_ldt02"
contacts=""
analysis=exit
<<<test_output>>>
modify_ldt02    1  TCONF  :  modify_ldt02.c:240: modify_ldt is available but not tested on the platform than __i386__
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=modify_ldt03 stime=1411895593
cmdline="modify_ldt03"
contacts=""
analysis=exit
<<<test_output>>>
modify_ldt03    1  TCONF  :  modify_ldt03.c:99: modify_ldt is available but not tested on the platform than __i386__
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mount01 stime=1411895593
cmdline="mount01"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
mount01     0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
mount01     0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
mount01     1  TPASS  :  mount(2) passed 
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mount02 stime=1411895593
cmdline="mount02"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
mount02     0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
mount02     0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
mount02     1  TPASS  :  mount() failed expectedly: TEST_ERRNO=ENODEV(19): No such device
mount02     2  TPASS  :  mount() failed expectedly: TEST_ERRNO=ENOTBLK(15): Block device required
mount02     3  TPASS  :  mount() failed expectedly: TEST_ERRNO=EBUSY(16): Device or resource busy
mount02     4  TPASS  :  mount() failed expectedly: TEST_ERRNO=EBUSY(16): Device or resource busy
mount02     5  TPASS  :  mount() failed expectedly: TEST_ERRNO=EINVAL(22): Invalid argument
mount02     6  TPASS  :  mount() failed expectedly: TEST_ERRNO=EINVAL(22): Invalid argument
mount02     7  TPASS  :  mount() failed expectedly: TEST_ERRNO=EINVAL(22): Invalid argument
mount02     8  TPASS  :  mount() failed expectedly: TEST_ERRNO=EFAULT(14): Bad address
mount02     9  TPASS  :  mount() failed expectedly: TEST_ERRNO=EFAULT(14): Bad address
mount02    10  TPASS  :  mount() failed expectedly: TEST_ERRNO=ENAMETOOLONG(36): File name too long
mount02    11  TPASS  :  mount() failed expectedly: TEST_ERRNO=ENOENT(2): No such file or directory
mount02    12  TPASS  :  mount() failed expectedly: TEST_ERRNO=ENOTDIR(20): Not a directory
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=mount03 stime=1411895593
cmdline="mount03"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
/bin/sh: /tmp/ltp-EAlAM7imVE/mou8ZI83Q/mntpoint/setuid_test: Permission denied
mount03     0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
mount03     0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
mount03     1  TPASS  :  mount(2) passed with rwflag = 1
mount03     2  TPASS  :  mount(2) passed with rwflag = 4
mount03     3  TPASS  :  mount(2) passed with rwflag = 8
mount03     4  TPASS  :  mount(2) passed with rwflag = 16
mount03     5  TPASS  :  mount(2) passed with rwflag = 1
mount03     6  TPASS  :  mount(2) passed with rwflag = 2
mount03     7  TPASS  :  mount(2) passed with rwflag = 1024
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=mount04 stime=1411895594
cmdline="mount04"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
mount04     0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
mount04     0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
mount04     1  TPASS  :  mount() failed expectedly: TEST_ERRNO=EPERM(1): Operation not permitted
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=mount05 stime=1411895594
cmdline="mount05"
contacts=""
analysis=exit
<<<test_output>>>
mount05     1  TPASS  :  bind mount is ok
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mount06 stime=1411895594
cmdline="mount06"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
mount06     0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
mount06     0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
mount06     1  TPASS  :  move mount is ok
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=move_pages01 stime=1411895594
cmdline="move_pages.sh 01"
contacts=""
analysis=exit
<<<test_output>>>
move_pages01    1  TCONF  :  move_pages_support.c:408: at least 2 allowed NUMA nodes are required
move_pages01    2  TCONF  :  move_pages_support.c:408: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=move_pages02 stime=1411895594
cmdline="move_pages.sh 02"
contacts=""
analysis=exit
<<<test_output>>>
move_pages02    1  TCONF  :  move_pages_support.c:408: at least 2 allowed NUMA nodes are required
move_pages02    2  TCONF  :  move_pages_support.c:408: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=move_pages03 stime=1411895594
cmdline="cd $LTPROOT/testcases/bin && chown root move_pages03 && chmod 04755 move_pages03 && move_pages.sh 03"
contacts=""
analysis=exit
<<<test_output>>>
move_pages03    1  TCONF  :  move_pages_support.c:408: at least 2 allowed NUMA nodes are required
move_pages03    2  TCONF  :  move_pages_support.c:408: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=move_pages04 stime=1411895594
cmdline="move_pages.sh 04"
contacts=""
analysis=exit
<<<test_output>>>
move_pages04    1  TCONF  :  move_pages_support.c:408: at least 2 allowed NUMA nodes are required
move_pages04    2  TCONF  :  move_pages_support.c:408: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=move_pages05 stime=1411895594
cmdline="move_pages.sh 05"
contacts=""
analysis=exit
<<<test_output>>>
move_pages05    1  TCONF  :  move_pages_support.c:408: at least 2 allowed NUMA nodes are required
move_pages05    2  TCONF  :  move_pages_support.c:408: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=move_pages06 stime=1411895594
cmdline="move_pages.sh 06"
contacts=""
analysis=exit
<<<test_output>>>
move_pages06    1  TCONF  :  move_pages_support.c:408: at least 2 allowed NUMA nodes are required
move_pages06    2  TCONF  :  move_pages_support.c:408: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=move_pages07 stime=1411895594
cmdline="move_pages.sh 07"
contacts=""
analysis=exit
<<<test_output>>>
move_pages07    1  TCONF  :  move_pages_support.c:408: at least 2 allowed NUMA nodes are required
move_pages07    2  TCONF  :  move_pages_support.c:408: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=move_pages08 stime=1411895594
cmdline="move_pages.sh 08"
contacts=""
analysis=exit
<<<test_output>>>
move_pages08    1  TCONF  :  move_pages08.c:142: move_pages: E2BIG was removed in commit 3140a227
move_pages08    2  TCONF  :  move_pages08.c:142: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=1 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=move_pages09 stime=1411895594
cmdline="move_pages.sh 09"
contacts=""
analysis=exit
<<<test_output>>>
move_pages09    1  TCONF  :  move_pages_support.c:408: at least 2 allowed NUMA nodes are required
move_pages09    2  TCONF  :  move_pages_support.c:408: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=move_pages10 stime=1411895594
cmdline="move_pages.sh 10"
contacts=""
analysis=exit
<<<test_output>>>
move_pages10    1  TCONF  :  move_pages_support.c:408: at least 2 allowed NUMA nodes are required
move_pages10    2  TCONF  :  move_pages_support.c:408: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=move_pages11 stime=1411895594
cmdline="cd $LTPROOT/testcases/bin && chown root move_pages11 && chmod 04755 move_pages11 && move_pages.sh 11"
contacts=""
analysis=exit
<<<test_output>>>
move_pages11    1  TCONF  :  move_pages_support.c:408: at least 2 allowed NUMA nodes are required
move_pages11    2  TCONF  :  move_pages_support.c:408: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mprotect01 stime=1411895594
cmdline="mprotect01"
contacts=""
analysis=exit
<<<test_output>>>
mprotect01    1  TPASS  :  expected failure - errno = 12 : Cannot allocate memory
mprotect01    2  TPASS  :  expected failure - errno = 22 : Invalid argument
mprotect01    3  TPASS  :  expected failure - errno = 13 : Permission denied
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mprotect02 stime=1411895594
cmdline="mprotect02"
contacts=""
analysis=exit
<<<test_output>>>
mprotect02    1  TPASS  :  got SIGSEGV as expected
mprotect02    2  TPASS  :  didn't get SIGSEGV
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mprotect03 stime=1411895594
cmdline="mprotect03"
contacts=""
analysis=exit
<<<test_output>>>
mprotect03    0  TINFO  :  received signal: SIGSEGV
mprotect03    1  TPASS  :  SIGSEGV generated as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mprotect04 stime=1411895594
cmdline="mprotect04"
contacts=""
analysis=exit
<<<test_output>>>
mprotect04    1  TPASS  :  test PROT_NONE for mprotect success
mprotect04    2  TPASS  :  test PROT_EXEC for mprotect success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mq_notify01 stime=1411895594
cmdline="mq_notify01"
contacts=""
analysis=exit
<<<test_output>>>
EXPECT: return value(ret)=(N >= 0) errno=0 (Success)
RESULT: return value(ret)=       0 errno=0 (Success)
EXPECT: return value(ret)=(N >= 0) errno=0 (Success)
RESULT: return value(ret)=       0 errno=0 (Success)
EXPECT: return value(ret)=(N >= 0) errno=0 (Success)
RESULT: return value(ret)=       0 errno=0 (Success)
EXPECT: return value(ret)=-1 errno=9 (Bad file descriptor)
RESULT: return value(ret)=-1 errno=9 (Bad file descriptor)
EXPECT: return value(ret)=-1 errno=9 (Bad file descriptor)
RESULT: return value(ret)=-1 errno=9 (Bad file descriptor)
EXPECT: return value(ret)=-1 errno=9 (Bad file descriptor)
RESULT: return value(ret)=-1 errno=9 (Bad file descriptor)
EXPECT: return value(ret)=-1 errno=16 (Device or resource busy)
RESULT: return value(ret)=-1 errno=16 (Device or resource busy)
mq_notify01    0  TINFO  :  (case00) START
mq_notify01    0  TINFO  :  (case00) END => OK
mq_notify01    0  TINFO  :  (case01) START
mq_notify01    0  TINFO  :  (case01) END => OK
mq_notify01    0  TINFO  :  (case02) START
mq_notify01    0  TINFO  :  (case02) END => OK
mq_notify01    0  TINFO  :  (case03) START
mq_notify01    0  TINFO  :  (case03) END => OK
mq_notify01    0  TINFO  :  (case04) START
mq_notify01    0  TINFO  :  (case04) END => OK
mq_notify01    0  TINFO  :  (case05) START
mq_notify01    0  TINFO  :  (case05) END => OK
mq_notify01    0  TINFO  :  (case06) START
mq_notify01    0  TINFO  :  (case06) END => OK
mq_notify01    1  TPASS  :  mq_notify call succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=mq_notify02 stime=1411895594
cmdline="mq_notify02"
contacts=""
analysis=exit
<<<test_output>>>
mq_notify02    1  TPASS  :  mq_notify failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
mq_notify02    2  TPASS  :  mq_notify failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mq_open01 stime=1411895594
cmdline="mq_open01"
contacts=""
analysis=exit
<<<test_output>>>
EXPECT: return value(ret)=(N >= 0) errno=0 (Success)
RESULT: return value(ret)=       7 errno=0 (Success)
mq_open01    0  TINFO  :  (case00) START
mq_open01    0  TINFO  :  mq_maxmsg E:20,	R:20
mq_open01    0  TINFO  :  mq_msgsize E:16384,	R:16384
mq_open01    0  TINFO  :  (case00) END => OK
mq_open01    1  TPASS  :  mq_open call succeeded 
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mq_timedreceive01 stime=1411895594
cmdline="mq_timedreceive01"
contacts=""
analysis=exit
<<<test_output>>>
EXPECT: return value(ret)=0 errno=0 (Success)
RESULT: return value(ret)=0 errno=0 (Success)
EXPECT: return value(ret)=1 errno=0 (Success)
RESULT: return value(ret)=1 errno=0 (Success)
EXPECT: return value(ret)=8192 errno=0 (Success)
RESULT: return value(ret)=8192 errno=0 (Success)
EXPECT: return value(ret)=1 errno=0 (Success)
RESULT: return value(ret)=1 errno=0 (Success)
EXPECT: return value(ret)=-1 errno=90 (Message too long)
RESULT: return value(ret)=-1 errno=90 (Message too long)
EXPECT: return value(ret)=-1 errno=9 (Bad file descriptor)
RESULT: return value(ret)=-1 errno=9 (Bad file descriptor)
EXPECT: return value(ret)=-1 errno=9 (Bad file descriptor)
RESULT: return value(ret)=-1 errno=9 (Bad file descriptor)
EXPECT: return value(ret)=-1 errno=9 (Bad file descriptor)
RESULT: return value(ret)=-1 errno=9 (Bad file descriptor)
EXPECT: return value(ret)=-1 errno=11 (Resource temporarily unavailable)
RESULT: return value(ret)=-1 errno=11 (Resource temporarily unavailable)
EXPECT: return value(ret)=-1 errno=22 (Invalid argument)
RESULT: return value(ret)=-1 errno=22 (Invalid argument)
EXPECT: return value(ret)=-1 errno=22 (Invalid argument)
RESULT: return value(ret)=-1 errno=22 (Invalid argument)
EXPECT: return value(ret)=-1 errno=22 (Invalid argument)
RESULT: return value(ret)=-1 errno=22 (Invalid argument)
EXPECT: return value(ret)=-1 errno=110 (Connection timed out)
RESULT: return value(ret)=-1 errno=110 (Connection timed out)
EXPECT: return value(ret)=-1 errno=4 (Interrupted system call)
RESULT: return value(ret)=-1 errno=4 (Interrupted system call)
mq_timedreceive01    0  TINFO  :  (case00) START
mq_timedreceive01    0  TINFO  :  (case00) END => OK
mq_timedreceive01    0  TINFO  :  (case01) START
mq_timedreceive01    0  TINFO  :  (case01) END => OK
mq_timedreceive01    0  TINFO  :  (case02) START
mq_timedreceive01    0  TINFO  :  (case02) END => OK
mq_timedreceive01    0  TINFO  :  (case03) START
mq_timedreceive01    0  TINFO  :  (case03) END => OK
mq_timedreceive01    0  TINFO  :  (case04) START
mq_timedreceive01    0  TINFO  :  (case04) END => OK
mq_timedreceive01    0  TINFO  :  (case05) START
mq_timedreceive01    0  TINFO  :  (case05) END => OK
mq_timedreceive01    0  TINFO  :  (case06) START
mq_timedreceive01    0  TINFO  :  (case06) END => OK
mq_timedreceive01    0  TINFO  :  (case07) START
mq_timedreceive01    0  TINFO  :  (case07) END => OK
mq_timedreceive01    0  TINFO  :  (case08) START
mq_timedreceive01    0  TINFO  :  (case08) END => OK
mq_timedreceive01    0  TINFO  :  (case09) START
mq_timedreceive01    0  TINFO  :  (case09) END => OK
mq_timedreceive01    0  TINFO  :  (case10) START
mq_timedreceive01    0  TINFO  :  (case10) END => OK
mq_timedreceive01    0  TINFO  :  (case11) START
mq_timedreceive01    0  TINFO  :  (case11) END => OK
mq_timedreceive01    0  TINFO  :  (case12) START
mq_timedreceive01    0  TINFO  :  (case12) END => OK
mq_timedreceive01    0  TINFO  :  (case13) START
mq_timedreceive01    0  TINFO  :  (case13) END => OK
mq_timedreceive01    1  TPASS  :  mq_timedreceive call succeeded
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mq_timedsend01 stime=1411895595
cmdline="mq_timedsend01"
contacts=""
analysis=exit
<<<test_output>>>
EXPECT: return value(ret)=(N >= 0) errno=0 (Success)
RESULT: return value(ret)=       0 errno=0 (Success)
EXPECT: return value(ret)=(N >= 0) errno=0 (Success)
RESULT: return value(ret)=       0 errno=0 (Success)
EXPECT: return value(ret)=(N >= 0) errno=0 (Success)
RESULT: return value(ret)=       0 errno=0 (Success)
EXPECT: return value(ret)=(N >= 0) errno=0 (Success)
RESULT: return value(ret)=       0 errno=0 (Success)
EXPECT: return value(ret)=-1 errno=90 (Message too long)
RESULT: return value(ret)=-1 errno=90 (Message too long)
EXPECT: return value(ret)=-1 errno=9 (Bad file descriptor)
RESULT: return value(ret)=-1 errno=9 (Bad file descriptor)
EXPECT: return value(ret)=-1 errno=9 (Bad file descriptor)
RESULT: return value(ret)=-1 errno=9 (Bad file descriptor)
EXPECT: return value(ret)=-1 errno=9 (Bad file descriptor)
RESULT: return value(ret)=-1 errno=9 (Bad file descriptor)
EXPECT: return value(ret)=-1 errno=11 (Resource temporarily unavailable)
RESULT: return value(ret)=-1 errno=11 (Resource temporarily unavailable)
EXPECT: return value(ret)=-1 errno=22 (Invalid argument)
RESULT: return value(ret)=-1 errno=22 (Invalid argument)
EXPECT: return value(ret)=-1 errno=22 (Invalid argument)
RESULT: return value(ret)=-1 errno=22 (Invalid argument)
EXPECT: return value(ret)=-1 errno=22 (Invalid argument)
RESULT: return value(ret)=-1 errno=22 (Invalid argument)
EXPECT: return value(ret)=-1 errno=22 (Invalid argument)
RESULT: return value(ret)=-1 errno=22 (Invalid argument)
EXPECT: return value(ret)=-1 errno=110 (Connection timed out)
RESULT: return value(ret)=-1 errno=110 (Connection timed out)
EXPECT: return value(ret)=-1 errno=4 (Interrupted system call)
RESULT: return value(ret)=-1 errno=4 (Interrupted system call)
mq_timedsend01    0  TINFO  :  (case00) START
mq_timedsend01    0  TINFO  :  (case00) END => OK
mq_timedsend01    0  TINFO  :  (case01) START
mq_timedsend01    0  TINFO  :  (case01) END => OK
mq_timedsend01    0  TINFO  :  (case02) START
mq_timedsend01    0  TINFO  :  (case02) END => OK
mq_timedsend01    0  TINFO  :  (case03) START
mq_timedsend01    0  TINFO  :  (case03) END => OK
mq_timedsend01    0  TINFO  :  (case04) START
mq_timedsend01    0  TINFO  :  (case04) END => OK
mq_timedsend01    0  TINFO  :  (case05) START
mq_timedsend01    0  TINFO  :  (case05) END => OK
mq_timedsend01    0  TINFO  :  (case06) START
mq_timedsend01    0  TINFO  :  (case06) END => OK
mq_timedsend01    0  TINFO  :  (case07) START
mq_timedsend01    0  TINFO  :  (case07) END => OK
mq_timedsend01    0  TINFO  :  (case08) START
mq_timedsend01    0  TINFO  :  (case08) END => OK
mq_timedsend01    0  TINFO  :  (case09) START
mq_timedsend01    0  TINFO  :  (case09) END => OK
mq_timedsend01    0  TINFO  :  (case10) START
mq_timedsend01    0  TINFO  :  (case10) END => OK
mq_timedsend01    0  TINFO  :  (case11) START
mq_timedsend01    0  TINFO  :  (case11) END => OK
mq_timedsend01    0  TINFO  :  (case12) START
mq_timedsend01    0  TINFO  :  (case12) END => OK
mq_timedsend01    0  TINFO  :  (case13) START
mq_timedsend01    0  TINFO  :  (case13) END => OK
mq_timedsend01    0  TINFO  :  (case14) START
mq_timedsend01    0  TINFO  :  (case14) END => OK
mq_timedsend01    1  TPASS  :  mq_timedsend call succeeded
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mq_unlink01 stime=1411895596
cmdline="mq_unlink01"
contacts=""
analysis=exit
<<<test_output>>>
EXPECT: return value(ret)=(N >= 0) errno=0 (Success)
RESULT: return value(ret)=       0 errno=0 (Success)
EXPECT: return value(ret)=-1 errno=13 (Permission denied)
RESULT: return value(ret)=-1 errno=13 (Permission denied)
EXPECT: return value(ret)=-1 errno=2 (No such file or directory)
RESULT: return value(ret)=-1 errno=2 (No such file or directory)
EXPECT: return value(ret)=-1 errno=36 (File name too long)
RESULT: return value(ret)=-1 errno=36 (File name too long)
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mremap01 stime=1411895596
cmdline="mremap01"
contacts=""
analysis=exit
<<<test_output>>>
mremap01    1  TPASS  :  Functionality of mremap() is correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=mremap02 stime=1411895596
cmdline="mremap02"
contacts=""
analysis=exit
<<<test_output>>>
mremap02    1  TPASS  :  mremap() Failed, 'invalid argument specified' - errno 22
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mremap03 stime=1411895596
cmdline="mremap03"
contacts=""
analysis=exit
<<<test_output>>>
mremap03    1  TPASS  :  mremap() Fails, 'old region not mapped', errno 14
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mremap04 stime=1411895596
cmdline="mremap04"
contacts=""
analysis=exit
<<<test_output>>>
mremap04    1  TPASS  :  mremap() failed, 'MREMAP_MAYMOVE flag unset', errno 12
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mremap05 stime=1411895596
cmdline="mremap05"
contacts=""
analysis=exit
<<<test_output>>>
mremap05    1  TPASS  :  MREMAP_FIXED requires MREMAP_MAYMOVE
mremap05    2  TPASS  :  new_addr has to be page aligned
mremap05    3  TPASS  :  old/new area must not overlap
mremap05    4  TPASS  :  mremap #1
mremap05    5  TPASS  :  mremap #1 value OK
mremap05    6  TPASS  :  mremap #2
mremap05    7  TPASS  :  mremap #2 value OK
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msgctl01 stime=1411895596
cmdline="msgctl01"
contacts=""
analysis=exit
<<<test_output>>>
msgctl01    1  TPASS  :  qs_buf.msg_qbytes is a positive value
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msgctl02 stime=1411895596
cmdline="msgctl02"
contacts=""
analysis=exit
<<<test_output>>>
msgctl02    1  TPASS  :  qs_buf.msg_qbytes is the new value - 16383
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msgctl03 stime=1411895596
cmdline="msgctl03"
contacts=""
analysis=exit
<<<test_output>>>
msgctl03    1  TPASS  :  The queue is gone
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msgctl04 stime=1411895596
cmdline="msgctl04"
contacts=""
analysis=exit
<<<test_output>>>
msgctl04    1  TPASS  :  expected failure: TEST_ERRNO=EACCES(13): Permission denied
msgctl04    2  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
msgctl04    3  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
msgctl04    4  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
msgctl04    5  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
msgctl04    6  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msgctl05 stime=1411895596
cmdline="msgctl05"
contacts=""
analysis=exit
<<<test_output>>>
msgctl05    1  TPASS  :  expected error = 1 : Operation not permitted
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msgctl06 stime=1411895596
cmdline="msgctl06"
contacts=""
analysis=exit
<<<test_output>>>
msgctl06    1  TPASS  :  msgctl06 ran successfully!
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msgctl07 stime=1411895596
cmdline="msgctl07"
contacts=""
analysis=exit
<<<test_output>>>
msgctl07    1  TPASS  :  msgctl07 ran successfully!
<<<execution_status>>>
initiation_status="ok"
duration=20 termination_type=exited termination_id=0 corefile=no
cutime=2001 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msgctl08 stime=1411895616
cmdline="msgctl08"
contacts=""
analysis=exit
<<<test_output>>>
msgctl08    1  TPASS  :  msgctl08 ran successfully!
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=43 cstime=194
<<<test_end>>>
<<<test_start>>>
tag=msgctl09 stime=1411895616
cmdline="msgctl09"
contacts=""
analysis=exit
<<<test_output>>>
msgctl09    1  TPASS  :  msgctl09 ran successfully!
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=3 cstime=50
<<<test_end>>>
<<<test_start>>>
tag=msgctl10 stime=1411895616
cmdline="msgctl10"
contacts=""
analysis=exit
<<<test_output>>>
msgctl10    1  TPASS  :  msgctl10 ran successfully!
<<<execution_status>>>
initiation_status="ok"
duration=19 termination_type=exited termination_id=0 corefile=no
cutime=2749 cstime=11969
<<<test_end>>>
<<<test_start>>>
tag=msgctl11 stime=1411895635
cmdline="msgctl11"
contacts=""
analysis=exit
<<<test_output>>>
msgctl11    0  TINFO  :  Found 11911 available message queues
msgctl11    0  TINFO  :  Using upto 16312 pids
msgctl11    1  TPASS  :  msgctl11 ran successfully!
<<<execution_status>>>
initiation_status="ok"
duration=6 termination_type=exited termination_id=0 corefile=no
cutime=453 cstime=4315
<<<test_end>>>
<<<test_start>>>
tag=msgctl12 stime=1411895641
cmdline="msgctl12"
contacts=""
analysis=exit
<<<test_output>>>
msgctl12    1  TPASS  :  msgctl() test IPC_INFO succeeded
msgctl12    2  TPASS  :  msgctl() test MSG_INFO succeeded
msgctl12    3  TPASS  :  msgctl() test MSG_STAT succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msgctl13 stime=1411895641
cmdline="msgctl13"
contacts=""
analysis=exit
<<<test_output>>>
msgctl13    1  TPASS  :  msgctl() test IPC_RMID succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msgget01 stime=1411895641
cmdline="msgget01"
contacts=""
analysis=exit
<<<test_output>>>
msgget01    1  TPASS  :  message received = message sent
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msgget02 stime=1411895641
cmdline="msgget02"
contacts=""
analysis=exit
<<<test_output>>>
msgget02    1  TPASS  :  expected failure - errno = 17 : File exists
msgget02    2  TPASS  :  expected failure - errno = 2 : No such file or directory
msgget02    3  TPASS  :  expected failure - errno = 2 : No such file or directory
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msgget03 stime=1411895641
cmdline="msgget03"
contacts=""
analysis=exit
<<<test_output>>>
msgget03    1  TPASS  :  expected failure - errno = 0 : Success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=64
<<<test_end>>>
<<<test_start>>>
tag=msgget04 stime=1411895641
cmdline="msgget04"
contacts=""
analysis=exit
<<<test_output>>>
msgget04    1  TPASS  :  expected failure - errno = 13 : Permission denied
msgget04    2  TPASS  :  expected failure - errno = 13 : Permission denied
msgget04    3  TPASS  :  expected failure - errno = 13 : Permission denied
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msgrcv01 stime=1411895641
cmdline="msgrcv01"
contacts=""
analysis=exit
<<<test_output>>>
msgrcv01    1  TPASS  :  message received = message sent
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msgrcv02 stime=1411895641
cmdline="msgrcv02"
contacts=""
analysis=exit
<<<test_output>>>
msgrcv02    1  TPASS  :  expected failure - errno = 13 : Permission denied
msgrcv02    2  TPASS  :  expected failure - errno = 14 : Bad address
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msgrcv03 stime=1411895641
cmdline="msgrcv03"
contacts=""
analysis=exit
<<<test_output>>>
msgrcv03    1  TPASS  :  expected failure - errno = 22 : Invalid argument
msgrcv03    2  TPASS  :  expected failure - errno = 22 : Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msgrcv04 stime=1411895641
cmdline="msgrcv04"
contacts=""
analysis=exit
<<<test_output>>>
msgrcv04    1  TPASS  :  expected failure - errno = 7 : Argument list too long
msgrcv04    2  TPASS  :  expected failure - errno = 42 : No message of desired type
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msgrcv05 stime=1411895641
cmdline="msgrcv05"
contacts=""
analysis=exit
<<<test_output>>>
msgrcv05    1  TPASS  :  got EINTR as expected
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msgrcv06 stime=1411895642
cmdline="msgrcv06"
contacts=""
analysis=exit
<<<test_output>>>
msgrcv06    1  TPASS  :  expected failure - errno = 43 : Identifier removed
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msgrcv07 stime=1411895643
cmdline="msgrcv07"
contacts=""
analysis=exit
<<<test_output>>>
msgrcv07    1  TPASS  :  test MSG_EXCEPT success
msgrcv07    2  TPASS  :  test MSG_NOERROR success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=msgsnd01 stime=1411895643
cmdline="msgsnd01"
contacts=""
analysis=exit
<<<test_output>>>
msgsnd01    1  TPASS  :  queue bytes = MSGSIZE and queue messages = 1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msgsnd02 stime=1411895643
cmdline="msgsnd02"
contacts=""
analysis=exit
<<<test_output>>>
msgsnd02    1  TPASS  :  expected failure - errno = 13 : Permission denied
msgsnd02    2  TPASS  :  expected failure - errno = 14 : Bad address
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msgsnd03 stime=1411895643
cmdline="msgsnd03"
contacts=""
analysis=exit
<<<test_output>>>
msgsnd03    1  TPASS  :  expected failure - errno = 22 : Invalid argument
msgsnd03    2  TPASS  :  expected failure - errno = 22 : Invalid argument
msgsnd03    3  TPASS  :  expected failure - errno = 22 : Invalid argument
msgsnd03    4  TPASS  :  expected failure - errno = 22 : Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msgsnd04 stime=1411895643
cmdline="msgsnd04"
contacts=""
analysis=exit
<<<test_output>>>
msgsnd04    1  TPASS  :  expected failure - errno = 11 : Resource temporarily unavailable
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msgsnd05 stime=1411895643
cmdline="msgsnd05"
contacts=""
analysis=exit
<<<test_output>>>
msgsnd05    1  TPASS  :  expected failure - errno = 4 : Interrupted system call
<<<execution_status>>>
initiation_status="ok"
duration=2 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msgsnd06 stime=1411895645
cmdline="msgsnd06"
contacts=""
analysis=exit
<<<test_output>>>
msgsnd06    1  TPASS  :  expected failure - errno = 43 : Identifier removed
<<<execution_status>>>
initiation_status="ok"
duration=2 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msync01 stime=1411895647
cmdline="msync01"
contacts=""
analysis=exit
<<<test_output>>>
msync01     1  TPASS  :  Functionality of msync() successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msync02 stime=1411895647
cmdline="msync02"
contacts=""
analysis=exit
<<<test_output>>>
msync02     1  TPASS  :  Functionality of msync successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=msync03 stime=1411895647
cmdline="msync03"
contacts=""
analysis=exit
<<<test_output>>>
msync03     1  TPASS  :  msync failed as expected: TEST_ERRNO=EBUSY(16): Device or resource busy
msync03     2  TPASS  :  msync failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
msync03     3  TPASS  :  msync failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
msync03     4  TPASS  :  msync failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
msync03     5  TPASS  :  msync failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
msync03     6  TPASS  :  msync failed as expected: TEST_ERRNO=ENOMEM(12): Cannot allocate memory
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=munlock01 stime=1411895647
cmdline="munlock01"
contacts=""
analysis=exit
<<<test_output>>>
munlock01    1  TPASS  :  test 0 passed length = 1
munlock01    2  TPASS  :  test 1 passed length = 1024
munlock01    3  TPASS  :  test 2 passed length = 1048576
munlock01    4  TPASS  :  test 3 passed length = 10485760
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=munlock02 stime=1411895647
cmdline="munlock02"
contacts=""
analysis=exit
<<<test_output>>>
munlock02    1  TPASS  :  expected failure - errno = 12 : Cannot allocate memory
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=munlockall01 stime=1411895647
cmdline="munlockall01"
contacts=""
analysis=exit
<<<test_output>>>
munlockall01    1  TPASS  :  munlockall() passed with return=0 
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=munlockall02 stime=1411895647
cmdline="munlockall02"
contacts=""
analysis=exit
<<<test_output>>>
munlockall02    1  TCONF  :  munlockall02.c:114: munlockall() failed to produce expected errno :1 Got : 0, Success. ***Some distros, such as Red Hat Enterprise Linux, support non-superuser munlockall calls.***
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=munmap01 stime=1411895647
cmdline="munmap01"
contacts=""
analysis=exit
<<<test_output>>>
munmap01    1  TPASS  :  Functionality of munmap() successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=munmap02 stime=1411895647
cmdline="munmap02"
contacts=""
analysis=exit
<<<test_output>>>
munmap02    1  TPASS  :  Functionality of munmap() successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=munmap03 stime=1411895647
cmdline="munmap03"
contacts=""
analysis=exit
<<<test_output>>>
munmap03    1  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
munmap03    2  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
munmap03    3  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=nanosleep01 stime=1411895647
cmdline="nanosleep01"
contacts=""
analysis=exit
<<<test_output>>>
nanosleep01    1  TPASS  :  nanosleep functionality is correct
<<<execution_status>>>
initiation_status="ok"
duration=2 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=nanosleep02 stime=1411895649
cmdline="nanosleep02"
contacts=""
analysis=exit
<<<test_output>>>
nanosleep02    0  TINFO  :  call succeeded
nanosleep02    1  TPASS  :  Functionality of nanosleep() is correct
<<<execution_status>>>
initiation_status="ok"
duration=6 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=nanosleep03 stime=1411895655
cmdline="nanosleep03"
contacts=""
analysis=exit
<<<test_output>>>
nanosleep03    1  TPASS  :  nanosleep() failed, interrupted by signal (4) as expected
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=nanosleep04 stime=1411895656
cmdline="nanosleep04"
contacts=""
analysis=exit
<<<test_output>>>
nanosleep04    1  TPASS  :  nanosleep() failed, when provided invalid pause time, with expected errno: 22
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=nftw01 stime=1411895656
cmdline="nftw01"
contacts=""
analysis=exit
<<<test_output>>>
nftw01      1  TPASS  :  Test block 0
nftw01      2  TPASS  :  Test block 1
nftw01      3  TPASS  :  Test block 2
nftw01      4  TPASS  :  Test block 3
nftw01      5  TPASS  :  Test block 4
nftw01      6  TPASS  :  Test block 5
nftw01      7  TPASS  :  Test block 6
nftw01      8  TPASS  :  Test block 7
nftw01      9  TPASS  :  Test block 8
nftw01     10  TPASS  :  Test block 9
nftw01     11  TPASS  :  Test block 10
nftw01     12  TPASS  :  Test block 11
nftw01     13  TPASS  :  Test block 12
nftw01     14  TPASS  :  Test block 13
nftw01     15  TPASS  :  Test block 14
nftw01     16  TPASS  :  Test block 15
nftw01     17  TPASS  :  Test block 16
nftw01     18  TPASS  :  Test block 17
nftw01     19  TPASS  :  Test block 18
nftw01     20  TPASS  :  Test block 19
nftw01     21  TPASS  :  Test block 20
nftw01     22  TPASS  :  Test block 21
nftw01     23  TPASS  :  Test block 22
nftw01     24  TPASS  :  Test block 23
nftw01     25  TPASS  :  Test block 24
nftw01     26  TPASS  :  Test block 25
nftw01     27  TPASS  :  Test block 26
nftw01     28  TPASS  :  Test block 27
nftw01     29  TPASS  :  Test block 28
nftw01     30  TPASS  :  Test block 29
nftw01     31  TPASS  :  Test passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=nftw6401 stime=1411895656
cmdline="nftw6401"
contacts=""
analysis=exit
<<<test_output>>>
nftw6401    1  TPASS  :  Test block 0
nftw6401    2  TPASS  :  Test block 1
nftw6401    3  TPASS  :  Test block 2
nftw6401    4  TPASS  :  Test block 3
nftw6401    5  TPASS  :  Test block 4
nftw6401    6  TPASS  :  Test block 5
nftw6401    7  TPASS  :  Test block 6
nftw6401    8  TPASS  :  Test block 7
nftw6401    9  TPASS  :  Test block 8
nftw6401   10  TPASS  :  Test block 9
nftw6401   11  TPASS  :  Test block 10
nftw6401   12  TPASS  :  Test block 11
nftw6401   13  TPASS  :  Test block 12
nftw6401   14  TPASS  :  Test block 13
nftw6401   15  TPASS  :  Test block 14
nftw6401   16  TPASS  :  Test block 15
nftw6401   17  TPASS  :  Test block 16
nftw6401   18  TPASS  :  Test block 17
nftw6401   19  TPASS  :  Test block 18
nftw6401   20  TPASS  :  Test block 19
nftw6401   21  TPASS  :  Test block 20
nftw6401   22  TPASS  :  Test block 21
nftw6401   23  TPASS  :  Test block 22
nftw6401   24  TPASS  :  Test block 23
nftw6401   25  TPASS  :  Test block 24
nftw6401   26  TPASS  :  Test block 25
nftw6401   27  TPASS  :  Test block 26
nftw6401   28  TPASS  :  Test block 27
nftw6401   29  TPASS  :  Test block 28
nftw6401   30  TPASS  :  Test block 29
nftw6401   31  TPASS  :  Test passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=nice01 stime=1411895656
cmdline="nice01"
contacts=""
analysis=exit
<<<test_output>>>
nice01      1  TPASS  :  Functionality of nice(-12) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=nice02 stime=1411895656
cmdline="nice02"
contacts=""
analysis=exit
<<<test_output>>>
nice02      1  TPASS  :  Functionality of nice(50) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=nice03 stime=1411895656
cmdline="nice03"
contacts=""
analysis=exit
<<<test_output>>>
nice03      1  TPASS  :  Functionality of nice(2) is correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=nice04 stime=1411895656
cmdline="nice04"
contacts=""
analysis=exit
<<<test_output>>>
nice04      1  TPASS  :  nice(2) returned -1 for Non-root cannot specify higher priority
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=nice05 stime=1411895656
cmdline="nice05"
contacts=""
analysis=exit
<<<test_output>>>
nice05      1  TPASS  :  nice(0) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=open01 stime=1411895656
cmdline="open01"
contacts=""
analysis=exit
<<<test_output>>>
open01      1  TPASS  :  Save text bit not cleared as expected
open01      2  TPASS  :  directory bit is set as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=open01A stime=1411895656
cmdline="symlink01 -T open01"
contacts=""
analysis=exit
<<<test_output>>>
open01      1  TPASS  :  open(2) with (O_CREAT | O_RDWR) to create object file through symbolic link file and all writes, reads, and lseeks are ok
open01      2  TPASS  :  open(2) with O_RDWR of existing  object file through symbolic link file and all writes, reads, and lseeks are ok
open01      3  TPASS  :  open(2) with (O_CREAT | O_EXCL) error  is caught when creating object file through symbolic link file
open01      4  TPASS  :  open(2) error with O_RDWR is caught when processing symbolic link file which points at no object file
open01      5  TPASS  :  Nested symbolic link access condition caught.  ELOOP is returned
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=open02 stime=1411895656
cmdline="open02"
contacts=""
analysis=exit
<<<test_output>>>
open02      1  TPASS  :  open() failed as expected: TEST_ERRNO=ENOENT(2): No such file or directory
open02      2  TPASS  :  open() failed as expected: TEST_ERRNO=EPERM(1): Operation not permitted
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=open03 stime=1411895656
cmdline="open03"
contacts=""
analysis=exit
<<<test_output>>>
open03      1  TPASS  :  open(tfile_29166, O_RDWR|O_CREAT,0700) returned 7
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=open04 stime=1411895656
cmdline="open04"
contacts=""
analysis=exit
<<<test_output>>>
open04      1  TPASS  :  call returned expected EMFILE error
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=open05 stime=1411895656
cmdline="open05"
contacts=""
analysis=exit
<<<test_output>>>
open05      1  TPASS  :  open returned expected EACCES error
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=open06 stime=1411895656
cmdline="open06"
contacts=""
analysis=exit
<<<test_output>>>
open06      1  TPASS  :  call returned expected ENXIO error
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=open07 stime=1411895656
cmdline="open07"
contacts=""
analysis=exit
<<<test_output>>>
open07      1  TPASS  :  open returned expected ELOOP error
open07      2  TPASS  :  open returned expected ELOOP error
open07      3  TPASS  :  open returned expected ELOOP error
open07      4  TPASS  :  open returned expected ELOOP error
open07      5  TPASS  :  open succeeded as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=open08 stime=1411895656
cmdline="open08"
contacts=""
analysis=exit
<<<test_output>>>
open08      1  TPASS  :  expected failure - errno = 17 : File exists
open08      2  TPASS  :  expected failure - errno = 21 : Is a directory
open08      3  TPASS  :  expected failure - errno = 20 : Not a directory
open08      4  TPASS  :  expected failure - errno = 36 : File name too long
open08      5  TPASS  :  expected failure - errno = 13 : Permission denied
open08      6  TPASS  :  expected failure - errno = 14 : Bad address
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=open09 stime=1411895656
cmdline="open09"
contacts=""
analysis=exit
<<<test_output>>>
open09      1  TPASS  :  Test passed in O_WRONLY.
open09      2  TPASS  :  Test passed in O_RDONLY.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=open10 stime=1411895656
cmdline="open10"
contacts=""
analysis=exit
<<<test_output>>>
open10      1  TPASS  :  Test passed in block0.
open10      2  TPASS  :  Test passed in block1.
open10      3  TPASS  :  Test passed in block2.
open10      4  TPASS  :  Test passed in block3.
open10      5  TPASS  :  Test passed.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=open11 stime=1411895656
cmdline="open11"
contacts=""
analysis=exit
<<<test_output>>>
open11      1  TPASS  :  Open regular file O_RDONLY
open11      2  TPASS  :  Open regular file O_WRONLY
open11      3  TPASS  :  Open regular file O_RDWR
open11      4  TPASS  :  Open regular file O_RDWR | O_SYNC
open11      5  TPASS  :  Open regular file O_RDWR | O_TRUNC
open11      6  TPASS  :  Open dir O_RDONLY
open11      7  TPASS  :  Open dir O_RDWR, expect EISDIR
open11      8  TPASS  :  Open regular file O_DIRECTORY, expect ENOTDIR
open11      9  TPASS  :  Open hard link file O_RDONLY
open11     10  TPASS  :  Open hard link file O_WRONLY
open11     11  TPASS  :  Open hard link file O_RDWR
open11     12  TPASS  :  Open sym link file O_RDONLY
open11     13  TPASS  :  Open sym link file O_WRONLY
open11     14  TPASS  :  Open sym link file O_RDWR
open11     15  TPASS  :  Open sym link dir O_RDONLY
open11     16  TPASS  :  Open sym link dir O_WRONLY, expect EISDIR
open11     17  TPASS  :  Open sym link dir O_RDWR, expect EISDIR
open11     18  TFAIL  :  open11.c:353: Open device special file O_RDONLY - expected errno 0 - Got: TEST_ERRNO=EACCES(13): Permission denied
open11     19  TFAIL  :  open11.c:353: Open device special file O_WRONLY - expected errno 0 - Got: TEST_ERRNO=EACCES(13): Permission denied
open11     20  TFAIL  :  open11.c:353: Open device special file O_RDWR - expected errno 0 - Got: TEST_ERRNO=EACCES(13): Permission denied
open11     21  TPASS  :  Open non-existing regular file in existing dir
open11     22  TPASS  :  Open link file O_RDONLY | O_CREAT
open11     23  TPASS  :  Open symlink file O_RDONLY | O_CREAT
open11     24  TPASS  :  Open regular file O_RDONLY | O_CREAT
open11     25  TPASS  :  Open symlink dir O_RDONLY | O_CREAT, expect EISDIR
open11     26  TPASS  :  Open dir O_RDONLY | O_CREAT, expect EISDIR
open11     27  TPASS  :  Open regular file O_RDONLY | O_TRUNC, behaviour is undefined but should not oops or hang
open11     28  TPASS  :  Open regular file(non-empty) O_RDONLY | O_TRUNC, behaviour is undefined but should not oops or hang
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=1 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=open12 stime=1411895656
cmdline="open12"
contacts=""
analysis=exit
<<<test_output>>>
open12      1  TPASS  :  test O_APPEND for open success
open12      2  TCONF  :  open12.c:123: test O_NOATIME flag for open needs filesystems which is mounted without noatime and relatime
open12      3  TPASS  :  test O_CLOEXEC for open success
open12      4  TPASS  :  test O_LARGEFILE for open success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=openat01 stime=1411895656
cmdline="openat01"
contacts=""
analysis=exit
<<<test_output>>>
openat01    1  TPASS  :  openat() returned 9: TEST_ERRNO=SUCCESS(0): Success
openat01    2  TPASS  :  openat() returned 9: TEST_ERRNO=SUCCESS(0): Success
openat01    3  TPASS  :  openat() returned -1: TEST_ERRNO=ENOTDIR(20): Not a directory
openat01    4  TPASS  :  openat() returned -1: TEST_ERRNO=EBADF(9): Bad file descriptor
openat01    5  TPASS  :  openat() returned 9: TEST_ERRNO=SUCCESS(0): Success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=openat02 stime=1411895656
cmdline="openat02"
contacts=""
analysis=exit
<<<test_output>>>
openat02    1  TPASS  :  test O_APPEND for openat success
openat02    2  TPASS  :  test O_CLOEXEC for openat success
openat02    3  TPASS  :  test O_LARGEFILE for openat success
openat02    4  TCONF  :  openat02.c:242: test O_NOATIME flag for openat needs filesystems which are mounted without noatime and relatime
openat02    5  TPASS  :  test O_NOFOLLOW for openat success
openat02    6  TPASS  :  test O_TRUNC for openat success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mincore01 stime=1411895656
cmdline="mincore01"
contacts=""
analysis=exit
<<<test_output>>>
mincore01    1  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
mincore01    2  TPASS  :  failed as expected: TEST_ERRNO=EFAULT(14): Bad address
mincore01    3  TPASS  :  failed as expected: TEST_ERRNO=ENOMEM(12): Cannot allocate memory
mincore01    4  TPASS  :  failed as expected: TEST_ERRNO=ENOMEM(12): Cannot allocate memory
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=mincore02 stime=1411895656
cmdline="mincore02"
contacts=""
analysis=exit
<<<test_output>>>
mincore02    1  TPASS  :  4 pages locked, 4 pages in-core
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=madvise01 stime=1411895656
cmdline="madvise01"
contacts=""
analysis=exit
<<<test_output>>>
madvise01    1  TPASS  :  madvise test for MADV_NORMAL PASSED
madvise01    2  TPASS  :  madvise test for MADV_RANDOM PASSED
madvise01    3  TPASS  :  madvise test for MADV_SEQUENTIAL PASSED
madvise01    4  TPASS  :  madvise test for MADV_WILLNEED PASSED
madvise01    5  TPASS  :  madvise test for MADV_DONTNEED PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=madvise02 stime=1411895656
cmdline="madvise02"
contacts=""
analysis=exit
<<<test_output>>>
madvise02    1  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
madvise02    2  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
madvise02    3  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
madvise02    4  TCONF  :  madvise02.c:225: kernel configured with CONFIG_KSM, skip EINVAL test for MADV_MERGEABLE.
madvise02    5  TCONF  :  madvise02.c:246: kernel configured with CONFIG_KSM, skip EINVAL test for MADV_UNMERGEABLE.
madvise02    6  TPASS  :  failed as expected: TEST_ERRNO=ENOMEM(12): Cannot allocate memory
madvise02    7  TPASS  :  madvise succeeded as expected, see kernel commit 1998cc0 for details.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=madvise03 stime=1411895656
cmdline="madvise03"
contacts=""
analysis=exit
<<<test_output>>>
madvise03    1  TPASS  :  madvise test for MADV_REMOVE PASSED
madvise03    2  TPASS  :  madvise test for MADV_DONTFORK PASSED
madvise03    3  TPASS  :  madvise test for MADV_DOFORK PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=madvise04 stime=1411895656
cmdline="madvise04"
contacts=""
analysis=exit
<<<test_output>>>
madvise04    1  TPASS  :  madvise test for MADV_DONTDUMP PASSED
madvise04    2  TPASS  :  madvise test for MADV_DODUMP PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=madvise05 stime=1411895656
cmdline="madvise05"
contacts=""
analysis=exit
<<<test_output>>>
madvise05    1  TPASS  :  issue has not been reproduced
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=newuname01 stime=1411895656
cmdline="newuname01"
contacts=""
analysis=exit
<<<test_output>>>
newuname01    1  TPASS  :  newuname call succeed: return value = 0 
newuname01    0  TINFO  :  This system is Linux
newuname01    0  TINFO  :  The system infomation is :
newuname01    0  TINFO  :  System is Linux on x86_64 hardware
newuname01    0  TINFO  :  Nodename is nhm-white
newuname01    0  TINFO  :  Version is 3.17.0-rc6-dirty, #1 SMP Thu Sep 25 13:22:59 CST 2014
newuname01    0  TINFO  :  Domainname is (none) 
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pathconf01 stime=1411895656
cmdline="pathconf01"
contacts=""
analysis=exit
<<<test_output>>>
pathconf01    1  TPASS  :  pathconf(/tmp, _PC_LINK_MAX) returned 127
pathconf01    2  TPASS  :  pathconf(/tmp, _PC_NAME_MAX) returned 255
pathconf01    3  TPASS  :  pathconf(/tmp, _PC_PATH_MAX) returned 4096
pathconf01    4  TPASS  :  pathconf(/tmp, _PC_PIPE_BUF) returned 4096
pathconf01    5  TPASS  :  pathconf(/tmp, _PC_CHOWN_RESTRICTED) returned 1
pathconf01    6  TPASS  :  pathconf(/tmp, _PC_NO_TRUNC) returned 1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pause01 stime=1411895656
cmdline="pause01"
contacts=""
analysis=exit
<<<test_output>>>
pause01     1  TPASS  :  pause() returned -1
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pause02 stime=1411895657
cmdline="pause02"
contacts=""
analysis=exit
<<<test_output>>>
pause02     1  TPASS  :  pause was interrupted correctly
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pause03 stime=1411895657
cmdline="pause03"
contacts=""
analysis=exit
<<<test_output>>>
pause03     1  TPASS  :  Functionality of pause() is correct
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pipe01 stime=1411895658
cmdline="pipe01"
contacts=""
analysis=exit
<<<test_output>>>
pipe01      1  TPASS  :  pipe() functionality is correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pipe02 stime=1411895658
cmdline="pipe02"
contacts=""
analysis=exit
<<<test_output>>>
pipe02      1  TPASS  :  child process returned expected SIGPIPE
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pipe03 stime=1411895658
cmdline="pipe03"
contacts=""
analysis=exit
<<<test_output>>>
pipe03      1  TPASS  :  expected failure writing to read end of pipe
pipe03      2  TPASS  :  expected failure reading from write end of pipe
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pipe04 stime=1411895658
cmdline="pipe04"
contacts=""
analysis=exit
<<<test_output>>>
pipe04      1  TPASS  :  Child 1 killed while writing to a pipe
pipe04      2  TPASS  :  Child 2 killed while writing to a pipe
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pipe05 stime=1411895658
cmdline="pipe05"
contacts=""
analysis=exit
<<<test_output>>>
pipe05      1  TPASS  :  expected failure - errno = 14 : Bad address
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pipe06 stime=1411895658
cmdline="pipe06"
contacts=""
analysis=exit
<<<test_output>>>
pipe06      1  TPASS  :  failed with EMFILE
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pipe07 stime=1411895658
cmdline="pipe07"
contacts=""
analysis=exit
<<<test_output>>>
pipe07      0  TINFO  :  Found 7 files open
pipe07      1  TPASS  :  Opened 508 pipes
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=pipe08 stime=1411895658
cmdline="pipe08"
contacts=""
analysis=exit
<<<test_output>>>
pipe08      1  TPASS  :  got expected SIGPIPE signal
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pipe09 stime=1411895658
cmdline="pipe09"
contacts=""
analysis=exit
<<<test_output>>>
pipe09      1  TPASS  :  functionality appears to be correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pipe10 stime=1411895658
cmdline="pipe10"
contacts=""
analysis=exit
<<<test_output>>>
pipe10      1  TPASS  :  functionality is correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pipe11 stime=1411895658
cmdline="pipe11"
contacts=""
analysis=exit
<<<test_output>>>
pipe11      0  TINFO  :  child 1 got 50 chars
pipe11      0  TINFO  :  child 3 got 50 chars
pipe11      0  TINFO  :  child 2 got 50 chars
pipe11      0  TINFO  :  child 4 got 50 chars
pipe11      0  TINFO  :  child 5 got 50 chars
pipe11      0  TINFO  :  child 6 got 50 chars
pipe11      0  TINFO  :  child 7 got 50 chars
pipe11      0  TINFO  :  child 9 got 50 chars
pipe11      0  TINFO  :  child 10 got 50 chars
pipe11      0  TINFO  :  child 8 got 50 chars
pipe11      0  TINFO  :  child 11 got 50 chars
pipe11      0  TINFO  :  child 12 got 50 chars
pipe11      0  TINFO  :  child 13 got 50 chars
pipe11      0  TINFO  :  child 14 got 50 chars
pipe11      0  TINFO  :  child 15 got 50 chars
pipe11      0  TINFO  :  child 16 got 50 chars
pipe11      0  TINFO  :  child 17 got 50 chars
pipe11      0  TINFO  :  child 18 got 50 chars
pipe11      0  TINFO  :  child 19 got 50 chars
pipe11      0  TINFO  :  child 20 got 50 chars
pipe11      0  TINFO  :  child 21 got 50 chars
pipe11      0  TINFO  :  child 23 got 50 chars
pipe11      0  TINFO  :  child 22 got 50 chars
pipe11      0  TINFO  :  child 25 got 50 chars
pipe11      0  TINFO  :  child 26 got 50 chars
pipe11      0  TINFO  :  child 24 got 50 chars
pipe11      0  TINFO  :  child 27 got 50 chars
pipe11      0  TINFO  :  child 30 got 50 chars
pipe11      0  TINFO  :  child 28 got 50 chars
pipe11      0  TINFO  :  child 31 got 50 chars
pipe11      0  TINFO  :  child 32 got 50 chars
pipe11      0  TINFO  :  child 29 got 50 chars
pipe11      0  TINFO  :  child 34 got 50 chars
pipe11      0  TINFO  :  child 35 got 50 chars
pipe11      0  TINFO  :  child 33 got 50 chars
pipe11      0  TINFO  :  child 36 got 50 chars
pipe11      0  TINFO  :  child 37 got 50 chars
pipe11      0  TINFO  :  child 38 got 50 chars
pipe11      0  TINFO  :  child 39 got 50 chars
pipe11      0  TINFO  :  child 40 got 50 chars
pipe11      0  TINFO  :  child 41 got 50 chars
pipe11      0  TINFO  :  child 42 got 50 chars
pipe11      0  TINFO  :  child 43 got 50 chars
pipe11      0  TINFO  :  child 44 got 50 chars
pipe11      0  TINFO  :  child 45 got 50 chars
pipe11      0  TINFO  :  child 46 got 50 chars
pipe11      0  TINFO  :  child 47 got 50 chars
pipe11      0  TINFO  :  child 48 got 50 chars
pipe11      0  TINFO  :  child 49 got 50 chars
pipe11      0  TINFO  :  child 50 got 50 chars
pipe11      0  TINFO  :  There are 50 children to wait for
pipe11      1  TPASS  :  child 1 exitted successfully
pipe11      2  TPASS  :  child 2 exitted successfully
pipe11      3  TPASS  :  child 3 exitted successfully
pipe11      4  TPASS  :  child 4 exitted successfully
pipe11      5  TPASS  :  child 5 exitted successfully
pipe11      6  TPASS  :  child 6 exitted successfully
pipe11      7  TPASS  :  child 7 exitted successfully
pipe11      8  TPASS  :  child 8 exitted successfully
pipe11      9  TPASS  :  child 9 exitted successfully
pipe11     10  TPASS  :  child 10 exitted successfully
pipe11     11  TPASS  :  child 11 exitted successfully
pipe11     12  TPASS  :  child 12 exitted successfully
pipe11     13  TPASS  :  child 13 exitted successfully
pipe11     14  TPASS  :  child 14 exitted successfully
pipe11     15  TPASS  :  child 15 exitted successfully
pipe11     16  TPASS  :  child 16 exitted successfully
pipe11     17  TPASS  :  child 17 exitted successfully
pipe11     18  TPASS  :  child 18 exitted successfully
pipe11     19  TPASS  :  child 19 exitted successfully
pipe11     20  TPASS  :  child 20 exitted successfully
pipe11     21  TPASS  :  child 21 exitted successfully
pipe11     22  TPASS  :  child 22 exitted successfully
pipe11     23  TPASS  :  child 23 exitted successfully
pipe11     24  TPASS  :  child 24 exitted successfully
pipe11     25  TPASS  :  child 25 exitted successfully
pipe11     26  TPASS  :  child 26 exitted successfully
pipe11     27  TPASS  :  child 27 exitted successfully
pipe11     28  TPASS  :  child 28 exitted successfully
pipe11     29  TPASS  :  child 29 exitted successfully
pipe11     30  TPASS  :  child 30 exitted successfully
pipe11     31  TPASS  :  child 31 exitted successfully
pipe11     32  TPASS  :  child 32 exitted successfully
pipe11     33  TPASS  :  child 33 exitted successfully
pipe11     34  TPASS  :  child 34 exitted successfully
pipe11     35  TPASS  :  child 35 exitted successfully
pipe11     36  TPASS  :  child 36 exitted successfully
pipe11     37  TPASS  :  child 37 exitted successfully
pipe11     38  TPASS  :  child 38 exitted successfully
pipe11     39  TPASS  :  child 39 exitted successfully
pipe11     40  TPASS  :  child 40 exitted successfully
pipe11     41  TPASS  :  child 41 exitted successfully
pipe11     42  TPASS  :  child 42 exitted successfully
pipe11     43  TPASS  :  child 43 exitted successfully
pipe11     44  TPASS  :  child 44 exitted successfully
pipe11     45  TPASS  :  child 45 exitted successfully
pipe11     46  TPASS  :  child 46 exitted successfully
pipe11     47  TPASS  :  child 47 exitted successfully
pipe11     48  TPASS  :  child 48 exitted successfully
pipe11     49  TPASS  :  child 49 exitted successfully
pipe11     50  TPASS  :  child 50 exitted successfully
<<<execution_status>>>
initiation_status="ok"
duration=5 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=pipe2_01 stime=1411895663
cmdline="pipe2_01"
contacts=""
analysis=exit
<<<test_output>>>
pipe2_01    1  TPASS  :  pipe2(O_CLOEXEC) PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pipe2_02 stime=1411895663
cmdline="pipe2_02"
contacts=""
analysis=exit
<<<test_output>>>
pipe2_02    1  TPASS  :  pipe2(O_NONBLOCK) PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=poll01 stime=1411895663
cmdline="poll01"
contacts=""
analysis=exit
<<<test_output>>>
poll01      1  TPASS  :  Functionality of poll() successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=ppoll01 stime=1411895663
cmdline="ppoll01"
contacts=""
analysis=exit
<<<test_output>>>
EXPECT: return value(ret)=(N >= 0) errno=0 (Success)
RESULT: return value(ret)=       1 errno=0 (Success)
EXPECT: return value(ret)=(N >= 0) errno=0 (Success)
RESULT: return value(ret)=       0 errno=0 (Success)
EXPECT: return value(ret)=(N >= 0) errno=0 (Success)
RESULT: return value(ret)=       0 errno=0 (Success)
EXPECT: return value(ret)=(N >= 0) errno=0 (Success)
RESULT: return value(ret)=       1 errno=0 (Success)
EXPECT: return value(ret)=-1 errno=4 (Interrupted system call)
RESULT: return value(ret)=-1 errno=4 (Interrupted system call)
EXPECT: return value(ret)=-1 errno=4 (Interrupted system call)
RESULT: return value(ret)=-1 errno=4 (Interrupted system call)
EXPECT: return value(ret)=-1 errno=22 (Invalid argument)
RESULT: return value(ret)=-1 errno=22 (Invalid argument)
EXPECT: return value(ret)=-1 errno=14 (Bad address)
RESULT: return value(ret)=-1 errno=14 (Bad address)
ppoll01     0  TINFO  :  (case00) START
ppoll01     0  TINFO  :  EXPECT: revents=0x0005
ppoll01     0  TINFO  :  RESULT: revents=0x0005
ppoll01     0  TINFO  :  (case00) END => OK
ppoll01     0  TINFO  :  (case01) START
ppoll01     0  TINFO  :  (case01) END => OK
ppoll01     0  TINFO  :  (case02) START
ppoll01     0  TINFO  :  (case02) END => OK
ppoll01     0  TINFO  :  (case03) START
ppoll01     0  TINFO  :  EXPECT: revents=0x0020
ppoll01     0  TINFO  :  RESULT: revents=0x0020
ppoll01     0  TINFO  :  (case03) END => OK
ppoll01     0  TINFO  :  (case04) START
ppoll01     0  TINFO  :  (case04) END => OK
ppoll01     0  TINFO  :  (case05) START
ppoll01     0  TINFO  :  (case05) END => OK
ppoll01     0  TINFO  :  (case06) START
ppoll01     0  TINFO  :  (case06) END => OK
ppoll01     0  TINFO  :  (case07) START
ppoll01     0  TINFO  :  (case07) END => OK
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=prctl01 stime=1411895664
cmdline="prctl01"
contacts=""
analysis=exit
<<<test_output>>>
prctl01     1  TPASS  :  Test Passed
prctl01     2  TPASS  :  Test Passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=prctl02 stime=1411895664
cmdline="prctl02"
contacts=""
analysis=exit
<<<test_output>>>
prctl02     1  TPASS  :  Test Passed
prctl02     2  TPASS  :  Test Passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pread01 stime=1411895664
cmdline="pread01"
contacts=""
analysis=exit
<<<test_output>>>
pread01     1  TPASS  :  Functionality of pread() is correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pread01_64 stime=1411895664
cmdline="pread01_64"
contacts=""
analysis=exit
<<<test_output>>>
pread01     1  TPASS  :  Functionality of pread() is correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pread02 stime=1411895664
cmdline="pread02"
contacts=""
analysis=exit
<<<test_output>>>
pread02     1  TPASS  :  pread() fails, file descriptor is a PIPE or FIFO, errno:29
pread02     2  TPASS  :  pread() fails, specified offset is -ve or invalid, errno:22
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pread02_64 stime=1411895664
cmdline="pread02_64"
contacts=""
analysis=exit
<<<test_output>>>
pread02     1  TPASS  :  pread() fails, file descriptor is a PIPE or FIFO, errno:29
pread02     2  TPASS  :  pread() fails, specified offset is -ve or invalid, errno:22
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pread03 stime=1411895664
cmdline="pread03"
contacts=""
analysis=exit
<<<test_output>>>
pread03     1  TPASS  :  pread() fails with expected error EISDIR errno:21
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=pread03_64 stime=1411895664
cmdline="pread03_64"
contacts=""
analysis=exit
<<<test_output>>>
pread03     1  TPASS  :  pread() fails with expected error EISDIR errno:21
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=profil01 stime=1411895664
cmdline="profil01"
contacts=""
analysis=exit
<<<test_output>>>
profil01    0  TINFO  :  buf[0x404e]=21
profil01    0  TINFO  :  buf[0x405c]=29
profil01    0  TINFO  :  buf[0x406c]=28
profil01    0  TINFO  :  buf[0x4082]=32
profil01    0  TINFO  :  buf[0x409c]=33
profil01    0  TINFO  :  buf[0x414e]=21
profil01    0  TINFO  :  buf[0x415c]=19
profil01    0  TINFO  :  buf[0x4166]=29
profil01    0  TINFO  :  buf[0x4170]=87
profil01    0  TINFO  :  buf[0x4174]=22
profil01    0  TINFO  :  buf[0x417e]=14
profil01    0  TINFO  :  buf[0x418a]=26
profil01    0  TINFO  :  buf[0x4196]=27
profil01    0  TINFO  :  buf[0x419a]=27
profil01    0  TINFO  :  buf[0x419e]=19
profil01    0  TINFO  :  buf[0x41a0]=25
profil01    0  TINFO  :  buf[0x41a2]=21
profil01    0  TINFO  :  buf[0x41a6]=19
profil01    1  TPASS  :  profil recorded some data
<<<execution_status>>>
initiation_status="ok"
duration=5 termination_type=exited termination_id=0 corefile=no
cutime=500 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=process_vm_readv01 stime=1411895669
cmdline="process_vm01 -r"
contacts=""
analysis=exit
<<<test_output>>>
process_vm_readv    0  TINFO  :  test_sane_params
process_vm_readv    1  TPASS  :  expected ret success - returned value = 4096
process_vm_readv    0  TINFO  :  test_flags, flags=-2147483647
process_vm_readv    2  TPASS  :  expected ret success - returned value = -1
process_vm_readv    3  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
process_vm_readv    0  TINFO  :  test_flags, flags=-1
process_vm_readv    4  TPASS  :  expected ret success - returned value = -1
process_vm_readv    5  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
process_vm_readv    0  TINFO  :  test_flags, flags=1
process_vm_readv    6  TPASS  :  expected ret success - returned value = -1
process_vm_readv    7  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
process_vm_readv    0  TINFO  :  test_flags, flags=2147483647
process_vm_readv    8  TPASS  :  expected ret success - returned value = -1
process_vm_readv    9  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
process_vm_readv    0  TINFO  :  test_flags, flags=0
process_vm_readv   10  TPASS  :  expected ret success - returned value = 4096
process_vm_readv    0  TINFO  :  test_iov_len_overflow
process_vm_readv   11  TPASS  :  expected ret success - returned value = -1
process_vm_readv   12  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
process_vm_readv    0  TINFO  :  test_iov_invalid - lvec->iov_base
process_vm_readv   13  TPASS  :  expected ret success - returned value = -1
process_vm_readv   14  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
process_vm_readv    0  TINFO  :  test_iov_invalid - rvec->iov_base
process_vm_readv   15  TPASS  :  expected ret success - returned value = -1
process_vm_readv   16  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
process_vm_readv    0  TINFO  :  test_iov_invalid - lvec
process_vm_readv   17  TPASS  :  expected ret success - returned value = -1
process_vm_readv   18  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
process_vm_readv    0  TINFO  :  test_iov_invalid - rvec
process_vm_readv   19  TPASS  :  expected ret success - returned value = -1
process_vm_readv   20  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
process_vm_readv    0  TINFO  :  test_invalid_pid
process_vm_readv   21  TPASS  :  expected ret success - returned value = -1
process_vm_readv   22  TPASS  :  expected failure: TEST_ERRNO=ESRCH(3): No such process
process_vm_readv   23  TPASS  :  expected ret success - returned value = -1
process_vm_readv   24  TPASS  :  expected failure: TEST_ERRNO=ESRCH(3): No such process
process_vm_readv    0  TINFO  :  test_invalid_perm
process_vm_readv   25  TPASS  :  expected ret success - returned value = -1
process_vm_readv   26  TPASS  :  expected failure: TEST_ERRNO=EPERM(1): Operation not permitted
process_vm_readv    0  TINFO  :  test_sane_params
process_vm_readv    1  TPASS  :  expected ret success - returned value = 4096
process_vm_readv    0  TINFO  :  test_flags, flags=-2147483647
process_vm_readv    2  TPASS  :  expected ret success - returned value = -1
process_vm_readv    3  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
process_vm_readv    0  TINFO  :  test_flags, flags=-1
process_vm_readv    4  TPASS  :  expected ret success - returned value = -1
process_vm_readv    5  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
process_vm_readv    0  TINFO  :  test_flags, flags=1
process_vm_readv    6  TPASS  :  expected ret success - returned value = -1
process_vm_readv    7  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
process_vm_readv    0  TINFO  :  test_flags, flags=2147483647
process_vm_readv    8  TPASS  :  expected ret success - returned value = -1
process_vm_readv    9  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
process_vm_readv    0  TINFO  :  test_flags, flags=0
process_vm_readv   10  TPASS  :  expected ret success - returned value = 4096
process_vm_readv    0  TINFO  :  test_iov_len_overflow
process_vm_readv   11  TPASS  :  expected ret success - returned value = -1
process_vm_readv   12  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
process_vm_readv    0  TINFO  :  test_iov_invalid - lvec->iov_base
process_vm_readv   13  TPASS  :  expected ret success - returned value = -1
process_vm_readv   14  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
process_vm_readv    0  TINFO  :  test_iov_invalid - rvec->iov_base
process_vm_readv   15  TPASS  :  expected ret success - returned value = -1
process_vm_readv   16  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
process_vm_readv    0  TINFO  :  test_iov_invalid - lvec
process_vm_readv   17  TPASS  :  expected ret success - returned value = -1
process_vm_readv   18  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
process_vm_readv    0  TINFO  :  test_iov_invalid - rvec
process_vm_readv   19  TPASS  :  expected ret success - returned value = -1
process_vm_readv   20  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
process_vm_readv    0  TINFO  :  test_invalid_pid
process_vm_readv   21  TPASS  :  expected ret success - returned value = -1
process_vm_readv   22  TPASS  :  expected failure: TEST_ERRNO=ESRCH(3): No such process
process_vm_readv   23  TPASS  :  expected ret success - returned value = -1
process_vm_readv   24  TPASS  :  expected failure: TEST_ERRNO=ESRCH(3): No such process
process_vm_readv    0  TINFO  :  test_invalid_perm
process_vm_readv    0  TINFO  :  test_invalid_protection lvec
process_vm_readv   25  TPASS  :  expected ret success - returned value = -1
process_vm_readv   26  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
process_vm_readv    0  TINFO  :  test_invalid_protection rvec
process_vm_readv   27  TPASS  :  expected ret success - returned value = -1
process_vm_readv   28  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=process_vm_readv02 stime=1411895669
cmdline="process_vm_readv02"
contacts=""
analysis=exit
<<<test_output>>>
process_vm_readv02    0  TINFO  :  child 1: reading string from same memory location.
process_vm_readv02    1  TPASS  :  expected string received.
process_vm_readv02    0  TINFO  :  child 0: memory allocated and initialized.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=process_vm_readv03 stime=1411895669
cmdline="process_vm_readv03"
contacts=""
analysis=exit
<<<test_output>>>
process_vm_readv03    0  TINFO  :  child 1: 10 remote iovecs received.
process_vm_readv03    0  TINFO  :  child 1: 4 local iovecs initialized.
process_vm_readv03    1  TPASS  :  child 1: all bytes are correctly received.
process_vm_readv03    0  TINFO  :  child 0: 10 iovecs allocated and initialized.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=process_vm_writev01 stime=1411895669
cmdline="process_vm01 -w"
contacts=""
analysis=exit
<<<test_output>>>
process_vm_writev    0  TINFO  :  test_sane_params
process_vm_writev    1  TPASS  :  expected ret success - returned value = 4096
process_vm_writev    0  TINFO  :  test_flags, flags=-2147483647
process_vm_writev    2  TPASS  :  expected ret success - returned value = -1
process_vm_writev    3  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
process_vm_writev    0  TINFO  :  test_flags, flags=-1
process_vm_writev    4  TPASS  :  expected ret success - returned value = -1
process_vm_writev    5  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
process_vm_writev    0  TINFO  :  test_flags, flags=1
process_vm_writev    6  TPASS  :  expected ret success - returned value = -1
process_vm_writev    7  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
process_vm_writev    0  TINFO  :  test_flags, flags=2147483647
process_vm_writev    8  TPASS  :  expected ret success - returned value = -1
process_vm_writev    9  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
process_vm_writev    0  TINFO  :  test_flags, flags=0
process_vm_writev   10  TPASS  :  expected ret success - returned value = 4096
process_vm_writev    0  TINFO  :  test_iov_len_overflow
process_vm_writev   11  TPASS  :  expected ret success - returned value = -1
process_vm_writev   12  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
process_vm_writev    0  TINFO  :  test_iov_invalid - lvec->iov_base
process_vm_writev   13  TPASS  :  expected ret success - returned value = -1
process_vm_writev   14  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
process_vm_writev    0  TINFO  :  test_iov_invalid - rvec->iov_base
process_vm_writev   15  TPASS  :  expected ret success - returned value = -1
process_vm_writev   16  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
process_vm_writev    0  TINFO  :  test_iov_invalid - lvec
process_vm_writev   17  TPASS  :  expected ret success - returned value = -1
process_vm_writev   18  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
process_vm_writev    0  TINFO  :  test_iov_invalid - rvec
process_vm_writev   19  TPASS  :  expected ret success - returned value = -1
process_vm_writev   20  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
process_vm_writev    0  TINFO  :  test_invalid_pid
process_vm_writev   21  TPASS  :  expected ret success - returned value = -1
process_vm_writev   22  TPASS  :  expected failure: TEST_ERRNO=ESRCH(3): No such process
process_vm_writev   23  TPASS  :  expected ret success - returned value = -1
process_vm_writev   24  TPASS  :  expected failure: TEST_ERRNO=ESRCH(3): No such process
process_vm_writev    0  TINFO  :  test_invalid_perm
process_vm_writev   25  TPASS  :  expected ret success - returned value = -1
process_vm_writev   26  TPASS  :  expected failure: TEST_ERRNO=EPERM(1): Operation not permitted
process_vm_writev    0  TINFO  :  test_sane_params
process_vm_writev    1  TPASS  :  expected ret success - returned value = 4096
process_vm_writev    0  TINFO  :  test_flags, flags=-2147483647
process_vm_writev    2  TPASS  :  expected ret success - returned value = -1
process_vm_writev    3  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
process_vm_writev    0  TINFO  :  test_flags, flags=-1
process_vm_writev    4  TPASS  :  expected ret success - returned value = -1
process_vm_writev    5  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
process_vm_writev    0  TINFO  :  test_flags, flags=1
process_vm_writev    6  TPASS  :  expected ret success - returned value = -1
process_vm_writev    7  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
process_vm_writev    0  TINFO  :  test_flags, flags=2147483647
process_vm_writev    8  TPASS  :  expected ret success - returned value = -1
process_vm_writev    9  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
process_vm_writev    0  TINFO  :  test_flags, flags=0
process_vm_writev   10  TPASS  :  expected ret success - returned value = 4096
process_vm_writev    0  TINFO  :  test_iov_len_overflow
process_vm_writev   11  TPASS  :  expected ret success - returned value = -1
process_vm_writev   12  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
process_vm_writev    0  TINFO  :  test_iov_invalid - lvec->iov_base
process_vm_writev   13  TPASS  :  expected ret success - returned value = -1
process_vm_writev   14  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
process_vm_writev    0  TINFO  :  test_iov_invalid - rvec->iov_base
process_vm_writev   15  TPASS  :  expected ret success - returned value = -1
process_vm_writev   16  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
process_vm_writev    0  TINFO  :  test_iov_invalid - lvec
process_vm_writev   17  TPASS  :  expected ret success - returned value = -1
process_vm_writev   18  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
process_vm_writev    0  TINFO  :  test_iov_invalid - rvec
process_vm_writev   19  TPASS  :  expected ret success - returned value = -1
process_vm_writev   20  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
process_vm_writev    0  TINFO  :  test_invalid_pid
process_vm_writev   21  TPASS  :  expected ret success - returned value = -1
process_vm_writev   22  TPASS  :  expected failure: TEST_ERRNO=ESRCH(3): No such process
process_vm_writev   23  TPASS  :  expected ret success - returned value = -1
process_vm_writev   24  TPASS  :  expected failure: TEST_ERRNO=ESRCH(3): No such process
process_vm_writev    0  TINFO  :  test_invalid_perm
process_vm_writev    0  TINFO  :  test_invalid_protection lvec
process_vm_writev   25  TPASS  :  expected ret success - returned value = -1
process_vm_writev   26  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
process_vm_writev    0  TINFO  :  test_invalid_protection rvec
process_vm_writev   27  TPASS  :  expected ret success - returned value = -1
process_vm_writev   28  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=process_vm_writev02 stime=1411895669
cmdline="process_vm_writev02"
contacts=""
analysis=exit
<<<test_output>>>
process_vm_writev02    0  TINFO  :  child 2: write to the same memory location.
process_vm_writev02    0  TINFO  :  child 0: memory allocated.
process_vm_writev02    1  TPASS  :  child 0: all bytes are expected.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=prot_hsymlinks stime=1411895669
cmdline="prot_hsymlinks"
contacts=""
analysis=exit
<<<test_output>>>
prot_hsymlinks    0  TINFO  :   --- HARDLINKS AND SYMLINKS RESTRICTIONS TEST ---

prot_hsymlinks    1  TPASS  :  Expect: can follow symlink '.../link_1', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks    2  TPASS  :  Expect: can follow symlink '.../link_1', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks    3  TPASS  :  Expect: can follow symlink '.../link_2', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks    4  TPASS  :  Expect: can follow symlink '.../link_2', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks    5  TPASS  :  Expect: can follow symlink '.../tmp_root/link_3', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks    6  TPASS  :  Expect: can follow symlink '.../tmp_root/link_3', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks    7  TPASS  :  Expect: can't follow symlink '.../tmp_root/link_4', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks    8  TPASS  :  Expect: can follow symlink '.../tmp_root/link_4', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks    9  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_5', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks   10  TPASS  :  Expect: can't follow symlink '.../tmp_hsym/link_5', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks   11  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_6', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks   12  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_6', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks   13  TPASS  :  Expect: can create hardlink '.../root.hs' to '.../link_7', owner 'root', curr.user 'root', w(1)
prot_hsymlinks   14  TPASS  :  Expect: can't create hardlink '.../root.hs' to '.../link_8', owner 'root', curr.user 'hsym', w(0)
prot_hsymlinks   15  TPASS  :  Expect: can create hardlink '.../root.hs' to '.../tmp_root/link_9', owner 'root', curr.user 'root', w(1)
prot_hsymlinks   16  TPASS  :  Expect: can't create hardlink '.../root.hs' to '.../tmp_root/link_10', owner 'root', curr.user 'hsym', w(0)
prot_hsymlinks   17  TPASS  :  Expect: can create hardlink '.../root.hs' to '.../tmp_hsym/link_11', owner 'root', curr.user 'root', w(1)
prot_hsymlinks   18  TPASS  :  Expect: can't create hardlink '.../root.hs' to '.../tmp_hsym/link_12', owner 'root', curr.user 'hsym', w(0)
prot_hsymlinks   19  TPASS  :  Expect: can follow symlink '.../link_13', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks   20  TPASS  :  Expect: can follow symlink '.../link_13', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks   21  TPASS  :  Expect: can follow symlink '.../link_14', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks   22  TPASS  :  Expect: can follow symlink '.../link_14', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks   23  TPASS  :  Expect: can follow symlink '.../tmp_root/link_15', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks   24  TPASS  :  Expect: can follow symlink '.../tmp_root/link_15', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks   25  TPASS  :  Expect: can't follow symlink '.../tmp_root/link_16', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks   26  TPASS  :  Expect: can follow symlink '.../tmp_root/link_16', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks   27  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_17', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks   28  TPASS  :  Expect: can't follow symlink '.../tmp_hsym/link_17', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks   29  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_18', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks   30  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_18', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks   31  TPASS  :  Expect: can create hardlink '.../root.hs_w' to '.../link_19', owner 'root', curr.user 'root', w(1)
prot_hsymlinks   32  TPASS  :  Expect: can create hardlink '.../root.hs_w' to '.../link_20', owner 'root', curr.user 'hsym', w(1)
prot_hsymlinks   33  TPASS  :  Expect: can create hardlink '.../root.hs_w' to '.../tmp_root/link_21', owner 'root', curr.user 'root', w(1)
prot_hsymlinks   34  TPASS  :  Expect: can create hardlink '.../root.hs_w' to '.../tmp_root/link_22', owner 'root', curr.user 'hsym', w(1)
prot_hsymlinks   35  TPASS  :  Expect: can create hardlink '.../root.hs_w' to '.../tmp_hsym/link_23', owner 'root', curr.user 'root', w(1)
prot_hsymlinks   36  TPASS  :  Expect: can create hardlink '.../root.hs_w' to '.../tmp_hsym/link_24', owner 'root', curr.user 'hsym', w(1)
prot_hsymlinks   37  TPASS  :  Expect: can follow symlink '.../link_25', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks   38  TPASS  :  Expect: can follow symlink '.../link_25', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks   39  TPASS  :  Expect: can follow symlink '.../link_26', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks   40  TPASS  :  Expect: can follow symlink '.../link_26', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks   41  TPASS  :  Expect: can follow symlink '.../tmp_root/link_27', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks   42  TPASS  :  Expect: can follow symlink '.../tmp_root/link_27', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks   43  TPASS  :  Expect: can't follow symlink '.../tmp_root/link_28', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks   44  TPASS  :  Expect: can follow symlink '.../tmp_root/link_28', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks   45  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_29', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks   46  TPASS  :  Expect: can't follow symlink '.../tmp_hsym/link_29', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks   47  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_30', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks   48  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_30', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks   49  TPASS  :  Expect: can follow symlink '.../link_31', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks   50  TPASS  :  Expect: can follow symlink '.../link_31', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks   51  TPASS  :  Expect: can follow symlink '.../link_32', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks   52  TPASS  :  Expect: can follow symlink '.../link_32', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks   53  TPASS  :  Expect: can follow symlink '.../tmp_root/link_33', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks   54  TPASS  :  Expect: can follow symlink '.../tmp_root/link_33', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks   55  TPASS  :  Expect: can't follow symlink '.../tmp_root/link_34', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks   56  TPASS  :  Expect: can follow symlink '.../tmp_root/link_34', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks   57  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_35', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks   58  TPASS  :  Expect: can't follow symlink '.../tmp_hsym/link_35', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks   59  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_36', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks   60  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_36', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks   61  TPASS  :  Expect: can create hardlink '.../root/local_root.hs' to '.../link_37', owner 'root', curr.user 'root', w(1)
prot_hsymlinks   62  TPASS  :  Expect: can't create hardlink '.../root/local_root.hs' to '.../link_38', owner 'root', curr.user 'hsym', w(0)
prot_hsymlinks   63  TPASS  :  Expect: can create hardlink '.../root/local_root.hs' to '.../tmp_root/link_39', owner 'root', curr.user 'root', w(1)
prot_hsymlinks   64  TPASS  :  Expect: can't create hardlink '.../root/local_root.hs' to '.../tmp_root/link_40', owner 'root', curr.user 'hsym', w(0)
prot_hsymlinks   65  TPASS  :  Expect: can create hardlink '.../root/local_root.hs' to '.../tmp_hsym/link_41', owner 'root', curr.user 'root', w(1)
prot_hsymlinks   66  TPASS  :  Expect: can't create hardlink '.../root/local_root.hs' to '.../tmp_hsym/link_42', owner 'root', curr.user 'hsym', w(0)
prot_hsymlinks   67  TPASS  :  Expect: can follow symlink '.../link_43', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks   68  TPASS  :  Expect: can follow symlink '.../link_43', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks   69  TPASS  :  Expect: can follow symlink '.../link_44', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks   70  TPASS  :  Expect: can follow symlink '.../link_44', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks   71  TPASS  :  Expect: can follow symlink '.../tmp_root/link_45', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks   72  TPASS  :  Expect: can follow symlink '.../tmp_root/link_45', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks   73  TPASS  :  Expect: can't follow symlink '.../tmp_root/link_46', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks   74  TPASS  :  Expect: can follow symlink '.../tmp_root/link_46', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks   75  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_47', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks   76  TPASS  :  Expect: can't follow symlink '.../tmp_hsym/link_47', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks   77  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_48', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks   78  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_48', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks   79  TPASS  :  Expect: can create hardlink '.../tmp_root/root.hs' to '.../link_49', owner 'root', curr.user 'root', w(1)
prot_hsymlinks   80  TPASS  :  Expect: can't create hardlink '.../tmp_root/root.hs' to '.../link_50', owner 'root', curr.user 'hsym', w(0)
prot_hsymlinks   81  TPASS  :  Expect: can create hardlink '.../tmp_root/root.hs' to '.../tmp_root/link_51', owner 'root', curr.user 'root', w(1)
prot_hsymlinks   82  TPASS  :  Expect: can't create hardlink '.../tmp_root/root.hs' to '.../tmp_root/link_52', owner 'root', curr.user 'hsym', w(0)
prot_hsymlinks   83  TPASS  :  Expect: can create hardlink '.../tmp_root/root.hs' to '.../tmp_hsym/link_53', owner 'root', curr.user 'root', w(1)
prot_hsymlinks   84  TPASS  :  Expect: can't create hardlink '.../tmp_root/root.hs' to '.../tmp_hsym/link_54', owner 'root', curr.user 'hsym', w(0)
prot_hsymlinks   85  TPASS  :  Expect: can follow symlink '.../link_55', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks   86  TPASS  :  Expect: can follow symlink '.../link_55', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks   87  TPASS  :  Expect: can follow symlink '.../link_56', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks   88  TPASS  :  Expect: can follow symlink '.../link_56', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks   89  TPASS  :  Expect: can follow symlink '.../tmp_root/link_57', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks   90  TPASS  :  Expect: can follow symlink '.../tmp_root/link_57', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks   91  TPASS  :  Expect: can't follow symlink '.../tmp_root/link_58', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks   92  TPASS  :  Expect: can follow symlink '.../tmp_root/link_58', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks   93  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_59', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks   94  TPASS  :  Expect: can't follow symlink '.../tmp_hsym/link_59', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks   95  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_60', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks   96  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_60', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks   97  TPASS  :  Expect: can create hardlink '.../tmp_root/root.hs_w' to '.../link_61', owner 'root', curr.user 'root', w(1)
prot_hsymlinks   98  TPASS  :  Expect: can create hardlink '.../tmp_root/root.hs_w' to '.../link_62', owner 'root', curr.user 'hsym', w(1)
prot_hsymlinks   99  TPASS  :  Expect: can create hardlink '.../tmp_root/root.hs_w' to '.../tmp_root/link_63', owner 'root', curr.user 'root', w(1)
prot_hsymlinks  100  TPASS  :  Expect: can create hardlink '.../tmp_root/root.hs_w' to '.../tmp_root/link_64', owner 'root', curr.user 'hsym', w(1)
prot_hsymlinks  101  TPASS  :  Expect: can create hardlink '.../tmp_root/root.hs_w' to '.../tmp_hsym/link_65', owner 'root', curr.user 'root', w(1)
prot_hsymlinks  102  TPASS  :  Expect: can create hardlink '.../tmp_root/root.hs_w' to '.../tmp_hsym/link_66', owner 'root', curr.user 'hsym', w(1)
prot_hsymlinks  103  TPASS  :  Expect: can follow symlink '.../link_67', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks  104  TPASS  :  Expect: can follow symlink '.../link_67', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  105  TPASS  :  Expect: can follow symlink '.../link_68', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks  106  TPASS  :  Expect: can follow symlink '.../link_68', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  107  TPASS  :  Expect: can follow symlink '.../tmp_root/link_69', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks  108  TPASS  :  Expect: can follow symlink '.../tmp_root/link_69', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  109  TPASS  :  Expect: can't follow symlink '.../tmp_root/link_70', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks  110  TPASS  :  Expect: can follow symlink '.../tmp_root/link_70', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  111  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_71', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  112  TPASS  :  Expect: can't follow symlink '.../tmp_hsym/link_71', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  113  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_72', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  114  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_72', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  115  TPASS  :  Expect: can follow symlink '.../link_73', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks  116  TPASS  :  Expect: can follow symlink '.../link_73', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  117  TPASS  :  Expect: can follow symlink '.../link_74', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks  118  TPASS  :  Expect: can follow symlink '.../link_74', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  119  TPASS  :  Expect: can follow symlink '.../tmp_root/link_75', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks  120  TPASS  :  Expect: can follow symlink '.../tmp_root/link_75', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  121  TPASS  :  Expect: can't follow symlink '.../tmp_root/link_76', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks  122  TPASS  :  Expect: can follow symlink '.../tmp_root/link_76', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  123  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_77', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  124  TPASS  :  Expect: can't follow symlink '.../tmp_hsym/link_77', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  125  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_78', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  126  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_78', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  127  TPASS  :  Expect: can create hardlink '.../tmp_root/root/local_root.hs' to '.../link_79', owner 'root', curr.user 'root', w(1)
prot_hsymlinks  128  TPASS  :  Expect: can't create hardlink '.../tmp_root/root/local_root.hs' to '.../link_80', owner 'root', curr.user 'hsym', w(0)
prot_hsymlinks  129  TPASS  :  Expect: can create hardlink '.../tmp_root/root/local_root.hs' to '.../tmp_root/link_81', owner 'root', curr.user 'root', w(1)
prot_hsymlinks  130  TPASS  :  Expect: can't create hardlink '.../tmp_root/root/local_root.hs' to '.../tmp_root/link_82', owner 'root', curr.user 'hsym', w(0)
prot_hsymlinks  131  TPASS  :  Expect: can create hardlink '.../tmp_root/root/local_root.hs' to '.../tmp_hsym/link_83', owner 'root', curr.user 'root', w(1)
prot_hsymlinks  132  TPASS  :  Expect: can't create hardlink '.../tmp_root/root/local_root.hs' to '.../tmp_hsym/link_84', owner 'root', curr.user 'hsym', w(0)
prot_hsymlinks  133  TPASS  :  Expect: can follow symlink '.../link_85', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks  134  TPASS  :  Expect: can follow symlink '.../link_85', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  135  TPASS  :  Expect: can follow symlink '.../link_86', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks  136  TPASS  :  Expect: can follow symlink '.../link_86', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  137  TPASS  :  Expect: can follow symlink '.../tmp_root/link_87', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks  138  TPASS  :  Expect: can follow symlink '.../tmp_root/link_87', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  139  TPASS  :  Expect: can't follow symlink '.../tmp_root/link_88', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks  140  TPASS  :  Expect: can follow symlink '.../tmp_root/link_88', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  141  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_89', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  142  TPASS  :  Expect: can't follow symlink '.../tmp_hsym/link_89', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  143  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_90', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  144  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_90', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  145  TPASS  :  Expect: can create hardlink '.../tmp_hsym/root.hs' to '.../link_91', owner 'root', curr.user 'root', w(1)
prot_hsymlinks  146  TPASS  :  Expect: can't create hardlink '.../tmp_hsym/root.hs' to '.../link_92', owner 'root', curr.user 'hsym', w(0)
prot_hsymlinks  147  TPASS  :  Expect: can create hardlink '.../tmp_hsym/root.hs' to '.../tmp_root/link_93', owner 'root', curr.user 'root', w(1)
prot_hsymlinks  148  TPASS  :  Expect: can't create hardlink '.../tmp_hsym/root.hs' to '.../tmp_root/link_94', owner 'root', curr.user 'hsym', w(0)
prot_hsymlinks  149  TPASS  :  Expect: can create hardlink '.../tmp_hsym/root.hs' to '.../tmp_hsym/link_95', owner 'root', curr.user 'root', w(1)
prot_hsymlinks  150  TPASS  :  Expect: can't create hardlink '.../tmp_hsym/root.hs' to '.../tmp_hsym/link_96', owner 'root', curr.user 'hsym', w(0)
prot_hsymlinks  151  TPASS  :  Expect: can follow symlink '.../link_97', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks  152  TPASS  :  Expect: can follow symlink '.../link_97', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  153  TPASS  :  Expect: can follow symlink '.../link_98', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks  154  TPASS  :  Expect: can follow symlink '.../link_98', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  155  TPASS  :  Expect: can follow symlink '.../tmp_root/link_99', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks  156  TPASS  :  Expect: can follow symlink '.../tmp_root/link_99', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  157  TPASS  :  Expect: can't follow symlink '.../tmp_root/link_100', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks  158  TPASS  :  Expect: can follow symlink '.../tmp_root/link_100', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  159  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_101', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  160  TPASS  :  Expect: can't follow symlink '.../tmp_hsym/link_101', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  161  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_102', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  162  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_102', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  163  TPASS  :  Expect: can create hardlink '.../tmp_hsym/root.hs_w' to '.../link_103', owner 'root', curr.user 'root', w(1)
prot_hsymlinks  164  TPASS  :  Expect: can create hardlink '.../tmp_hsym/root.hs_w' to '.../link_104', owner 'root', curr.user 'hsym', w(1)
prot_hsymlinks  165  TPASS  :  Expect: can create hardlink '.../tmp_hsym/root.hs_w' to '.../tmp_root/link_105', owner 'root', curr.user 'root', w(1)
prot_hsymlinks  166  TPASS  :  Expect: can create hardlink '.../tmp_hsym/root.hs_w' to '.../tmp_root/link_106', owner 'root', curr.user 'hsym', w(1)
prot_hsymlinks  167  TPASS  :  Expect: can create hardlink '.../tmp_hsym/root.hs_w' to '.../tmp_hsym/link_107', owner 'root', curr.user 'root', w(1)
prot_hsymlinks  168  TPASS  :  Expect: can create hardlink '.../tmp_hsym/root.hs_w' to '.../tmp_hsym/link_108', owner 'root', curr.user 'hsym', w(1)
prot_hsymlinks  169  TPASS  :  Expect: can follow symlink '.../link_109', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks  170  TPASS  :  Expect: can follow symlink '.../link_109', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  171  TPASS  :  Expect: can follow symlink '.../link_110', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks  172  TPASS  :  Expect: can follow symlink '.../link_110', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  173  TPASS  :  Expect: can follow symlink '.../tmp_root/link_111', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks  174  TPASS  :  Expect: can follow symlink '.../tmp_root/link_111', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  175  TPASS  :  Expect: can't follow symlink '.../tmp_root/link_112', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks  176  TPASS  :  Expect: can follow symlink '.../tmp_root/link_112', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  177  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_113', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  178  TPASS  :  Expect: can't follow symlink '.../tmp_hsym/link_113', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  179  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_114', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  180  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_114', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  181  TPASS  :  Expect: can follow symlink '.../link_115', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks  182  TPASS  :  Expect: can follow symlink '.../link_115', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  183  TPASS  :  Expect: can follow symlink '.../link_116', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks  184  TPASS  :  Expect: can follow symlink '.../link_116', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  185  TPASS  :  Expect: can follow symlink '.../tmp_root/link_117', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks  186  TPASS  :  Expect: can follow symlink '.../tmp_root/link_117', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  187  TPASS  :  Expect: can't follow symlink '.../tmp_root/link_118', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'root'
prot_hsymlinks  188  TPASS  :  Expect: can follow symlink '.../tmp_root/link_118', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  189  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_119', owner 'root', src.owner 'root', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  190  TPASS  :  Expect: can't follow symlink '.../tmp_hsym/link_119', owner 'root', src.owner 'root', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  191  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_120', owner 'hsym', src.owner 'root', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  192  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_120', owner 'hsym', src.owner 'root', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  193  TPASS  :  Expect: can create hardlink '.../tmp_hsym/root/local_root.hs' to '.../link_121', owner 'root', curr.user 'root', w(1)
prot_hsymlinks  194  TPASS  :  Expect: can't create hardlink '.../tmp_hsym/root/local_root.hs' to '.../link_122', owner 'root', curr.user 'hsym', w(0)
prot_hsymlinks  195  TPASS  :  Expect: can create hardlink '.../tmp_hsym/root/local_root.hs' to '.../tmp_root/link_123', owner 'root', curr.user 'root', w(1)
prot_hsymlinks  196  TPASS  :  Expect: can't create hardlink '.../tmp_hsym/root/local_root.hs' to '.../tmp_root/link_124', owner 'root', curr.user 'hsym', w(0)
prot_hsymlinks  197  TPASS  :  Expect: can create hardlink '.../tmp_hsym/root/local_root.hs' to '.../tmp_hsym/link_125', owner 'root', curr.user 'root', w(1)
prot_hsymlinks  198  TPASS  :  Expect: can't create hardlink '.../tmp_hsym/root/local_root.hs' to '.../tmp_hsym/link_126', owner 'root', curr.user 'hsym', w(0)
prot_hsymlinks  199  TPASS  :  Expect: can follow symlink '.../link_127', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  200  TPASS  :  Expect: can follow symlink '.../link_127', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  201  TPASS  :  Expect: can follow symlink '.../link_128', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  202  TPASS  :  Expect: can follow symlink '.../link_128', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  203  TPASS  :  Expect: can follow symlink '.../tmp_root/link_129', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  204  TPASS  :  Expect: can follow symlink '.../tmp_root/link_129', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  205  TPASS  :  Expect: can't follow symlink '.../tmp_root/link_130', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  206  TPASS  :  Expect: can follow symlink '.../tmp_root/link_130', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  207  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_131', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  208  TPASS  :  Expect: can't follow symlink '.../tmp_hsym/link_131', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  209  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_132', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  210  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_132', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  211  TPASS  :  Expect: can create hardlink '.../hsym.hs' to '.../link_133', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  212  TPASS  :  Expect: can create hardlink '.../hsym.hs' to '.../link_134', owner 'hsym', curr.user 'hsym', w(1)
prot_hsymlinks  213  TPASS  :  Expect: can create hardlink '.../hsym.hs' to '.../tmp_root/link_135', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  214  TPASS  :  Expect: can create hardlink '.../hsym.hs' to '.../tmp_root/link_136', owner 'hsym', curr.user 'hsym', w(1)
prot_hsymlinks  215  TPASS  :  Expect: can create hardlink '.../hsym.hs' to '.../tmp_hsym/link_137', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  216  TPASS  :  Expect: can create hardlink '.../hsym.hs' to '.../tmp_hsym/link_138', owner 'hsym', curr.user 'hsym', w(1)
prot_hsymlinks  217  TPASS  :  Expect: can follow symlink '.../link_139', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  218  TPASS  :  Expect: can follow symlink '.../link_139', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  219  TPASS  :  Expect: can follow symlink '.../link_140', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  220  TPASS  :  Expect: can follow symlink '.../link_140', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  221  TPASS  :  Expect: can follow symlink '.../tmp_root/link_141', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  222  TPASS  :  Expect: can follow symlink '.../tmp_root/link_141', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  223  TPASS  :  Expect: can't follow symlink '.../tmp_root/link_142', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  224  TPASS  :  Expect: can follow symlink '.../tmp_root/link_142', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  225  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_143', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  226  TPASS  :  Expect: can't follow symlink '.../tmp_hsym/link_143', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  227  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_144', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  228  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_144', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  229  TPASS  :  Expect: can create hardlink '.../hsym.hs_w' to '.../link_145', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  230  TPASS  :  Expect: can create hardlink '.../hsym.hs_w' to '.../link_146', owner 'hsym', curr.user 'hsym', w(0)
prot_hsymlinks  231  TPASS  :  Expect: can create hardlink '.../hsym.hs_w' to '.../tmp_root/link_147', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  232  TPASS  :  Expect: can create hardlink '.../hsym.hs_w' to '.../tmp_root/link_148', owner 'hsym', curr.user 'hsym', w(0)
prot_hsymlinks  233  TPASS  :  Expect: can create hardlink '.../hsym.hs_w' to '.../tmp_hsym/link_149', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  234  TPASS  :  Expect: can create hardlink '.../hsym.hs_w' to '.../tmp_hsym/link_150', owner 'hsym', curr.user 'hsym', w(0)
prot_hsymlinks  235  TPASS  :  Expect: can follow symlink '.../link_151', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  236  TPASS  :  Expect: can follow symlink '.../link_151', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  237  TPASS  :  Expect: can follow symlink '.../link_152', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  238  TPASS  :  Expect: can follow symlink '.../link_152', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  239  TPASS  :  Expect: can follow symlink '.../tmp_root/link_153', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  240  TPASS  :  Expect: can follow symlink '.../tmp_root/link_153', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  241  TPASS  :  Expect: can't follow symlink '.../tmp_root/link_154', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  242  TPASS  :  Expect: can follow symlink '.../tmp_root/link_154', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  243  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_155', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  244  TPASS  :  Expect: can't follow symlink '.../tmp_hsym/link_155', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  245  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_156', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  246  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_156', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  247  TPASS  :  Expect: can follow symlink '.../link_157', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  248  TPASS  :  Expect: can follow symlink '.../link_157', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  249  TPASS  :  Expect: can follow symlink '.../link_158', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  250  TPASS  :  Expect: can follow symlink '.../link_158', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  251  TPASS  :  Expect: can follow symlink '.../tmp_root/link_159', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  252  TPASS  :  Expect: can follow symlink '.../tmp_root/link_159', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  253  TPASS  :  Expect: can't follow symlink '.../tmp_root/link_160', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  254  TPASS  :  Expect: can follow symlink '.../tmp_root/link_160', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  255  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_161', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  256  TPASS  :  Expect: can't follow symlink '.../tmp_hsym/link_161', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  257  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_162', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  258  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_162', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  259  TPASS  :  Expect: can create hardlink '.../hsym/local_hsym.hs' to '.../link_163', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  260  TPASS  :  Expect: can create hardlink '.../hsym/local_hsym.hs' to '.../link_164', owner 'hsym', curr.user 'hsym', w(1)
prot_hsymlinks  261  TPASS  :  Expect: can create hardlink '.../hsym/local_hsym.hs' to '.../tmp_root/link_165', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  262  TPASS  :  Expect: can create hardlink '.../hsym/local_hsym.hs' to '.../tmp_root/link_166', owner 'hsym', curr.user 'hsym', w(1)
prot_hsymlinks  263  TPASS  :  Expect: can create hardlink '.../hsym/local_hsym.hs' to '.../tmp_hsym/link_167', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  264  TPASS  :  Expect: can create hardlink '.../hsym/local_hsym.hs' to '.../tmp_hsym/link_168', owner 'hsym', curr.user 'hsym', w(1)
prot_hsymlinks  265  TPASS  :  Expect: can follow symlink '.../link_169', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  266  TPASS  :  Expect: can follow symlink '.../link_169', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  267  TPASS  :  Expect: can follow symlink '.../link_170', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  268  TPASS  :  Expect: can follow symlink '.../link_170', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  269  TPASS  :  Expect: can follow symlink '.../tmp_root/link_171', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  270  TPASS  :  Expect: can follow symlink '.../tmp_root/link_171', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  271  TPASS  :  Expect: can't follow symlink '.../tmp_root/link_172', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  272  TPASS  :  Expect: can follow symlink '.../tmp_root/link_172', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  273  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_173', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  274  TPASS  :  Expect: can't follow symlink '.../tmp_hsym/link_173', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  275  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_174', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  276  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_174', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  277  TPASS  :  Expect: can create hardlink '.../tmp_root/hsym.hs' to '.../link_175', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  278  TPASS  :  Expect: can create hardlink '.../tmp_root/hsym.hs' to '.../link_176', owner 'hsym', curr.user 'hsym', w(1)
prot_hsymlinks  279  TPASS  :  Expect: can create hardlink '.../tmp_root/hsym.hs' to '.../tmp_root/link_177', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  280  TPASS  :  Expect: can create hardlink '.../tmp_root/hsym.hs' to '.../tmp_root/link_178', owner 'hsym', curr.user 'hsym', w(1)
prot_hsymlinks  281  TPASS  :  Expect: can create hardlink '.../tmp_root/hsym.hs' to '.../tmp_hsym/link_179', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  282  TPASS  :  Expect: can create hardlink '.../tmp_root/hsym.hs' to '.../tmp_hsym/link_180', owner 'hsym', curr.user 'hsym', w(1)
prot_hsymlinks  283  TPASS  :  Expect: can follow symlink '.../link_181', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  284  TPASS  :  Expect: can follow symlink '.../link_181', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  285  TPASS  :  Expect: can follow symlink '.../link_182', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  286  TPASS  :  Expect: can follow symlink '.../link_182', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  287  TPASS  :  Expect: can follow symlink '.../tmp_root/link_183', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  288  TPASS  :  Expect: can follow symlink '.../tmp_root/link_183', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  289  TPASS  :  Expect: can't follow symlink '.../tmp_root/link_184', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  290  TPASS  :  Expect: can follow symlink '.../tmp_root/link_184', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  291  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_185', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  292  TPASS  :  Expect: can't follow symlink '.../tmp_hsym/link_185', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  293  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_186', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  294  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_186', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  295  TPASS  :  Expect: can create hardlink '.../tmp_root/hsym.hs_w' to '.../link_187', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  296  TPASS  :  Expect: can create hardlink '.../tmp_root/hsym.hs_w' to '.../link_188', owner 'hsym', curr.user 'hsym', w(0)
prot_hsymlinks  297  TPASS  :  Expect: can create hardlink '.../tmp_root/hsym.hs_w' to '.../tmp_root/link_189', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  298  TPASS  :  Expect: can create hardlink '.../tmp_root/hsym.hs_w' to '.../tmp_root/link_190', owner 'hsym', curr.user 'hsym', w(0)
prot_hsymlinks  299  TPASS  :  Expect: can create hardlink '.../tmp_root/hsym.hs_w' to '.../tmp_hsym/link_191', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  300  TPASS  :  Expect: can create hardlink '.../tmp_root/hsym.hs_w' to '.../tmp_hsym/link_192', owner 'hsym', curr.user 'hsym', w(0)
prot_hsymlinks  301  TPASS  :  Expect: can follow symlink '.../link_193', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  302  TPASS  :  Expect: can follow symlink '.../link_193', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  303  TPASS  :  Expect: can follow symlink '.../link_194', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  304  TPASS  :  Expect: can follow symlink '.../link_194', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  305  TPASS  :  Expect: can follow symlink '.../tmp_root/link_195', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  306  TPASS  :  Expect: can follow symlink '.../tmp_root/link_195', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  307  TPASS  :  Expect: can't follow symlink '.../tmp_root/link_196', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  308  TPASS  :  Expect: can follow symlink '.../tmp_root/link_196', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  309  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_197', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  310  TPASS  :  Expect: can't follow symlink '.../tmp_hsym/link_197', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  311  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_198', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  312  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_198', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  313  TPASS  :  Expect: can follow symlink '.../link_199', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  314  TPASS  :  Expect: can follow symlink '.../link_199', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  315  TPASS  :  Expect: can follow symlink '.../link_200', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  316  TPASS  :  Expect: can follow symlink '.../link_200', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  317  TPASS  :  Expect: can follow symlink '.../tmp_root/link_201', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  318  TPASS  :  Expect: can follow symlink '.../tmp_root/link_201', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  319  TPASS  :  Expect: can't follow symlink '.../tmp_root/link_202', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  320  TPASS  :  Expect: can follow symlink '.../tmp_root/link_202', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  321  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_203', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  322  TPASS  :  Expect: can't follow symlink '.../tmp_hsym/link_203', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  323  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_204', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  324  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_204', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  325  TPASS  :  Expect: can create hardlink '.../tmp_root/hsym/local_hsym.hs' to '.../link_205', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  326  TPASS  :  Expect: can create hardlink '.../tmp_root/hsym/local_hsym.hs' to '.../link_206', owner 'hsym', curr.user 'hsym', w(1)
prot_hsymlinks  327  TPASS  :  Expect: can create hardlink '.../tmp_root/hsym/local_hsym.hs' to '.../tmp_root/link_207', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  328  TPASS  :  Expect: can create hardlink '.../tmp_root/hsym/local_hsym.hs' to '.../tmp_root/link_208', owner 'hsym', curr.user 'hsym', w(1)
prot_hsymlinks  329  TPASS  :  Expect: can create hardlink '.../tmp_root/hsym/local_hsym.hs' to '.../tmp_hsym/link_209', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  330  TPASS  :  Expect: can create hardlink '.../tmp_root/hsym/local_hsym.hs' to '.../tmp_hsym/link_210', owner 'hsym', curr.user 'hsym', w(1)
prot_hsymlinks  331  TPASS  :  Expect: can follow symlink '.../link_211', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  332  TPASS  :  Expect: can follow symlink '.../link_211', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  333  TPASS  :  Expect: can follow symlink '.../link_212', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  334  TPASS  :  Expect: can follow symlink '.../link_212', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  335  TPASS  :  Expect: can follow symlink '.../tmp_root/link_213', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  336  TPASS  :  Expect: can follow symlink '.../tmp_root/link_213', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  337  TPASS  :  Expect: can't follow symlink '.../tmp_root/link_214', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  338  TPASS  :  Expect: can follow symlink '.../tmp_root/link_214', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  339  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_215', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  340  TPASS  :  Expect: can't follow symlink '.../tmp_hsym/link_215', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  341  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_216', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  342  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_216', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  343  TPASS  :  Expect: can create hardlink '.../tmp_hsym/hsym.hs' to '.../link_217', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  344  TPASS  :  Expect: can create hardlink '.../tmp_hsym/hsym.hs' to '.../link_218', owner 'hsym', curr.user 'hsym', w(1)
prot_hsymlinks  345  TPASS  :  Expect: can create hardlink '.../tmp_hsym/hsym.hs' to '.../tmp_root/link_219', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  346  TPASS  :  Expect: can create hardlink '.../tmp_hsym/hsym.hs' to '.../tmp_root/link_220', owner 'hsym', curr.user 'hsym', w(1)
prot_hsymlinks  347  TPASS  :  Expect: can create hardlink '.../tmp_hsym/hsym.hs' to '.../tmp_hsym/link_221', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  348  TPASS  :  Expect: can create hardlink '.../tmp_hsym/hsym.hs' to '.../tmp_hsym/link_222', owner 'hsym', curr.user 'hsym', w(1)
prot_hsymlinks  349  TPASS  :  Expect: can follow symlink '.../link_223', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  350  TPASS  :  Expect: can follow symlink '.../link_223', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  351  TPASS  :  Expect: can follow symlink '.../link_224', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  352  TPASS  :  Expect: can follow symlink '.../link_224', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  353  TPASS  :  Expect: can follow symlink '.../tmp_root/link_225', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  354  TPASS  :  Expect: can follow symlink '.../tmp_root/link_225', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  355  TPASS  :  Expect: can't follow symlink '.../tmp_root/link_226', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  356  TPASS  :  Expect: can follow symlink '.../tmp_root/link_226', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  357  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_227', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  358  TPASS  :  Expect: can't follow symlink '.../tmp_hsym/link_227', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  359  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_228', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  360  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_228', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  361  TPASS  :  Expect: can create hardlink '.../tmp_hsym/hsym.hs_w' to '.../link_229', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  362  TPASS  :  Expect: can create hardlink '.../tmp_hsym/hsym.hs_w' to '.../link_230', owner 'hsym', curr.user 'hsym', w(0)
prot_hsymlinks  363  TPASS  :  Expect: can create hardlink '.../tmp_hsym/hsym.hs_w' to '.../tmp_root/link_231', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  364  TPASS  :  Expect: can create hardlink '.../tmp_hsym/hsym.hs_w' to '.../tmp_root/link_232', owner 'hsym', curr.user 'hsym', w(0)
prot_hsymlinks  365  TPASS  :  Expect: can create hardlink '.../tmp_hsym/hsym.hs_w' to '.../tmp_hsym/link_233', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  366  TPASS  :  Expect: can create hardlink '.../tmp_hsym/hsym.hs_w' to '.../tmp_hsym/link_234', owner 'hsym', curr.user 'hsym', w(0)
prot_hsymlinks  367  TPASS  :  Expect: can follow symlink '.../link_235', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  368  TPASS  :  Expect: can follow symlink '.../link_235', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  369  TPASS  :  Expect: can follow symlink '.../link_236', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  370  TPASS  :  Expect: can follow symlink '.../link_236', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  371  TPASS  :  Expect: can follow symlink '.../tmp_root/link_237', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  372  TPASS  :  Expect: can follow symlink '.../tmp_root/link_237', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  373  TPASS  :  Expect: can't follow symlink '.../tmp_root/link_238', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  374  TPASS  :  Expect: can follow symlink '.../tmp_root/link_238', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  375  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_239', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  376  TPASS  :  Expect: can't follow symlink '.../tmp_hsym/link_239', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  377  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_240', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  378  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_240', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  379  TPASS  :  Expect: can follow symlink '.../link_241', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  380  TPASS  :  Expect: can follow symlink '.../link_241', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  381  TPASS  :  Expect: can follow symlink '.../link_242', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  382  TPASS  :  Expect: can follow symlink '.../link_242', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  383  TPASS  :  Expect: can follow symlink '.../tmp_root/link_243', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  384  TPASS  :  Expect: can follow symlink '.../tmp_root/link_243', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  385  TPASS  :  Expect: can't follow symlink '.../tmp_root/link_244', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'root'
prot_hsymlinks  386  TPASS  :  Expect: can follow symlink '.../tmp_root/link_244', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'root'
prot_hsymlinks  387  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_245', owner 'root', src.owner 'hsym', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  388  TPASS  :  Expect: can't follow symlink '.../tmp_hsym/link_245', owner 'root', src.owner 'hsym', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  389  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_246', owner 'hsym', src.owner 'hsym', curr.user 'root', dir.owner 'hsym'
prot_hsymlinks  390  TPASS  :  Expect: can follow symlink '.../tmp_hsym/link_246', owner 'hsym', src.owner 'hsym', curr.user 'hsym', dir.owner 'hsym'
prot_hsymlinks  391  TPASS  :  Expect: can create hardlink '.../tmp_hsym/hsym/local_hsym.hs' to '.../link_247', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  392  TPASS  :  Expect: can create userdel: hsym mail spool (/var/mail/hsym) not found
userdel: hsym home directory (/home/hsym) not found
hardlink '.../tmp_hsym/hsym/local_hsym.hs' to '.../link_248', owner 'hsym', curr.user 'hsym', w(1)
prot_hsymlinks  393  TPASS  :  Expect: can create hardlink '.../tmp_hsym/hsym/local_hsym.hs' to '.../tmp_root/link_249', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  394  TPASS  :  Expect: can create hardlink '.../tmp_hsym/hsym/local_hsym.hs' to '.../tmp_root/link_250', owner 'hsym', curr.user 'hsym', w(1)
prot_hsymlinks  395  TPASS  :  Expect: can create hardlink '.../tmp_hsym/hsym/local_hsym.hs' to '.../tmp_hsym/link_251', owner 'hsym', curr.user 'root', w(1)
prot_hsymlinks  396  TPASS  :  Expect: can create hardlink '.../tmp_hsym/hsym/local_hsym.hs' to '.../tmp_hsym/link_252', owner 'hsym', curr.user 'hsym', w(1)
prot_hsymlinks    0  TINFO  :  All test-cases have been completed, summary:
 - symlinks  test:	PASS
 - hardlinks test:	PASS
prot_hsymlinks    0  TINFO  :  Disable protected hardlinks mode back
prot_hsymlinks    0  TINFO  :  Disable protected symlinks mode back
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=2
<<<test_end>>>
<<<test_start>>>
tag=pselect01 stime=1411895669
cmdline="pselect01"
contacts=""
analysis=exit
<<<test_output>>>
pselect01    1  TPASS  :  pselect() succeeded retval=0
pselect01    0  TINFO  :  Testing basic pselect sanity,Sleeping for 1 secs
pselect01    2  TPASS  :  Sleep time was correct (1.501109/1 < 20 %)
pselect01    0  TINFO  :  Testing basic pselect sanity,Sleeping for 2 secs
pselect01    3  TPASS  :  Sleep time was correct (2.502112/2 < 20 %)
pselect01    0  TINFO  :  Testing basic pselect sanity,Sleeping for 3 secs
pselect01    4  TPASS  :  Sleep time was correct (3.503108/3 < 20 %)
pselect01    0  TINFO  :  Testing basic pselect sanity,Sleeping for 4 secs
pselect01    5  TPASS  :  Sleep time was correct (4.504108/4 < 20 %)
pselect01    0  TINFO  :  Testing basic pselect sanity,Sleeping for 100000000 nano secs
pselect01    6  TPASS  :  Sleep time was correct
pselect01    0  TINFO  :  Testing basic pselect sanity,Sleeping for 200000000 nano secs
pselect01    7  TPASS  :  Sleep time was correct
pselect01    0  TINFO  :  Testing basic pselect sanity,Sleeping for 300000000 nano secs
pselect01    8  TPASS  :  Sleep time was correct
pselect01    0  TINFO  :  Testing basic pselect sanity,Sleeping for 400000000 nano secs
pselect01    9  TPASS  :  Sleep time was correct
<<<execution_status>>>
initiation_status="ok"
duration=11 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pselect01_64 stime=1411895680
cmdline="pselect01_64"
contacts=""
analysis=exit
<<<test_output>>>
pselect01_64    1  TPASS  :  pselect() succeeded retval=0
pselect01_64    0  TINFO  :  Testing basic pselect sanity,Sleeping for 1 secs
pselect01_64    2  TPASS  :  Sleep time was correct (1.501109/1 < 20 %)
pselect01_64    0  TINFO  :  Testing basic pselect sanity,Sleeping for 2 secs
pselect01_64    3  TPASS  :  Sleep time was correct (2.502111/2 < 20 %)
pselect01_64    0  TINFO  :  Testing basic pselect sanity,Sleeping for 3 secs
pselect01_64    4  TPASS  :  Sleep time was correct (3.503111/3 < 20 %)
pselect01_64    0  TINFO  :  Testing basic pselect sanity,Sleeping for 4 secs
pselect01_64    5  TPASS  :  Sleep time was correct (4.504111/4 < 20 %)
pselect01_64    0  TINFO  :  Testing basic pselect sanity,Sleeping for 100000000 nano secs
pselect01_64    6  TPASS  :  Sleep time was correct
pselect01_64    0  TINFO  :  Testing basic pselect sanity,Sleeping for 200000000 nano secs
pselect01_64    7  TPASS  :  Sleep time was correct
pselect01_64    0  TINFO  :  Testing basic pselect sanity,Sleeping for 300000000 nano secs
pselect01_64    8  TPASS  :  Sleep time was correct
pselect01_64    0  TINFO  :  Testing basic pselect sanity,Sleeping for 400000000 nano secs
pselect01_64    9  TPASS  :  Sleep time was correct
<<<execution_status>>>
initiation_status="ok"
duration=11 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pselect02 stime=1411895691
cmdline="pselect02"
contacts=""
analysis=exit
<<<test_output>>>
pselect02    1  TPASS  :  pselect() failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
pselect02    2  TPASS  :  pselect() failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
pselect02    3  TPASS  :  pselect() failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pselect02_64 stime=1411895691
cmdline="pselect02_64"
contacts=""
analysis=exit
<<<test_output>>>
pselect02_64    1  TPASS  :  pselect() failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
pselect02_64    2  TPASS  :  pselect() failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
pselect02_64    3  TPASS  :  pselect() failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=ptrace01 stime=1411895691
cmdline="ptrace01"
contacts=""
analysis=exit
<<<test_output>>>
ptrace01    1  TPASS  :  Test Passed
ptrace01    2  TPASS  :  Test Passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=ptrace02 stime=1411895691
cmdline="ptrace02"
contacts=""
analysis=exit
<<<test_output>>>
ptrace02    1  TPASS  :  Test Passed
ptrace02    2  TPASS  :  Test Passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=ptrace03 stime=1411895691
cmdline="ptrace03"
contacts=""
analysis=exit
<<<test_output>>>
ptrace03    1  TCONF  :  ptrace03.c:142: this kernel allows to trace init
ptrace03    2  TPASS  :  Test Passed
ptrace03    3  TPASS  :  Test Passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=ptrace04 stime=1411895691
cmdline="ptrace04"
contacts=""
analysis=exit
<<<test_output>>>
ptrace04    1  TCONF  :  ptrace04.c:106: test not supported for your arch (yet)
ptrace04    2  TCONF  :  ptrace04.c:106: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=ptrace05 stime=1411895691
cmdline="ptrace05"
contacts=""
analysis=exit
<<<test_output>>>
ptrace05    0  TINFO  :  [child] Sending kill(.., 0)
ptrace05    1  TPASS  :  kill(.., 0) exited with 0, as expected.
ptrace05    2  TPASS  :  Stopped as expected
ptrace05    3  TPASS  :  Stopped as expected
ptrace05    4  TPASS  :  Stopped as expected
ptrace05    5  TPASS  :  Stopped as expected
ptrace05    6  TPASS  :  Stopped as expected
ptrace05    7  TPASS  :  Stopped as expected
ptrace05    8  TPASS  :  Stopped as expected
ptrace05    9  TPASS  :  Stopped as expected
ptrace05   10  TPASS  :  Killed with SIGKILL, as expected.
ptrace05   11  TPASS  :  Stopped as expected
ptrace05   12  TPASS  :  Stopped as expected
ptrace05   13  TPASS  :  Stopped as expected
ptrace05   14  TPASS  :  Stopped as expected
ptrace05   15  TPASS  :  Stopped as expected
ptrace05   16  TPASS  :  Stopped as expected
ptrace05   17  TPASS  :  Stopped as expected
ptrace05   18  TPASS  :  Stopped as expected
ptrace05   19  TPASS  :  Stopped as expected
ptrace05   20  TPASS  :  Stopped as expected
ptrace05   21  TPASS  :  Stopped as expected
ptrace05   22  TPASS  :  Stopped as expected
ptrace05   23  TPASS  :  Stopped as expected
ptrace05   24  TPASS  :  Stopped as expected
ptrace05   25  TPASS  :  Stopped as expected
ptrace05   26  TPASS  :  Stopped as expected
ptrace05   27  TPASS  :  Stopped as expected
ptrace05   28  TPASS  :  Stopped as expected
ptrace05   29  TPASS  :  Stopped as expected
ptrace05   30  TPASS  :  Stopped as expected
ptrace05   31  TPASS  :  Stopped as expected
ptrace05   32  TPASS  :  Stopped as expected
ptrace05   33  TPASS  :  Stopped as expected
ptrace05   34  TPASS  :  Stopped as expected
ptrace05   35  TPASS  :  Stopped as expected
ptrace05   36  TPASS  :  Stopped as expected
ptrace05   37  TPASS  :  Stopped as expected
ptrace05   38  TPASS  :  Stopped as expected
ptrace05   39  TPASS  :  Stopped as expected
ptrace05   40  TPASS  :  Stopped as expected
ptrace05   41  TPASS  :  Stopped as expected
ptrace05   42  TPASS  :  Stopped as expected
ptrace05   43  TPASS  :  Stopped as expected
ptrace05   44  TPASS  :  Stopped as expected
ptrace05   45  TPASS  :  Stopped as expected
ptrace05   46  TPASS  :  Stopped as expected
ptrace05   47  TPASS  :  Stopped as expected
ptrace05   48  TPASS  :  Stopped as expected
ptrace05   49  TPASS  :  Stopped as expected
ptrace05   50  TPASS  :  Stopped as expected
ptrace05   51  TPASS  :  Stopped as expected
ptrace05   52  TPASS  :  Stopped as expected
ptrace05   53  TPASS  :  Stopped as expected
ptrace05   54  TPASS  :  Stopped as expected
ptrace05   55  TPASS  :  Stopped as expected
ptrace05   56  TPASS  :  Stopped as expected
ptrace05   57  TPASS  :  Stopped as expected
ptrace05   58  TPASS  :  Stopped as expected
ptrace05   59  TPASS  :  Stopped as expected
ptrace05   60  TPASS  :  Stopped as expected
ptrace05   61  TPASS  :  Stopped as expected
ptrace05   62  TPASS  :  Stopped as expected
ptrace05   63  TPASS  :  Stopped as expected
ptrace05   64  TPASS  :  Stopped as expected
ptrace05   65  TPASS  :  Stopped as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=pwrite01 stime=1411895691
cmdline="pwrite01"
contacts=""
analysis=exit
<<<test_output>>>
pwrite01    1  TPASS  :  Functionality of pwrite() successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pwrite02 stime=1411895691
cmdline="pwrite02"
contacts=""
analysis=exit
<<<test_output>>>
pwrite02    1  TPASS  :  pwrite failed as expected: 29 - Illegal seek
pwrite02    2  TPASS  :  pwrite failed as expected: 22 - Invalid argument
pwrite02    3  TPASS  :  pwrite failed as expected: 9 - Bad file descriptor
pwrite02    4  TPASS  :  pwrite failed as expected: 9 - Bad file descriptor
pwrite02    5  TPASS  :  pwrite failed as expected: 14 - Bad address
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pwrite04 stime=1411895691
cmdline="pwrite04"
contacts=""
analysis=exit
<<<test_output>>>
pwrite04    1  TPASS  :  O_APPEND test passed.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pwrite01_64 stime=1411895691
cmdline="pwrite01_64"
contacts=""
analysis=exit
<<<test_output>>>
pwrite01    1  TPASS  :  Functionality of pwrite() successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pwrite02_64 stime=1411895691
cmdline="pwrite02_64"
contacts=""
analysis=exit
<<<test_output>>>
pwrite02_64    1  TPASS  :  pwrite failed as expected: 29 - Illegal seek
pwrite02_64    2  TPASS  :  pwrite failed as expected: 22 - Invalid argument
pwrite02_64    3  TPASS  :  pwrite failed as expected: 9 - Bad file descriptor
pwrite02_64    4  TPASS  :  pwrite failed as expected: 9 - Bad file descriptor
pwrite02_64    5  TPASS  :  pwrite failed as expected: 14 - Bad address
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=pwrite04_64 stime=1411895691
cmdline="pwrite04_64"
contacts=""
analysis=exit
<<<test_output>>>
pwrite04    1  TPASS  :  O_APPEND test passed.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=quotactl01 stime=1411895691
cmdline="quotactl01"
contacts=""
analysis=exit
<<<test_output>>>
quotactl01    1  TCONF  :  quotactl01.c:171: failed to enable quotas on block device: (null); 1. Ensure that the device is mounted with the quota option. 2. Check the filesystem status with `quotacheck (null)': errno=ENODEV(19): No such device
quotactl01    2  TCONF  :  quotactl01.c:171: Remaining cases not appropriate for configuration: errno=ENODEV(19): No such device
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=quotactl02 stime=1411895691
cmdline="quotactl02"
contacts=""
analysis=exit
<<<test_output>>>
quotactl02    0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
quotactl02    0  TINFO  :  Appending '-f' flag to mkfs.xfs
quotactl02    0  TINFO  :  Formatting /dev/loop0 with xfs extra opts=''
quotactl02    1  TPASS  :  enforcement is off
quotactl02    2  TPASS  :  enforcement is on
quotactl02    3  TPASS  :  get the right quota type
quotactl02    4  TPASS  :  quotactl works fine with Q_XSETQLIM
quotactl02    5  TPASS  :  get correct qstat version
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=read01 stime=1411895691
cmdline="read01"
contacts=""
analysis=exit
<<<test_output>>>
read01      1  TPASS  :  read(pfds) returned 512
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=read02 stime=1411895691
cmdline="read02"
contacts=""
analysis=exit
<<<test_output>>>
read02      1  TPASS  :  expected failure: TEST_ERRNO=EBADF(9): Bad file descriptor
read02      2  TPASS  :  expected failure: TEST_ERRNO=EISDIR(21): Is a directory
read02      3  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
read02      4  TCONF  :  read02.c:140: O_DIRECT not supported on TMPFS filesystem
read02      5  TCONF  :  read02.c:140: O_DIRECT not supported on TMPFS filesystem
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=read03 stime=1411895691
cmdline="read03"
contacts=""
analysis=exit
<<<test_output>>>
read03      0  TINFO  :  read() succeded in setting errno to EAGAIN
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=read04 stime=1411895691
cmdline="read04"
contacts=""
analysis=exit
<<<test_output>>>
read04      1  TPASS  :  functionality of read() is correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=readahead01 stime=1411895691
cmdline="readahead01"
contacts=""
analysis=exit
<<<test_output>>>
readahead01    0  TINFO  :  test_bad_fd -1
readahead01    1  TPASS  :  expected ret success - returned value = -1
readahead01    2  TPASS  :  expected failure: TEST_ERRNO=EBADF(9): Bad file descriptor
readahead01    0  TINFO  :  test_bad_fd O_WRONLY
readahead01    3  TPASS  :  expected ret success - returned value = -1
readahead01    4  TPASS  :  expected failure: TEST_ERRNO=EBADF(9): Bad file descriptor
readahead01    0  TINFO  :  test_invalid_fd pipe
readahead01    5  TPASS  :  expected ret success - returned value = -1
readahead01    6  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
readahead01    0  TINFO  :  test_invalid_fd socket
readahead01    7  TPASS  :  expected ret success - returned value = -1
readahead01    8  TPASS  :  expected failure: TEST_ERRNO=EINVAL(22): Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=readahead02 stime=1411895691
cmdline="readahead02"
contacts=""
analysis=exit
<<<test_output>>>
readahead02    0  TINFO  :  creating test file of size: 67108864
readahead02    0  TINFO  :  read_testfile(0)
readahead02    0  TINFO  :  read_testfile(1)
readahead02    1  TFAIL  :  readahead02.c:85: unexpected failure - returned value = -1, expected: 0
readahead02    2  TPASS  :  offset is still at 0 as expected
readahead02    0  TINFO  :  read_testfile(0) took: 9917 usec
readahead02    0  TINFO  :  read_testfile(1) took: 9737 usec
readahead02    0  TINFO  :  read_testfile(0) read: 0 bytes
readahead02    0  TINFO  :  read_testfile(1) read: 0 bytes
readahead02    3  TFAIL  :  readahead02.c:307: readahead failed to save any I/O
readahead02    0  TINFO  :  cache can hold at least: 0 kB
readahead02    0  TINFO  :  read_testfile(0) used cache: 0 kB
readahead02    0  TINFO  :  read_testfile(1) used cache: 0 kB
readahead02    4  TCONF  :  readahead02.c:328: Page cache on your system is too small to hold whole testfile.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=33 corefile=no
cutime=0 cstime=11
<<<test_end>>>
<<<test_start>>>
tag=readdir01 stime=1411895691
cmdline="readdir01"
contacts=""
analysis=exit
<<<test_output>>>
readdir01    1  TPASS  :  found all 10 that were created
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=readdir02 stime=1411895691
cmdline="readdir02"
contacts=""
analysis=exit
<<<test_output>>>
readdir02    1  TPASS  :  expected failure - errno = 9 : Bad file descriptor
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=readdir21 stime=1411895691
cmdline="readdir21"
contacts=""
analysis=exit
<<<test_output>>>
readdir21    1  TCONF  :  readdir21.c:129: syscall __NR_readdir not supported on your arch
readdir21    2  TCONF  :  readdir21.c:129: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=readlink01A stime=1411895691
cmdline="symlink01 -T readlink01"
contacts=""
analysis=exit
<<<test_output>>>
readlink01    1  TPASS  :  Reading of symbolic link file contents checks out ok
readlink01    2  TPASS  :  Reading of symbolic link file contents checks out ok
readlink01    3  TPASS  :  Reading a symbolic link which exceeds maximum pathname error is caught
readlink01    4  TPASS  :  Reading a nonsymbolic link file error condition is caught.  EINVAL is returned
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=readlink01 stime=1411895691
cmdline="readlink01"
contacts=""
analysis=exit
<<<test_output>>>
readlink01    1  TPASS  :  readlink() functionality on 'slink_file' is correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=readlink02 stime=1411895691
cmdline="readlink02"
contacts=""
analysis=exit
<<<test_output>>>
readlink02    1  TPASS  :  readlink(./sl_29412, buf, 255) returned 13
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=readlink03 stime=1411895691
cmdline="readlink03"
contacts=""
analysis=exit
<<<test_output>>>
readlink03    1  TPASS  :  readlink() failed as expected: TEST_ERRNO=EACCES(13): Permission denied
readlink03    2  TPASS  :  readlink() failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
readlink03    3  TPASS  :  readlink() failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
readlink03    4  TPASS  :  readlink() failed as expected: TEST_ERRNO=ENAMETOOLONG(36): File name too long
readlink03    5  TPASS  :  readlink() failed as expected: TEST_ERRNO=ENOENT(2): No such file or directory
readlink03    6  TPASS  :  readlink() failed as expected: TEST_ERRNO=ENOTDIR(20): Not a directory
readlink03    7  TPASS  :  readlink() failed as expected: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=readlink04 stime=1411895691
cmdline="readlink04"
contacts=""
analysis=exit
<<<test_output>>>
readlink04    1  TPASS  :  readlink() functionality on 'slink_file' is correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=readlinkat01 stime=1411895691
cmdline="readlinkat01"
contacts=""
analysis=exit
<<<test_output>>>
readlinkat01    1  TPASS  :  readlinkat() returned 13: TEST_ERRNO=SUCCESS(0): Success
readlinkat01    2  TPASS  :  readlinkat() returned 13: TEST_ERRNO=SUCCESS(0): Success
readlinkat01    3  TPASS  :  readlinkat() returned -1: TEST_ERRNO=ENOTDIR(20): Not a directory
readlinkat01    4  TPASS  :  readlinkat() returned -1: TEST_ERRNO=EBADF(9): Bad file descriptor
readlinkat01    5  TPASS  :  readlinkat() returned 13: TEST_ERRNO=SUCCESS(0): Success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=readlinkat02 stime=1411895691
cmdline="readlinkat02"
contacts=""
analysis=exit
<<<test_output>>>
readlinkat02    1  TPASS  :  readlinkat failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
readlinkat02    2  TPASS  :  readlinkat failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
readlinkat02    3  TPASS  :  readlinkat failed as expected: TEST_ERRNO=ENOTDIR(20): Not a directory
readlinkat02    4  TPASS  :  readlinkat failed as expected: TEST_ERRNO=ENOTDIR(20): Not a directory
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=readv01 stime=1411895691
cmdline="readv01"
contacts=""
analysis=exit
<<<test_output>>>
readv01     1  TPASS  :  readv read 0 io vectors
readv01     2  TPASS  :  readv passed reading 64 bytes followed by two NULL vectors
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=readv02 stime=1411895691
cmdline="readv02"
contacts=""
analysis=exit
<<<test_output>>>
readv02     1  TPASS  :  got EINVAL
readv02     2  TPASS  :  got EFAULT
readv02     3  TPASS  :  got EBADF
readv02     4  TPASS  :  got EINVAL
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=readv03 stime=1411895691
cmdline="readv03"
contacts=""
analysis=exit
<<<test_output>>>
readv03     1  TPASS  :  got EISDIR
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=reboot01 stime=1411895691
cmdline="reboot01"
contacts=""
analysis=exit
<<<test_output>>>
reboot01    1  TPASS  :  reboot(2) Passed for option LINUX_REBOOT_CMD_CAD_ON
reboot01    2  TPASS  :  reboot(2) Passed for option LINUX_REBOOT_CMD_CAD_OFF
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=reboot02 stime=1411895691
cmdline="reboot02"
contacts=""
analysis=exit
<<<test_output>>>
reboot02    1  TPASS  :  reboot(2) expected failure; Got errno - EINVAL : Invalid flag
reboot02    1  TPASS  :  reboot(2) expected failure; Got errno - EPERM  : Permission denied
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=recv01 stime=1411895691
cmdline="recv01"
contacts=""
analysis=exit
<<<test_output>>>
recv01      1  TPASS  :  bad file descriptor successful
recv01      2  TPASS  :  invalid socket successful
recv01      3  TPASS  :  invalid recv buffer successful
recv01      4  TFAIL  :  recv01.c:142: invalid flags set ; returned -1 (expected -1), errno 11 (expected 22)
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=1 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=recvfrom01 stime=1411895691
cmdline="recvfrom01"
contacts=""
analysis=exit
<<<test_output>>>
recvfrom01    1  TPASS  :  bad file descriptor successful
recvfrom01    2  TPASS  :  invalid socket successful
recvfrom01    3  TPASS  :  invalid socket buffer successful
recvfrom01    4  TFAIL  :  recvfrom01.c:164: invalid socket length ; returned -1 (expected -1), errno 11 (expected 22)
recvfrom01    5  TPASS  :  invalid recv buffer successful
recvfrom01    6  TFAIL  :  recvfrom01.c:164: invalid flags set ; returned -1 (expected -1), errno 11 (expected 22)
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=1 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=recvmsg01 stime=1411895691
cmdline="recvmsg01"
contacts=""
analysis=exit
<<<test_output>>>
recvmsg01    1  TPASS  :  bad file descriptor successful
recvmsg01    2  TPASS  :  invalid socket successful
recvmsg01    3  TPASS  :  invalid socket buffer successful
recvmsg01    4  TPASS  :  invalid socket length successful
recvmsg01    5  TPASS  :  invalid recv buffer successful
recvmsg01    6  TPASS  :  invalid iovec buffer successful
recvmsg01    7  TPASS  :  invalid iovec count successful
recvmsg01    8  TPASS  :  rights reception successful
recvmsg01    9  TFAIL  :  recvmsg01.c:228: invalid flags set ; returned -1 (expected -1), errno 11 (expected 22)
recvmsg01   10  TPASS  :  invalid cmsg length successful
recvmsg01   11  TPASS  :  large cmesg length successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=1 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=remap_file_pages01 stime=1411895691
cmdline="remap_file_pages01"
contacts=""
analysis=exit
<<<test_output>>>
remap_file_pages01    1  TPASS  :  Non-Linear shm file OK
remap_file_pages01    2  TPASS  :  Non-Linear /tmp/ file OK
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=remap_file_pages02 stime=1411895691
cmdline="remap_file_pages02"
contacts=""
analysis=exit
<<<test_output>>>
remap_file_pages02    1  TPASS  :  remap_file_pages(2) expected failure; Got errno - EINVAL : start does not refer to a valid mapping created with the MAP_SHARED flag
remap_file_pages02    2  TPASS  :  remap_file_pages(2) expected failure; Got errno - EINVAL : start is invalid
remap_file_pages02    3  TPASS  :  remap_file_pages(2) expected failure; Got errno - EINVAL : size is invalid
remap_file_pages02    4  TPASS  :  remap_file_pages(2) expected failure; Got errno - EINVAL : prot is invalid
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=rename01 stime=1411895691
cmdline="rename01"
contacts=""
analysis=exit
<<<test_output>>>
rename01    1  TPASS  :  functionality is correct for renaming a file
rename01    2  TPASS  :  functionality is correct for renaming a directory
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=rename01A stime=1411895691
cmdline="symlink01 -T rename01"
contacts=""
analysis=exit
<<<test_output>>>
rename01    1  TPASS  :  rename(3) of symbolic link file name which points at no object file is ok
rename01    2  TPASS  :  rename(3) of symbolic link file name which points at object file is ok
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=rename02 stime=1411895691
cmdline="rename02"
contacts=""
analysis=exit
<<<test_output>>>
rename02    1  TPASS  :  rename(./tfile_29432, ./rnfile_29432) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=rename03 stime=1411895691
cmdline="rename03"
contacts=""
analysis=exit
<<<test_output>>>
rename03    1  TPASS  :  functionality is correct for renaming a file
rename03    2  TPASS  :  functionality is correct for renaming a directory
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=rename04 stime=1411895691
cmdline="rename04"
contacts=""
analysis=exit
<<<test_output>>>
rename04    1  TPASS  :  rename() returned ENOTEMPTY
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=rename05 stime=1411895691
cmdline="rename05"
contacts=""
analysis=exit
<<<test_output>>>
rename05    1  TPASS  :  rename() returned EISDIR
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=rename06 stime=1411895691
cmdline="rename06"
contacts=""
analysis=exit
<<<test_output>>>
rename06    1  TPASS  :  rename() returned EINVAL
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=rename07 stime=1411895691
cmdline="rename07"
contacts=""
analysis=exit
<<<test_output>>>
rename07    1  TPASS  :  rename() returned ENOTDIR
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=rename08 stime=1411895691
cmdline="rename08"
contacts=""
analysis=exit
<<<test_output>>>
rename08    1  TPASS  :  expected failure - errno = 14 : Bad address
rename08    2  TPASS  :  expected failure - errno = 14 : Bad address
rename08    3  TPASS  :  expected failure - errno = 14 : Bad address
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=rename09 stime=1411895691
cmdline="rename09"
contacts=""
analysis=exit
<<<test_output>>>
rename09    1  TPASS  :  rename() returned EACCES
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=rename10 stime=1411895691
cmdline="rename10"
contacts=""
analysis=exit
<<<test_output>>>
rename10    1  TPASS  :  expected failure - errno = 36 : File name too long
rename10    2  TPASS  :  expected failure - errno = 2 : No such file or directory
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=rename11 stime=1411895691
cmdline="rename11"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
rename11    0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
rename11    0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
rename11    0  TINFO  :  Failed reach the subdirs limit
rename11    1  TPASS  :  failed as expected: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
rename11    2  TPASS  :  failed as expected: TEST_ERRNO=EROFS(30): Read-only file system
rename11    3  TCONF  :  rename11.c:183: EMLINK test is not appropriate
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=4 cstime=18
<<<test_end>>>
<<<test_start>>>
tag=rename12 stime=1411895691
cmdline="rename12"
contacts=""
analysis=exit
<<<test_output>>>
rename12    1  TPASS  :  rename returned EPERM or EACCES
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=rename13 stime=1411895691
cmdline="rename13"
contacts=""
analysis=exit
<<<test_output>>>
rename13    1  TPASS  :  functionality of rename() is correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=rename14 stime=1411895691
cmdline="rename14"
contacts=""
analysis=exit
<<<test_output>>>
rename14    1  TPASS  :  Test Passed
<<<execution_status>>>
initiation_status="ok"
duration=45 termination_type=exited termination_id=0 corefile=no
cutime=204 cstime=8797
<<<test_end>>>
<<<test_start>>>
tag=renameat01 stime=1411895736
cmdline="renameat01"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
renameat01    0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
renameat01    0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
renameat01    0  TINFO  :  Failed reach the subdirs limit
renameat01    1  TPASS  :  renameat() returned the expected value: TEST_ERRNO=SUCCESS(0): Success
renameat01    2  TPASS  :  renameat() returned the expected value: TEST_ERRNO=SUCCESS(0): Success
renameat01    3  TPASS  :  renameat() returned the expected value: TEST_ERRNO=SUCCESS(0): Success
renameat01    4  TPASS  :  renameat() returned the expected value: TEST_ERRNO=EBADF(9): Bad file descriptor
renameat01    5  TPASS  :  renameat() returned the expected value: TEST_ERRNO=ENOTDIR(20): Not a directory
renameat01    6  TPASS  :  renameat() returned the expected value: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
renameat01    7  TPASS  :  renameat() returned the expected value: TEST_ERRNO=EROFS(30): Read-only file system
renameat01    8  TCONF  :  renameat01.c:215: EMLINK test is not appropriate
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=32 corefile=no
cutime=2 cstime=20
<<<test_end>>>
<<<test_start>>>
tag=rmdir01 stime=1411895737
cmdline="rmdir01"
contacts=""
analysis=exit
<<<test_output>>>
rmdir01     1  TPASS  :  directory has been removed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=rmdir02 stime=1411895737
cmdline="rmdir02"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
rmdir02     0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
rmdir02     0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
rmdir02     1  TPASS  :  rmdir() failed as expected: TEST_ERRNO=ENOTEMPTY(39): Directory not empty
rmdir02     2  TPASS  :  rmdir() failed as expected: TEST_ERRNO=ENAMETOOLONG(36): File name too long
rmdir02     3  TPASS  :  rmdir() failed as expected: TEST_ERRNO=ENOENT(2): No such file or directory
rmdir02     4  TPASS  :  rmdir() failed as expected: TEST_ERRNO=ENOTDIR(20): Not a directory
rmdir02     5  TPASS  :  rmdir() failed as expected: TEST_ERRNO=EFAULT(14): Bad address
rmdir02     6  TPASS  :  rmdir() failed as expected: TEST_ERRNO=EFAULT(14): Bad address
rmdir02     7  TPASS  :  rmdir() failed as expected: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
rmdir02     8  TPASS  :  rmdir() failed as expected: TEST_ERRNO=EROFS(30): Read-only file system
rmdir02     9  TPASS  :  rmdir() failed as expected: TEST_ERRNO=EBUSY(16): Device or resource busy
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=rmdir03 stime=1411895737
cmdline="rmdir03"
contacts=""
analysis=exit
<<<test_output>>>
rmdir03     1  TPASS  :  rmdir() produced EPERM or EACCES
rmdir03     1  TPASS  :  rmdir() produced EACCES
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=rmdir03A stime=1411895737
cmdline="symlink01 -T rmdir03"
contacts=""
analysis=exit
<<<test_output>>>
rmdir03     1  TPASS  :  rmdir(2) of object file through symbolic link file failed as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=rmdir04 stime=1411895737
cmdline="rmdir04"
contacts=""
analysis=exit
<<<test_output>>>
rmdir04     1  TPASS  :  rmdir(./dir_29466) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=rmdir05 stime=1411895737
cmdline="rmdir05"
contacts=""
analysis=exit
<<<test_output>>>
rmdir05     1  TPASS  :  rmdir(".") failed to remove the current working directory. Returned 22 : Invalid argument
rmdir05     2  TCONF  :  rmdir05.c:119: rmdir on "dir/." supported on Linux
rmdir05     3  TCONF  :  rmdir05.c:122: linked directories test not implemented on Linux
rmdir05     4  TPASS  :  rmdir() - path argument points below the minimum allocated address space failed as expected with errno 14 : Bad address
rmdir05     5  TPASS  :  rmdir() - path argument points above the maximum allocated address space failed as expected with errno 14 : Bad address
rmdir05     6  TPASS  :  rmdir("./dir_29467") removed the directory as expected.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=rt_sigaction01 stime=1411895737
cmdline="rt_sigaction01"
contacts=""
analysis=exit
<<<test_output>>>
rt_sigaction01    0  TINFO  :  signal: 34 
rt_sigaction01    1  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 34

rt_sigaction01    0  TINFO  :  signal: 34 
rt_sigaction01    2  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 34

rt_sigaction01    0  TINFO  :  signal: 34 
rt_sigaction01    3  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 34

rt_sigaction01    0  TINFO  :  signal: 34 
rt_sigaction01    4  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 34

rt_sigaction01    0  TINFO  :  signal: 34 
rt_sigaction01    5  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 34

rt_sigaction01    0  TINFO  :  signal: 35 
rt_sigaction01    6  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 35

rt_sigaction01    0  TINFO  :  signal: 35 
rt_sigaction01    7  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 35

rt_sigaction01    0  TINFO  :  signal: 35 
rt_sigaction01    8  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 35

rt_sigaction01    0  TINFO  :  signal: 35 
rt_sigaction01    9  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 35

rt_sigaction01    0  TINFO  :  signal: 35 
rt_sigaction01   10  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 35

rt_sigaction01    0  TINFO  :  signal: 36 
rt_sigaction01   11  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 36

rt_sigaction01    0  TINFO  :  signal: 36 
rt_sigaction01   12  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 36

rt_sigaction01    0  TINFO  :  signal: 36 
rt_sigaction01   13  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 36

rt_sigaction01    0  TINFO  :  signal: 36 
rt_sigaction01   14  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 36

rt_sigaction01    0  TINFO  :  signal: 36 
rt_sigaction01   15  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 36

rt_sigaction01    0  TINFO  :  signal: 37 
rt_sigaction01   16  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 37

rt_sigaction01    0  TINFO  :  signal: 37 
rt_sigaction01   17  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 37

rt_sigaction01    0  TINFO  :  signal: 37 
rt_sigaction01   18  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 37

rt_sigaction01    0  TINFO  :  signal: 37 
rt_sigaction01   19  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 37

rt_sigaction01    0  TINFO  :  signal: 37 
rt_sigaction01   20  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 37

rt_sigaction01    0  TINFO  :  signal: 38 
rt_sigaction01   21  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 38

rt_sigaction01    0  TINFO  :  signal: 38 
rt_sigaction01   22  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 38

rt_sigaction01    0  TINFO  :  signal: 38 
rt_sigaction01   23  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 38

rt_sigaction01    0  TINFO  :  signal: 38 
rt_sigaction01   24  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 38

rt_sigaction01    0  TINFO  :  signal: 38 
rt_sigaction01   25  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 38

rt_sigaction01    0  TINFO  :  signal: 39 
rt_sigaction01   26  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 39

rt_sigaction01    0  TINFO  :  signal: 39 
rt_sigaction01   27  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 39

rt_sigaction01    0  TINFO  :  signal: 39 
rt_sigaction01   28  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 39

rt_sigaction01    0  TINFO  :  signal: 39 
rt_sigaction01   29  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 39

rt_sigaction01    0  TINFO  :  signal: 39 
rt_sigaction01   30  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 39

rt_sigaction01    0  TINFO  :  signal: 40 
rt_sigaction01   31  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 40

rt_sigaction01    0  TINFO  :  signal: 40 
rt_sigaction01   32  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 40

rt_sigaction01    0  TINFO  :  signal: 40 
rt_sigaction01   33  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 40

rt_sigaction01    0  TINFO  :  signal: 40 
rt_sigaction01   34  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 40

rt_sigaction01    0  TINFO  :  signal: 40 
rt_sigaction01   35  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 40

rt_sigaction01    0  TINFO  :  signal: 41 
rt_sigaction01   36  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 41

rt_sigaction01    0  TINFO  :  signal: 41 
rt_sigaction01   37  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 41

rt_sigaction01    0  TINFO  :  signal: 41 
rt_sigaction01   38  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 41

rt_sigaction01    0  TINFO  :  signal: 41 
rt_sigaction01   39  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 41

rt_sigaction01    0  TINFO  :  signal: 41 
rt_sigaction01   40  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 41

rt_sigaction01    0  TINFO  :  signal: 42 
rt_sigaction01   41  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 42

rt_sigaction01    0  TINFO  :  signal: 42 
rt_sigaction01   42  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 42

rt_sigaction01    0  TINFO  :  signal: 42 
rt_sigaction01   43  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 42

rt_sigaction01    0  TINFO  :  signal: 42 
rt_sigaction01   44  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 42

rt_sigaction01    0  TINFO  :  signal: 42 
rt_sigaction01   45  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 42

rt_sigaction01    0  TINFO  :  signal: 43 
rt_sigaction01   46  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 43

rt_sigaction01    0  TINFO  :  signal: 43 
rt_sigaction01   47  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 43

rt_sigaction01    0  TINFO  :  signal: 43 
rt_sigaction01   48  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 43

rt_sigaction01    0  TINFO  :  signal: 43 
rt_sigaction01   49  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 43

rt_sigaction01    0  TINFO  :  signal: 43 
rt_sigaction01   50  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 43

rt_sigaction01    0  TINFO  :  signal: 44 
rt_sigaction01   51  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 44

rt_sigaction01    0  TINFO  :  signal: 44 
rt_sigaction01   52  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 44

rt_sigaction01    0  TINFO  :  signal: 44 
rt_sigaction01   53  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 44

rt_sigaction01    0  TINFO  :  signal: 44 
rt_sigaction01   54  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 44

rt_sigaction01    0  TINFO  :  signal: 44 
rt_sigaction01   55  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 44

rt_sigaction01    0  TINFO  :  signal: 45 
rt_sigaction01   56  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 45

rt_sigaction01    0  TINFO  :  signal: 45 
rt_sigaction01   57  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 45

rt_sigaction01    0  TINFO  :  signal: 45 
rt_sigaction01   58  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 45

rt_sigaction01    0  TINFO  :  signal: 45 
rt_sigaction01   59  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 45

rt_sigaction01    0  TINFO  :  signal: 45 
rt_sigaction01   60  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 45

rt_sigaction01    0  TINFO  :  signal: 46 
rt_sigaction01   61  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 46

rt_sigaction01    0  TINFO  :  signal: 46 
rt_sigaction01   62  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 46

rt_sigaction01    0  TINFO  :  signal: 46 
rt_sigaction01   63  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 46

rt_sigaction01    0  TINFO  :  signal: 46 
rt_sigaction01   64  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 46

rt_sigaction01    0  TINFO  :  signal: 46 
rt_sigaction01   65  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 46

rt_sigaction01    0  TINFO  :  signal: 47 
rt_sigaction01   66  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 47

rt_sigaction01    0  TINFO  :  signal: 47 
rt_sigaction01   67  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 47

rt_sigaction01    0  TINFO  :  signal: 47 
rt_sigaction01   68  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 47

rt_sigaction01    0  TINFO  :  signal: 47 
rt_sigaction01   69  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 47

rt_sigaction01    0  TINFO  :  signal: 47 
rt_sigaction01   70  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 47

rt_sigaction01    0  TINFO  :  signal: 48 
rt_sigaction01   71  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 48

rt_sigaction01    0  TINFO  :  signal: 48 
rt_sigaction01   72  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 48

rt_sigaction01    0  TINFO  :  signal: 48 
rt_sigaction01   73  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 48

rt_sigaction01    0  TINFO  :  signal: 48 
rt_sigaction01   74  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 48

rt_sigaction01    0  TINFO  :  signal: 48 
rt_sigaction01   75  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 48

rt_sigaction01    0  TINFO  :  signal: 49 
rt_sigaction01   76  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 49

rt_sigaction01    0  TINFO  :  signal: 49 
rt_sigaction01   77  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 49

rt_sigaction01    0  TINFO  :  signal: 49 
rt_sigaction01   78  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 49

rt_sigaction01    0  TINFO  :  signal: 49 
rt_sigaction01   79  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 49

rt_sigaction01    0  TINFO  :  signal: 49 
rt_sigaction01   80  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 49

rt_sigaction01    0  TINFO  :  signal: 50 
rt_sigaction01   81  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 50

rt_sigaction01    0  TINFO  :  signal: 50 
rt_sigaction01   82  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 50

rt_sigaction01    0  TINFO  :  signal: 50 
rt_sigaction01   83  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 50

rt_sigaction01    0  TINFO  :  signal: 50 
rt_sigaction01   84  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 50

rt_sigaction01    0  TINFO  :  signal: 50 
rt_sigaction01   85  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 50

rt_sigaction01    0  TINFO  :  signal: 51 
rt_sigaction01   86  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 51

rt_sigaction01    0  TINFO  :  signal: 51 
rt_sigaction01   87  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 51

rt_sigaction01    0  TINFO  :  signal: 51 
rt_sigaction01   88  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 51

rt_sigaction01    0  TINFO  :  signal: 51 
rt_sigaction01   89  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 51

rt_sigaction01    0  TINFO  :  signal: 51 
rt_sigaction01   90  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 51

rt_sigaction01    0  TINFO  :  signal: 52 
rt_sigaction01   91  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 52

rt_sigaction01    0  TINFO  :  signal: 52 
rt_sigaction01   92  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 52

rt_sigaction01    0  TINFO  :  signal: 52 
rt_sigaction01   93  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 52

rt_sigaction01    0  TINFO  :  signal: 52 
rt_sigaction01   94  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 52

rt_sigaction01    0  TINFO  :  signal: 52 
rt_sigaction01   95  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 52

rt_sigaction01    0  TINFO  :  signal: 53 
rt_sigaction01   96  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 53

rt_sigaction01    0  TINFO  :  signal: 53 
rt_sigaction01   97  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 53

rt_sigaction01    0  TINFO  :  signal: 53 
rt_sigaction01   98  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 53

rt_sigaction01    0  TINFO  :  signal: 53 
rt_sigaction01   99  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 53

rt_sigaction01    0  TINFO  :  signal: 53 
rt_sigaction01  100  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 53

rt_sigaction01    0  TINFO  :  signal: 54 
rt_sigaction01  101  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 54

rt_sigaction01    0  TINFO  :  signal: 54 
rt_sigaction01  102  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 54

rt_sigaction01    0  TINFO  :  signal: 54 
rt_sigaction01  103  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 54

rt_sigaction01    0  TINFO  :  signal: 54 
rt_sigaction01  104  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 54

rt_sigaction01    0  TINFO  :  signal: 54 
rt_sigaction01  105  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 54

rt_sigaction01    0  TINFO  :  signal: 55 
rt_sigaction01  106  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 55

rt_sigaction01    0  TINFO  :  signal: 55 
rt_sigaction01  107  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 55

rt_sigaction01    0  TINFO  :  signal: 55 
rt_sigaction01  108  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 55

rt_sigaction01    0  TINFO  :  signal: 55 
rt_sigaction01  109  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 55

rt_sigaction01    0  TINFO  :  signal: 55 
rt_sigaction01  110  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 55

rt_sigaction01    0  TINFO  :  signal: 56 
rt_sigaction01  111  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 56

rt_sigaction01    0  TINFO  :  signal: 56 
rt_sigaction01  112  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 56

rt_sigaction01    0  TINFO  :  signal: 56 
rt_sigaction01  113  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 56

rt_sigaction01    0  TINFO  :  signal: 56 
rt_sigaction01  114  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 56

rt_sigaction01    0  TINFO  :  signal: 56 
rt_sigaction01  115  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 56

rt_sigaction01    0  TINFO  :  signal: 57 
rt_sigaction01  116  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 57

rt_sigaction01    0  TINFO  :  signal: 57 
rt_sigaction01  117  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 57

rt_sigaction01    0  TINFO  :  signal: 57 
rt_sigaction01  118  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 57

rt_sigaction01    0  TINFO  :  signal: 57 
rt_sigaction01  119  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 57

rt_sigaction01    0  TINFO  :  signal: 57 
rt_sigaction01  120  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 57

rt_sigaction01    0  TINFO  :  signal: 58 
rt_sigaction01  121  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 58

rt_sigaction01    0  TINFO  :  signal: 58 
rt_sigaction01  122  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 58

rt_sigaction01    0  TINFO  :  signal: 58 
rt_sigaction01  123  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 58

rt_sigaction01    0  TINFO  :  signal: 58 
rt_sigaction01  124  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 58

rt_sigaction01    0  TINFO  :  signal: 58 
rt_sigaction01  125  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 58

rt_sigaction01    0  TINFO  :  signal: 59 
rt_sigaction01  126  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 59

rt_sigaction01    0  TINFO  :  signal: 59 
rt_sigaction01  127  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 59

rt_sigaction01    0  TINFO  :  signal: 59 
rt_sigaction01  128  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 59

rt_sigaction01    0  TINFO  :  signal: 59 
rt_sigaction01  129  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 59

rt_sigaction01    0  TINFO  :  signal: 59 
rt_sigaction01  130  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 59

rt_sigaction01    0  TINFO  :  signal: 60 
rt_sigaction01  131  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 60

rt_sigaction01    0  TINFO  :  signal: 60 
rt_sigaction01  132  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 60

rt_sigaction01    0  TINFO  :  signal: 60 
rt_sigaction01  133  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 60

rt_sigaction01    0  TINFO  :  signal: 60 
rt_sigaction01  134  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 60

rt_sigaction01    0  TINFO  :  signal: 60 
rt_sigaction01  135  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 60

rt_sigaction01    0  TINFO  :  signal: 61 
rt_sigaction01  136  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 61

rt_sigaction01    0  TINFO  :  signal: 61 
rt_sigaction01  137  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 61

rt_sigaction01    0  TINFO  :  signal: 61 
rt_sigaction01  138  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 61

rt_sigaction01    0  TINFO  :  signal: 61 
rt_sigaction01  139  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 61

rt_sigaction01    0  TINFO  :  signal: 61 
rt_sigaction01  140  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 61

rt_sigaction01    0  TINFO  :  signal: 62 
rt_sigaction01  141  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 62

rt_sigaction01    0  TINFO  :  signal: 62 
rt_sigaction01  142  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 62

rt_sigaction01    0  TINFO  :  signal: 62 
rt_sigaction01  143  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 62

rt_sigaction01    0  TINFO  :  signal: 62 
rt_sigaction01  144  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 62

rt_sigaction01    0  TINFO  :  signal: 62 
rt_sigaction01  145  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 62

rt_sigaction01    0  TINFO  :  signal: 63 
rt_sigaction01  146  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 63

rt_sigaction01    0  TINFO  :  signal: 63 
rt_sigaction01  147  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 63

rt_sigaction01    0  TINFO  :  signal: 63 
rt_sigaction01  148  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 63

rt_sigaction01    0  TINFO  :  signal: 63 
rt_sigaction01  149  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 63

rt_sigaction01    0  TINFO  :  signal: 63 
rt_sigaction01  150  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 63

rt_sigaction01    0  TINFO  :  signal: 64 
rt_sigaction01  151  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 64

rt_sigaction01    0  TINFO  :  signal: 64 
rt_sigaction01  152  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 64

rt_sigaction01    0  TINFO  :  signal: 64 
rt_sigaction01  153  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 64

rt_sigaction01    0  TINFO  :  signal: 64 
rt_sigaction01  154  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 64

rt_sigaction01    0  TINFO  :  signal: 64 
rt_sigaction01  155  TPASS  :  rt_sigaction call succeeded: result = 0 
rt_sigaction01    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction01    0  TINFO  :  Signal Handler Called with signal number 64

<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=rt_sigaction02 stime=1411895737
cmdline="rt_sigaction02"
contacts=""
analysis=exit
<<<test_output>>>
rt_sigaction02    0  TINFO  :  Signal 34
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02    1  TPASS  :  rt_sigaction02 failure with sig: 34 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02    2  TPASS  :  rt_sigaction02 failure with sig: 34 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02    3  TPASS  :  rt_sigaction02 failure with sig: 34 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02    4  TPASS  :  rt_sigaction02 failure with sig: 34 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02    5  TPASS  :  rt_sigaction02 failure with sig: 34 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 35
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02    6  TPASS  :  rt_sigaction02 failure with sig: 35 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02    7  TPASS  :  rt_sigaction02 failure with sig: 35 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02    8  TPASS  :  rt_sigaction02 failure with sig: 35 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02    9  TPASS  :  rt_sigaction02 failure with sig: 35 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02   10  TPASS  :  rt_sigaction02 failure with sig: 35 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 36
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   11  TPASS  :  rt_sigaction02 failure with sig: 36 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02   12  TPASS  :  rt_sigaction02 failure with sig: 36 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   13  TPASS  :  rt_sigaction02 failure with sig: 36 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   14  TPASS  :  rt_sigaction02 failure with sig: 36 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02   15  TPASS  :  rt_sigaction02 failure with sig: 36 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 37
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   16  TPASS  :  rt_sigaction02 failure with sig: 37 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02   17  TPASS  :  rt_sigaction02 failure with sig: 37 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   18  TPASS  :  rt_sigaction02 failure with sig: 37 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   19  TPASS  :  rt_sigaction02 failure with sig: 37 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02   20  TPASS  :  rt_sigaction02 failure with sig: 37 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 38
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   21  TPASS  :  rt_sigaction02 failure with sig: 38 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02   22  TPASS  :  rt_sigaction02 failure with sig: 38 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   23  TPASS  :  rt_sigaction02 failure with sig: 38 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   24  TPASS  :  rt_sigaction02 failure with sig: 38 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02   25  TPASS  :  rt_sigaction02 failure with sig: 38 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 39
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   26  TPASS  :  rt_sigaction02 failure with sig: 39 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02   27  TPASS  :  rt_sigaction02 failure with sig: 39 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   28  TPASS  :  rt_sigaction02 failure with sig: 39 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   29  TPASS  :  rt_sigaction02 failure with sig: 39 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02   30  TPASS  :  rt_sigaction02 failure with sig: 39 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 40
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   31  TPASS  :  rt_sigaction02 failure with sig: 40 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02   32  TPASS  :  rt_sigaction02 failure with sig: 40 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   33  TPASS  :  rt_sigaction02 failure with sig: 40 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   34  TPASS  :  rt_sigaction02 failure with sig: 40 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02   35  TPASS  :  rt_sigaction02 failure with sig: 40 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 41
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   36  TPASS  :  rt_sigaction02 failure with sig: 41 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02   37  TPASS  :  rt_sigaction02 failure with sig: 41 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   38  TPASS  :  rt_sigaction02 failure with sig: 41 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   39  TPASS  :  rt_sigaction02 failure with sig: 41 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02   40  TPASS  :  rt_sigaction02 failure with sig: 41 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 42
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   41  TPASS  :  rt_sigaction02 failure with sig: 42 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02   42  TPASS  :  rt_sigaction02 failure with sig: 42 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   43  TPASS  :  rt_sigaction02 failure with sig: 42 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   44  TPASS  :  rt_sigaction02 failure with sig: 42 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02   45  TPASS  :  rt_sigaction02 failure with sig: 42 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 43
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   46  TPASS  :  rt_sigaction02 failure with sig: 43 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02   47  TPASS  :  rt_sigaction02 failure with sig: 43 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   48  TPASS  :  rt_sigaction02 failure with sig: 43 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   49  TPASS  :  rt_sigaction02 failure with sig: 43 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02   50  TPASS  :  rt_sigaction02 failure with sig: 43 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 44
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   51  TPASS  :  rt_sigaction02 failure with sig: 44 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02   52  TPASS  :  rt_sigaction02 failure with sig: 44 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   53  TPASS  :  rt_sigaction02 failure with sig: 44 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   54  TPASS  :  rt_sigaction02 failure with sig: 44 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02   55  TPASS  :  rt_sigaction02 failure with sig: 44 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 45
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   56  TPASS  :  rt_sigaction02 failure with sig: 45 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02   57  TPASS  :  rt_sigaction02 failure with sig: 45 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   58  TPASS  :  rt_sigaction02 failure with sig: 45 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   59  TPASS  :  rt_sigaction02 failure with sig: 45 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02   60  TPASS  :  rt_sigaction02 failure with sig: 45 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 46
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   61  TPASS  :  rt_sigaction02 failure with sig: 46 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02   62  TPASS  :  rt_sigaction02 failure with sig: 46 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   63  TPASS  :  rt_sigaction02 failure with sig: 46 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   64  TPASS  :  rt_sigaction02 failure with sig: 46 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02   65  TPASS  :  rt_sigaction02 failure with sig: 46 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 47
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   66  TPASS  :  rt_sigaction02 failure with sig: 47 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02   67  TPASS  :  rt_sigaction02 failure with sig: 47 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   68  TPASS  :  rt_sigaction02 failure with sig: 47 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   69  TPASS  :  rt_sigaction02 failure with sig: 47 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02   70  TPASS  :  rt_sigaction02 failure with sig: 47 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 48
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   71  TPASS  :  rt_sigaction02 failure with sig: 48 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02   72  TPASS  :  rt_sigaction02 failure with sig: 48 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   73  TPASS  :  rt_sigaction02 failure with sig: 48 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   74  TPASS  :  rt_sigaction02 failure with sig: 48 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02   75  TPASS  :  rt_sigaction02 failure with sig: 48 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 49
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   76  TPASS  :  rt_sigaction02 failure with sig: 49 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02   77  TPASS  :  rt_sigaction02 failure with sig: 49 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   78  TPASS  :  rt_sigaction02 failure with sig: 49 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   79  TPASS  :  rt_sigaction02 failure with sig: 49 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02   80  TPASS  :  rt_sigaction02 failure with sig: 49 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 50
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   81  TPASS  :  rt_sigaction02 failure with sig: 50 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02   82  TPASS  :  rt_sigaction02 failure with sig: 50 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   83  TPASS  :  rt_sigaction02 failure with sig: 50 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   84  TPASS  :  rt_sigaction02 failure with sig: 50 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02   85  TPASS  :  rt_sigaction02 failure with sig: 50 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 51
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   86  TPASS  :  rt_sigaction02 failure with sig: 51 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02   87  TPASS  :  rt_sigaction02 failure with sig: 51 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   88  TPASS  :  rt_sigaction02 failure with sig: 51 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   89  TPASS  :  rt_sigaction02 failure with sig: 51 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02   90  TPASS  :  rt_sigaction02 failure with sig: 51 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 52
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   91  TPASS  :  rt_sigaction02 failure with sig: 52 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02   92  TPASS  :  rt_sigaction02 failure with sig: 52 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   93  TPASS  :  rt_sigaction02 failure with sig: 52 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   94  TPASS  :  rt_sigaction02 failure with sig: 52 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02   95  TPASS  :  rt_sigaction02 failure with sig: 52 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 53
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   96  TPASS  :  rt_sigaction02 failure with sig: 53 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02   97  TPASS  :  rt_sigaction02 failure with sig: 53 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   98  TPASS  :  rt_sigaction02 failure with sig: 53 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02   99  TPASS  :  rt_sigaction02 failure with sig: 53 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02  100  TPASS  :  rt_sigaction02 failure with sig: 53 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 54
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  101  TPASS  :  rt_sigaction02 failure with sig: 54 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02  102  TPASS  :  rt_sigaction02 failure with sig: 54 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  103  TPASS  :  rt_sigaction02 failure with sig: 54 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  104  TPASS  :  rt_sigaction02 failure with sig: 54 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02  105  TPASS  :  rt_sigaction02 failure with sig: 54 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 55
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  106  TPASS  :  rt_sigaction02 failure with sig: 55 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02  107  TPASS  :  rt_sigaction02 failure with sig: 55 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  108  TPASS  :  rt_sigaction02 failure with sig: 55 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  109  TPASS  :  rt_sigaction02 failure with sig: 55 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02  110  TPASS  :  rt_sigaction02 failure with sig: 55 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 56
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  111  TPASS  :  rt_sigaction02 failure with sig: 56 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02  112  TPASS  :  rt_sigaction02 failure with sig: 56 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  113  TPASS  :  rt_sigaction02 failure with sig: 56 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  114  TPASS  :  rt_sigaction02 failure with sig: 56 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02  115  TPASS  :  rt_sigaction02 failure with sig: 56 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 57
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  116  TPASS  :  rt_sigaction02 failure with sig: 57 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02  117  TPASS  :  rt_sigaction02 failure with sig: 57 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  118  TPASS  :  rt_sigaction02 failure with sig: 57 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  119  TPASS  :  rt_sigaction02 failure with sig: 57 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02  120  TPASS  :  rt_sigaction02 failure with sig: 57 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 58
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  121  TPASS  :  rt_sigaction02 failure with sig: 58 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02  122  TPASS  :  rt_sigaction02 failure with sig: 58 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  123  TPASS  :  rt_sigaction02 failure with sig: 58 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  124  TPASS  :  rt_sigaction02 failure with sig: 58 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02  125  TPASS  :  rt_sigaction02 failure with sig: 58 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 59
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  126  TPASS  :  rt_sigaction02 failure with sig: 59 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02  127  TPASS  :  rt_sigaction02 failure with sig: 59 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  128  TPASS  :  rt_sigaction02 failure with sig: 59 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  129  TPASS  :  rt_sigaction02 failure with sig: 59 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02  130  TPASS  :  rt_sigaction02 failure with sig: 59 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 60
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  131  TPASS  :  rt_sigaction02 failure with sig: 60 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02  132  TPASS  :  rt_sigaction02 failure with sig: 60 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  133  TPASS  :  rt_sigaction02 failure with sig: 60 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  134  TPASS  :  rt_sigaction02 failure with sig: 60 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02  135  TPASS  :  rt_sigaction02 failure with sig: 60 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 61
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  136  TPASS  :  rt_sigaction02 failure with sig: 61 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02  137  TPASS  :  rt_sigaction02 failure with sig: 61 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  138  TPASS  :  rt_sigaction02 failure with sig: 61 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  139  TPASS  :  rt_sigaction02 failure with sig: 61 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02  140  TPASS  :  rt_sigaction02 failure with sig: 61 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 62
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  141  TPASS  :  rt_sigaction02 failure with sig: 62 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02  142  TPASS  :  rt_sigaction02 failure with sig: 62 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  143  TPASS  :  rt_sigaction02 failure with sig: 62 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  144  TPASS  :  rt_sigaction02 failure with sig: 62 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02  145  TPASS  :  rt_sigaction02 failure with sig: 62 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 63
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  146  TPASS  :  rt_sigaction02 failure with sig: 63 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02  147  TPASS  :  rt_sigaction02 failure with sig: 63 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  148  TPASS  :  rt_sigaction02 failure with sig: 63 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  149  TPASS  :  rt_sigaction02 failure with sig: 63 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02  150  TPASS  :  rt_sigaction02 failure with sig: 63 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  Signal 64
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  151  TPASS  :  rt_sigaction02 failure with sig: 64 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction02  152  TPASS  :  rt_sigaction02 failure with sig: 64 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  153  TPASS  :  rt_sigaction02 failure with sig: 64 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction02  154  TPASS  :  rt_sigaction02 failure with sig: 64 as expected errno  = EFAULT : Bad address
rt_sigaction02    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction02  155  TPASS  :  rt_sigaction02 failure with sig: 64 as expected errno  = EFAULT : Bad address
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=rt_sigaction03 stime=1411895737
cmdline="rt_sigaction03"
contacts=""
analysis=exit
<<<test_output>>>
rt_sigaction03    0  TINFO  :  Signal 34
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03    1  TPASS  :  rt_sigaction03 failure with sig: 34 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03    2  TPASS  :  rt_sigaction03 failure with sig: 34 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03    3  TPASS  :  rt_sigaction03 failure with sig: 34 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03    4  TPASS  :  rt_sigaction03 failure with sig: 34 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03    5  TPASS  :  rt_sigaction03 failure with sig: 34 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 35
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03    6  TPASS  :  rt_sigaction03 failure with sig: 35 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03    7  TPASS  :  rt_sigaction03 failure with sig: 35 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03    8  TPASS  :  rt_sigaction03 failure with sig: 35 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03    9  TPASS  :  rt_sigaction03 failure with sig: 35 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03   10  TPASS  :  rt_sigaction03 failure with sig: 35 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 36
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   11  TPASS  :  rt_sigaction03 failure with sig: 36 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03   12  TPASS  :  rt_sigaction03 failure with sig: 36 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   13  TPASS  :  rt_sigaction03 failure with sig: 36 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   14  TPASS  :  rt_sigaction03 failure with sig: 36 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03   15  TPASS  :  rt_sigaction03 failure with sig: 36 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 37
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   16  TPASS  :  rt_sigaction03 failure with sig: 37 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03   17  TPASS  :  rt_sigaction03 failure with sig: 37 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   18  TPASS  :  rt_sigaction03 failure with sig: 37 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   19  TPASS  :  rt_sigaction03 failure with sig: 37 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03   20  TPASS  :  rt_sigaction03 failure with sig: 37 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 38
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   21  TPASS  :  rt_sigaction03 failure with sig: 38 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03   22  TPASS  :  rt_sigaction03 failure with sig: 38 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   23  TPASS  :  rt_sigaction03 failure with sig: 38 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   24  TPASS  :  rt_sigaction03 failure with sig: 38 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03   25  TPASS  :  rt_sigaction03 failure with sig: 38 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 39
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   26  TPASS  :  rt_sigaction03 failure with sig: 39 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03   27  TPASS  :  rt_sigaction03 failure with sig: 39 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   28  TPASS  :  rt_sigaction03 failure with sig: 39 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   29  TPASS  :  rt_sigaction03 failure with sig: 39 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03   30  TPASS  :  rt_sigaction03 failure with sig: 39 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 40
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   31  TPASS  :  rt_sigaction03 failure with sig: 40 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03   32  TPASS  :  rt_sigaction03 failure with sig: 40 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   33  TPASS  :  rt_sigaction03 failure with sig: 40 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   34  TPASS  :  rt_sigaction03 failure with sig: 40 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03   35  TPASS  :  rt_sigaction03 failure with sig: 40 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 41
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   36  TPASS  :  rt_sigaction03 failure with sig: 41 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03   37  TPASS  :  rt_sigaction03 failure with sig: 41 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   38  TPASS  :  rt_sigaction03 failure with sig: 41 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   39  TPASS  :  rt_sigaction03 failure with sig: 41 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03   40  TPASS  :  rt_sigaction03 failure with sig: 41 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 42
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   41  TPASS  :  rt_sigaction03 failure with sig: 42 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03   42  TPASS  :  rt_sigaction03 failure with sig: 42 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   43  TPASS  :  rt_sigaction03 failure with sig: 42 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   44  TPASS  :  rt_sigaction03 failure with sig: 42 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03   45  TPASS  :  rt_sigaction03 failure with sig: 42 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 43
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   46  TPASS  :  rt_sigaction03 failure with sig: 43 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03   47  TPASS  :  rt_sigaction03 failure with sig: 43 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   48  TPASS  :  rt_sigaction03 failure with sig: 43 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   49  TPASS  :  rt_sigaction03 failure with sig: 43 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03   50  TPASS  :  rt_sigaction03 failure with sig: 43 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 44
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   51  TPASS  :  rt_sigaction03 failure with sig: 44 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03   52  TPASS  :  rt_sigaction03 failure with sig: 44 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   53  TPASS  :  rt_sigaction03 failure with sig: 44 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   54  TPASS  :  rt_sigaction03 failure with sig: 44 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03   55  TPASS  :  rt_sigaction03 failure with sig: 44 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 45
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   56  TPASS  :  rt_sigaction03 failure with sig: 45 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03   57  TPASS  :  rt_sigaction03 failure with sig: 45 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   58  TPASS  :  rt_sigaction03 failure with sig: 45 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   59  TPASS  :  rt_sigaction03 failure with sig: 45 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03   60  TPASS  :  rt_sigaction03 failure with sig: 45 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 46
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   61  TPASS  :  rt_sigaction03 failure with sig: 46 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03   62  TPASS  :  rt_sigaction03 failure with sig: 46 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   63  TPASS  :  rt_sigaction03 failure with sig: 46 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   64  TPASS  :  rt_sigaction03 failure with sig: 46 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03   65  TPASS  :  rt_sigaction03 failure with sig: 46 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 47
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   66  TPASS  :  rt_sigaction03 failure with sig: 47 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03   67  TPASS  :  rt_sigaction03 failure with sig: 47 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   68  TPASS  :  rt_sigaction03 failure with sig: 47 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   69  TPASS  :  rt_sigaction03 failure with sig: 47 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03   70  TPASS  :  rt_sigaction03 failure with sig: 47 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 48
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   71  TPASS  :  rt_sigaction03 failure with sig: 48 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03   72  TPASS  :  rt_sigaction03 failure with sig: 48 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   73  TPASS  :  rt_sigaction03 failure with sig: 48 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   74  TPASS  :  rt_sigaction03 failure with sig: 48 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03   75  TPASS  :  rt_sigaction03 failure with sig: 48 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 49
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   76  TPASS  :  rt_sigaction03 failure with sig: 49 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03   77  TPASS  :  rt_sigaction03 failure with sig: 49 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   78  TPASS  :  rt_sigaction03 failure with sig: 49 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   79  TPASS  :  rt_sigaction03 failure with sig: 49 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03   80  TPASS  :  rt_sigaction03 failure with sig: 49 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 50
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   81  TPASS  :  rt_sigaction03 failure with sig: 50 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03   82  TPASS  :  rt_sigaction03 failure with sig: 50 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   83  TPASS  :  rt_sigaction03 failure with sig: 50 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   84  TPASS  :  rt_sigaction03 failure with sig: 50 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03   85  TPASS  :  rt_sigaction03 failure with sig: 50 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 51
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   86  TPASS  :  rt_sigaction03 failure with sig: 51 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03   87  TPASS  :  rt_sigaction03 failure with sig: 51 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   88  TPASS  :  rt_sigaction03 failure with sig: 51 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   89  TPASS  :  rt_sigaction03 failure with sig: 51 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03   90  TPASS  :  rt_sigaction03 failure with sig: 51 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 52
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   91  TPASS  :  rt_sigaction03 failure with sig: 52 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03   92  TPASS  :  rt_sigaction03 failure with sig: 52 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   93  TPASS  :  rt_sigaction03 failure with sig: 52 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   94  TPASS  :  rt_sigaction03 failure with sig: 52 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03   95  TPASS  :  rt_sigaction03 failure with sig: 52 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 53
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   96  TPASS  :  rt_sigaction03 failure with sig: 53 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03   97  TPASS  :  rt_sigaction03 failure with sig: 53 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   98  TPASS  :  rt_sigaction03 failure with sig: 53 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03   99  TPASS  :  rt_sigaction03 failure with sig: 53 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03  100  TPASS  :  rt_sigaction03 failure with sig: 53 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 54
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  101  TPASS  :  rt_sigaction03 failure with sig: 54 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03  102  TPASS  :  rt_sigaction03 failure with sig: 54 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  103  TPASS  :  rt_sigaction03 failure with sig: 54 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  104  TPASS  :  rt_sigaction03 failure with sig: 54 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03  105  TPASS  :  rt_sigaction03 failure with sig: 54 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 55
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  106  TPASS  :  rt_sigaction03 failure with sig: 55 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03  107  TPASS  :  rt_sigaction03 failure with sig: 55 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  108  TPASS  :  rt_sigaction03 failure with sig: 55 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  109  TPASS  :  rt_sigaction03 failure with sig: 55 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03  110  TPASS  :  rt_sigaction03 failure with sig: 55 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 56
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  111  TPASS  :  rt_sigaction03 failure with sig: 56 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03  112  TPASS  :  rt_sigaction03 failure with sig: 56 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  113  TPASS  :  rt_sigaction03 failure with sig: 56 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  114  TPASS  :  rt_sigaction03 failure with sig: 56 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03  115  TPASS  :  rt_sigaction03 failure with sig: 56 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 57
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  116  TPASS  :  rt_sigaction03 failure with sig: 57 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03  117  TPASS  :  rt_sigaction03 failure with sig: 57 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  118  TPASS  :  rt_sigaction03 failure with sig: 57 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  119  TPASS  :  rt_sigaction03 failure with sig: 57 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03  120  TPASS  :  rt_sigaction03 failure with sig: 57 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 58
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  121  TPASS  :  rt_sigaction03 failure with sig: 58 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03  122  TPASS  :  rt_sigaction03 failure with sig: 58 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  123  TPASS  :  rt_sigaction03 failure with sig: 58 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  124  TPASS  :  rt_sigaction03 failure with sig: 58 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03  125  TPASS  :  rt_sigaction03 failure with sig: 58 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 59
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  126  TPASS  :  rt_sigaction03 failure with sig: 59 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03  127  TPASS  :  rt_sigaction03 failure with sig: 59 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  128  TPASS  :  rt_sigaction03 failure with sig: 59 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  129  TPASS  :  rt_sigaction03 failure with sig: 59 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03  130  TPASS  :  rt_sigaction03 failure with sig: 59 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 60
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  131  TPASS  :  rt_sigaction03 failure with sig: 60 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03  132  TPASS  :  rt_sigaction03 failure with sig: 60 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  133  TPASS  :  rt_sigaction03 failure with sig: 60 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  134  TPASS  :  rt_sigaction03 failure with sig: 60 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03  135  TPASS  :  rt_sigaction03 failure with sig: 60 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 61
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  136  TPASS  :  rt_sigaction03 failure with sig: 61 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03  137  TPASS  :  rt_sigaction03 failure with sig: 61 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  138  TPASS  :  rt_sigaction03 failure with sig: 61 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  139  TPASS  :  rt_sigaction03 failure with sig: 61 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03  140  TPASS  :  rt_sigaction03 failure with sig: 61 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 62
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  141  TPASS  :  rt_sigaction03 failure with sig: 62 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03  142  TPASS  :  rt_sigaction03 failure with sig: 62 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  143  TPASS  :  rt_sigaction03 failure with sig: 62 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  144  TPASS  :  rt_sigaction03 failure with sig: 62 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03  145  TPASS  :  rt_sigaction03 failure with sig: 62 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 63
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  146  TPASS  :  rt_sigaction03 failure with sig: 63 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03  147  TPASS  :  rt_sigaction03 failure with sig: 63 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  148  TPASS  :  rt_sigaction03 failure with sig: 63 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  149  TPASS  :  rt_sigaction03 failure with sig: 63 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03  150  TPASS  :  rt_sigaction03 failure with sig: 63 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  Signal 64
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  151  TPASS  :  rt_sigaction03 failure with sig: 64 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND 
rt_sigaction03  152  TPASS  :  rt_sigaction03 failure with sig: 64 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  153  TPASS  :  rt_sigaction03 failure with sig: 64 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_RESETHAND|SA_SIGINFO 
rt_sigaction03  154  TPASS  :  rt_sigaction03 failure with sig: 64 as expected errno  = EINVAL : Invalid argument
rt_sigaction03    0  TINFO  :  sa.sa_flags = SA_NOMASK 
rt_sigaction03  155  TPASS  :  rt_sigaction03 failure with sig: 64 as expected errno  = EINVAL : Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=rt_sigprocmask01 stime=1411895737
cmdline="rt_sigprocmask01"
contacts=""
analysis=exit
<<<test_output>>>
rt_sigprocmask01    1  TPASS  :  rt_sigprocmask functionality passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=rt_sigprocmask02 stime=1411895737
cmdline="rt_sigprocmask02"
contacts=""
analysis=exit
<<<test_output>>>
rt_sigprocmask02    1  TPASS  :  Got expected errno: TEST_ERRNO=EINVAL(22): Invalid argument
rt_sigprocmask02    2  TPASS  :  Got expected errno: TEST_ERRNO=EFAULT(14): Bad address
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=rt_sigqueueinfo01 stime=1411895737
cmdline="rt_sigqueueinfo01"
contacts=""
analysis=exit
<<<test_output>>>
rt_sigqueueinfo01    1  TPASS  :  Test Succeeded
rt_sigqueueinfo01    0  TINFO  :  Failed to record test working dir
rt_sigqueueinfo01    1  TPASS  :  Test Succeeded
rt_sigqueueinfo01    0  TINFO  :  Failed to record test working dir
rt_sigqueueinfo01    2  TPASS  :  Test Succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=rt_sigsuspend01 stime=1411895737
cmdline="rt_sigsuspend01"
contacts=""
analysis=exit
<<<test_output>>>
rt_sigsuspend01    1  TPASS  :  rt_sigsuspend PASSED
<<<execution_status>>>
initiation_status="ok"
duration=5 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sbrk01 stime=1411895742
cmdline="sbrk01"
contacts=""
analysis=exit
<<<test_output>>>
sbrk01      1  TPASS  :  sbrk - Increase by 8192 bytes returned 0x10b3000
sbrk01      2  TPASS  :  sbrk - Increase by -8192 bytes returned 0x10b5000
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sbrk02 stime=1411895742
cmdline="sbrk02"
contacts=""
analysis=exit
<<<test_output>>>
sbrk02      0  TINFO  :  setup() bailing inc: 6006243328, ret: 0xffffffffffffffff, sbrk: 0xf83b8ca000: errno=ENOMEM(12): Cannot allocate memory
sbrk02      1  TPASS  :  sbrk(6006243328) failed as expected: TEST_ERRNO=ENOMEM(12): Cannot allocate memory
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=sched_get_priority_max01 stime=1411895742
cmdline="sched_get_priority_max01"
contacts=""
analysis=exit
<<<test_output>>>
sched_get_priority_max01    1  TPASS  :  Test for SCHED_OTHER Passed
sched_get_priority_max01    2  TPASS  :  Test for SCHED_FIFO Passed
sched_get_priority_max01    3  TPASS  :  Test for SCHED_RR Passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sched_get_priority_max02 stime=1411895742
cmdline="sched_get_priority_max02"
contacts=""
analysis=exit
<<<test_output>>>
sched_get_priority_max02    1  TPASS  :  Test Passed, Got EINVAL
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sched_get_priority_min01 stime=1411895742
cmdline="sched_get_priority_min01"
contacts=""
analysis=exit
<<<test_output>>>
sched_get_priority_min01    1  TPASS  :  Test for SCHED_OTHER Passed
sched_get_priority_min01    2  TPASS  :  Test for SCHED_FIFO Passed
sched_get_priority_min01    3  TPASS  :  Test for SCHED_RR Passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sched_get_priority_min02 stime=1411895742
cmdline="sched_get_priority_min02"
contacts=""
analysis=exit
<<<test_output>>>
sched_get_priority_min02    1  TPASS  :  Test Passed, Got EINVAL
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sched_getparam01 stime=1411895742
cmdline="sched_getparam01"
contacts=""
analysis=exit
<<<test_output>>>
sched_getparam01    1  TPASS  :  sched_getparam() returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sched_getparam02 stime=1411895742
cmdline="sched_getparam02"
contacts=""
analysis=exit
<<<test_output>>>
sched_getparam02    1  TPASS  :  Test Passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sched_getparam03 stime=1411895742
cmdline="sched_getparam03"
contacts=""
analysis=exit
<<<test_output>>>
sched_getparam03    1  TPASS  :  expected failure; Got ESRCH
sched_getparam03    2  TPASS  :  expected failure; Got EINVAL
sched_getparam03    3  TPASS  :  expected failure; Got EINVAL
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sched_rr_get_interval01 stime=1411895742
cmdline="sched_rr_get_interval01"
contacts=""
analysis=exit
<<<test_output>>>
sched_rr_get_interval01    1  TPASS  :  sched_rr_get_interval() returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sched_rr_get_interval02 stime=1411895742
cmdline="sched_rr_get_interval02"
contacts=""
analysis=exit
<<<test_output>>>
sched_rr_get_interval02    1  TPASS  :  Test passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sched_rr_get_interval03 stime=1411895742
cmdline="sched_rr_get_interval03"
contacts=""
analysis=exit
<<<test_output>>>
sched_rr_get_interval03    1  TPASS  :  Test Passed
sched_rr_get_interval03    2  TPASS  :  Test Passed
sched_rr_get_interval03    3  TPASS  :  Test Passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sched_setparam01 stime=1411895742
cmdline="sched_setparam01"
contacts=""
analysis=exit
<<<test_output>>>
sched_setparam01    1  TPASS  :  sched_setparam() returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sched_setparam02 stime=1411895742
cmdline="sched_setparam02"
contacts=""
analysis=exit
<<<test_output>>>
sched_setparam02    1  TPASS  :  Test with policy SCHED_FIFO Passed
sched_setparam02    2  TPASS  :  Test with policy SCHED_RR Passed
sched_setparam02    3  TPASS  :  Test with SCHED_OTHER Passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sched_setparam03 stime=1411895742
cmdline="sched_setparam03"
contacts=""
analysis=exit
<<<test_output>>>
sched_setparam03    1  TPASS  :  Test Passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sched_setparam04 stime=1411895742
cmdline="sched_setparam04"
contacts=""
analysis=exit
<<<test_output>>>
sched_setparam04    1  TPASS  :  expected failure; Got ESRCH
sched_setparam04    2  TPASS  :  expected failure; Got EINVAL
sched_setparam04    3  TPASS  :  expected failure; Got EINVAL
sched_setparam04    4  TPASS  :  expected failure; Got EINVAL
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sched_setparam05 stime=1411895742
cmdline="sched_setparam05"
contacts=""
analysis=exit
<<<test_output>>>
sched_setparam05    1  TPASS  :  Test passed, Got EPERM
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sched_getscheduler01 stime=1411895742
cmdline="sched_getscheduler01"
contacts=""
analysis=exit
<<<test_output>>>
sched_getscheduler01    1  TPASS  :  policy value returned is correct
sched_getscheduler01    2  TPASS  :  policy value returned is correct
sched_getscheduler01    3  TPASS  :  policy value returned is correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sched_getscheduler02 stime=1411895742
cmdline="sched_getscheduler02"
contacts=""
analysis=exit
<<<test_output>>>
sched_getscheduler02    1  TPASS  :  call failed with ESRCH
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sched_setscheduler01 stime=1411895742
cmdline="sched_setscheduler01"
contacts=""
analysis=exit
<<<test_output>>>
sched_setscheduler01    1  TPASS  :  expected failure - errno = 3 : No such process
sched_setscheduler01    2  TPASS  :  expected failure - errno = 22 : Invalid argument
sched_setscheduler01    3  TPASS  :  expected failure - errno = 14 : Bad address
sched_setscheduler01    4  TPASS  :  expected failure - errno = 22 : Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sched_setscheduler02 stime=1411895742
cmdline="sched_setscheduler02"
contacts=""
analysis=exit
<<<test_output>>>
sched_setscheduler02    1  TPASS  :  got EPERM
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sched_yield01 stime=1411895742
cmdline="sched_yield01"
contacts=""
analysis=exit
<<<test_output>>>
sched_yield01    1  TPASS  :  sched_yield() call succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=sched_setaffinity01 stime=1411895742
cmdline="sched_setaffinity01"
contacts=""
analysis=exit
<<<test_output>>>
sched_setaffinity01    1  TPASS  :  expected failure with 'Bad address'
sched_setaffinity01    2  TPASS  :  expected failure with 'Invalid argument'
sched_setaffinity01    3  TPASS  :  expected failure with 'No such process'
sched_setaffinity01    4  TPASS  :  expected failure with 'Operation not permitted'
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sched_getaffinity01 stime=1411895742
cmdline="sched_getaffinity01"
contacts=""
analysis=exit
<<<test_output>>>
sched_getaffinity01    0  TINFO  :  system has 8 processor(s).
sched_getaffinity01    0  TINFO  :  cpusetsize is 128
sched_getaffinity01    0  TINFO  :  mask.__bits[0] = 255 
sched_getaffinity01    1  TPASS  :  sched_getaffinity() succeed, this process 29505 is running processor: 0
sched_getaffinity01    2  TPASS  :  sched_getaffinity() succeed, this process 29505 is running processor: 1
sched_getaffinity01    3  TPASS  :  sched_getaffinity() succeed, this process 29505 is running processor: 2
sched_getaffinity01    4  TPASS  :  sched_getaffinity() succeed, this process 29505 is running processor: 3
sched_getaffinity01    5  TPASS  :  sched_getaffinity() succeed, this process 29505 is running processor: 4
sched_getaffinity01    6  TPASS  :  sched_getaffinity() succeed, this process 29505 is running processor: 5
sched_getaffinity01    7  TPASS  :  sched_getaffinity() succeed, this process 29505 is running processor: 6
sched_getaffinity01    8  TPASS  :  sched_getaffinity() succeed, this process 29505 is running processor: 7
sched_getaffinity01    9  TPASS  :  sched_getaffinity(0, len, (cpu_set_t *) - 1): TEST_ERRNO=EFAULT(14): Bad address
sched_getaffinity01   10  TPASS  :  sched_getaffinity(0, 0, mask): TEST_ERRNO=EINVAL(22): Invalid argument
sched_getaffinity01   11  TPASS  :  sched_getaffinity(unused_pid, len, mask): TEST_ERRNO=ESRCH(3): No such process
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=select01 stime=1411895742
cmdline="select01"
contacts=""
analysis=exit
<<<test_output>>>
select01    1  TPASS  :  select(4, &Readfds, 0, 0, &timeout) timeout = 0 usecs
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=select02 stime=1411895742
cmdline="select02"
contacts=""
analysis=exit
<<<test_output>>>
select02    1  TPASS  :  select(5, &Readfds, &Writefds, 0, &timeout) timeout = 0 usecs
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=select03 stime=1411895742
cmdline="select03"
contacts=""
analysis=exit
<<<test_output>>>
select03    1  TPASS  :  select(5, &Readfds, &Writefds, 0, &timeout) timeout = 0 usecs
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=semctl01 stime=1411895742
cmdline="semctl01"
contacts=""
analysis=exit
<<<test_output>>>
semctl01    1  TPASS  :  buf.sem_nsems and buf.sem_perm.mode are correct
semctl01    2  TPASS  :  buf.sem_perm.mode is correct
semctl01    3  TPASS  :  semaphores have expected values
semctl01    4  TPASS  :  number of sleeping processes is correct
semctl01    5  TPASS  :  last pid value is correct
semctl01    6  TPASS  :  semaphore value is correct
semctl01    7  TPASS  :  number of sleeping processes is correct
semctl01    8  TPASS  :  semaphore values are correct
semctl01    9  TPASS  :  semaphore value is correct
semctl01   10  TPASS  :  the highest index is correct
semctl01   11  TPASS  :  number of semaphore sets is correct
semctl01   12  TPASS  :  id of the semaphore set is correct
semctl01   13  TPASS  :  semaphore appears to be removed
<<<execution_status>>>
initiation_status="ok"
duration=3 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=semctl02 stime=1411895745
cmdline="semctl02"
contacts=""
analysis=exit
<<<test_output>>>
semctl02    1  TPASS  :  expected failure - errno = 13 : Permission denied
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=semctl03 stime=1411895745
cmdline="semctl03"
contacts=""
analysis=exit
<<<test_output>>>
semctl03    1  TPASS  :  expected failure - errno = 22 : Invalid argument
semctl03    2  TPASS  :  expected failure - errno = 22 : Invalid argument
semctl03    3  TPASS  :  expected failure - errno = 14 : Bad address
semctl03    4  TPASS  :  expected failure - errno = 14 : Bad address
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=semctl04 stime=1411895745
cmdline="semctl04"
contacts=""
analysis=exit
<<<test_output>>>
semctl04    1  TPASS  :  expected failure - errno = 1 : Operation not permitted
semctl04    2  TPASS  :  expected failure - errno = 1 : Operation not permitted
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=semctl05 stime=1411895745
cmdline="semctl05"
contacts=""
analysis=exit
<<<test_output>>>
semctl05    1  TPASS  :  expected failure - errno = 34 : Numerical result out of range
semctl05    2  TPASS  :  expected failure - errno = 34 : Numerical result out of range
semctl05    3  TPASS  :  expected failure - errno = 34 : Numerical result out of range
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=semctl06 stime=1411895745
cmdline="semctl06"
contacts=""
analysis=exit
<<<test_output>>>
semctl06    1  TPASS  :  semctl06 ran successfully!
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=2
<<<test_end>>>
<<<test_start>>>
tag=semctl07 stime=1411895745
cmdline="semctl07"
contacts=""
analysis=exit
<<<test_output>>>
semctl07    1  TPASS  :  semctl07 ran successfully!
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=semget01 stime=1411895745
cmdline="semget01"
contacts=""
analysis=exit
<<<test_output>>>
semget01    1  TPASS  :  basic semaphore values are okay
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=semget02 stime=1411895745
cmdline="semget02"
contacts=""
analysis=exit
<<<test_output>>>
semget02    1  TPASS  :  expected failure - errno = 13 : Permission denied
semget02    2  TPASS  :  expected failure - errno = 17 : File exists
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=semget03 stime=1411895745
cmdline="semget03"
contacts=""
analysis=exit
<<<test_output>>>
semget03    1  TPASS  :  expected failure - errno = 2 : No such file or directory
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=semget05 stime=1411895745
cmdline="semget05"
contacts=""
analysis=exit
<<<test_output>>>
semget05    1  TPASS  :  expected failure - errno = 28 : No space left on device
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=semget06 stime=1411895745
cmdline="semget06"
contacts=""
analysis=exit
<<<test_output>>>
semget06    1  TPASS  :  expected failure - errno = 22 : Invalid argument
semget06    2  TPASS  :  expected failure - errno = 22 : Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=semop01 stime=1411895745
cmdline="semop01"
contacts=""
analysis=exit
<<<test_output>>>
semop01     1  TPASS  :  semaphore values are correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=semop02 stime=1411895745
cmdline="semop02"
contacts=""
analysis=exit
<<<test_output>>>
semop02     1  TPASS  :  semop failed as expected: TEST_ERRNO=E2BIG(7): Argument list too long
semop02     2  TPASS  :  semop failed as expected: TEST_ERRNO=EACCES(13): Permission denied
semop02     3  TPASS  :  semop failed as expected: TEST_ERRNO=EFAULT(14): Bad address
semop02     4  TPASS  :  semop failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
semop02     5  TPASS  :  semop failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
semop02     6  TPASS  :  semop failed as expected: TEST_ERRNO=ERANGE(34): Numerical result out of range
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=semop03 stime=1411895745
cmdline="semop03"
contacts=""
analysis=exit
<<<test_output>>>
semop03     1  TPASS  :  expected failure - errno = 27 : File too large
semop03     2  TPASS  :  expected failure - errno = 27 : File too large
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=semop04 stime=1411895745
cmdline="semop04"
contacts=""
analysis=exit
<<<test_output>>>
semop04     1  TPASS  :  expected failure - errno = 11 : Resource temporarily unavailable
semop04     2  TPASS  :  expected failure - errno = 11 : Resource temporarily unavailable
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=semop05 stime=1411895745
cmdline="semop05"
contacts=""
analysis=exit
<<<test_output>>>
semop05     1  TPASS  :  expected failure - errno = 43 : Identifier removed
semop05     1  TPASS  :  expected failure - errno = 43 : Identifier removed
semop05     1  TPASS  :  expected failure - errno = 4 : Interrupted system call
semop05     1  TPASS  :  expected failure - errno = 4 : Interrupted system call
<<<execution_status>>>
initiation_status="ok"
duration=4 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=send01 stime=1411895749
cmdline="send01"
contacts=""
analysis=exit
<<<test_output>>>
send01      1  TPASS  :  bad file descriptor successful
send01      2  TPASS  :  invalid socket successful
send01      3  TPASS  :  invalid send buffer successful
send01      4  TPASS  :  UDP message too big successful
send01      5  TPASS  :  local endpoint shutdown successful
send01      6  TPASS  :  invalid flags set successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sendfile02 stime=1411895749
cmdline="sendfile02"
contacts=""
analysis=exit
<<<test_output>>>
sendfile02    1  TPASS  :  functionality of sendfile() is correct
sendfile02    2  TPASS  :  functionality of sendfile() is correct
sendfile02    3  TPASS  :  functionality of sendfile() is correct
sendfile02    4  TPASS  :  functionality of sendfile() is correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sendfile02_64 stime=1411895749
cmdline="sendfile02_64"
contacts=""
analysis=exit
<<<test_output>>>
sendfile02_64    1  TPASS  :  functionality of sendfile() is correct
sendfile02_64    2  TPASS  :  functionality of sendfile() is correct
sendfile02_64    3  TPASS  :  functionality of sendfile() is correct
sendfile02_64    4  TPASS  :  functionality of sendfile() is correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sendfile03 stime=1411895749
cmdline="sendfile03"
contacts=""
analysis=exit
<<<test_output>>>
sendfile03    1  TPASS  :  sendfile() returned 9 : Bad file descriptor
sendfile03    2  TPASS  :  sendfile() returned 9 : Bad file descriptor
sendfile03    3  TPASS  :  sendfile() returned 9 : Bad file descriptor
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sendfile03_64 stime=1411895749
cmdline="sendfile03_64"
contacts=""
analysis=exit
<<<test_output>>>
sendfile03_64    1  TPASS  :  sendfile() returned 9 : Bad file descriptor
sendfile03_64    2  TPASS  :  sendfile() returned 9 : Bad file descriptor
sendfile03_64    3  TPASS  :  sendfile() returned 9 : Bad file descriptor
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sendfile04 stime=1411895749
cmdline="sendfile04"
contacts=""
analysis=exit
<<<test_output>>>
sendfile04    1  TPASS  :  sendfile() returned 14 : Bad address
sendfile04    2  TPASS  :  sendfile() returned 14 : Bad address
sendfile04    3  TPASS  :  sendfile() returned 14 : Bad address
sendfile04    4  TPASS  :  sendfile() returned 14 : Bad address
sendfile04    5  TPASS  :  sendfile() returned 14 : Bad address
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=sendfile04_64 stime=1411895749
cmdline="sendfile04_64"
contacts=""
analysis=exit
<<<test_output>>>
sendfile04_64    1  TPASS  :  sendfile() returned 14 : Bad address
sendfile04_64    2  TPASS  :  sendfile() returned 14 : Bad address
sendfile04_64    3  TPASS  :  sendfile() returned 14 : Bad address
sendfile04_64    4  TPASS  :  sendfile() returned 14 : Bad address
sendfile04_64    5  TPASS  :  sendfile() returned 14 : Bad address
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sendfile05 stime=1411895749
cmdline="sendfile05"
contacts=""
analysis=exit
<<<test_output>>>
sendfile05    1  TPASS  :  sendfile() returned 22 : Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sendfile05_64 stime=1411895749
cmdline="sendfile05_64"
contacts=""
analysis=exit
<<<test_output>>>
sendfile05_64    1  TPASS  :  sendfile() returned 22 : Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sendfile06 stime=1411895749
cmdline="sendfile06"
contacts=""
analysis=exit
<<<test_output>>>
sendfile06    1  TPASS  :  functionality of sendfile() is correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sendfile06_64 stime=1411895749
cmdline="sendfile06_64"
contacts=""
analysis=exit
<<<test_output>>>
sendfile06_64    1  TPASS  :  functionality of sendfile() is correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sendfile07 stime=1411895749
cmdline="sendfile07"
contacts=""
analysis=exit
<<<test_output>>>
sendfile07    1  TPASS  :  sendfile() returned 11 : Resource temporarily unavailable
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sendfile07_64 stime=1411895749
cmdline="sendfile07_64"
contacts=""
analysis=exit
<<<test_output>>>
sendfile07_64    1  TPASS  :  sendfile() returned 11 : Resource temporarily unavailable
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sendfile08 stime=1411895749
cmdline="sendfile08"
contacts=""
analysis=exit
<<<test_output>>>
sendfile08    1  TPASS  :  sendfile(2) copies data correctly
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sendfile08_64 stime=1411895749
cmdline="sendfile08_64"
contacts=""
analysis=exit
<<<test_output>>>
sendfile08_64    1  TPASS  :  sendfile(2) copies data correctly
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sendfile09 stime=1411895749
cmdline="sendfile09"
contacts=""
analysis=exit
<<<test_output>>>
sendfile09    1  TCONF  :  sendfile09.c:142: sendfile(2) on large file needs 5G free space.
sendfile09    2  TCONF  :  sendfile09.c:142: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sendfile09_64 stime=1411895749
cmdline="sendfile09_64"
contacts=""
analysis=exit
<<<test_output>>>
sendfile09_64    1  TCONF  :  sendfile09.c:142: sendfile(2) on large file needs 5G free space.
sendfile09_64    2  TCONF  :  sendfile09.c:142: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sendmsg01 stime=1411895749
cmdline="sendmsg01"
contacts=""
analysis=exit
<<<test_output>>>
sendmsg01    1  TPASS  :  bad file descriptor successful
sendmsg01    2  TPASS  :  invalid socket successful
sendmsg01    3  TPASS  :  invalid send buffer successful
sendmsg01    4  TPASS  :  connected TCP successful
sendmsg01    5  TPASS  :  not connected TCP successful
sendmsg01    6  TPASS  :  invalid to buffer length successful
sendmsg01    7  TPASS  :  invalid to buffer successful
sendmsg01    8  TPASS  :  UDP message too big successful
sendmsg01    9  TPASS  :  local endpoint shutdown successful
sendmsg01   10  TPASS  :  invalid iovec pointer successful
sendmsg01   11  TPASS  :  invalid msghdr pointer successful
sendmsg01   12  TPASS  :  rights passing successful
sendmsg01   13  TPASS  :  invalid flags set w/ control successful
sendmsg01   14  TPASS  :  invalid flags set successful
sendmsg01   15  TPASS  :  invalid cmsg length successful
sendmsg01   16  TPASS  :  invalid cmsg pointer successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sendmsg02 stime=1411895749
cmdline="sendmsg02"
contacts=""
analysis=exit
<<<test_output>>>
sendmsg02    1  TPASS  :  finished after 15 seconds
<<<execution_status>>>
initiation_status="ok"
duration=15 termination_type=exited termination_id=0 corefile=no
cutime=488 cstime=10650
<<<test_end>>>
<<<test_start>>>
tag=sendto01 stime=1411895764
cmdline="sendto01"
contacts=""
analysis=exit
<<<test_output>>>
sendto01    1  TPASS  :  bad file descriptor successful
sendto01    2  TPASS  :  invalid socket successful
sendto01    3  TPASS  :  invalid send buffer successful
sendto01    4  TPASS  :  connected TCP successful
sendto01    5  TPASS  :  not connected TCP successful
sendto01    6  TPASS  :  invalid to buffer length successful
sendto01    7  TPASS  :  invalid to buffer successful
sendto01    8  TPASS  :  UDP message too big successful
sendto01    9  TPASS  :  local endpoint shutdown successful
sendto01   10  TPASS  :  invalid flags set successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setdomainname01 stime=1411895764
cmdline="setdomainname01"
contacts=""
analysis=exit
<<<test_output>>>
setdomainname01    1  TPASS  :  setdomainname() returned 0, Domain name set to "test_dom"
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setdomainname02 stime=1411895764
cmdline="setdomainname02"
contacts=""
analysis=exit
<<<test_output>>>
setdomainname02    1  TPASS  :  expected failure; Got EINVAL
setdomainname02    2  TPASS  :  expected failure; Got EINVAL
setdomainname02    3  TPASS  :  expected failure; Got EFAULT
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setdomainname03 stime=1411895764
cmdline="setdomainname03"
contacts=""
analysis=exit
<<<test_output>>>
setdomainname03    1  TPASS  :  expected failure; Got EPERM
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setfsgid01 stime=1411895764
cmdline="setfsgid01"
contacts=""
analysis=exit
<<<test_output>>>
setfsgid01    1  TPASS  :  setfsgid() returned expected value : 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setfsgid01_16 stime=1411895764
cmdline="setfsgid01_16"
contacts=""
analysis=exit
<<<test_output>>>
setfsgid01_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setfsgid/../utils/compat_16.h:118: 16-bit version of setfsgid() is not supported on your platform
setfsgid01_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setfsgid/../utils/compat_16.h:118: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setfsgid02 stime=1411895764
cmdline="setfsgid02"
contacts=""
analysis=exit
<<<test_output>>>
setfsgid02    1  TPASS  :  setfsgid() returned expected value : 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setfsgid02_16 stime=1411895764
cmdline="setfsgid02_16"
contacts=""
analysis=exit
<<<test_output>>>
setfsgid02_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setfsgid/../utils/compat_16.h:118: 16-bit version of setfsgid() is not supported on your platform
setfsgid02_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setfsgid/../utils/compat_16.h:118: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setfsgid03 stime=1411895764
cmdline="setfsgid03"
contacts=""
analysis=exit
<<<test_output>>>
setfsgid03    1  TPASS  :  setfsgid() returned expected value : 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setfsgid03_16 stime=1411895764
cmdline="setfsgid03_16"
contacts=""
analysis=exit
<<<test_output>>>
setfsgid03_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setfsgid/../utils/compat_16.h:118: 16-bit version of setfsgid() is not supported on your platform
setfsgid03_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setfsgid/../utils/compat_16.h:118: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setfsuid01 stime=1411895764
cmdline="setfsuid01"
contacts=""
analysis=exit
<<<test_output>>>
setfsuid01    1  TPASS  :  setfsuid() returned expected value : 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setfsuid01_16 stime=1411895764
cmdline="setfsuid01_16"
contacts=""
analysis=exit
<<<test_output>>>
setfsuid01_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setfsuid/../utils/compat_16.h:113: 16-bit version of setfsuid() is not supported on your platform
setfsuid01_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setfsuid/../utils/compat_16.h:113: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setfsuid02 stime=1411895764
cmdline="setfsuid02"
contacts=""
analysis=exit
<<<test_output>>>
setfsuid02    1  TPASS  :  setfsuid() returned expected value : 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setfsuid02_16 stime=1411895764
cmdline="setfsuid02_16"
contacts=""
analysis=exit
<<<test_output>>>
setfsuid02_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setfsuid/../utils/compat_16.h:113: 16-bit version of setfsuid() is not supported on your platform
setfsuid02_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setfsuid/../utils/compat_16.h:113: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setfsuid03 stime=1411895764
cmdline="setfsuid03"
contacts=""
analysis=exit
<<<test_output>>>
setfsuid03    1  TPASS  :  setfsuid() returned expected value : 65534
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setfsuid03_16 stime=1411895764
cmdline="setfsuid03_16"
contacts=""
analysis=exit
<<<test_output>>>
setfsuid03_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setfsuid/../utils/compat_16.h:113: 16-bit version of setfsuid() is not supported on your platform
setfsuid03_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setfsuid/../utils/compat_16.h:113: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setfsuid04 stime=1411895764
cmdline="setfsuid04"
contacts=""
analysis=exit
<<<test_output>>>
open failed with EACCESS as expected
open failed with EACCESS as expected
open call succeeded
open call succeeded
setfsuid04    0  TINFO  :  Child process returned TPASS
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=setfsuid04_16 stime=1411895764
cmdline="setfsuid04_16"
contacts=""
analysis=exit
<<<test_output>>>
setfsuid04_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setfsuid/../utils/compat_16.h:113: 16-bit version of setfsuid() is not supported on your platform
setfsuid04_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setfsuid/../utils/compat_16.h:113: Remaining cases not appropriate for configuration
setfsuid04_16    0  TINFO  :  Child process returned TCONF
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setgid01 stime=1411895764
cmdline="setgid01"
contacts=""
analysis=exit
<<<test_output>>>
setgid01    1  TPASS  :  setgid(0) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setgid01_16 stime=1411895764
cmdline="setgid01_16"
contacts=""
analysis=exit
<<<test_output>>>
setgid01_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setgid/../utils/compat_16.h:93: 16-bit version of setgid() is not supported on your platform
setgid01_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setgid/../utils/compat_16.h:93: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setgid02 stime=1411895764
cmdline="setgid02"
contacts=""
analysis=exit
<<<test_output>>>
setgid02    1  TPASS  :  setgid returned EPERM
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setgid02_16 stime=1411895764
cmdline="setgid02_16"
contacts=""
analysis=exit
<<<test_output>>>
setgid02_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setgid/../utils/compat_16.h:93: 16-bit version of setgid() is not supported on your platform
setgid02_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setgid/../utils/compat_16.h:93: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setgid03 stime=1411895764
cmdline="setgid03"
contacts=""
analysis=exit
<<<test_output>>>
setgid03    1  TPASS  :  functionality of getgid() is correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setgid03_16 stime=1411895764
cmdline="setgid03_16"
contacts=""
analysis=exit
<<<test_output>>>
setgid03_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setgid/../utils/compat_16.h:93: 16-bit version of setgid() is not supported on your platform
setgid03_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setgid/../utils/compat_16.h:93: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setegid01 stime=1411895764
cmdline="setegid01"
contacts=""
analysis=exit
<<<test_output>>>
setegid01    0  TINFO  :  getresgid reports rgid 0, egid 0, sgid 0
setegid01    0  TINFO  :  calling setegid(nobody_gid 65534)
setegid01    0  TINFO  :  getresgid reports rgid 0, egid 65534, sgid 0
setegid01    1  TPASS  :  setegid() passed functional test
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setegid02 stime=1411895764
cmdline="setegid02"
contacts=""
analysis=exit
<<<test_output>>>
setegid02    1  TPASS  :  setegid failed as expected: TEST_ERRNO=EPERM(1): Operation not permitted
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sgetmask01 stime=1411895764
cmdline="sgetmask01"
contacts=""
analysis=exit
<<<test_output>>>
sgetmask01    1  TCONF  :  sgetmask01.c:134: syscall __NR_ssetmask not supported on your arch
sgetmask01    2  TCONF  :  sgetmask01.c:134: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setgroups01 stime=1411895764
cmdline="setgroups01"
contacts=""
analysis=exit
<<<test_output>>>
setgroups01    1  TPASS  :  setgroups(65536, list) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setgroups01_16 stime=1411895764
cmdline="setgroups01_16"
contacts=""
analysis=exit
<<<test_output>>>
setgroups01_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setgroups/../utils/compat_16.h:78: 16-bit version of getgroups() is not supported on your platform
setgroups01_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setgroups/../utils/compat_16.h:78: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setgroups02 stime=1411895764
cmdline="setgroups02"
contacts=""
analysis=exit
<<<test_output>>>
setgroups02    1  TPASS  :  Functionality of setgroups(1, groups_list) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setgroups02_16 stime=1411895764
cmdline="setgroups02_16"
contacts=""
analysis=exit
<<<test_output>>>
setgroups02_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setgroups/../utils/compat_16.h:73: 16-bit version of setgroups() is not supported on your platform
setgroups02_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setgroups/../utils/compat_16.h:73: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=setgroups03 stime=1411895764
cmdline="setgroups03"
contacts=""
analysis=exit
<<<test_output>>>
setgroups03    1  TPASS  :  setgroups(65537) fails, Size is > sysconf(_SC_NGROUPS_MAX), errno=22
setgroups03    2  TPASS  :  setgroups(65536) fails, Permission denied, not super-user, errno=1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setgroups03_16 stime=1411895764
cmdline="setgroups03_16"
contacts=""
analysis=exit
<<<test_output>>>
setgroups03_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setgroups/../utils/compat_16.h:73: 16-bit version of setgroups() is not supported on your platform
setgroups03_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setgroups/../utils/compat_16.h:73: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setgroups04 stime=1411895764
cmdline="setgroups04"
contacts=""
analysis=exit
<<<test_output>>>
setgroups04    1  TPASS  :  setgroups() fails with expected error EFAULT errno:14
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setgroups04_16 stime=1411895764
cmdline="setgroups04_16"
contacts=""
analysis=exit
<<<test_output>>>
setgroups04_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setgroups/../utils/compat_16.h:73: 16-bit version of setgroups() is not supported on your platform
setgroups04_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setgroups/../utils/compat_16.h:73: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sethostname01 stime=1411895764
cmdline="sethostname01"
contacts=""
analysis=exit
<<<test_output>>>
sethostname01    1  TPASS  :  sethostname() returned 0, Hostname set to "ltphost"
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sethostname02 stime=1411895764
cmdline="sethostname02"
contacts=""
analysis=exit
<<<test_output>>>
sethostname02    1  TPASS  :  expected failure; Got EINVAL
sethostname02    2  TPASS  :  expected failure; Got EINVAL
sethostname02    3  TPASS  :  expected failure; Got EFAULT
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sethostname03 stime=1411895764
cmdline="sethostname03"
contacts=""
analysis=exit
<<<test_output>>>
sethostname03    1  TPASS  :  Expected Failure; Got EPERM
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setitimer01 stime=1411895764
cmdline="setitimer01"
contacts=""
analysis=exit
<<<test_output>>>
setitimer01    1  TPASS  :  functionality is correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setitimer02 stime=1411895764
cmdline="setitimer02"
contacts=""
analysis=exit
<<<test_output>>>
setitimer02    1  TPASS  :  expected failure - errno = 14 - Bad address
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setitimer03 stime=1411895764
cmdline="setitimer03"
contacts=""
analysis=exit
<<<test_output>>>
setitimer03    1  TPASS  :  expected failure - errno = 22 - Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setns01 stime=1411895764
cmdline="setns01"
contacts=""
analysis=exit
<<<test_output>>>
setns01     0  TINFO  :  ns_name=ipc, ns_fds[0]=7, ns_types[0]=0x8000000
setns01     0  TINFO  :  ns_name=mnt, ns_fds[1]=8, ns_types[1]=0x20000
setns01     0  TINFO  :  ns_name=net, ns_fds[2]=9, ns_types[2]=0x40000000
setns01     0  TINFO  :  ns_name=pid, ns_fds[3]=10, ns_types[3]=0x20000000
setns01     0  TINFO  :  ns_name=uts, ns_fds[4]=11, ns_types[4]=0x4000000
setns01     0  TINFO  :  setns(-1, 0x8000000)
setns01     1  TPASS  :  invalid fd exp_errno=9
setns01     0  TINFO  :  setns(-1, 0x20000)
setns01     2  TPASS  :  invalid fd exp_errno=9
setns01     0  TINFO  :  setns(-1, 0x40000000)
setns01     3  TPASS  :  invalid fd exp_errno=9
setns01     0  TINFO  :  setns(-1, 0x20000000)
setns01     4  TPASS  :  invalid fd exp_errno=9
setns01     0  TINFO  :  setns(-1, 0x4000000)
setns01     5  TPASS  :  invalid fd exp_errno=9
setns01     0  TINFO  :  setns(12, 0x8000000)
setns01     6  TPASS  :  regular file fd exp_errno=22
setns01     0  TINFO  :  setns(12, 0x20000)
setns01     7  TPASS  :  regular file fd exp_errno=22
setns01     0  TINFO  :  setns(12, 0x40000000)
setns01     8  TPASS  :  regular file fd exp_errno=22
setns01     0  TINFO  :  setns(12, 0x20000000)
setns01     9  TPASS  :  regular file fd exp_errno=22
setns01     0  TINFO  :  setns(12, 0x4000000)
setns01    10  TPASS  :  regular file fd exp_errno=22
setns01     0  TINFO  :  setns(7, 0xffffffff)
setns01    11  TPASS  :  invalid ns_type exp_errno=22
setns01     0  TINFO  :  setns(8, 0xffffffff)
setns01    12  TPASS  :  invalid ns_type exp_errno=22
setns01     0  TINFO  :  setns(9, 0xffffffff)
setns01    13  TPASS  :  invalid ns_type exp_errno=22
setns01     0  TINFO  :  setns(10, 0xffffffff)
setns01    14  TPASS  :  invalid ns_type exp_errno=22
setns01     0  TINFO  :  setns(11, 0xffffffff)
setns01    15  TPASS  :  invalid ns_type exp_errno=22
setns01     0  TINFO  :  setns(7, 0x20000)
setns01    16  TPASS  :  mismatch ns_type/fd exp_errno=22
setns01     0  TINFO  :  setns(8, 0x40000000)
setns01    17  TPASS  :  mismatch ns_type/fd exp_errno=22
setns01     0  TINFO  :  setns(9, 0x20000000)
setns01    18  TPASS  :  mismatch ns_type/fd exp_errno=22
setns01     0  TINFO  :  setns(10, 0x4000000)
setns01    19  TPASS  :  mismatch ns_type/fd exp_errno=22
setns01     0  TINFO  :  setns(11, 0x8000000)
setns01    20  TPASS  :  mismatch ns_type/fd exp_errno=22
setns01     0  TINFO  :  setns(7, 0x8000000)
setns01    21  TPASS  :  without CAP_SYS_ADMIN exp_errno=1
setns01     0  TINFO  :  setns(8, 0x20000)
setns01    22  TPASS  :  without CAP_SYS_ADMIN exp_errno=1
setns01     0  TINFO  :  setns(9, 0x40000000)
setns01    23  TPASS  :  without CAP_SYS_ADMIN exp_errno=1
setns01     0  TINFO  :  setns(10, 0x20000000)
setns01    24  TPASS  :  without CAP_SYS_ADMIN exp_errno=1
setns01     0  TINFO  :  setns(11, 0x4000000)
setns01    25  TPASS  :  without CAP_SYS_ADMIN exp_errno=1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setns02 stime=1411895764
cmdline="setns02"
contacts=""
analysis=exit
<<<test_output>>>
setns02     0  TINFO  :  test_newuts
setns02     0  TINFO  :  creating child with clone_flag=0x4000000, ns_flag=0x4000000
setns02     1  TPASS  :  child finished succesfully
setns02     0  TINFO  :  creating child with clone_flag=0x4000000, ns_flag=0x0
setns02     2  TPASS  :  child finished succesfully
setns02     0  TINFO  :  test_newipc
setns02     0  TINFO  :  creating child with clone_flag=0x8000000, ns_flag=0x8000000
setns02     3  TPASS  :  child finished succesfully
setns02     0  TINFO  :  creating child with clone_flag=0x8000000, ns_flag=0x0
setns02     4  TPASS  :  child finished succesfully
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setpgid01 stime=1411895764
cmdline="setpgid01"
contacts=""
analysis=exit
<<<test_output>>>
setpgid01    1  TPASS  :  test setpgid(29719, 29719) success
setpgid01    2  TPASS  :  test setpgid(0, 0) success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setpgid02 stime=1411895764
cmdline="setpgid02"
contacts=""
analysis=exit
<<<test_output>>>
setpgid02    1  TPASS  :  expected failure - errno = 22 : Invalid argument
setpgid02    2  TPASS  :  expected failure - errno = 3 : No such process
setpgid02    3  TPASS  :  expected failure - errno = 1 : Operation not permitted
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=setpgid03 stime=1411895764
cmdline="setpgid03"
contacts=""
analysis=exit
<<<test_output>>>
setpgid03    1  TPASS  :  setpgid failed with EPERM
setpgid03    2  TPASS  :  setpgid failed with EACCES
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setpgrp01 stime=1411895764
cmdline="setpgrp01"
contacts=""
analysis=exit
<<<test_output>>>
setpgrp01    1  TPASS  :  setpgrp -  Call the setpgrp system call returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setpgrp02 stime=1411895764
cmdline="setpgrp02"
contacts=""
analysis=exit
<<<test_output>>>
setpgrp02    1  TPASS  :  functionality is correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setpriority01 stime=1411895764
cmdline="setpriority01"
contacts=""
analysis=exit
<<<test_output>>>
setpriority01    1  TPASS  :  setpriority(-20) succeeded
setpriority01    2  TPASS  :  setpriority(-19) succeeded
setpriority01    3  TPASS  :  setpriority(-18) succeeded
setpriority01    4  TPASS  :  setpriority(-17) succeeded
setpriority01    5  TPASS  :  setpriority(-16) succeeded
setpriority01    6  TPASS  :  setpriority(-15) succeeded
setpriority01    7  TPASS  :  setpriority(-14) succeeded
setpriority01    8  TPASS  :  setpriority(-13) succeeded
setpriority01    9  TPASS  :  setpriority(-12) succeeded
setpriority01   10  TPASS  :  setpriority(-11) succeeded
setpriority01   11  TPASS  :  setpriority(-10) succeeded
setpriority01   12  TPASS  :  setpriority(-9) succeeded
setpriority01   13  TPASS  :  setpriority(-8) succeeded
setpriority01   14  TPASS  :  setpriority(-7) succeeded
setpriority01   15  TPASS  :  setpriority(-6) succeeded
setpriority01   16  TPASS  :  setpriority(-5) succeeded
setpriority01   17  TPASS  :  setpriority(-4) succeeded
setpriority01   18  TPASS  :  setpriority(-3) succeeded
setpriority01   19  TPASS  :  setpriority(-2) succeeded
setpriority01   20  TPASS  :  setpriority(-1) succeeded
setpriority01   21  TPASS  :  setpriority(0) succeeded
setpriority01   22  TPASS  :  setpriority(1) succeeded
setpriority01   23  TPASS  :  setpriority(2) succeeded
setpriority01   24  TPASS  :  setpriority(3) succeeded
setpriority01   25  TPASS  :  setpriority(4) succeeded
setpriority01   26  TPASS  :  setpriority(5) succeeded
setpriority01   27  TPASS  :  setpriority(6) succeeded
setpriority01   28  TPASS  :  setpriority(7) succeeded
setpriority01   29  TPASS  :  setpriority(8) succeeded
setpriority01   30  TPASS  :  setpriority(9) succeeded
setpriority01   31  TPASS  :  setpriority(10) succeeded
setpriority01   32  TPASS  :  setpriority(11) succeeded
setpriority01   33  TPASS  :  setpriority(12) succeeded
setpriority01   34  TPASS  :  setpriority(13) succeeded
setpriority01   35  TPASS  :  setpriority(14) succeeded
setpriority01   36  TPASS  :  setpriority(15) succeeded
setpriority01   37  TPASS  :  setpriority(16) succeeded
setpriority01   38  TPASS  :  setpriority(17) succeeded
setpriority01   39  TPASS  :  setpriority(18) succeeded
setpriority01   40  TPASS  :  setpriority(19) succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setpriority02 stime=1411895764
cmdline="setpriority02"
contacts=""
analysis=exit
<<<test_output>>>
setpriority02    1  TPASS  :  expected failure - errno = 13 - Permission denied
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setpriority03 stime=1411895764
cmdline="setpriority03"
contacts=""
analysis=exit
<<<test_output>>>
setpriority03    1  TPASS  :  expected failure - errno = 22 - Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setpriority04 stime=1411895764
cmdline="setpriority04"
contacts=""
analysis=exit
<<<test_output>>>
setpriority04    1  TPASS  :  expected failure - errno = 3 - No such process
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setpriority05 stime=1411895764
cmdline="setpriority05"
contacts=""
analysis=exit
<<<test_output>>>
setpriority05    1  TPASS  :  expected failure - errno = 1 - Operation not permitted
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setregid01 stime=1411895764
cmdline="setregid01"
contacts=""
analysis=exit
<<<test_output>>>
setregid01    1  TPASS  :  setregid -  Dont change either real or effective gid returned 0
setregid01    2  TPASS  :  setregid -  change effective to effective gid returned 0
setregid01    3  TPASS  :  setregid -  change real to real gid returned 0
setregid01    4  TPASS  :  setregid -  change effective to real gid returned 0
setregid01    5  TPASS  :  setregid return 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setregid01_16 stime=1411895764
cmdline="setregid01_16"
contacts=""
analysis=exit
<<<test_output>>>
setregid01_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setregid/../utils/compat_16.h:127: 16-bit version of setregid() is not supported on your platform
setregid01_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setregid/../utils/compat_16.h:127: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setregid03 stime=1411895764
cmdline="setregid03"
contacts=""
analysis=exit
<<<test_output>>>
setregid03    1  TPASS  :  setregid(3, 2) succeeded as expected.
setregid03    2  TPASS  :  real or effective gid was modified as expected
setregid03    3  TPASS  :  setregid(-1, 3) succeeded as expected.
setregid03    4  TPASS  :  real or effective gid was modified as expected
setregid03    5  TPASS  :  setregid(-1, 2) succeeded as expected.
setregid03    6  TPASS  :  real or effective gid was modified as expected
setregid03    7  TPASS  :  setregid(2, -1) succeeded as expected.
setregid03    8  TPASS  :  real or effective gid was modified as expected
setregid03    9  TPASS  :  setregid(-1, -1) succeeded as expected.
setregid03   10  TPASS  :  real or effective gid was modified as expected
setregid03   11  TPASS  :  setregid(-1, 2) succeeded as expected.
setregid03   12  TPASS  :  real or effective gid was modified as expected
setregid03   13  TPASS  :  setregid(2, -1) succeeded as expected.
setregid03   14  TPASS  :  real or effective gid was modified as expected
setregid03   15  TPASS  :  setregid(2, 2) succeeded as expected.
setregid03   16  TPASS  :  real or effective gid was modified as expected
setregid03   17  TPASS  :  setregid(3, -1) failed as expected.
setregid03   18  TPASS  :  real or effective gid was modified as expected
setregid03   19  TPASS  :  setregid(-1, 3) failed as expected.
setregid03   20  TPASS  :  real or effective gid was modified as expected
setregid03   21  TPASS  :  setregid(3, 3) failed as expected.
setregid03   22  TPASS  :  real or effective gid was modified as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setregid03_16 stime=1411895764
cmdline="setregid03_16"
contacts=""
analysis=exit
<<<test_output>>>
setregid03_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setregid/../utils/compat_16.h:127: 16-bit version of setregid() is not supported on your platform
setregid03_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setregid/../utils/compat_16.h:127: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setregid04 stime=1411895764
cmdline="setregid04"
contacts=""
analysis=exit
<<<test_output>>>
setregid04    1  TPASS  :  real or effective gid was modified as expected
setregid04    2  TPASS  :  real or effective gid was modified as expected
setregid04    3  TPASS  :  real or effective gid was modified as expected
setregid04    4  TPASS  :  real or effective gid was modified as expected
setregid04    5  TPASS  :  real or effective gid was modified as expected
setregid04    6  TPASS  :  real or effective gid was modified as expected
setregid04    7  TPASS  :  real or effective gid was modified as expected
setregid04    8  TPASS  :  real or effective gid was modified as expected
setregid04    9  TPASS  :  real or effective gid was modified as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setregid04_16 stime=1411895764
cmdline="setregid04_16"
contacts=""
analysis=exit
<<<test_output>>>
setregid04_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setregid/../utils/compat_16.h:127: 16-bit version of setregid() is not supported on your platform
setregid04_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setregid/../utils/compat_16.h:127: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setresgid01 stime=1411895764
cmdline="setresgid01"
contacts=""
analysis=exit
<<<test_output>>>
setresgid01    1  TPASS  :  Test for setresgid(-1, -1, -1) successful
setresgid01    2  TPASS  :  Test for setresgid(-1, -1, nobody) successful
setresgid01    3  TPASS  :  Test for setresgid(-1, nobody, -1) successful
setresgid01    4  TPASS  :  Test for setresgid(nobody, -1, -1) successful
setresgid01    5  TPASS  :  Test for setresgid(root, root, root) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=setresgid01_16 stime=1411895764
cmdline="setresgid01_16"
contacts=""
analysis=exit
<<<test_output>>>
setresgid01    1  TPASS  :  Test for setresgid(-1, -1, -1) successful
setresgid01    2  TPASS  :  Test for setresgid(-1, -1, nobody) successful
setresgid01    3  TPASS  :  Test for setresgid(-1, nobody, -1) successful
setresgid01    4  TPASS  :  Test for setresgid(nobody, -1, -1) successful
setresgid01    5  TPASS  :  Test for setresgid(root, root, root) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setresgid02 stime=1411895764
cmdline="setresgid02"
contacts=""
analysis=exit
<<<test_output>>>
setresgid02    1  TPASS  :  Test for setresgid(-1, -1, -1) successful
setresgid02    2  TPASS  :  Test for setresgid(-1, -1, bin) successful
setresgid02    3  TPASS  :  Test for setresgid(-1, bin, -1) successful
setresgid02    4  TPASS  :  Test for setresgid(bin, -1, -1) successful
setresgid02    5  TPASS  :  Test for setresgid(root, root, root) successful
setresgid02    6  TPASS  :  Test for setresgid(root, nobody, nobody) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setresgid02_16 stime=1411895764
cmdline="setresgid02_16"
contacts=""
analysis=exit
<<<test_output>>>
setresgid02    1  TPASS  :  Test for setresgid(-1, -1, -1) successful
setresgid02    2  TPASS  :  Test for setresgid(-1, -1, bin) successful
setresgid02    3  TPASS  :  Test for setresgid(-1, bin, -1) successful
setresgid02    4  TPASS  :  Test for setresgid(bin, -1, -1) successful
setresgid02    5  TPASS  :  Test for setresgid(root, root, root) successful
setresgid02    6  TPASS  :  Test for setresgid(root, nobody, nobody) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setresgid03 stime=1411895764
cmdline="setresgid03"
contacts=""
analysis=exit
<<<test_output>>>
setresgid03    1  TPASS  :  setresgid() failed as expected for unprivileged user : errno 1
setresgid03    2  TPASS  :  setresgid() failed as expected for unprivileged user : errno 1
setresgid03    3  TPASS  :  setresgid() failed as expected for unprivileged user : errno 1
setresgid03    4  TPASS  :  setresgid() failed as expected for unprivileged user : errno 1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setresgid03_16 stime=1411895764
cmdline="setresgid03_16"
contacts=""
analysis=exit
<<<test_output>>>
setresgid03    1  TPASS  :  setresgid() failed as expected for unprivileged user : errno 1
setresgid03    2  TPASS  :  setresgid() failed as expected for unprivileged user : errno 1
setresgid03    3  TPASS  :  setresgid() failed as expected for unprivileged user : errno 1
setresgid03    4  TPASS  :  setresgid() failed as expected for unprivileged user : errno 1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setresgid04 stime=1411895764
cmdline="setresgid04"
contacts=""
analysis=exit
<<<test_output>>>
setresgid04    1  TPASS  :  setresgid succeeded as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setresgid04_16 stime=1411895764
cmdline="setresgid04_16"
contacts=""
analysis=exit
<<<test_output>>>
setresgid04    1  TPASS  :  setresgid succeeded as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setresuid01 stime=1411895764
cmdline="setresuid01"
contacts=""
analysis=exit
<<<test_output>>>
setresuid01    1  TPASS  :  real uid = 0, effective uid = 0, and saved uid = 0 as expected
setresuid01    2  TPASS  :  real uid = 0, effective uid = 0, and saved uid = 65534 as expected
setresuid01    3  TPASS  :  real uid = 0, effective uid = 2, and saved uid = 65534 as expected
setresuid01    4  TPASS  :  real uid = 0, effective uid = 2, and saved uid = 0 as expected
setresuid01    5  TPASS  :  real uid = 0, effective uid = 2, and saved uid = 2 as expected
setresuid01    6  TPASS  :  real uid = 0, effective uid = 0, and saved uid = 2 as expected
setresuid01    7  TPASS  :  real uid = 65534, effective uid = 0, and saved uid = 2 as expected
setresuid01    8  TPASS  :  real uid = 65534, effective uid = 0, and saved uid = 2 as expected
setresuid01    9  TPASS  :  real uid = 0, effective uid = 0, and saved uid = 0 as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setresuid01_16 stime=1411895764
cmdline="setresuid01_16"
contacts=""
analysis=exit
<<<test_output>>>
setresuid01    1  TPASS  :  real uid = 0, effective uid = 0, and saved uid = 0 as expected
setresuid01    2  TPASS  :  real uid = 0, effective uid = 0, and saved uid = 65534 as expected
setresuid01    3  TPASS  :  real uid = 0, effective uid = 2, and saved uid = 65534 as expected
setresuid01    4  TPASS  :  real uid = 0, effective uid = 2, and saved uid = 0 as expected
setresuid01    5  TPASS  :  real uid = 0, effective uid = 2, and saved uid = 2 as expected
setresuid01    6  TPASS  :  real uid = 0, effective uid = 0, and saved uid = 2 as expected
setresuid01    7  TPASS  :  real uid = 65534, effective uid = 0, and saved uid = 2 as expected
setresuid01    8  TPASS  :  real uid = 65534, effective uid = 0, and saved uid = 2 as expected
setresuid01    9  TPASS  :  real uid = 0, effective uid = 0, and saved uid = 0 as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setresuid02 stime=1411895764
cmdline="setresuid02"
contacts=""
analysis=exit
<<<test_output>>>
setresuid02    1  TPASS  :  setresuid(-1, -1, 2) succeeded as expected.
setresuid02    0  TINFO  :  real uid = 65534, effective uid = 2, and saved uid = 2 as expected
setresuid02    2  TPASS  :  setresuid(-1, 65534, -1) succeeded as expected.
setresuid02    0  TINFO  :  real uid = 65534, effective uid = 65534, and saved uid = 2 as expected
setresuid02    3  TPASS  :  setresuid(2, -1, -1) succeeded as expected.
setresuid02    0  TINFO  :  real uid = 2, effective uid = 65534, and saved uid = 2 as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setresuid02_16 stime=1411895764
cmdline="setresuid02_16"
contacts=""
analysis=exit
<<<test_output>>>
setresuid02    1  TPASS  :  setresuid(-1, -1, 2) succeeded as expected.
setresuid02    0  TINFO  :  real uid = 65534, effective uid = 2, and saved uid = 2 as expected
setresuid02    2  TPASS  :  setresuid(-1, 65534, -1) succeeded as expected.
setresuid02    0  TINFO  :  real uid = 65534, effective uid = 65534, and saved uid = 2 as expected
setresuid02    3  TPASS  :  setresuid(2, -1, -1) succeeded as expected.
setresuid02    0  TINFO  :  real uid = 2, effective uid = 65534, and saved uid = 2 as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setresuid03 stime=1411895764
cmdline="setresuid03"
contacts=""
analysis=exit
<<<test_output>>>
setresuid03    1  TPASS  :  setresuid(65534, -1, -1) failed as expected.
setresuid03    0  TINFO  :  real uid = 0, effective uid = 2, and saved uid = 2 as expected
setresuid03    2  TPASS  :  setresuid(-1, -1, 65534) failed as expected.
setresuid03    0  TINFO  :  real uid = 0, effective uid = 2, and saved uid = 2 as expected
setresuid03    3  TPASS  :  setresuid(-1, 65534, -1) failed as expected.
setresuid03    0  TINFO  :  real uid = 0, effective uid = 2, and saved uid = 2 as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setresuid03_16 stime=1411895764
cmdline="setresuid03_16"
contacts=""
analysis=exit
<<<test_output>>>
setresuid03    1  TPASS  :  setresuid(65534, -1, -1) failed as expected.
setresuid03    0  TINFO  :  real uid = 0, effective uid = 2, and saved uid = 2 as expected
setresuid03    2  TPASS  :  setresuid(-1, -1, 65534) failed as expected.
setresuid03    0  TINFO  :  real uid = 0, effective uid = 2, and saved uid = 2 as expected
setresuid03    3  TPASS  :  setresuid(-1, 65534, -1) failed as expected.
setresuid03    0  TINFO  :  real uid = 0, effective uid = 2, and saved uid = 2 as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setresuid04 stime=1411895764
cmdline="setresuid04"
contacts=""
analysis=exit
<<<test_output>>>
open failed with EACCES as expected
open failed with EACCES as expected
open call succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=setresuid04_16 stime=1411895764
cmdline="setresuid04_16"
contacts=""
analysis=exit
<<<test_output>>>
open failed with EACCES as expected
open failed with EACCES as expected
open call succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setresuid05 stime=1411895764
cmdline="setresuid05"
contacts=""
analysis=exit
<<<test_output>>>
setresuid05    1  TPASS  :  setresuid succeeded as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setresuid05_16 stime=1411895764
cmdline="setresuid05_16"
contacts=""
analysis=exit
<<<test_output>>>
setresuid05    1  TPASS  :  setresuid succeeded as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setreuid01 stime=1411895764
cmdline="setreuid01"
contacts=""
analysis=exit
<<<test_output>>>
setreuid01    1  TPASS  :  setreuid -  Don't change either real or effective uid returned 0
setreuid01    2  TPASS  :  setreuid -  change effective to effective uid returned 0
setreuid01    3  TPASS  :  setreuid -  change real to real uid returned 0
setreuid01    4  TPASS  :  setreuid -  change effective to real uid returned 0
setreuid01    5  TPASS  :  setreuid -  try to change real to current real returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setreuid01_16 stime=1411895764
cmdline="setreuid01_16"
contacts=""
analysis=exit
<<<test_output>>>
setreuid01_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setreuid/../utils/compat_16.h:123: 16-bit version of setreuid() is not supported on your platform
setreuid01_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setreuid/../utils/compat_16.h:123: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setreuid02 stime=1411895764
cmdline="setreuid02"
contacts=""
analysis=exit
<<<test_output>>>
setreuid02    1  TPASS  :  real or effective uid was modified as expected
setreuid02    2  TPASS  :  real or effective uid was modified as expected
setreuid02    3  TPASS  :  real or effective uid was modified as expected
setreuid02    4  TPASS  :  real or effective uid was modified as expected
setreuid02    5  TPASS  :  real or effective uid was modified as expected
setreuid02    6  TPASS  :  real or effective uid was modified as expected
setreuid02    7  TPASS  :  real or effective uid was modified as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setreuid02_16 stime=1411895764
cmdline="setreuid02_16"
contacts=""
analysis=exit
<<<test_output>>>
setreuid02_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setreuid/../utils/compat_16.h:123: 16-bit version of setreuid() is not supported on your platform
setreuid02_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setreuid/../utils/compat_16.h:123: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setreuid03 stime=1411895764
cmdline="setreuid03"
contacts=""
analysis=exit
<<<test_output>>>
setreuid03    1  TPASS  :  setreuid(65534, 65534) succeeded as expected.
setreuid03    2  TPASS  :  setreuid(-1, 65534) succeeded as expected.
setreuid03    3  TPASS  :  setreuid(65534, -1) succeeded as expected.
setreuid03    4  TPASS  :  setreuid(-1, -1) succeeded as expected.
setreuid03    5  TPASS  :  setreuid(-1, 0) succeeded as expected.
setreuid03    6  TPASS  :  setreuid(0, -1) succeeded as expected.
setreuid03    7  TPASS  :  setreuid(0, 0) succeeded as expected.
setreuid03    8  TPASS  :  setreuid(0, 65534) succeeded as expected.
setreuid03    9  TPASS  :  setreuid(0, 2) succeeded as expected.
setreuid03   10  TPASS  :  setreuid(2, 0) succeeded as expected.
setreuid03   11  TPASS  :  setreuid(2, -1) succeeded as expected.
setreuid03   12  TPASS  :  setreuid(2, 2) succeeded as expected.
setreuid03   13  TPASS  :  setreuid(2, 65534) succeeded as expected.
setreuid03   14  TPASS  :  setreuid(65534, 2) succeeded as expected.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setreuid03_16 stime=1411895764
cmdline="setreuid03_16"
contacts=""
analysis=exit
<<<test_output>>>
setreuid03_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setreuid/../utils/compat_16.h:123: 16-bit version of setreuid() is not supported on your platform
setreuid03_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setreuid/../utils/compat_16.h:123: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setreuid04 stime=1411895764
cmdline="setreuid04"
contacts=""
analysis=exit
<<<test_output>>>
setreuid04    1  TPASS  :  setreuid(-1, -1) succeeded as expected.
setreuid04    2  TPASS  :  setreuid(65534, 65534) succeeded as expected.
setreuid04    0  TINFO  :  Child process returned TPASS
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setreuid04_16 stime=1411895764
cmdline="setreuid04_16"
contacts=""
analysis=exit
<<<test_output>>>
setreuid04_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setreuid/../utils/compat_16.h:123: 16-bit version of setreuid() is not supported on your platform
setreuid04_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setreuid/../utils/compat_16.h:123: Remaining cases not appropriate for configuration
setreuid04_16    0  TINFO  :  Child process returned TCONF
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setreuid05 stime=1411895764
cmdline="setreuid05"
contacts=""
analysis=exit
<<<test_output>>>
setreuid05    1  TPASS  :  setreuid(65534, 0) succeeded as expected.
setreuid05    2  TPASS  :  setreuid(-1, 65534) succeeded as expected.
setreuid05    3  TPASS  :  setreuid(-1, 0) succeeded as expected.
setreuid05    4  TPASS  :  setreuid(1, -1) succeeded as expected.
setreuid05    5  TPASS  :  setreuid(-1, 2) succeeded as expected.
setreuid05    6  TPASS  :  setreuid(-1, 0) succeeded as expected.
setreuid05    7  TPASS  :  setreuid(-1, 65534) succeeded as expected.
setreuid05    8  TPASS  :  setreuid(-1, 1) succeeded as expected.
setreuid05    9  TPASS  :  setreuid(-1, 2) succeeded as expected.
setreuid05   10  TPASS  :  setreuid(2, 1) succeeded as expected.
setreuid05   11  TPASS  :  setreuid(-1, 2) succeeded as expected.
setreuid05   12  TPASS  :  setreuid(-1, 1) succeeded as expected.
setreuid05   13  TPASS  :  setreuid(1, -1) succeeded as expected.
setreuid05   14  TPASS  :  setreuid(-1, 2) succeeded as expected.
setreuid05    0  TINFO  :  Child process returned TPASS
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setreuid05_16 stime=1411895764
cmdline="setreuid05_16"
contacts=""
analysis=exit
<<<test_output>>>
setreuid05_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setreuid/../utils/compat_16.h:123: 16-bit version of setreuid() is not supported on your platform
setreuid05_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setreuid/../utils/compat_16.h:123: Remaining cases not appropriate for configuration
setreuid05_16    0  TINFO  :  Child process returned TCONF
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setreuid06 stime=1411895764
cmdline="setreuid06"
contacts=""
analysis=exit
<<<test_output>>>
setreuid06    1  TPASS  :  setreuid set errno to EPERM as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setreuid06_16 stime=1411895764
cmdline="setreuid06_16"
contacts=""
analysis=exit
<<<test_output>>>
setreuid06_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setreuid/../utils/compat_16.h:123: 16-bit version of setreuid() is not supported on your platform
setreuid06_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setreuid/../utils/compat_16.h:123: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=setreuid07 stime=1411895764
cmdline="setreuid07"
contacts=""
analysis=exit
<<<test_output>>>
open failed with EACCES as expected
open failed with EACCES as expected
open call succeeded
setreuid07    0  TINFO  :  Child process returned TPASS
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setreuid07_16 stime=1411895764
cmdline="setreuid07_16"
contacts=""
analysis=exit
<<<test_output>>>
setreuid07_16    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setreuid/../utils/compat_16.h:123: 16-bit version of setreuid() is not supported on your platform
setreuid07_16    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setreuid/../utils/compat_16.h:123: Remaining cases not appropriate for configuration
setreuid07_16    0  TINFO  :  Child process returned TCONF
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setrlimit01 stime=1411895764
cmdline="setrlimit01"
contacts=""
analysis=exit
<<<test_output>>>
setrlimit01    1  TPASS  :  RLIMIT_NOFILE functionality is correct
setrlimit01    2  TPASS  :  RLIMIT_FSIZE test PASSED
setrlimit01    3  TPASS  :  RLIMIT_NPROC functionality is correct
setrlimit01    4  TPASS  :  RLIMIT_CORE functionality is correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setrlimit02 stime=1411895764
cmdline="setrlimit02"
contacts=""
analysis=exit
<<<test_output>>>
setrlimit02    1  TPASS  :  expected failure - errno = 14 : Bad address
setrlimit02    2  TPASS  :  expected failure - errno = 22 : Invalid argument
setrlimit02    3  TPASS  :  expected failure - errno = 1 : Operation not permitted
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setrlimit03 stime=1411895764
cmdline="setrlimit03"
contacts=""
analysis=exit
<<<test_output>>>
setrlimit03    1  TPASS  :  got expected EPERM error
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=set_robust_list01 stime=1411895764
cmdline="set_robust_list01"
contacts=""
analysis=exit
<<<test_output>>>
set_robust_list01    1  TPASS  :  set_robust_list: retval = -1 (expected -1), errno = 22 (expected 22)
set_robust_list01    2  TPASS  :  set_robust_list: retval = 0 (expected 0), errno = 0 (expected 0)
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=set_thread_area01 stime=1411895764
cmdline="set_thread_area01"
contacts=""
analysis=exit
<<<test_output>>>
set_thread_area_01    1  TCONF  :  set_thread_area01.c:90: syscall tests[i].syscall not supported on your arch
set_thread_area_01    2  TCONF  :  set_thread_area01.c:90: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=set_tid_address01 stime=1411895764
cmdline="set_tid_address01"
contacts=""
analysis=exit
<<<test_output>>>
set_tid_address01    1  TPASS  :  set_tid_address call succeeded:  as expected 29815
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setsid01 stime=1411895764
cmdline="setsid01"
contacts=""
analysis=exit
<<<test_output>>>
setsid01    1  TPASS  :  setsid SUCCESS to set errno to EPERM
setsid01    1  TPASS  :  all misc tests passed
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setsockopt01 stime=1411895765
cmdline="setsockopt01"
contacts=""
analysis=exit
<<<test_output>>>
setsockopt01    1  TPASS  :  bad file descriptor successful
setsockopt01    2  TPASS  :  bad file descriptor successful
setsockopt01    3  TPASS  :  invalid option buffer successful
setsockopt01    4  TPASS  :  invalid optlen successful
setsockopt01    5  TPASS  :  invalid level successful
setsockopt01    6  TPASS  :  invalid option name (UDP) successful
setsockopt01    7  TPASS  :  invalid option name (IP) successful
setsockopt01    8  TPASS  :  invalid option name (TCP) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=settimeofday01 stime=1411895765
cmdline="settimeofday01"
contacts=""
analysis=exit
<<<test_output>>>
settimeofday01    1  TPASS  :  Test condition 1 successful
settimeofday01    2  TPASS  :  Test condition 2 successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=settimeofday02 stime=1411895765
cmdline="settimeofday02"
contacts=""
analysis=exit
<<<test_output>>>
settimeofday02    1  TPASS  :  Received expected errno
settimeofday02    2  TPASS  :  Received expected errno
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=setuid01 stime=1411895765
cmdline="setuid01"
contacts=""
analysis=exit
<<<test_output>>>
setuid01    1  TPASS  :  setuid -  Set the effective user ID to the current real uid returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setuid01_16 stime=1411895765
cmdline="setuid01_16"
contacts=""
analysis=exit
<<<test_output>>>
setuid01    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setuid/../utils/compat_16.h:83: 16-bit version of setuid() is not supported on your platform
setuid01    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setuid/../utils/compat_16.h:83: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setuid02 stime=1411895765
cmdline="setuid02"
contacts=""
analysis=exit
<<<test_output>>>
setuid02    1  TPASS  :  setuid -  Set the effective user ID to the current real uid returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setuid02_16 stime=1411895765
cmdline="setuid02_16"
contacts=""
analysis=exit
<<<test_output>>>
setuid02    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setuid/../utils/compat_16.h:83: 16-bit version of setuid() is not supported on your platform
setuid02    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setuid/../utils/compat_16.h:83: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setuid03 stime=1411895765
cmdline="setuid03"
contacts=""
analysis=exit
<<<test_output>>>
setuid03    1  TPASS  :  setuid returned errno EPERM
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setuid03_16 stime=1411895765
cmdline="setuid03_16"
contacts=""
analysis=exit
<<<test_output>>>
setuid03    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setuid/../utils/compat_16.h:83: 16-bit version of setuid() is not supported on your platform
setuid03    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setuid/../utils/compat_16.h:83: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setuid04 stime=1411895765
cmdline="setuid04"
contacts=""
analysis=exit
<<<test_output>>>
setuid04    1  TPASS  :  open returned errno EACCES
setuid04    2  TPASS  :  open returned errno EACCES
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setuid04_16 stime=1411895765
cmdline="setuid04_16"
contacts=""
analysis=exit
<<<test_output>>>
setuid04    1  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setuid/../utils/compat_16.h:83: 16-bit version of setuid() is not supported on your platform
setuid04    2  TCONF  :  /tmp/ltp/testcases/kernel/syscalls/setuid/../utils/compat_16.h:83: Remaining cases not appropriate for configuration
setuid04    1  TCONF  :  setuid04.c:78: son process exits with error
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setxattr01 stime=1411895765
cmdline="setxattr01"
contacts=""
analysis=exit
<<<test_output>>>
setxattr01    1  TCONF  :  setxattr01.c:198: No xattr support in fs or mount without user_xattr option
setxattr01    2  TCONF  :  setxattr01.c:198: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setxattr02 stime=1411895765
cmdline="setxattr02"
contacts=""
analysis=exit
<<<test_output>>>
setxattr02    1  TCONF  :  setxattr02.c:198: No xattr support in fs or mount without user_xattr option
setxattr02    2  TCONF  :  setxattr02.c:198: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=setxattr03 stime=1411895765
cmdline="setxattr03"
contacts=""
analysis=exit
<<<test_output>>>
setxattr03    1  TCONF  :  setxattr03.c:181: No xattr support in fs or fs mounted without user_xattr option
setxattr03    2  TCONF  :  setxattr03.c:181: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=shmat01 stime=1411895765
cmdline="shmat01"
contacts=""
analysis=exit
<<<test_output>>>
shmat01     1  TPASS  :  conditions and functionality are correct
shmat01     2  TPASS  :  conditions and functionality are correct
shmat01     3  TPASS  :  conditions and functionality are correct
shmat01     4  TPASS  :  conditions and functionality are correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=shmat02 stime=1411895765
cmdline="shmat02"
contacts=""
analysis=exit
<<<test_output>>>
shmat02     1  TPASS  :  shmat failed as expected: errno=EINVAL(22): Invalid argument
shmat02     2  TPASS  :  shmat failed as expected: errno=EINVAL(22): Invalid argument
shmat02     3  TPASS  :  shmat failed as expected: errno=EACCES(13): Permission denied
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=shmat03 stime=1411895765
cmdline="shmat03"
contacts=""
analysis=exit
<<<test_output>>>
shmat03     1  TPASS  :  expected failure: TEST_ERRNO=EACCES(13): Permission denied
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=shmctl01 stime=1411895765
cmdline="shmctl01"
contacts=""
analysis=exit
<<<test_output>>>
shmctl01    1  TPASS  :  pid, size, # of attaches and mode are correct - pass #1
shmctl01    2  TPASS  :  pid, size, # of attaches and mode are correct - pass #2
shmctl01    3  TPASS  :  new mode and change time are correct
shmctl01    4  TPASS  :  get correct shared memory limits
shmctl01    5  TPASS  :  get correct shared memory id
shmctl01    6  TPASS  :  SHM_LOCK is set
shmctl01    7  TPASS  :  SHM_LOCK is cleared
shmctl01    8  TPASS  :  shared memory appears to be removed
<<<execution_status>>>
initiation_status="ok"
duration=3 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=shmctl02 stime=1411895768
cmdline="shmctl02"
contacts=""
analysis=exit
<<<test_output>>>
shmctl02    1  TPASS  :  expected failure - errno = 13 : Permission denied
shmctl02    2  TPASS  :  expected failure - errno = 14 : Bad address
shmctl02    3  TPASS  :  expected failure - errno = 14 : Bad address
shmctl02    4  TPASS  :  expected failure - errno = 22 : Invalid argument
shmctl02    5  TPASS  :  expected failure - errno = 22 : Invalid argument
shmctl02    6  TCONF  :  shmctl02.c:145: shmctl() did not fail for non-root user.This may be okay for your distribution.
shmctl02    7  TCONF  :  shmctl02.c:145: shmctl() did not fail for non-root user.This may be okay for your distribution.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=shmctl03 stime=1411895768
cmdline="shmctl03"
contacts=""
analysis=exit
<<<test_output>>>
shmctl03    1  TPASS  :  expected failure - errno = 13 : Permission denied
shmctl03    2  TPASS  :  expected failure - errno = 1 : Operation not permitted
shmctl03    3  TPASS  :  expected failure - errno = 1 : Operation not permitted
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=shmctl04 stime=1411895768
cmdline="shmctl04"
contacts=""
analysis=exit
<<<test_output>>>
shmctl04    1  TPASS  :  SHM_INFO call succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=shmdt01 stime=1411895768
cmdline="shmdt01"
contacts=""
analysis=exit
<<<test_output>>>
shmdt01     1  TPASS  :  shared memory detached correctly
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=shmdt02 stime=1411895768
cmdline="shmdt02"
contacts=""
analysis=exit
<<<test_output>>>
shmdt02     1  TPASS  :  expected failure - errno = 22 : Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=shmget01 stime=1411895768
cmdline="shmget01"
contacts=""
analysis=exit
<<<test_output>>>
shmget01    1  TPASS  :  size, pid & mode are correct
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=shmget02 stime=1411895768
cmdline="shmget02"
contacts=""
analysis=exit
<<<test_output>>>
shmget02    1  TPASS  :  expected failure - errno = 22 : Invalid argument
shmget02    2  TPASS  :  expected failure - errno = 22 : Invalid argument
shmget02    3  TPASS  :  expected failure - errno = 17 : File exists
shmget02    4  TPASS  :  expected failure - errno = 2 : No such file or directory
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=shmget03 stime=1411895768
cmdline="shmget03"
contacts=""
analysis=exit
<<<test_output>>>
shmget03    1  TPASS  :  expected failure - errno = 28 : No space left on device
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=shmget04 stime=1411895768
cmdline="shmget04"
contacts=""
analysis=exit
<<<test_output>>>
shmget04    1  TPASS  :  expected failure - errno = 13 : Permission denied
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=shmget05 stime=1411895768
cmdline="shmget05"
contacts=""
analysis=exit
<<<test_output>>>
shmget05    1  TPASS  :  expected failure - errno = 13 : Permission denied
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sigaction01 stime=1411895768
cmdline="sigaction01"
contacts=""
analysis=exit
<<<test_output>>>
sigaction01    1  TPASS  :  SA_RESETHAND did not cause SA_SIGINFO to be cleared
sigaction01    2  TPASS  :  SA_RESETHAND was masked when handler executed
sigaction01    3  TPASS  :  sig has been masked because sa_mask originally contained sig
sigaction01    4  TPASS  :  siginfo pointer non NULL
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sigaction02 stime=1411895768
cmdline="sigaction02"
contacts=""
analysis=exit
<<<test_output>>>
sigaction02    1  TPASS  :  call failed with expected EINVAL error
sigaction02    2  TPASS  :  call failed with expected EINVAL error
sigaction02    3  TPASS  :  call failed with expected EINVAL error
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sigaltstack01 stime=1411895768
cmdline="sigaltstack01"
contacts=""
analysis=exit
<<<test_output>>>
sigaltstack01    1  TPASS  :  Functionality of sigaltstack() successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sigaltstack02 stime=1411895768
cmdline="sigaltstack02"
contacts=""
analysis=exit
<<<test_output>>>
sigaltstack02    1  TPASS  :  stgaltstack() fails, Invalid Flag value, errno:22
sigaltstack02    2  TPASS  :  stgaltstack() fails, alternate stack is < MINSIGSTKSZ, errno:12
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sighold02 stime=1411895768
cmdline="sighold02"
contacts=""
analysis=exit
<<<test_output>>>
sighold02    1  TPASS  :  Sighold called without error for 57 of 64 signals
sighold02    2  TPASS  :  No signals trapped after being sent by parent
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=signal01 stime=1411895768
cmdline="signal01"
contacts=""
analysis=exit
<<<test_output>>>
signal01    1  TPASS  :  From child: signal(SIGKILL, catchsig) ret:0xffffffffffffffff SIG_ERR (-1) as expected
signal01    2  TPASS  :  The child was killed by SIGKILL.
signal01    3  TPASS  :  From child: signal(SIGKILL, SIG_IGN) ret:0xffffffffffffffff SIG_ERR (-1) as expected
signal01    4  TPASS  :  The child was killed by SIGKILL.
signal01    5  TPASS  :  signal(SIGKILL,SIG_DFL) ret:0xffffffffffffffff, errno EINVAL as expected
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=signal02 stime=1411895768
cmdline="signal02"
contacts=""
analysis=exit
<<<test_output>>>
signal02    1  TPASS  :  expected failure - errno = 22 - Invalid argument
signal02    2  TPASS  :  expected failure - errno = 22 - Invalid argument
signal02    3  TPASS  :  expected failure - errno = 22 - Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=signal03 stime=1411895768
cmdline="signal03"
contacts=""
analysis=exit
<<<test_output>>>
signal03    1  TPASS  :  signal03 call succeeded
signal03    2  TPASS  :  signal03 call succeeded
signal03    3  TPASS  :  signal03 call succeeded
signal03    4  TPASS  :  signal03 call succeeded
signal03    5  TPASS  :  signal03 call succeeded
signal03    6  TPASS  :  signal03 call succeeded
signal03    7  TPASS  :  signal03 call succeeded
signal03    8  TPASS  :  signal03 call succeeded
signal03    9  TPASS  :  signal03 call succeeded
signal03   10  TPASS  :  signal03 call succeeded
signal03   11  TPASS  :  signal03 call succeeded
signal03   12  TPASS  :  signal03 call succeeded
signal03   13  TPASS  :  signal03 call succeeded
signal03   14  TPASS  :  signal03 call succeeded
signal03   15  TPASS  :  signal03 call succeeded
signal03   16  TPASS  :  signal03 call succeeded
signal03   17  TPASS  :  signal03 call succeeded
signal03   18  TPASS  :  signal03 call succeeded
signal03   19  TPASS  :  signal03 call succeeded
signal03   20  TPASS  :  signal03 call succeeded
signal03   21  TPASS  :  signal03 call succeeded
signal03   22  TPASS  :  signal03 call succeeded
signal03   23  TPASS  :  signal03 call succeeded
signal03   24  TPASS  :  signal03 call succeeded
signal03   25  TPASS  :  signal03 call succeeded
signal03   26  TPASS  :  signal03 call succeeded
signal03   27  TPASS  :  signal03 call succeeded
signal03   28  TPASS  :  signal03 call succeeded
signal03   29  TPASS  :  signal03 call succeeded
signal03   30  TPASS  :  signal03 call succeeded
signal03   31  TPASS  :  signal03 call succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=signal04 stime=1411895768
cmdline="signal04"
contacts=""
analysis=exit
<<<test_output>>>
signal04    1  TPASS  :  signal04 call succeeded received (nil).
signal04    2  TPASS  :  signal04 call succeeded received (nil).
signal04    3  TPASS  :  signal04 call succeeded received (nil).
signal04    4  TPASS  :  signal04 call succeeded received (nil).
signal04    5  TPASS  :  signal04 call succeeded received (nil).
signal04    6  TPASS  :  signal04 call succeeded received (nil).
signal04    7  TPASS  :  signal04 call succeeded received (nil).
signal04    8  TPASS  :  signal04 call succeeded received (nil).
signal04    9  TPASS  :  signal04 call succeeded received (nil).
signal04   10  TPASS  :  signal04 call succeeded received (nil).
signal04   11  TPASS  :  signal04 call succeeded received (nil).
signal04   12  TPASS  :  signal04 call succeeded received (nil).
signal04   13  TPASS  :  signal04 call succeeded received (nil).
signal04   14  TPASS  :  signal04 call succeeded received (nil).
signal04   15  TPASS  :  signal04 call succeeded received (nil).
signal04   16  TPASS  :  signal04 call succeeded received (nil).
signal04   17  TPASS  :  signal04 call succeeded received (nil).
signal04   18  TPASS  :  signal04 call succeeded received (nil).
signal04   19  TPASS  :  signal04 call succeeded received (nil).
signal04   20  TPASS  :  signal04 call succeeded received (nil).
signal04   21  TPASS  :  signal04 call succeeded received (nil).
signal04   22  TPASS  :  signal04 call succeeded received (nil).
signal04   23  TPASS  :  signal04 call succeeded received (nil).
signal04   24  TPASS  :  signal04 call succeeded received (nil).
signal04   25  TPASS  :  signal04 call succeeded received (nil).
signal04   26  TPASS  :  signal04 call succeeded received (nil).
signal04   27  TPASS  :  signal04 call succeeded received (nil).
signal04   28  TPASS  :  signal04 call succeeded received (nil).
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=signal05 stime=1411895768
cmdline="signal05"
contacts=""
analysis=exit
<<<test_output>>>
signal05    1  TPASS  :  signal05 call succeeded
signal05    2  TPASS  :  signal05 call succeeded
signal05    3  TPASS  :  signal05 call succeeded
signal05    4  TPASS  :  signal05 call succeeded
signal05    5  TPASS  :  signal05 call succeeded
signal05    6  TPASS  :  signal05 call succeeded
signal05    7  TPASS  :  signal05 call succeeded
signal05    8  TPASS  :  signal05 call succeeded
signal05    9  TPASS  :  signal05 call succeeded
signal05   10  TPASS  :  signal05 call succeeded
signal05   11  TPASS  :  signal05 call succeeded
signal05   12  TPASS  :  signal05 call succeeded
signal05   13  TPASS  :  signal05 call succeeded
signal05   14  TPASS  :  signal05 call succeeded
signal05   15  TPASS  :  signal05 call succeeded
signal05   16  TPASS  :  signal05 call succeeded
signal05   17  TPASS  :  signal05 call succeeded
signal05   18  TPASS  :  signal05 call succeeded
signal05   19  TPASS  :  signal05 call succeeded
signal05   20  TPASS  :  signal05 call succeeded
signal05   21  TPASS  :  signal05 call succeeded
signal05   22  TPASS  :  signal05 call succeeded
signal05   23  TPASS  :  signal05 call succeeded
signal05   24  TPASS  :  signal05 call succeeded
signal05   25  TPASS  :  signal05 call succeeded
signal05   26  TPASS  :  signal05 call succeeded
signal05   27  TPASS  :  signal05 call succeeded
signal05   28  TPASS  :  signal05 call succeeded
signal05   29  TPASS  :  signal05 call succeeded
signal05   30  TPASS  :  signal05 call succeeded
signal05   31  TPASS  :  signal05 call succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=signalfd01 stime=1411895768
cmdline="signalfd01"
contacts=""
analysis=exit
<<<test_output>>>
signalfd01    1  TPASS  :  signalfd is created successfully
signalfd01    2  TPASS  :  signalfd is successfully reassigned
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=signalfd4_01 stime=1411895768
cmdline="signalfd4_01"
contacts=""
analysis=exit
<<<test_output>>>
signalfd4_01    1  TPASS  :  signalfd4(SFD_CLOEXEC) Passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=signalfd4_02 stime=1411895768
cmdline="signalfd4_02"
contacts=""
analysis=exit
<<<test_output>>>
signalfd4_02    1  TPASS  :  signalfd4(SFD_NONBLOCK) PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sigpending02 stime=1411895768
cmdline="sigpending02"
contacts=""
analysis=exit
<<<test_output>>>
sigpending02    1  TPASS  :  expected failure - errno = 14 : Bad address
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sigprocmask01 stime=1411895768
cmdline="sigprocmask01"
contacts=""
analysis=exit
<<<test_output>>>
sigprocmask01    1  TPASS  :  Functionality of sigprocmask() Successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sigrelse01 stime=1411895768
cmdline="sigrelse01"
contacts=""
analysis=exit
<<<test_output>>>
sigrelse01    1  TPASS  :  sigrelse() released all 55 signals under test.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sigsuspend01 stime=1411895768
cmdline="sigsuspend01"
contacts=""
analysis=exit
<<<test_output>>>
sigsuspend01    1  TPASS  :  Functionality of sigsuspend() successful
<<<execution_status>>>
initiation_status="ok"
duration=5 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=socket01 stime=1411895773
cmdline="socket01"
contacts=""
analysis=exit
<<<test_output>>>
socket01    1  TPASS  :  invalid domain successful
socket01    2  TPASS  :  invalid type successful
socket01    3  TPASS  :  UNIX domain dgram successful
socket01    4  TPASS  :  raw open as non-root successful
socket01    5  TPASS  :  UDP socket successful
socket01    6  TPASS  :  UDP stream successful
socket01    7  TPASS  :  TCP dgram successful
socket01    8  TPASS  :  TCP socket successful
socket01    9  TPASS  :  ICMP stream successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=socket02 stime=1411895773
cmdline="socket02"
contacts=""
analysis=exit
<<<test_output>>>
socket02    1  TPASS  :  socket(SOCK_CLOEXEC) PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=socket03 stime=1411895773
cmdline="socket03"
contacts=""
analysis=exit
<<<test_output>>>
socket03    1  TPASS  :  socket(SOCK_NONBLOCK) PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=socketcall01 stime=1411895773
cmdline="socketcall01"
contacts=""
analysis=exit
<<<test_output>>>
socketcall01    1  TPASS  :  socket call test on this architecture disabled.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=socketcall02 stime=1411895773
cmdline="socketcall02"
contacts=""
analysis=exit
<<<test_output>>>
socketcall02    1  TPASS  :  socket call test on this architecture disabled.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=socketcall03 stime=1411895773
cmdline="socketcall03"
contacts=""
analysis=exit
<<<test_output>>>
socketcall03    1  TPASS  :  socket call test on this architecture disabled.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=socketcall04 stime=1411895773
cmdline="socketcall04"
contacts=""
analysis=exit
<<<test_output>>>
socketcall04    1  TPASS  :  socket call test on this architecture disabled.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=socketpair01 stime=1411895773
cmdline="socketpair01"
contacts=""
analysis=exit
<<<test_output>>>
socketpair01    1  TPASS  :  invalid domain successful
socketpair01    2  TPASS  :  invalid type successful
socketpair01    3  TPASS  :  UNIX domain dgram successful
socketpair01    4  TPASS  :  raw open as non-root successful
socketpair01    5  TPASS  :  bad aligned pointer successful
socketpair01    6  TPASS  :  bad unaligned pointer successful
socketpair01    7  TPASS  :  UDP socket successful
socketpair01    8  TPASS  :  TCP dgram successful
socketpair01    9  TPASS  :  TCP socket successful
socketpair01   10  TPASS  :  ICMP stream successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=socketpair02 stime=1411895773
cmdline="socketpair02"
contacts=""
analysis=exit
<<<test_output>>>
socketpair02    1  TPASS  :  socketpair(SOCK_NONBLOCK) PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sockioctl01 stime=1411895773
cmdline="sockioctl01"
contacts=""
analysis=exit
<<<test_output>>>
sockioctl01    1  TPASS  :  bad file descriptor successful
sockioctl01    2  TPASS  :  not a socket successful
sockioctl01    3  TPASS  :  invalid option buffer successful
sockioctl01    4  TPASS  :  ATMARK on UDP successful
sockioctl01    5  TPASS  :  SIOCGIFCONF successful
sockioctl01    6  TPASS  :  SIOCGIFFLAGS successful
sockioctl01    7  TPASS  :  SIOCGIFFLAGS with invalid ifr successful
sockioctl01    8  TPASS  :  SIOCSIFFLAGS with invalid ifr successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=splice01 stime=1411895773
cmdline="splice01"
contacts=""
analysis=exit
<<<test_output>>>
splice01    1  TPASS  :  Written data has been read back correctly
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=splice02 stime=1411895773
cmdline="seq 1 10000000 | splice02 splice02-temp"
contacts=""
analysis=exit
<<<test_output>>>
splice02    1  TPASS  :  splice() system call Passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=splice03 stime=1411895773
cmdline="splice03"
contacts=""
analysis=exit
<<<test_output>>>
splice03    1  TPASS  :  splice() failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
splice03    2  TPASS  :  splice() failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
splice03    3  TPASS  :  splice() failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
splice03    4  TPASS  :  splice() failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
splice03    5  TPASS  :  splice() failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
splice03    6  TPASS  :  splice() failed as expected: TEST_ERRNO=ESPIPE(29): Illegal seek
splice03    7  TPASS  :  splice() failed as expected: TEST_ERRNO=ESPIPE(29): Illegal seek
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=tee01 stime=1411895773
cmdline="tee01"
contacts=""
analysis=exit
<<<test_output>>>
tee01       1  TPASS  :  Written data has been read back correctly
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=tee02 stime=1411895773
cmdline="tee02"
contacts=""
analysis=exit
<<<test_output>>>
tee02       1  TPASS  :  tee() failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
tee02       2  TPASS  :  tee() failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
tee02       3  TPASS  :  tee() failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=ssetmask01 stime=1411895773
cmdline="ssetmask01"
contacts=""
analysis=exit
<<<test_output>>>
ssetmask01    1  TCONF  :  ssetmask01.c:121: syscall __NR_ssetmask not supported on your arch
ssetmask01    2  TCONF  :  ssetmask01.c:121: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=stat01 stime=1411895773
cmdline="stat01"
contacts=""
analysis=exit
<<<test_output>>>
stat01      1  TPASS  :  Functionality of stat(2) on 'testfile' Succcessful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=stat01_64 stime=1411895773
cmdline="stat01_64"
contacts=""
analysis=exit
<<<test_output>>>
stat01      1  TPASS  :  Functionality of stat(2) on 'testfile' Succcessful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=stat02 stime=1411895773
cmdline="stat02"
contacts=""
analysis=exit
<<<test_output>>>
stat02      1  TPASS  :  Functionality of stat(2) on 'testfile' Succcessful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=stat02_64 stime=1411895773
cmdline="stat02_64"
contacts=""
analysis=exit
<<<test_output>>>
stat02      1  TPASS  :  Functionality of stat(2) on 'testfile' Succcessful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=stat03 stime=1411895773
cmdline="stat03"
contacts=""
analysis=exit
<<<test_output>>>
stat03      1  TPASS  :  stat() fails, No Search permissions to process, errno:13
stat03      2  TPASS  :  stat() fails, Address beyond address space, errno:14
stat03      3  TPASS  :  stat() fails, Negative address, errno:14
stat03      4  TPASS  :  stat() fails, Pathname too long, errno:36
stat03      5  TPASS  :  stat() fails, Pathname is empty, errno:2
stat03      6  TPASS  :  stat() fails, Path contains regular file, errno:20
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=stat03_64 stime=1411895773
cmdline="stat03_64"
contacts=""
analysis=exit
<<<test_output>>>
stat03      1  TPASS  :  stat() fails, No Search permissions to process, errno:13
stat03      2  TPASS  :  stat() fails, Address beyond address space, errno:14
stat03      3  TPASS  :  stat() fails, Negative address, errno:14
stat03      4  TPASS  :  stat() fails, Pathname too long, errno:36
stat03      5  TPASS  :  stat() fails, Pathname is empty, errno:2
stat03      6  TPASS  :  stat() fails, Path contains regular file, errno:20
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=stat04 stime=1411895773
cmdline="symlink01 -T stat04"
contacts=""
analysis=exit
<<<test_output>>>
stat04      1  TPASS  :  Getting stat info about object file through symbolic link file is ok
stat04      2  TPASS  :  Stat(2) error when accessing non-existent object through symbolic link is caught
stat04      3  TPASS  :  Nested symbolic link access condition caught.  ELOOP is returned
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=stat04_64 stime=1411895773
cmdline="symlink01 -T stat04_64"
contacts=""
analysis=exit
<<<test_output>>>
stat04_64    1  TPASS  :  Getting stat info about object file through symbolic link file is ok
stat04_64    2  TPASS  :  Stat(2) error when accessing non-existent object through symbolic link is caught
stat04_64    3  TPASS  :  Nested symbolic link access condition caught.  ELOOP is returned
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=stat05 stime=1411895773
cmdline="stat05"
contacts=""
analysis=exit
<<<test_output>>>
stat05      1  TPASS  :  stat(tfile_29941, &statter) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=stat05_64 stime=1411895773
cmdline="stat05_64"
contacts=""
analysis=exit
<<<test_output>>>
stat05      1  TPASS  :  stat(tfile_29942, &statter) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=stat06 stime=1411895773
cmdline="stat06"
contacts=""
analysis=exit
<<<test_output>>>
stat06      1  TPASS  :  stat(<non-existent file>, &stbuf) Failed, errno=2
stat06      2  TPASS  :  stat(<path is empty string>, &stbuf) Failed, errno=2
stat06      3  TPASS  :  stat(<path contains a non-existent file>, &stbuf) Failed, errno=2
stat06      4  TPASS  :  stat(<path contains a regular file>, &stbuf) Failed, errno=20
stat06      5  TPASS  :  stat(<pathname too long>, &stbuf) Failed, errno=36
stat06      6  TPASS  :  stat(<address beyond address space>, &stbuf) Failed, errno=14
stat06      7  TPASS  :  stat(<negative address>, &stbuf) Failed, errno=14
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=stat06_64 stime=1411895773
cmdline="stat06_64"
contacts=""
analysis=exit
<<<test_output>>>
stat06      1  TPASS  :  stat(<non-existent file>, &stbuf) Failed, errno=2
stat06      2  TPASS  :  stat(<path is empty string>, &stbuf) Failed, errno=2
stat06      3  TPASS  :  stat(<path contains a non-existent file>, &stbuf) Failed, errno=2
stat06      4  TPASS  :  stat(<path contains a regular file>, &stbuf) Failed, errno=20
stat06      5  TPASS  :  stat(<pathname too long>, &stbuf) Failed, errno=36
stat06      6  TPASS  :  stat(<address beyond address space>, &stbuf) Failed, errno=14
stat06      7  TPASS  :  stat(<negative address>, &stbuf) Failed, errno=14
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=statfs01 stime=1411895773
cmdline="statfs01"
contacts=""
analysis=exit
<<<test_output>>>
statfs01    1  TPASS  :  statfs(tfile_29945, ..) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=statfs01_64 stime=1411895773
cmdline="statfs01_64"
contacts=""
analysis=exit
<<<test_output>>>
statfs01    1  TPASS  :  statfs(tfile_29946, ..) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=statfs02 stime=1411895773
cmdline="statfs02"
contacts=""
analysis=exit
<<<test_output>>>
statfs02    1  TPASS  :  expected failure: TEST_ERRNO=ENOTDIR(20): Not a directory
statfs02    2  TPASS  :  expected failure: TEST_ERRNO=ENOENT(2): No such file or directory
statfs02    3  TPASS  :  expected failure: TEST_ERRNO=ENAMETOOLONG(36): File name too long
statfs02    4  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
statfs02    5  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
statfs02    6  TPASS  :  expected failure: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=statfs02_64 stime=1411895773
cmdline="statfs02_64"
contacts=""
analysis=exit
<<<test_output>>>
statfs02    1  TPASS  :  expected failure: TEST_ERRNO=ENOTDIR(20): Not a directory
statfs02    2  TPASS  :  expected failure: TEST_ERRNO=ENOENT(2): No such file or directory
statfs02    3  TPASS  :  expected failure: TEST_ERRNO=ENAMETOOLONG(36): File name too long
statfs02    4  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
statfs02    5  TPASS  :  expected failure: TEST_ERRNO=EFAULT(14): Bad address
statfs02    6  TPASS  :  expected failure: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=statfs03 stime=1411895773
cmdline="statfs03"
contacts=""
analysis=exit
<<<test_output>>>
statfs03    1  TPASS  :  expected failure - errno = 13 : Permission denied
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=statfs03_64 stime=1411895773
cmdline="statfs03_64"
contacts=""
analysis=exit
<<<test_output>>>
statfs03    1  TPASS  :  expected failure - errno = 13 : Permission denied
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=statvfs01 stime=1411895773
cmdline="statvfs01"
contacts=""
analysis=exit
<<<test_output>>>
statvfs01    1  TPASS  :  statvfs(/, ...) passed
statvfs01    0  TINFO  :  This call is similar to statfs
statvfs01    0  TINFO  :  Extracting info about the '/' file system
statvfs01    0  TINFO  :  file system block size = 4096 bytes
statvfs01    0  TINFO  :  file system fragment size = 4096 bytes
statvfs01    0  TINFO  :  file system free blocks = 0
statvfs01    0  TINFO  :  file system total inodes = 0
statvfs01    0  TINFO  :  file system free inodes = 0
statvfs01    0  TINFO  :  file system id = 0
statvfs01    0  TINFO  :  file system max filename length = 255
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=statvfs02 stime=1411895773
cmdline="statvfs02"
contacts=""
analysis=exit
<<<test_output>>>
statvfs02    1  TPASS  :  statvfs() failed as expected: TEST_ERRNO=EFAULT(14): Bad address
statvfs02    2  TPASS  :  statvfs() failed as expected: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
statvfs02    3  TPASS  :  statvfs() failed as expected: TEST_ERRNO=ENAMETOOLONG(36): File name too long
statvfs02    4  TPASS  :  statvfs() failed as expected: TEST_ERRNO=ENOENT(2): No such file or directory
statvfs02    5  TPASS  :  statvfs() failed as expected: TEST_ERRNO=ENOTDIR(20): Not a directory
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=stime01 stime=1411895773
cmdline="stime01"
contacts=""
analysis=exit
<<<test_output>>>
stime01     0  TINFO  :  pt.tv_sec: 1411895803
stime01     1  TPASS  :  system time was set to 1411895803
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=stime02 stime=1411895773
cmdline="stime02"
contacts=""
analysis=exit
<<<test_output>>>
stime02     1  TPASS  :  stime(2) fails, Caller not root, errno:1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=string01 stime=1411895773
cmdline="string01"
contacts=""
analysis=exit
<<<test_output>>>
string01    1  TPASS  :  Test passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=swapoff01 stime=1411895773
cmdline="swapoff01"
contacts=""
analysis=exit
<<<test_output>>>
swapoff01    1  TCONF  :  swapoff01.c:98: Cannot do swapoff on a file on TMPFS filesystem
swapoff01    2  TCONF  :  swapoff01.c:98: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=swapoff02 stime=1411895773
cmdline="swapoff02"
contacts=""
analysis=exit
<<<test_output>>>
swapoff02    1  TCONF  :  swapoff02.c:156: Cannot do swapoff on a file on TMPFS filesystem
swapoff02    2  TCONF  :  swapoff02.c:156: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=swapon01 stime=1411895773
cmdline="swapon01"
contacts=""
analysis=exit
<<<test_output>>>
swapon01    1  TCONF  :  swapon01.c:96: Cannot do swapon on a file on TMPFS filesystem
swapon01    2  TCONF  :  swapon01.c:96: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=swapon02 stime=1411895773
cmdline="swapon02"
contacts=""
analysis=exit
<<<test_output>>>
swapon02    1  TCONF  :  swapon02.c:148: Cannot do swapon on a file on TMPFS filesystem
swapon02    2  TCONF  :  swapon02.c:148: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=swapon03 stime=1411895773
cmdline="swapon03"
contacts=""
analysis=exit
<<<test_output>>>
swapon03    1  TCONF  :  swapon03.c:348: Cannot do swapon on a file on TMPFS filesystem
swapon03    2  TCONF  :  swapon03.c:348: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=switch01 stime=1411895773
cmdline="endian_switch01"
contacts=""
analysis=exit
<<<test_output>>>
endian_switch01    1  TCONF  :  endian_switch01.c:147: This system does not support running of switch() syscall
endian_switch01    2  TCONF  :  endian_switch01.c:147: Remaining cases not appropriate for configuration
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=symlink01 stime=1411895773
cmdline="symlink01"
contacts=""
analysis=exit
<<<test_output>>>
symlink01    1  TPASS  :  Creation of symbolic link file to no object file is ok
symlink01    2  TPASS  :  Creation of symbolic link file to no object file is ok
symlink01    3  TPASS  :  Creation of symbolic link file and object file via symbolic link is ok
symlink01    4  TPASS  :  Creating an existing symbolic link file error is caught
symlink01    5  TPASS  :  Creating a symbolic link which exceeds maximum pathname error is caught
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=symlink02 stime=1411895773
cmdline="symlink02"
contacts=""
analysis=exit
<<<test_output>>>
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=symlink03 stime=1411895773
cmdline="symlink03"
contacts=""
analysis=exit
<<<test_output>>>
symlink03    1  TPASS  :  symlink() Fails, No Search permissions to process, errno=13
symlink03    2  TPASS  :  symlink() Fails, Specified symlink already exists, errno=17
symlink03    3  TPASS  :  symlink() Fails, Address beyond address space, errno=14
symlink03    4  TPASS  :  symlink() Fails, Negative address, errno=14
symlink03    5  TPASS  :  symlink() Fails, Symlink path too long, errno=36
symlink03    6  TPASS  :  symlink() Fails, Symlink Pathname is empty, errno=2
symlink03    7  TPASS  :  symlink() Fails, Symlink Path contains regular file, errno=20
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=symlink04 stime=1411895773
cmdline="symlink04"
contacts=""
analysis=exit
<<<test_output>>>
symlink04    1  TPASS  :  symlink(testfile, slink_file) functionality successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=symlink05 stime=1411895773
cmdline="symlink05"
contacts=""
analysis=exit
<<<test_output>>>
symlink05    1  TPASS  :  symlink(testfile, slink_file) functionality successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=symlinkat01 stime=1411895773
cmdline="symlinkat01"
contacts=""
analysis=exit
<<<test_output>>>
symlinkat01    1  TPASS  :  Test passed
symlinkat01    2  TPASS  :  Test passed
symlinkat01    3  TPASS  :  Test passed
symlinkat01    4  TPASS  :  Test passed
symlinkat01    5  TPASS  :  symlinkat() returned the expected  errno 20: Not a directory
symlinkat01    6  TPASS  :  Test passed
symlinkat01    7  TPASS  :  symlinkat() returned the expected  errno 9: Bad file descriptor
symlinkat01    8  TPASS  :  Test passed
symlinkat01    9  TPASS  :  symlinkat() returned the expected  errno 2: No such file or directory
symlinkat01   10  TPASS  :  Test passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sync01 stime=1411895773
cmdline="sync01"
contacts=""
analysis=exit
<<<test_output>>>
sync01      1  TPASS  :  sync() returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=sync02 stime=1411895773
cmdline="sync02"
contacts=""
analysis=exit
<<<test_output>>>
sync02      1  TPASS  :  Functionality of sync() successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sync_file_range01 stime=1411895773
cmdline="sync_file_range01"
contacts=""
analysis=exit
<<<test_output>>>
sync_file_range01    1  TPASS  :  got expected error: TEST_ERRNO=EBADF(9): Bad file descriptor
sync_file_range01    2  TPASS  :  got expected error: TEST_ERRNO=ESPIPE(29): Illegal seek
sync_file_range01    3  TPASS  :  got expected error: TEST_ERRNO=EINVAL(22): Invalid argument
sync_file_range01    4  TPASS  :  got expected error: TEST_ERRNO=EINVAL(22): Invalid argument
sync_file_range01    5  TPASS  :  got expected error: TEST_ERRNO=EINVAL(22): Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=syscall01 stime=1411895773
cmdline="syscall01"
contacts=""
analysis=exit
<<<test_output>>>
syscall01    1  TPASS  :  Test passed
syscall01    2  TPASS  :  Test passed
syscall01    3  TPASS  :  Test passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sysconf01 stime=1411895773
cmdline="sysconf01"
contacts=""
analysis=exit
<<<test_output>>>
sysconf01    1  TPASS  :  _SC_CLK_TCK = 100
sysconf01    2  TPASS  :  _SC_ARG_MAX = 2097152
sysconf01    3  TPASS  :  _SC_CHILD_MAX = 23124
sysconf01    4  TPASS  :  _SC_OPEN_MAX = 1024
sysconf01    5  TPASS  :  _SC_JOB_CONTROL = 1
sysconf01    6  TPASS  :  _SC_SAVED_IDS = 1
sysconf01    7  TPASS  :  _SC_VERSION = 200809
sysconf01    8  TPASS  :  _SC_PASS_MAX = 8192
sysconf01    9  TPASS  :  _SC_LOGIN_NAME_MAX = 256
sysconf01   10  TPASS  :  _SC_XOPEN_VERSION = 700
sysconf01   11  TPASS  :  _SC_TZNAME_MAX = 6
sysconf01   12  TPASS  :  _SC_STREAM_MAX = 16
sysconf01   13  TPASS  :  _SC_XOPEN_CRYPT = 1
sysconf01   14  TPASS  :  _SC_XOPEN_ENH_I18N = 1
sysconf01   15  TPASS  :  _SC_XOPEN_SHM = 1
sysconf01   16  TPASS  :  _SC_XOPEN_XCU_VERSION = 4
sysconf01   17  TPASS  :  _SC_ATEXIT_MAX = 2147483647
sysconf01   18  TPASS  :  _SC_2_C_BIND = 200809
sysconf01   19  TPASS  :  _SC_2_C_DEV = 200809
sysconf01   20  TCONF  :  sysconf01.c:67: Not supported sysconf resource: _SC_2_C_VERSION
sysconf01   21  TPASS  :  _SC_2_CHAR_TERM = 200809
sysconf01   22  TCONF  :  sysconf01.c:67: Not supported sysconf resource: _SC_2_FORT_DEV
sysconf01   23  TCONF  :  sysconf01.c:67: Not supported sysconf resource: _SC_2_FORT_RUN
sysconf01   24  TPASS  :  _SC_2_LOCALEDEF = 200809
sysconf01   25  TPASS  :  _SC_2_SW_DEV = 200809
sysconf01   26  TCONF  :  sysconf01.c:67: Not supported sysconf resource: _SC_2_UPE
sysconf01   27  TPASS  :  _SC_2_VERSION = 200809
sysconf01   28  TPASS  :  _SC_BC_BASE_MAX = 99
sysconf01   29  TPASS  :  _SC_BC_DIM_MAX = 2048
sysconf01   30  TPASS  :  _SC_BC_SCALE_MAX = 99
sysconf01   31  TPASS  :  _SC_BC_STRING_MAX = 1000
sysconf01   32  TPASS  :  _SC_COLL_WEIGHTS_MAX = 255
sysconf01   33  TPASS  :  _SC_EXPR_NEST_MAX = 32
sysconf01   34  TPASS  :  _SC_LINE_MAX = 2048
sysconf01   35  TPASS  :  _SC_RE_DUP_MAX = 32767
sysconf01   36  TPASS  :  _SC_XOPEN_UNIX = 1
sysconf01   37  TPASS  :  _SC_PAGESIZE = 4096
sysconf01   38  TPASS  :  _SC_PHYS_PAGES = 1525126
sysconf01   39  TPASS  :  _SC_AVPHYS_PAGES = 1340163
sysconf01   40  TCONF  :  sysconf01.c:67: Not supported sysconf resource: _SC_AIO_MAX
sysconf01   41  TPASS  :  _SC_AIO_PRIO_DELTA_MAX = 20
sysconf01   42  TPASS  :  _SC_SEMAPHORES = 200809
sysconf01   43  TCONF  :  sysconf01.c:67: Not supported sysconf resource: _SC_SEM_NSEMS_MAX
sysconf01   44  TPASS  :  _SC_SEM_VALUE_MAX = 2147483647
sysconf01   45  TPASS  :  _SC_MEMORY_PROTECTION = 200809
sysconf01   46  TPASS  :  _SC_FSYNC = 200809
sysconf01   47  TPASS  :  _SC_MEMORY_PROTECTION = 200809
sysconf01   48  TPASS  :  _SC_TIMERS = 200809
sysconf01   49  TCONF  :  sysconf01.c:67: Not supported sysconf resource: _SC_TIMER_MAX
sysconf01   50  TPASS  :  _SC_MAPPED_FILES = 200809
sysconf01   51  TPASS  :  _SC_THREAD_PRIORITY_SCHEDULING = 200809
sysconf01   52  TPASS  :  _SC_XOPEN_LEGACY = 1
sysconf01   53  TPASS  :  _SC_MEMLOCK = 200809
sysconf01   54  TCONF  :  sysconf01.c:67: Not supported sysconf resource: _SC_XBS5_ILP32_OFF32
sysconf01   55  TCONF  :  sysconf01.c:67: Not supported sysconf resource: _SC_XBS5_ILP32_OFFBIG
sysconf01   56  TPASS  :  The invalid sysconf key was trapped appropriately
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sysctl01 stime=1411895773
cmdline="sysctl01"
contacts=""
analysis=exit
<<<test_output>>>
sysctl01    1  TCONF  :  sysctl01.c:203: This test needs a kernel that has sysctl syscall.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sysctl03 stime=1411895773
cmdline="sysctl03"
contacts=""
analysis=exit
<<<test_output>>>
sysctl03    1  TCONF  :  sysctl03.c:227: This test needs a kernel that has sysctl syscall.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sysctl04 stime=1411895773
cmdline="sysctl04"
contacts=""
analysis=exit
<<<test_output>>>
sysctl04    1  TCONF  :  sysctl04.c:180: This test needs a kernel that has sysctl syscall.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sysctl05 stime=1411895773
cmdline="sysctl05"
contacts=""
analysis=exit
<<<test_output>>>
sysctl05    1  TCONF  :  sysctl05.c:207: This test needs a kernel that has sysctl syscall.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=32 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sysfs01 stime=1411895773
cmdline="sysfs01"
contacts=""
analysis=exit
<<<test_output>>>
sysfs01     1  TPASS  :  sysfs(2) Passed for option 1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sysfs02 stime=1411895773
cmdline="sysfs02"
contacts=""
analysis=exit
<<<test_output>>>
sysfs02     1  TPASS  :  sysfs(2) Passed for option 2
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sysfs03 stime=1411895773
cmdline="sysfs03"
contacts=""
analysis=exit
<<<test_output>>>
sysfs03     1  TPASS  :  sysfs(2) Passed for option 3
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sysfs04 stime=1411895773
cmdline="sysfs04"
contacts=""
analysis=exit
<<<test_output>>>
sysfs04     1  TPASS  :  sysfs(2) expected failure; Got errno - EINVAL : Invalid option
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sysfs05 stime=1411895773
cmdline="sysfs05"
contacts=""
analysis=exit
<<<test_output>>>
sysfs05     1  TPASS  :  sysfs(2) expected failure; Got errno - EINVAL : Invalid option
sysfs05     1  TPASS  :  sysfs(2) expected failure; Got errno - EINVAL  : Invalid filesystem name
sysfs05     1  TPASS  :  sysfs(2) expected failure; Got errno - EFAULT  : Address is out of your address space
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sysfs06 stime=1411895773
cmdline="sysfs06"
contacts=""
analysis=exit
<<<test_output>>>
sysfs06     1  TPASS  :  sysfs(2) expected failure; Got errno - EINVAL : Invalid option
sysfs06     1  TPASS  :  sysfs(2) expected failure; Got errno - EINVAL : fs_index is out of bounds
sysfs06     1  TPASS  :  sysfs(2) expected failure; Got errno - EFAULT : buf is outside your accessible address space
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sysinfo01 stime=1411895773
cmdline="sysinfo01"
contacts=""
analysis=exit
<<<test_output>>>
sysinfo01    1  TPASS  :  Test to check the return code PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=sysinfo02 stime=1411895773
cmdline="sysinfo02"
contacts=""
analysis=exit
<<<test_output>>>
sysinfo02    1  TPASS  :  Test to check the error code 14 PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=syslog11 stime=1411895773
cmdline="syslog11"
contacts=""
analysis=exit
<<<test_output>>>
syslog11    1  TPASS  :  syslog() successful for type 0/Close the log
syslog11    2  TPASS  :  syslog() successful for type 1/Open the log
syslog11    3  TPASS  :  syslog() successful for type 2/Read from the log
syslog11    4  TPASS  :  syslog() successful for type 3/Read ring buffer
syslog11    5  TPASS  :  syslog() successful for type 3/Read ring buffer for non-root user
syslog11    6  TPASS  :  syslog() successful for type 8/Set log level to 1
syslog11    7  TPASS  :  syslog() successful for type 8/Set log level to 7(default)
syslog11    8  TPASS  :  syslog() successful for type 6/Disable printk's to console
syslog11    9  TPASS  :  syslog() successful for type 7/Enable printk's to console
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=syslog12 stime=1411895773
cmdline="syslog12"
contacts=""
analysis=exit
<<<test_output>>>
syslog12    1  TPASS  :  syslog() failed as expected for invalid type/command : errno 22
syslog12    2  TPASS  :  syslog() failed as expected for NULL buffer argument : errno 22
syslog12    3  TPASS  :  syslog() failed as expected for negative length argument : errno 22
syslog12    4  TPASS  :  syslog() failed as expected for non-root user : errno 1
syslog12    5  TPASS  :  syslog() failed as expected for console level less than 0 : errno 22
syslog12    6  TPASS  :  syslog() failed as expected for console level greater than 8 : errno 22
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=time01 stime=1411895773
cmdline="time01"
contacts=""
analysis=exit
<<<test_output>>>
time01      1  TPASS  :  time(0) returned 1411895773
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=time02 stime=1411895773
cmdline="time02"
contacts=""
analysis=exit
<<<test_output>>>
time02      1  TPASS  :  time() returned value 1411895773, stored value 1411895773 are same
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=times01 stime=1411895773
cmdline="times01"
contacts=""
analysis=exit
<<<test_output>>>
times01     1  TPASS  :  times(&mytimes) returned 429512816
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=times03 stime=1411895773
cmdline="times03"
contacts=""
analysis=exit
<<<test_output>>>
<<<execution_status>>>
initiation_status="ok"
duration=23 termination_type=exited termination_id=0 corefile=no
cutime=760 cstime=1498
<<<test_end>>>
<<<test_start>>>
tag=timerfd01 stime=1411895796
cmdline="timerfd01"
contacts=""
analysis=exit
<<<test_output>>>


---------------------------------------
| testing CLOCK MONOTONIC
---------------------------------------

relative timer test (at 500 ms) ...
timerfd = 7
wating timer ...
got timer ticks (1) after 500 ms
absolute timer test (at 500 ms) ...
wating timer ...
got timer ticks (1) after 500 ms
sequential timer test (100 ms clock) ...
sleeping 1 second ...
timerfd_gettime returned:
	it_value = { 0, 99831931 } it_interval = { 0, 100000000 }
sleeping 1 second ...
wating timer ...
got timer ticks (20) after 2000 ms
O_NONBLOCK test ...
timerfd = 7
wating timer (flush the single tick) ...
got timer ticks (1) after 100 ms
success


---------------------------------------
| testing CLOCK REALTIME
---------------------------------------

relative timer test (at 500 ms) ...
timerfd = 7
wating timer ...
got timer ticks (1) after 500 ms
absolute timer test (at 500 ms) ...
wating timer ...
got timer ticks (1) after 500 ms
sequential timer test (100 ms clock) ...
sleeping 1 second ...
timerfd_gettime returned:
	it_value = { 0, 99834705 } it_interval = { 0, 100000000 }
sleeping 1 second ...
wating timer ...
got timer ticks (20) after 2000 ms
O_NONBLOCK test ...
timerfd = 7
wating timer (flush the single tick) ...
got timer ticks (1) after 100 ms
success
<<<execution_status>>>
initiation_status="ok"
duration=6 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=timerfd02 stime=1411895802
cmdline="timerfd02"
contacts=""
analysis=exit
<<<test_output>>>
timerfd02    1  TPASS  :  timerfd_create(TFD_CLOEXEC) Passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=timerfd03 stime=1411895802
cmdline="timerfd03"
contacts=""
analysis=exit
<<<test_output>>>
timerfd03    1  TPASS  :  timerfd_create(TFD_NONBLOCK) PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=timerfd_create01 stime=1411895802
cmdline="timerfd_create01"
contacts=""
analysis=exit
<<<test_output>>>
timerfd_create01    1  TPASS  :  timerfd_create() failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
timerfd_create01    2  TPASS  :  timerfd_create() failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=timerfd_gettime01 stime=1411895802
cmdline="timerfd_gettime01"
contacts=""
analysis=exit
<<<test_output>>>
timerfd_gettime01    1  TPASS  :  timerfd_gettime() failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
timerfd_gettime01    2  TPASS  :  timerfd_gettime() failed as expected: TEST_ERRNO=EFAULT(14): Bad address
timerfd_gettime01    3  TPASS  :  timerfd_gettime() failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=timerfd_settime01 stime=1411895802
cmdline="timerfd_settime01"
contacts=""
analysis=exit
<<<test_output>>>
timerfd_settime01    1  TPASS  :  timerfd_settime() failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
timerfd_settime01    2  TPASS  :  timerfd_settime() failed as expected: TEST_ERRNO=EFAULT(14): Bad address
timerfd_settime01    3  TPASS  :  timerfd_settime() failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
timerfd_settime01    4  TPASS  :  timerfd_settime() failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=timer_getoverrun01 stime=1411895802
cmdline="timer_getoverrun01"
contacts=""
analysis=exit
<<<test_output>>>
timer_getoverrun01    1  TPASS  :  timer_getoverrun(CLOCK_REALTIME) Passed
timer_getoverrun01    2  TPASS  :  timer_gettime(-1) Failed: EINVAL
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=timer_gettime01 stime=1411895802
cmdline="timer_gettime01"
contacts=""
analysis=exit
<<<test_output>>>
timer_gettime01    1  TPASS  :  timer_gettime(CLOCK_REALTIME) Passed
timer_gettime01    2  TPASS  :  timer_gettime(-1) Failed: EINVAL
timer_gettime01    3  TPASS  :  timer_gettime(NULL) Failed: EFAULT
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=tkill01 stime=1411895802
cmdline="tkill01"
contacts=""
analysis=exit
<<<test_output>>>
tkill01     1  TPASS  :  tkill call succeeded
tkill01     2  TPASS  :  tkill call succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=tkill02 stime=1411895802
cmdline="tkill02"
contacts=""
analysis=exit
<<<test_output>>>
tkill02     1  TPASS  :  tkill(-1, SIGUSR1) failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
tkill02     2  TPASS  :  tkill(32768, SIGUSR1) failed as expected: TEST_ERRNO=ESRCH(3): No such process
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=truncate01 stime=1411895802
cmdline="truncate01"
contacts=""
analysis=exit
<<<test_output>>>
truncate01    1  TPASS  :  Functionality of truncate(testfile, 256) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=truncate01_64 stime=1411895802
cmdline="truncate01_64"
contacts=""
analysis=exit
<<<test_output>>>
truncate01_64    1  TPASS  :  Functionality of truncate(testfile, 256) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=truncate02 stime=1411895802
cmdline="truncate02"
contacts=""
analysis=exit
<<<test_output>>>
truncate02    1  TPASS  :  Functionality of truncate(2) on testfile successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=truncate02_64 stime=1411895802
cmdline="truncate02_64"
contacts=""
analysis=exit
<<<test_output>>>
truncate02_64    1  TPASS  :  Functionality of truncate(2) on testfile successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=truncate03 stime=1411895802
cmdline="truncate03"
contacts=""
analysis=exit
<<<test_output>>>
truncate03    1  TPASS  :  truncate() failed as expected: TEST_ERRNO=EACCES(13): Permission denied
truncate03    2  TPASS  :  truncate() failed as expected: TEST_ERRNO=ENOTDIR(20): Not a directory
truncate03    3  TPASS  :  truncate() failed as expected: TEST_ERRNO=EFAULT(14): Bad address
truncate03    4  TPASS  :  truncate() failed as expected: TEST_ERRNO=EFAULT(14): Bad address
truncate03    5  TPASS  :  truncate() failed as expected: TEST_ERRNO=ENAMETOOLONG(36): File name too long
truncate03    6  TPASS  :  truncate() failed as expected: TEST_ERRNO=ENOENT(2): No such file or directory
truncate03    7  TPASS  :  truncate() failed as expected: TEST_ERRNO=EISDIR(21): Is a directory
truncate03    8  TPASS  :  truncate() failed as expected: TEST_ERRNO=EFBIG(27): File too large
truncate03    9  TPASS  :  truncate() failed as expected: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=truncate03_64 stime=1411895802
cmdline="truncate03_64"
contacts=""
analysis=exit
<<<test_output>>>
truncate03    1  TPASS  :  truncate() failed as expected: TEST_ERRNO=EACCES(13): Permission denied
truncate03    2  TPASS  :  truncate() failed as expected: TEST_ERRNO=ENOTDIR(20): Not a directory
truncate03    3  TPASS  :  truncate() failed as expected: TEST_ERRNO=EFAULT(14): Bad address
truncate03    4  TPASS  :  truncate() failed as expected: TEST_ERRNO=EFAULT(14): Bad address
truncate03    5  TPASS  :  truncate() failed as expected: TEST_ERRNO=ENAMETOOLONG(36): File name too long
truncate03    6  TPASS  :  truncate() failed as expected: TEST_ERRNO=ENOENT(2): No such file or directory
truncate03    7  TPASS  :  truncate() failed as expected: TEST_ERRNO=EISDIR(21): Is a directory
truncate03    8  TPASS  :  truncate() failed as expected: TEST_ERRNO=EFBIG(27): File too large
truncate03    9  TPASS  :  truncate() failed as expected: TEST_ERRNO=ELOOP(40): Too many levels of symbolic links
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=ulimit01 stime=1411895802
cmdline="ulimit01"
contacts=""
analysis=exit
<<<test_output>>>
ulimit01    1  TPASS  :  ulimit(1, -1) returned 9223372036854775807
ulimit01    2  TPASS  :  ulimit(2, 9223372036854775807) returned 9223372036854775807
ulimit01    3  TPASS  :  ulimit(2, 9223372036854775806) returned 9223372036854775807
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=umask01 stime=1411895802
cmdline="umask01"
contacts=""
analysis=exit
<<<test_output>>>
umask01     1  TPASS  :  umask(022) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=umask02 stime=1411895802
cmdline="umask02"
contacts=""
analysis=exit
<<<test_output>>>
umask02     1  TPASS  :  All umask values return correct values
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=umask03 stime=1411895802
cmdline="umask03"
contacts=""
analysis=exit
<<<test_output>>>
umask03     1  TPASS  :  umask correctly returns the previous value for all masks
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=uname01 stime=1411895802
cmdline="uname01"
contacts=""
analysis=exit
<<<test_output>>>
uname01     1  TPASS  :  uname(&un) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=uname02 stime=1411895802
cmdline="uname02"
contacts=""
analysis=exit
<<<test_output>>>
uname02     1  TPASS  :  uname failed as expected: TEST_ERRNO=EFAULT(14): Bad address
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=uname03 stime=1411895802
cmdline="uname03"
contacts=""
analysis=exit
<<<test_output>>>
uname03     1  TPASS  :  uname03 functionality test succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=unlink01 stime=1411895802
cmdline="symlink01 -T unlink01"
contacts=""
analysis=exit
<<<test_output>>>
unlink01    1  TPASS  :  unlink(2) of symbolic link file with no object file removal is ok
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=unlink05 stime=1411895802
cmdline="unlink05"
contacts=""
analysis=exit
<<<test_output>>>
unlink05    1  TPASS  :  unlink(tfile_30019) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=unlink06 stime=1411895802
cmdline="unlink06"
contacts=""
analysis=exit
<<<test_output>>>
unlink06    1  TPASS  :  unlink(fifo_unlink30020) returned 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=unlink07 stime=1411895802
cmdline="unlink07"
contacts=""
analysis=exit
<<<test_output>>>
unlink07    1  TPASS  :  unlink(<non-existent file>) Failed, errno=2
unlink07    2  TPASS  :  unlink(<path is empty string>) Failed, errno=2
unlink07    3  TPASS  :  unlink(<path contains a non-existent file>) Failed, errno=2
unlink07    4  TPASS  :  unlink(<address beyond address space>) Failed, errno=14
unlink07    5  TPASS  :  unlink(<path contains a regular file>) Failed, errno=20
unlink07    6  TPASS  :  unlink(<address beyond address space>) Failed, errno=14
unlink07    7  TPASS  :  unlink(<pathname too long>) Failed, errno=36
unlink07    8  TPASS  :  unlink(<negative address>) Failed, errno=14
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=unlink08 stime=1411895802
cmdline="unlink08"
contacts=""
analysis=exit
<<<test_output>>>
unlink08    1  TPASS  :  unlink(<unwritable directory>) returned 0
unlink08    2  TPASS  :  unlink(<unsearchable directory>) returned 0
unlink08    3  TPASS  :  unlink(<directory>) Failed, errno=21
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=unlinkat01 stime=1411895802
cmdline="unlinkat01"
contacts=""
analysis=exit
<<<test_output>>>
unlinkat01    1  TPASS  :  unlinkat() returned the expected  errno 0: Success
unlinkat01    2  TPASS  :  unlinkat() returned the expected  errno 0: Success
unlinkat01    3  TPASS  :  unlinkat() returned the expected  errno 20: Not a directory
unlinkat01    4  TPASS  :  unlinkat() returned the expected  errno 9: Bad file descriptor
unlinkat01    5  TPASS  :  unlinkat() returned the expected  errno 22: Invalid argument
unlinkat01    6  TPASS  :  unlinkat() returned the expected  errno 0: Success
unlinkat01    7  TPASS  :  unlinkat() returned the expected  errno 0: Success
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=unshare01 stime=1411895802
cmdline="unshare01"
contacts=""
analysis=exit
<<<test_output>>>
unshare with CLONE_FILES call succeeded
unshare with CLONE_FS call succeeded
unshare call with CLONE_NEWNS succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=unshare02 stime=1411895802
cmdline="unshare02"
contacts=""
analysis=exit
<<<test_output>>>
Got EINVAL
unshare02    1  TPASS  :  Call succeeded
Got EINVAL
unshare02    1  TPASS  :  Call succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=umount01 stime=1411895802
cmdline="umount01"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
umount01    0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
umount01    0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
umount01    1  TPASS  :  umount(2) Passed 
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=umount02 stime=1411895802
cmdline="umount02"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
umount02    0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
umount02    0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
umount02    1  TPASS  :  umount(2) expected failure; Got errno - EBUSY : Already mounted/busy
umount02    2  TPASS  :  umount(2) expected failure; Got errno - EFAULT : Invalid address space
umount02    3  TPASS  :  umount(2) expected failure; Got errno - ENOENT : Directory not found
umount02    4  TPASS  :  umount(2) expected failure; Got errno - EINVAL : Invalid  device
umount02    5  TPASS  :  umount(2) expected failure; Got errno - ENAMETOOLONG : Pathname too long
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=umount03 stime=1411895802
cmdline="umount03"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
umount03    0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
umount03    0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
umount03    1  TPASS  :  umount() failed with EPERM: TEST_ERRNO=EPERM(1): Operation not permitted
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=ustat01 stime=1411895802
cmdline="ustat01"
contacts=""
analysis=exit
<<<test_output>>>
ustat01     1  TPASS  :  ustat(2) passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=ustat02 stime=1411895802
cmdline="ustat02"
contacts=""
analysis=exit
<<<test_output>>>
ustat02     1  TPASS  :  ustat(2) expected failure; Got errno - EINVAL : Invalid parameter
ustat02     2  TPASS  :  ustat(2) expected failure; Got errno - EFAULT : Bad address
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utime01 stime=1411895802
cmdline="utime01"
contacts=""
analysis=exit
<<<test_output>>>
utime01     1  TPASS  :  Functionality of utime(tmp_file, NULL) successful
<<<execution_status>>>
initiation_status="ok"
duration=4 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=utime01A stime=1411895806
cmdline="symlink01 -T utime01"
contacts=""
analysis=exit
<<<test_output>>>
utime01     1  TPASS  :  utime(2) change of object file access and modify times through symbolic link file is ok
utime01     2  TPASS  :  utime(2) error when accessing non-existent object through symbolic link is caught
utime01     3  TPASS  :  Nested symbolic link access condition caught.  ELOOP is returned
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utime02 stime=1411895806
cmdline="utime02"
contacts=""
analysis=exit
<<<test_output>>>
utime02     1  TPASS  :  Functionality of utime(tmp_file, NULL) successful
<<<execution_status>>>
initiation_status="ok"
duration=4 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utime03 stime=1411895810
cmdline="utime03"
contacts=""
analysis=exit
<<<test_output>>>
utime03     1  TPASS  :  Functionality of utime(tmp_file, NULL) successful
<<<execution_status>>>
initiation_status="ok"
duration=4 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utime04 stime=1411895814
cmdline="utime04"
contacts=""
analysis=exit
<<<test_output>>>
utime04     1  TPASS  :  Functionality of utime(tmp_file, &times) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utime05 stime=1411895814
cmdline="utime05"
contacts=""
analysis=exit
<<<test_output>>>
utime05     1  TPASS  :  Functionality of utime(tmp_file, &times) successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utime06 stime=1411895814
cmdline="utime06"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
utime06     0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
utime06     0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
utime06     1  TPASS  :  utime failed as expected: TEST_ERRNO=EACCES(13): Permission denied
utime06     2  TPASS  :  utime failed as expected: TEST_ERRNO=ENOENT(2): No such file or directory
utime06     3  TPASS  :  utime failed as expected: TEST_ERRNO=EPERM(1): Operation not permitted
utime06     4  TPASS  :  utime failed as expected: TEST_ERRNO=EROFS(30): Read-only file system
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=utimes01 stime=1411895814
cmdline="utimes01"
contacts=""
analysis=exit
<<<test_output>>>
mke2fs 1.42.8 (20-Jun-2013)
utimes01    0  TINFO  :  Using test device LTP_DEV='/dev/loop0'
utimes01    0  TINFO  :  Formatting /dev/loop0 with ext2 extra opts=''
utimes01    1  TPASS  :  utimes() worked as expected: TEST_ERRNO=SUCCESS(0): Success
utimes01    2  TPASS  :  utimes() worked as expected: TEST_ERRNO=SUCCESS(0): Success
utimes01    3  TPASS  :  utimes() worked as expected: TEST_ERRNO=EACCES(13): Permission denied
utimes01    4  TPASS  :  utimes() worked as expected: TEST_ERRNO=ENOENT(2): No such file or directory
utimes01    5  TPASS  :  utimes() worked as expected: TEST_ERRNO=EFAULT(14): Bad address
utimes01    6  TPASS  :  utimes() worked as expected: TEST_ERRNO=EPERM(1): Operation not permitted
utimes01    7  TPASS  :  utimes() worked as expected: TEST_ERRNO=EROFS(30): Read-only file system
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=vfork01 stime=1411895814
cmdline="vfork01"
contacts=""
analysis=exit
<<<test_output>>>
vfork01     0  TINFO  :  Attribute values of parent and child match
vfork01     0  TINFO  :  Working directories of parent and child match
vfork01     0  TINFO  :  Device/inode number of parent and childs '/' match
vfork01     0  TINFO  :  Device/inode number of parent and childs '.' don't match
vfork01     1  TPASS  :  Call of vfork() successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=vfork02 stime=1411895814
cmdline="vfork02"
contacts=""
analysis=exit
<<<test_output>>>
vfork02     1  TPASS  :  Call to vfork() successful
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=vhangup01 stime=1411895814
cmdline="vhangup01"
contacts=""
analysis=exit
<<<test_output>>>
vhangup01    1  TPASS  :  Got EPERM as expected.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=vhangup02 stime=1411895814
cmdline="vhangup02"
contacts=""
analysis=exit
<<<test_output>>>
vhangup02    1  TPASS  :  vhangup() succeeded
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=vmsplice01 stime=1411895814
cmdline="vmsplice01"
contacts=""
analysis=exit
<<<test_output>>>
vmsplice01    1  TPASS  :  Written data has been read back correctly
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=vmsplice02 stime=1411895814
cmdline="vmsplice02"
contacts=""
analysis=exit
<<<test_output>>>
vmsplice02    1  TPASS  :  vmsplice() failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
vmsplice02    2  TPASS  :  vmsplice() failed as expected: TEST_ERRNO=EBADF(9): Bad file descriptor
vmsplice02    3  TPASS  :  vmsplice() failed as expected: TEST_ERRNO=EINVAL(22): Invalid argument
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=wait01 stime=1411895814
cmdline="wait01"
contacts=""
analysis=exit
<<<test_output>>>
wait01      1  TPASS  :  wait failed as expected: TEST_ERRNO=ECHILD(10): No child processes
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=wait02 stime=1411895814
cmdline="wait02"
contacts=""
analysis=exit
<<<test_output>>>
wait02      1  TPASS  :  wait(&status) returned 30074
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=wait401 stime=1411895815
cmdline="wait401"
contacts=""
analysis=exit
<<<test_output>>>
wait401     1  TPASS  :  Received child pid as expected.
wait401     2  TPASS  :  wait401 call succeeded
<<<execution_status>>>
initiation_status="ok"
duration=1 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=wait402 stime=1411895816
cmdline="wait402"
contacts=""
analysis=exit
<<<test_output>>>
wait402     1  TPASS  :  received expected failure - errno = 10 - No child processes
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=waitpid01 stime=1411895816
cmdline="waitpid01"
contacts=""
analysis=exit
<<<test_output>>>
waitpid01    1  TPASS  :  recieved expected pid
waitpid01    2  TPASS  :  recieved expected signal
<<<execution_status>>>
initiation_status="ok"
duration=2 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=waitpid02 stime=1411895818
cmdline="waitpid02"
contacts=""
analysis=exit
<<<test_output>>>
waitpid02    1  TPASS  :  recieved expected pid
waitpid02    2  TPASS  :  recieved expected signal
waitpid02    3  TPASS  :  recieved expected exit value
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=1 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=waitpid03 stime=1411895818
cmdline="waitpid03"
contacts=""
analysis=exit
<<<test_output>>>
waitpid03    1  TPASS  :  Got correct child PID
waitpid03    2  TPASS  :  Condition 2 test passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=waitpid04 stime=1411895818
cmdline="waitpid04"
contacts=""
analysis=exit
<<<test_output>>>
waitpid04    1  TPASS  :  condition 1 test passed
waitpid04    2  TPASS  :  condition 2 test passed
waitpid04    3  TPASS  :  condition 3 test passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=waitpid05 stime=1411895818
cmdline="waitpid05"
contacts=""
analysis=exit
<<<test_output>>>
waitpid05    1  TPASS  :  received expected pid.
waitpid05    2  TPASS  :  received expected exit number.
waitpid05    3  TPASS  :  received expected pid.
waitpid05    4  TPASS  :  received expected exit number.
waitpid05    5  TPASS  :  received expected pid.
waitpid05    6  TPASS  :  received expected exit number.
waitpid05    7  TPASS  :  received expected pid.
waitpid05    8  TPASS  :  received expected exit number.
waitpid05    9  TPASS  :  received expected pid.
waitpid05   10  TPASS  :  received expected exit number.
waitpid05   11  TPASS  :  received expected pid.
waitpid05   12  TPASS  :  received expected exit number.
waitpid05   13  TPASS  :  received expected pid.
waitpid05   14  TPASS  :  received expected exit number.
waitpid05   15  TPASS  :  received expected pid.
waitpid05   16  TPASS  :  received expected exit number.
waitpid05   17  TPASS  :  received expected pid.
waitpid05   18  TPASS  :  received expected exit number.
waitpid05   19  TPASS  :  received expected pid.
waitpid05   20  TPASS  :  received expected exit number.
waitpid05   21  TPASS  :  received expected pid.
waitpid05   22  TPASS  :  received expected exit number.
waitpid05   23  TPASS  :  received expected pid.
waitpid05   24  TPASS  :  received expected exit number.
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=waitpid06 stime=1411895818
cmdline="waitpid06"
contacts=""
analysis=exit
<<<test_output>>>
waitpid06    1  TPASS  :  waitpid06 PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=waitpid07 stime=1411895818
cmdline="waitpid07"
contacts=""
analysis=exit
<<<test_output>>>
waitpid07    1  TPASS  :  waitpid07 PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=waitpid08 stime=1411895818
cmdline="waitpid08"
contacts=""
analysis=exit
<<<test_output>>>
waitpid08    1  TPASS  :  waitpid08 PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=waitpid09 stime=1411895818
cmdline="waitpid09"
contacts=""
analysis=exit
<<<test_output>>>
waitpid09    1  TPASS  :  case 1 PASSED
waitpid09    2  TPASS  :  case 2 PASSED
<<<execution_status>>>
initiation_status="ok"
duration=2 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=waitpid10 stime=1411895820
cmdline="waitpid10 5"
contacts=""
analysis=exit
<<<test_output>>>
waitpid10    1  TPASS  :  Test PASSED
<<<execution_status>>>
initiation_status="ok"
duration=7 termination_type=exited termination_id=0 corefile=no
cutime=3999 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=waitpid11 stime=1411895827
cmdline="waitpid11"
contacts=""
analysis=exit
<<<test_output>>>
waitpid11    1  TPASS  :  Test PASSED
waitpid11    1  TPASS  :  waitpid11 PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=waitpid12 stime=1411895827
cmdline="waitpid12"
contacts=""
analysis=exit
<<<test_output>>>
waitpid12    1  TPASS  :  Test PASSED
waitpid12    1  TPASS  :  waitpid12 PASSED
<<<execution_status>>>
initiation_status="ok"
duration=2 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=waitpid13 stime=1411895829
cmdline="waitpid13"
contacts=""
analysis=exit
<<<test_output>>>
waitpid13    1  TPASS  :  Test PASSED
waitpid13    1  TPASS  :  waitpid13 PASSED
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=waitid01 stime=1411895829
cmdline="waitid01"
contacts=""
analysis=exit
<<<test_output>>>
waitid01    0  TINFO  :  Process 30297 terminated:
waitid01    0  TINFO  :  code = 1
waitid01    0  TINFO  :  exit value = 123
waitid01    0  TINFO  :  Process 30297 terminated:
waitid01    0  TINFO  :  code = 1
waitid01    0  TINFO  :  exit value = 123
waitid01    0  TINFO  :  Process 30298 terminated:
waitid01    0  TINFO  :  code = 1
waitid01    0  TINFO  :  exit value = 0
waitid01    0  TINFO  :  Process 30299 terminated:
waitid01    0  TINFO  :  code = 2
waitid01    0  TINFO  :  signal = 1
waitid01    0  TINFO  :  Process 30297 terminated:
waitid01    0  TINFO  :  code = 1
waitid01    0  TINFO  :  exit value = 123
waitid01    0  TINFO  :  Process 30298 terminated:
waitid01    0  TINFO  :  code = 1
waitid01    0  TINFO  :  exit value = 0
waitid01    0  TINFO  :  Process 30299 terminated:
waitid01    0  TINFO  :  code = 2
waitid01    0  TINFO  :  signal = 1
waitid01    0  TINFO  :  Process 30300 terminated:
waitid01    0  TINFO  :  code = 1
waitid01    0  TINFO  :  exit value = 123
waitid01    0  TINFO  :  Process 30297 terminated:
waitid01    0  TINFO  :  code = 1
waitid01    0  TINFO  :  exit value = 123
waitid01    0  TINFO  :  Process 30298 terminated:
waitid01    0  TINFO  :  code = 1
waitid01    0  TINFO  :  exit value = 0
waitid01    0  TINFO  :  Process 30299 terminated:
waitid01    0  TINFO  :  code = 2
waitid01    0  TINFO  :  signal = 1
waitid01    0  TINFO  :  Process 30300 terminated:
waitid01    0  TINFO  :  code = 1
waitid01    0  TINFO  :  exit value = 123
waitid01    0  TINFO  :  Process 30301 terminated:
waitid01    0  TINFO  :  code = 1
waitid01    0  TINFO  :  exit value = 0
waitid01    0  TINFO  :  Process 30302 terminated:
waitid01    0  TINFO  :  code = 2
waitid01    0  TINFO  :  signal = 1
waitid01    0  TINFO  :  Process 30297 terminated:
waitid01    0  TINFO  :  code = 1
waitid01    0  TINFO  :  exit value = 123
waitid01    0  TINFO  :  Process 30298 terminated:
waitid01    0  TINFO  :  code = 1
waitid01    0  TINFO  :  exit value = 0
waitid01    0  TINFO  :  Process 30299 terminated:
waitid01    0  TINFO  :  code = 2
waitid01    0  TINFO  :  signal = 1
waitid01    0  TINFO  :  Process 30300 terminated:
waitid01    0  TINFO  :  code = 1
waitid01    0  TINFO  :  exit value = 123
waitid01    0  TINFO  :  Process 30301 terminated:
waitid01    0  TINFO  :  code = 1
waitid01    0  TINFO  :  exit value = 0
waitid01    0  TINFO  :  Process 30302 terminated:
waitid01    0  TINFO  :  code = 2
waitid01    0  TINFO  :  signal = 1
waitid01    0  TINFO  :  Process 30303 terminated:
waitid01    0  TINFO  :  code = 1
waitid01    0  TINFO  :  exit value = 123
waitid01    0  TINFO  :  Process 30297 terminated:
waitid01    0  TINFO  :  code = 1
waitid01    0  TINFO  :  exit value = 123
waitid01    0  TINFO  :  Process 30298 terminated:
waitid01    0  TINFO  :  code = 1
waitid01    0  TINFO  :  exit value = 0
waitid01    0  TINFO  :  Process 30299 terminated:
waitid01    0  TINFO  :  code = 2
waitid01    0  TINFO  :  signal = 1
waitid01    0  TINFO  :  Process 30300 terminated:
waitid01    0  TINFO  :  code = 1
waitid01    0  TINFO  :  exit value = 123
waitid01    0  TINFO  :  Process 30301 terminated:
waitid01    0  TINFO  :  code = 1
waitid01    0  TINFO  :  exit value = 0
waitid01    0  TINFO  :  Process 30302 terminated:
waitid01    0  TINFO  :  code = 2
waitid01    0  TINFO  :  signal = 1
waitid01    0  TINFO  :  Process 30303 terminated:
waitid01    0  TINFO  :  code = 1
waitid01    0  TINFO  :  exit value = 123
waitid01    0  TINFO  :  Process 30304 terminated:
waitid01    0  TINFO  :  code = 1
waitid01    0  TINFO  :  exit value = 0
waitid01    0  TINFO  :  Process 30305 terminated:
waitid01    0  TINFO  :  code = 2
waitid01    0  TINFO  :  signal = 1
waitid01    1  TPASS  :  waitid(): system call passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=waitid02 stime=1411895829
cmdline="waitid02"
contacts=""
analysis=exit
<<<test_output>>>
waitid02    0  TINFO  :  WNOHANG
waitid02    0  TINFO  :  (30306) waitid(0, 0, 0x7fff70417710, 1)
waitid02    1  TPASS  :  exp_errno=22
waitid02    0  TINFO  :  si_pid = 0 ; si_code = 0 ; si_status = 0
waitid02    0  TINFO  :  WNOHANG | WEXITED no child
waitid02    0  TINFO  :  (30306) waitid(0, 0, 0x7fff70417710, 5)
waitid02    2  TPASS  :  exp_errno=10
waitid02    0  TINFO  :  si_pid = 0 ; si_code = 0 ; si_status = 0
waitid02    0  TINFO  :  WNOHANG
waitid02    0  TINFO  :  (30306) waitid(0, 0, 0x7fff70417710, 1)
waitid02    1  TPASS  :  exp_errno=22
waitid02    0  TINFO  :  si_pid = 0 ; si_code = 0 ; si_status = 0
waitid02    0  TINFO  :  WNOHANG | WEXITED no child
waitid02    0  TINFO  :  (30306) waitid(0, 0, 0x7fff70417710, 5)
waitid02    2  TPASS  :  exp_errno=10
waitid02    0  TINFO  :  si_pid = 0 ; si_code = 0 ; si_status = 0
waitid02    0  TINFO  :  WNOHANG | WEXITED with child
waitid02    0  TINFO  :  (30306) waitid(0, 0, 0x7fff70417710, 5)
waitid02    3  TPASS  :  ret: 0
waitid02    0  TINFO  :  si_pid = 0 ; si_code = 0 ; si_status = 0
waitid02    0  TINFO  :  WNOHANG
waitid02    0  TINFO  :  (30306) waitid(0, 0, 0x7fff70417710, 1)
waitid02    1  TPASS  :  exp_errno=22
waitid02    0  TINFO  :  si_pid = 0 ; si_code = 0 ; si_status = 0
waitid02    0  TINFO  :  WNOHANG | WEXITED no child
waitid02    0  TINFO  :  (30306) waitid(0, 0, 0x7fff70417710, 5)
waitid02    2  TPASS  :  exp_errno=10
waitid02    0  TINFO  :  si_pid = 0 ; si_code = 0 ; si_status = 0
waitid02    0  TINFO  :  WNOHANG | WEXITED with child
waitid02    0  TINFO  :  (30306) waitid(0, 0, 0x7fff70417710, 5)
waitid02    3  TPASS  :  ret: 0
waitid02    0  TINFO  :  si_pid = 0 ; si_code = 0 ; si_status = 0
waitid02    0  TINFO  :  P_PGID, WEXITED wait for child
waitid02    0  TINFO  :  (30306) waitid(2, 30306, 0x7fff70417710, 4)
waitid02    4  TPASS  :  ret: 0
waitid02    0  TINFO  :  si_pid = 30308 ; si_code = 1 ; si_status = 0
waitid02    0  TINFO  :  WNOHANG
waitid02    0  TINFO  :  (30306) waitid(0, 0, 0x7fff70417710, 1)
waitid02    1  TPASS  :  exp_errno=22
waitid02    0  TINFO  :  si_pid = 0 ; si_code = 0 ; si_status = 0
waitid02    0  TINFO  :  WNOHANG | WEXITED no child
waitid02    0  TINFO  :  (30306) waitid(0, 0, 0x7fff70417710, 5)
waitid02    2  TPASS  :  exp_errno=10
waitid02    0  TINFO  :  si_pid = 0 ; si_code = 0 ; si_status = 0
waitid02    0  TINFO  :  WNOHANG | WEXITED with child
waitid02    0  TINFO  :  (30306) waitid(0, 0, 0x7fff70417710, 5)
waitid02    3  TPASS  :  ret: 0
waitid02    0  TINFO  :  si_pid = 0 ; si_code = 0 ; si_status = 0
waitid02    0  TINFO  :  P_PGID, WEXITED wait for child
waitid02    0  TINFO  :  (30306) waitid(2, 30306, 0x7fff70417710, 4)
waitid02    4  TPASS  :  ret: 0
waitid02    0  TINFO  :  si_pid = 30308 ; si_code = 1 ; si_status = 0
waitid02    0  TINFO  :  P_PID, WEXITED wait for child
waitid02    0  TINFO  :  (30306) waitid(1, 30309, 0x7fff70417710, 4)
waitid02    5  TPASS  :  ret: 0
waitid02    0  TINFO  :  si_pid = 30309 ; si_code = 1 ; si_status = 0
waitid02    0  TINFO  :  WNOHANG
waitid02    0  TINFO  :  (30306) waitid(0, 0, 0x7fff70417710, 1)
waitid02    1  TPASS  :  exp_errno=22
waitid02    0  TINFO  :  si_pid = 0 ; si_code = 0 ; si_status = 0
waitid02    0  TINFO  :  WNOHANG | WEXITED no child
waitid02    0  TINFO  :  (30306) waitid(0, 0, 0x7fff70417710, 5)
waitid02    2  TPASS  :  exp_errno=10
waitid02    0  TINFO  :  si_pid = 0 ; si_code = 0 ; si_status = 0
waitid02    0  TINFO  :  WNOHANG | WEXITED with child
waitid02    0  TINFO  :  (30306) waitid(0, 0, 0x7fff70417710, 5)
waitid02    3  TPASS  :  ret: 0
waitid02    0  TINFO  :  si_pid = 0 ; si_code = 0 ; si_status = 0
waitid02    0  TINFO  :  P_PGID, WEXITED wait for child
waitid02    0  TINFO  :  (30306) waitid(2, 30306, 0x7fff70417710, 4)
waitid02    4  TPASS  :  ret: 0
waitid02    0  TINFO  :  si_pid = 30308 ; si_code = 1 ; si_status = 0
waitid02    0  TINFO  :  P_PID, WEXITED wait for child
waitid02    0  TINFO  :  (30306) waitid(1, 30309, 0x7fff70417710, 4)
waitid02    5  TPASS  :  ret: 0
waitid02    0  TINFO  :  si_pid = 30309 ; si_code = 1 ; si_status = 0
waitid02    0  TINFO  :  P_PID, WSTOPPED | WNOWAIT
waitid02    0  TINFO  :  (30306) waitid(1, 30310, 0x7fff70417710, 16777218)
waitid02    6  TPASS  :  ret: 0
waitid02    0  TINFO  :  si_pid = 30310 ; si_code = 5 ; si_status = 19
waitid02    0  TINFO  :  WNOHANG
waitid02    0  TINFO  :  (30306) waitid(0, 0, 0x7fff70417710, 1)
waitid02    1  TPASS  :  exp_errno=22
waitid02    0  TINFO  :  si_pid = 0 ; si_code = 0 ; si_status = 0
waitid02    0  TINFO  :  WNOHANG | WEXITED no child
waitid02    0  TINFO  :  (30306) waitid(0, 0, 0x7fff70417710, 5)
waitid02    2  TPASS  :  exp_errno=10
waitid02    0  TINFO  :  si_pid = 0 ; si_code = 0 ; si_status = 0
waitid02    0  TINFO  :  WNOHANG | WEXITED with child
waitid02    0  TINFO  :  (30306) waitid(0, 0, 0x7fff70417710, 5)
waitid02    3  TPASS  :  ret: 0
waitid02    0  TINFO  :  si_pid = 0 ; si_code = 0 ; si_status = 0
waitid02    0  TINFO  :  P_PGID, WEXITED wait for child
waitid02    0  TINFO  :  (30306) waitid(2, 30306, 0x7fff70417710, 4)
waitid02    4  TPASS  :  ret: 0
waitid02    0  TINFO  :  si_pid = 30308 ; si_code = 1 ; si_status = 0
waitid02    0  TINFO  :  P_PID, WEXITED wait for child
waitid02    0  TINFO  :  (30306) waitid(1, 30309, 0x7fff70417710, 4)
waitid02    5  TPASS  :  ret: 0
waitid02    0  TINFO  :  si_pid = 30309 ; si_code = 1 ; si_status = 0
waitid02    0  TINFO  :  P_PID, WSTOPPED | WNOWAIT
waitid02    0  TINFO  :  (30306) waitid(1, 30310, 0x7fff70417710, 16777218)
waitid02    6  TPASS  :  ret: 0
waitid02    0  TINFO  :  si_pid = 30310 ; si_code = 5 ; si_status = 19
waitid02    0  TINFO  :  P_PID, WCONTINUED
waitid02    0  TINFO  :  (30306) waitid(1, 30311, 0x7fff70417710, 8)
waitid02    7  TPASS  :  ret: 0
waitid02    0  TINFO  :  si_pid = 30311 ; si_code = 6 ; si_status = 18
waitid02    0  TINFO  :  WNOHANG
waitid02    0  TINFO  :  (30306) waitid(0, 0, 0x7fff70417710, 1)
waitid02    1  TPASS  :  exp_errno=22
waitid02    0  TINFO  :  si_pid = 0 ; si_code = 0 ; si_status = 0
waitid02    0  TINFO  :  WNOHANG | WEXITED no child
waitid02    0  TINFO  :  (30306) waitid(0, 0, 0x7fff70417710, 5)
waitid02    2  TPASS  :  exp_errno=10
waitid02    0  TINFO  :  si_pid = 0 ; si_code = 0 ; si_status = 0
waitid02    0  TINFO  :  WNOHANG | WEXITED with child
waitid02    0  TINFO  :  (30306) waitid(0, 0, 0x7fff70417710, 5)
waitid02    3  TPASS  :  ret: 0
waitid02    0  TINFO  :  si_pid = 0 ; si_code = 0 ; si_status = 0
waitid02    0  TINFO  :  P_PGID, WEXITED wait for child
waitid02    0  TINFO  :  (30306) waitid(2, 30306, 0x7fff70417710, 4)
waitid02    4  TPASS  :  ret: 0
waitid02    0  TINFO  :  si_pid = 30308 ; si_code = 1 ; si_status = 0
waitid02    0  TINFO  :  P_PID, WEXITED wait for child
waitid02    0  TINFO  :  (30306) waitid(1, 30309, 0x7fff70417710, 4)
waitid02    5  TPASS  :  ret: 0
waitid02    0  TINFO  :  si_pid = 30309 ; si_code = 1 ; si_status = 0
waitid02    0  TINFO  :  P_PID, WSTOPPED | WNOWAIT
waitid02    0  TINFO  :  (30306) waitid(1, 30310, 0x7fff70417710, 16777218)
waitid02    6  TPASS  :  ret: 0
waitid02    0  TINFO  :  si_pid = 30310 ; si_code = 5 ; si_status = 19
waitid02    0  TINFO  :  P_PID, WCONTINUED
waitid02    0  TINFO  :  (30306) waitid(1, 30311, 0x7fff70417710, 8)
waitid02    7  TPASS  :  ret: 0
waitid02    0  TINFO  :  si_pid = 30311 ; si_code = 6 ; si_status = 18
waitid02    0  TINFO  :  P_PID, WEXITED not a child of the calling process
waitid02    0  TINFO  :  (30306) waitid(1, 1, 0x7fff70417710, 4)
waitid02    8  TPASS  :  exp_errno=10
waitid02    0  TINFO  :  si_pid = 0 ; si_code = 0 ; si_status = 0
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=write01 stime=1411895829
cmdline="write01"
contacts=""
analysis=exit
<<<test_output>>>
write01     1  TPASS  :  write returned 1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=write02 stime=1411895829
cmdline="write02"
contacts=""
analysis=exit
<<<test_output>>>
write02     0  TINFO  :  Block 1: test to see write() returns proper write count
write02     1  TPASS  :  write() PASSED
write02     0  TINFO  :  block 1 passed
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=write03 stime=1411895829
cmdline="write03"
contacts=""
analysis=exit
<<<test_output>>>
write03     0  TINFO  :  Enter Block 1: test to check if write corrupts the file when write fails
write03     1  TPASS  :  failure of write(2) didnot corrupt the file
write03     0  TINFO  :  Exit block 1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=write04 stime=1411895829
cmdline="write04"
contacts=""
analysis=exit
<<<test_output>>>
write04     0  TINFO  :  Enter block 1: test for EAGAIN in write()
write04     0  TINFO  :  read() succeded in setting errno to EAGAIN
write04     1  TPASS  :  Block 1 PASSED
write04     0  TINFO  :  Exit block 1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=write05 stime=1411895829
cmdline="write05"
contacts=""
analysis=exit
<<<test_output>>>
write05     0  TINFO  :  Enter Block 1: test with bad fd
write05     1  TPASS  :  received EBADF as expected.
write05     0  TINFO  :  Exit Block 1
write05     0  TINFO  :  Enter Block 2: test with a bad address
write05     2  TPASS  :  received EFAULT as expected.
write05     0  TINFO  :  Exit Block 2
write05     0  TINFO  :  Enter Block 3: test with invalid pipe
write05     3  TPASS  :  received EPIPE as expected.
write05     0  TINFO  :  Exit Block 3
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=writev01 stime=1411895829
cmdline="writev01"
contacts=""
analysis=exit
<<<test_output>>>
writev01    1  TPASS  :  Enter Block 1
writev01    2  TPASS  :  Received EINVAL as expected
writev01    0  TINFO  :  Exit block 1
writev01    3  TPASS  :  Enter block 2
writev01    0  TINFO  :  Exit block 2
writev01    4  TPASS  :  Enter block 3
writev01    0  TINFO  :  Exit block 3
writev01    5  TPASS  :  Enter block 4
writev01    6  TPASS  :  Received EBADF as expected
writev01    0  TINFO  :  Exit block 4
writev01    7  TPASS  :  Enter block 5
writev01    8  TPASS  :  Received EINVAL as expected
writev01    0  TINFO  :  Exit block 5
writev01    9  TPASS  :  Enter block 6
writev01   10  TPASS  :  writev wrote 0 iovectors
writev01    0  TINFO  :  Exit block 6
writev01   11  TPASS  :  Enter block 7
writev01   12  TPASS  :  writev passed writing 64 bytes, followed by two NULL vectors
writev01    0  TINFO  :  Exit block 7
writev01   13  TPASS  :  Enter block 8
writev01   14  TPASS  :  Received EPIPE as expected
writev01    0  TINFO  :  Exit block 8
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=writev02 stime=1411895829
cmdline="writev02"
contacts=""
analysis=exit
<<<test_output>>>
writev02    0  TINFO  :  Enter block 1
writev02    1  TPASS  :  Received EFAULT as expected
writev02    0  TINFO  :  Exit block 1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=writev03 stime=1411895829
cmdline="writev03"
contacts=""
analysis=exit
<<<test_output>>>
writev03    0  TINFO  :  Enter block 1
writev03    0  TINFO  :  Exit block 1
writev03    0  TINFO  :  Enter block 2
writev03    0  TINFO  :  Exit block 2
writev03    0  TINFO  :  Enter block 3
writev03    0  TINFO  :  Exit block 3
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=1
<<<test_end>>>
<<<test_start>>>
tag=writev04 stime=1411895829
cmdline="writev04"
contacts=""
analysis=exit
<<<test_output>>>
writev04    0  TINFO  :  Enter block 1
writev04    0  TINFO  :  block 1 PASSED
writev04    0  TINFO  :  Exit block 1
writev04    0  TINFO  :  Enter block 2
writev04    0  TINFO  :  block 2 PASSED
writev04    0  TINFO  :  Exit block 2
writev04    0  TINFO  :  Enter block 3
writev04    0  TINFO  :  block 3 PASSED
writev04    0  TINFO  :  Exit block 3
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=writev05 stime=1411895829
cmdline="writev05"
contacts=""
analysis=exit
<<<test_output>>>
writev05    0  TINFO  :  Enter block 1
writev05    0  TINFO  :  Received EFAULT as expected
writev05    0  TINFO  :  block 1 PASSED
writev05    0  TINFO  :  Exit block 1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=writev06 stime=1411895829
cmdline="writev06"
contacts=""
analysis=exit
<<<test_output>>>
writev06    0  TINFO  :  Enter block 1
writev06    0  TINFO  :  writev returned 2 as expected
writev06    0  TINFO  :  block 1 PASSED
writev06    0  TINFO  :  Exit block 1
<<<execution_status>>>
initiation_status="ok"
duration=0 termination_type=exited termination_id=0 corefile=no
cutime=0 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=perf_event_open01 stime=1411895829
cmdline="perf_event_open01"
contacts=""
analysis=exit
<<<test_output>>>
perf_event_open01    0  TINFO  :  read event counter succeeded, value: 3000000752
perf_event_open01    1  TPASS  :  test PERF_TYPE_HARDWARE: PERF_COUNT_HW_INSTRUCTIONS succeeded
perf_event_open01    0  TINFO  :  read event counter succeeded, value: 324
perf_event_open01    2  TPASS  :  test PERF_TYPE_HARDWARE: PERF_COUNT_HW_CACHE_REFERENCES succeeded
perf_event_open01    0  TINFO  :  read event counter succeeded, value: 0
perf_event_open01    3  TPASS  :  test PERF_TYPE_HARDWARE: PERF_COUNT_HW_CACHE_MISSES succeeded
perf_event_open01    0  TINFO  :  read event counter succeeded, value: 1000000743
perf_event_open01    4  TPASS  :  test PERF_TYPE_HARDWARE: PERF_COUNT_HW_BRANCH_INSTRUCTIONS succeeded
perf_event_open01    0  TINFO  :  read event counter succeeded, value: 2240
perf_event_open01    5  TPASS  :  test PERF_TYPE_HARDWARE: PERF_COUNT_HW_BRANCH_MISSES succeeded
perf_event_open01    0  TINFO  :  read event counter succeeded, value: 690633572
perf_event_open01    6  TPASS  :  test PERF_TYPE_HARDWARE: PERF_COUNT_SW_CPU_CLOCK succeeded
perf_event_open01    0  TINFO  :  read event counter succeeded, value: 690773360
perf_event_open01    7  TPASS  :  test PERF_TYPE_HARDWARE: PERF_COUNT_SW_TASK_CLOCK succeeded
<<<execution_status>>>
initiation_status="ok"
duration=5 termination_type=exited termination_id=0 corefile=no
cutime=484 cstime=0
<<<test_end>>>
<<<test_start>>>
tag=perf_event_open02 stime=1411895834
cmdline="perf_event_open02"
contacts=""
analysis=exit
<<<test_output>>>
perf_event_open02    0  TINFO  :  overall task clock: 696777671
perf_event_open02    0  TINFO  :  hw sum: 15020775535, task clock sum: 3480139111
perf_event_open02    0  TINFO  :  ratio: 4.99
perf_event_open02    1  TPASS  :  test passed
incrementing stop
<<<execution_status>>>
initiation_status="ok"
duration=5 termination_type=exited termination_id=0 corefile=no
cutime=485 cstime=0
<<<test_end>>>
INFO: ltp-pan reported some tests FAIL
LTP Version: 20140828-30-g22f3ba1

       ###############################################################

            Done executing testcases.
            LTP Version:  20140828-30-g22f3ba1
       ###############################################################


--+HP7ph2BbKc20aGI--
