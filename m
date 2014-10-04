From: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Subject: Fw: [Bug 85571] New: wakeup from hibernate does not bring up
 networking (hard freeze, soft lockups and unusable system)
Date: Sat, 4 Oct 2014 10:32:00 -0700
Message-ID: <20141004103200.2ad147c7@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Fri, 3 Oct 2014 21:22:46 -0700
From: "bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org" <bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org>
To: "stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org" <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Subject: [Bug 85571] New: wakeup from hibernate does not bring up networking (hard freeze, soft lockups and unusable system)


https://bugzilla.kernel.org/show_bug.cgi?id=85571

            Bug ID: 85571
           Summary: wakeup from hibernate does not bring up networking
                    (hard freeze, soft lockups and unusable system)
           Product: Networking
           Version: 2.5
    Kernel Version: 3.16.3-200.fc20.x86_64
          Hardware: Intel
                OS: Linux
              Tree: Fedora
            Status: NEW
          Severity: blocking
          Priority: P1
         Component: Other
          Assignee: shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
          Reporter: itsme_410-/E1597aS9LQAvxtiuMwx3w@public.gmane.org
        Regression: No

The subject line is pretty explanatory. On my Dell Precision M3800, my system
does not wake up from hibernate correctly. (I have no issues with either a Dell
Latitude E6400 or a Dell XPS 13). The latop is unusable and needs a hard
reboot. Here are my hardware details. I also occassionally get the message:

BUG: soft lockup - CPU#0 stuck for 22s! and so on all the way till CPU#1

And I also get the following messages from systemd:

kernel:[43026.180173] do_IRQ: 0.81 No irq handler for vector (irq -1)

kernel:do_IRQ: 0.81 No irq handler for vector (irq -1)

Here is the output from cat /proc/cpuinfo, lsmod, lsb, lspci, etc:


$ cat /proc/cpuinfo
processor    : 0
vendor_id    : GenuineIntel
cpu family    : 6
model        : 60
model name    : Intel(R) Core(TM) i7-4702HQ CPU @ 2.20GHz
stepping    : 3
microcode    : 0x1a
cpu MHz        : 2196.132
cache size    : 6144 KB
physical id    : 0
siblings    : 8
core id        : 0
cpu cores    : 4
apicid        : 0
initial apicid    : 0
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb
rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology
nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2
ssse3 fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt
tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm ida arat epb xsaveopt
pln pts dtherm tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1
avx2 smep bmi2 erms invpcid
bogomips    : 4389.99
clflush size    : 64
cache_alignment    : 64
address sizes    : 39 bits physical, 48 bits virtual
power management:

processor    : 1
vendor_id    : GenuineIntel
cpu family    : 6
model        : 60
model name    : Intel(R) Core(TM) i7-4702HQ CPU @ 2.20GHz
stepping    : 3
microcode    : 0x1a
cpu MHz        : 1900.335
cache size    : 6144 KB
physical id    : 0
siblings    : 8
core id        : 1
cpu cores    : 4
apicid        : 2
initial apicid    : 2
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb
rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology
nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2
ssse3 fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt
tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm ida arat epb xsaveopt
pln pts dtherm tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1
avx2 smep bmi2 erms invpcid
bogomips    : 4389.99
clflush size    : 64
cache_alignment    : 64
address sizes    : 39 bits physical, 48 bits virtual
power management:

processor    : 2
vendor_id    : GenuineIntel
cpu family    : 6
model        : 60
model name    : Intel(R) Core(TM) i7-4702HQ CPU @ 2.20GHz
stepping    : 3
microcode    : 0x1a
cpu MHz        : 2039.382
cache size    : 6144 KB
physical id    : 0
siblings    : 8
core id        : 2
cpu cores    : 4
apicid        : 4
initial apicid    : 4
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb
rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology
nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2
ssse3 fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt
tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm ida arat epb xsaveopt
pln pts dtherm tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1
avx2 smep bmi2 erms invpcid
bogomips    : 4389.99
clflush size    : 64
cache_alignment    : 64
address sizes    : 39 bits physical, 48 bits virtual
power management:

processor    : 3
vendor_id    : GenuineIntel
cpu family    : 6
model        : 60
model name    : Intel(R) Core(TM) i7-4702HQ CPU @ 2.20GHz
stepping    : 3
microcode    : 0x1a
cpu MHz        : 2199.312
cache size    : 6144 KB
physical id    : 0
siblings    : 8
core id        : 3
cpu cores    : 4
apicid        : 6
initial apicid    : 6
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb
rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology
nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2
ssse3 fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt
tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm ida arat epb xsaveopt
pln pts dtherm tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1
avx2 smep bmi2 erms invpcid
bogomips    : 4389.99
clflush size    : 64
cache_alignment    : 64
address sizes    : 39 bits physical, 48 bits virtual
power management:

processor    : 4
vendor_id    : GenuineIntel
cpu family    : 6
model        : 60
model name    : Intel(R) Core(TM) i7-4702HQ CPU @ 2.20GHz
stepping    : 3
microcode    : 0x1a
cpu MHz        : 1176.656
cache size    : 6144 KB
physical id    : 0
siblings    : 8
core id        : 0
cpu cores    : 4
apicid        : 1
initial apicid    : 1
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb
rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology
nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2
ssse3 fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt
tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm ida arat epb xsaveopt
pln pts dtherm tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1
avx2 smep bmi2 erms invpcid
bogomips    : 4389.99
clflush size    : 64
cache_alignment    : 64
address sizes    : 39 bits physical, 48 bits virtual
power management:

processor    : 5
vendor_id    : GenuineIntel
cpu family    : 6
model        : 60
model name    : Intel(R) Core(TM) i7-4702HQ CPU @ 2.20GHz
stepping    : 3
microcode    : 0x1a
cpu MHz        : 1218.250
cache size    : 6144 KB
physical id    : 0
siblings    : 8
core id        : 1
cpu cores    : 4
apicid        : 3
initial apicid    : 3
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb
rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology
nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2
ssse3 fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt
tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm ida arat epb xsaveopt
pln pts dtherm tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1
avx2 smep bmi2 erms invpcid
bogomips    : 4389.99
clflush size    : 64
cache_alignment    : 64
address sizes    : 39 bits physical, 48 bits virtual
power management:

processor    : 6
vendor_id    : GenuineIntel
cpu family    : 6
model        : 60
model name    : Intel(R) Core(TM) i7-4702HQ CPU @ 2.20GHz
stepping    : 3
microcode    : 0x1a
cpu MHz        : 2200.000
cache size    : 6144 KB
physical id    : 0
siblings    : 8
core id        : 2
cpu cores    : 4
apicid        : 5
initial apicid    : 5
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb
rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology
nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2
ssse3 fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt
tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm ida arat epb xsaveopt
pln pts dtherm tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1
avx2 smep bmi2 erms invpcid
bogomips    : 4389.99
clflush size    : 64
cache_alignment    : 64
address sizes    : 39 bits physical, 48 bits virtual
power management:

processor    : 7
vendor_id    : GenuineIntel
cpu family    : 6
model        : 60
model name    : Intel(R) Core(TM) i7-4702HQ CPU @ 2.20GHz
stepping    : 3
microcode    : 0x1a
cpu MHz        : 1901.453
cache size    : 6144 KB
physical id    : 0
siblings    : 8
core id        : 3
cpu cores    : 4
apicid        : 7
initial apicid    : 7
fpu        : yes
fpu_exception    : yes
cpuid level    : 13
wp        : yes
flags        : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov
pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb
rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology
nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2
ssse3 fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt
tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm ida arat epb xsaveopt
pln pts dtherm tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1
avx2 smep bmi2 erms invpcid
bogomips    : 4389.99
clflush size    : 64
cache_alignment    : 64
address sizes    : 39 bits physical, 48 bits virtual
power management:


$ lsmod
Module                  Size  Used by
ccm                    17773  1
tun                    27153  3
ip6t_rpfilter          12546  1
ip6t_REJECT            12939  2
xt_conntrack           12760  9
bnep                   19624  2
ebtable_nat            12807  0
ebtable_broute         12731  0
bridge                116006  1 ebtable_broute
stp                    12868  1 bridge
llc                    13941  2 stp,bridge
ebtable_filter         12827  0
ebtables               30758  3 ebtable_broute,ebtable_nat,ebtable_filter
ip6table_nat           12974  1
nf_conntrack_ipv6      18738  6
nf_defrag_ipv6         34712  1 nf_conntrack_ipv6
nf_nat_ipv6            13213  1 ip6table_nat
ip6table_mangle        12700  1
ip6table_security      12710  1
ip6table_raw           12683  1
ip6table_filter        12815  1
ip6_tables             26809  5
ip6table_filter,ip6table_mangle,ip6table_security,ip6table_nat,ip6table_raw
iptable_nat            12970  1
nf_conntrack_ipv4      14656  5
nf_defrag_ipv4         12702  1 nf_conntrack_ipv4
nf_nat_ipv4            13199  1 iptable_nat
nf_nat                 25178  4
nf_nat_ipv4,nf_nat_ipv6,ip6table_nat,iptable_nat
nf_conntrack           99420  8
nf_nat,nf_nat_ipv4,nf_nat_ipv6,xt_conntrack,ip6table_nat,iptable_nat,nf_conntrack_ipv4,nf_conntrack_ipv6
iptable_mangle         12695  1
iptable_security       12705  1
iptable_raw            12678  1
arc4                   12608  2
x86_pkg_temp_thermal    14205  0
coretemp               13441  0
kvm_intel             147547  0
kvm                   452677  1 kvm_intel
crct10dif_pclmul       14307  0
crc32_pclmul           13133  0
iwlmvm                222115  0
crc32c_intel           22094  0
ghash_clmulni_intel    13230  0
mac80211              623787  1 iwlmvm
pn544_mei              12802  0
mei_phy                13574  1 pn544_mei
pn544                  18073  1 pn544_mei
hci                    43298  2 pn544,mei_phy
rtsx_pci_sdmmc         22998  0
snd_hda_codec_realtek    72791  1
mmc_core              121087  1 rtsx_pci_sdmmc
nfc                    98285  2 hci,pn544
snd_hda_codec_generic    67662  1 snd_hda_codec_realtek
snd_hda_codec_hdmi     47489  1
rtsx_pci_ms            18168  0
iTCO_wdt               13480  0
memstick               16199  1 rtsx_pci_ms
iTCO_vendor_support    13419  1 iTCO_wdt
snd_hda_intel          30379  7
dell_wmi               12681  0
sparse_keymap          13584  1 dell_wmi
dell_laptop            18168  0
snd_hda_controller     30139  1 snd_hda_intel
uvcvideo               81022  0
dcdbas                 14875  1 dell_laptop
videobuf2_vmalloc      13163  1 uvcvideo
snd_hda_codec         131298  5
snd_hda_codec_realtek,snd_hda_codec_hdmi,snd_hda_codec_generic,snd_hda_intel,snd_hda_controller
videobuf2_memops       13161  1 videobuf2_vmalloc
videobuf2_core         57175  1 uvcvideo
v4l2_common            14542  1 videobuf2_core
snd_hwdep              17650  1 snd_hda_codec
joydev                 17344  0
iwlwifi               125702  1 iwlmvm
snd_seq                62266  0
videodev              147660  3 uvcvideo,v4l2_common,videobuf2_core
snd_seq_device         14136  1 snd_seq
btusb                  32448  0
cfg80211              500115  3 iwlwifi,mac80211,iwlmvm
lpc_ich                21093  0
microcode              44710  0
serio_raw              13434  0
snd_pcm               104333  4
snd_hda_codec_hdmi,snd_hda_codec,snd_hda_intel,snd_hda_controller
i2c_i801               18146  0
rtsx_pci               44989  2 rtsx_pci_ms,rtsx_pci_sdmmc
mei_me                 19568  0
mfd_core               13182  2 lpc_ich,rtsx_pci
bluetooth             433970  21 bnep,btusb
mei                    86597  3 pn544_mei,mei_phy,mei_me
hid_multitouch         17419  0
rfkill                 21979  6 nfc,cfg80211,bluetooth,dell_laptop
snd_timer              28778  2 snd_pcm,snd_seq
media                  20846  2 uvcvideo,videodev
snd                    75905  24
snd_hda_codec_realtek,snd_hwdep,snd_timer,snd_hda_codec_hdmi,snd_pcm,snd_seq,snd_hda_codec_generic,snd_hda_codec,snd_hda_intel,snd_seq_device
soundcore              14491  2 snd,snd_hda_codec
shpchp                 37047  0
nfsd                  283833  1
auth_rpcgss            58761  1 nfsd
nfs_acl                12741  1 nfsd
int3403_thermal        12967  0
lockd                  93436  1 nfsd
sunrpc                279214  5 nfsd,auth_rpcgss,lockd,nfs_acl
dell_smo8800           13154  0
nouveau              1222531  1
i915                  904304  5
ttm                    80772  1 nouveau
i2c_algo_bit           13257  2 i915,nouveau
drm_kms_helper         58041  2 i915,nouveau
drm                   291361  7 ttm,i915,drm_kms_helper,nouveau
i2c_core               55486  8
drm,i915,i2c_i801,drm_kms_helper,i2c_algo_bit,v4l2_common,nouveau,videodev
mxm_wmi                12865  1 nouveau
video                  19777  2 i915,nouveau
wmi                    18820  3 dell_wmi,mxm_wmi,nouveau


$ lspci
00:00.0 Host bridge: Intel Corporation Xeon E3-1200 v3/4th Gen Core Processor
DRAM Controller (rev 06)
00:01.0 PCI bridge: Intel Corporation Xeon E3-1200 v3/4th Gen Core Processor
PCI Express x16 Controller (rev 06)
00:02.0 VGA compatible controller: Intel Corporation 4th Gen Core Processor
Integrated Graphics Controller (rev 06)
00:03.0 Audio device: Intel Corporation Xeon E3-1200 v3/4th Gen Core Processor
HD Audio Controller (rev 06)
00:04.0 Signal processing controller: Intel Corporation Device 0c03 (rev 06)
00:14.0 USB controller: Intel Corporation 8 Series/C220 Series Chipset Family
USB xHCI (rev 05)
00:16.0 Communication controller: Intel Corporation 8 Series/C220 Series
Chipset Family MEI Controller #1 (rev 04)
00:1a.0 USB controller: Intel Corporation 8 Series/C220 Series Chipset Family
USB EHCI #2 (rev 05)
00:1b.0 Audio device: Intel Corporation 8 Series/C220 Series Chipset High
Definition Audio Controller (rev 05)
00:1c.0 PCI bridge: Intel Corporation 8 Series/C220 Series Chipset Family PCI
Express Root Port #1 (rev d5)
00:1c.2 PCI bridge: Intel Corporation 8 Series/C220 Series Chipset Family PCI
Express Root Port #3 (rev d5)
00:1c.3 PCI bridge: Intel Corporation 8 Series/C220 Series Chipset Family PCI
Express Root Port #4 (rev d5)
00:1d.0 USB controller: Intel Corporation 8 Series/C220 Series Chipset Family
USB EHCI #1 (rev 05)
00:1f.0 ISA bridge: Intel Corporation HM87 Express LPC Controller (rev 05)
00:1f.2 SATA controller: Intel Corporation 8 Series/C220 Series Chipset Family
6-port SATA Controller 1 [AHCI mode] (rev 05)
00:1f.3 SMBus: Intel Corporation 8 Series/C220 Series Chipset Family SMBus
Controller (rev 05)
00:1f.6 Signal processing controller: Intel Corporation 8 Series Chipset Family
Thermal Management Controller (rev 05)
Please let me know if more information is needed and what I can provide!

--
You are receiving this mail because:
You are the assignee for the bug.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
