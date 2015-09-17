From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH net 2/2]  8139cp: reset BQL when ring tx ring cleared
Date: Thu, 17 Sep 2015 13:02:30 +0100
Message-ID: <1442491350.131189.147.camel@infradead.org>
References: <20130520095443.2d18b2cb@nehalam.linuxnetplumber.net>
	 <20130520213728.GA28252@electric-eye.fr.zoreil.com>
	 <20130520172749.2a4447b6@nehalam.linuxnetplumber.net>
	 <1442232308.30875.6.camel@infradead.org>
	 <20150914215913.GA24962@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha-1"; protocol="application/x-pkcs7-signature";
	boundary="=-FQJJ6HqpySPGOClVJDBz"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:60936 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500AbbIQMCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 08:02:42 -0400
In-Reply-To: <20150914215913.GA24962@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-FQJJ6HqpySPGOClVJDBz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-09-14 at 23:59 +0200, Francois Romieu wrote:
> Instant (untested) hack below.

That seems to trigger a lot, but ultimately doesn't help...

[  250.998980] 8139cp 0000:00:0b.0 eth1: Timeout head=3D0000000b, tail=3D00=
00000a  =20
[  252.637287] net_ratelimit: 5 callbacks suppressed                       =
    =20
[  252.642022] 8139cp 0000:00:0b.0 eth1: Timeout head=3D0000003f, tail=3D00=
00003e  =20
[  252.973255] 8139cp 0000:00:0b.0 eth1: Timeout head=3D00000028, tail=3D00=
000027  =20
[  253.911945] 8139cp 0000:00:0b.0 eth1: Timeout head=3D00000010, tail=3D00=
00000f  =20
[  254.151013] 8139cp 0000:00:0b.0 eth1: Timeout head=3D0000000e, tail=3D00=
00000d  =20
[  255.551730] 8139cp 0000:00:0b.0 eth1: Timeout head=3D00000025, tail=3D00=
000024  =20
[  255.568070] 8139cp 0000:00:0b.0 eth1: Timeout head=3D00000027, tail=3D00=
000024  =20
[  255.575717] 8139cp 0000:00:0b.0 eth1: Timeout head=3D0000002a, tail=3D00=
000024  =20
[  255.583035] 8139cp 0000:00:0b.0 eth1: Timeout head=3D0000002b, tail=3D00=
000024  =20
[  255.590361] 8139cp 0000:00:0b.0 eth1: Timeout head=3D0000002c, tail=3D00=
000024  =20
[  255.598080] 8139cp 0000:00:0b.0 eth1: Timeout head=3D0000002e, tail=3D00=
000024  =20
[  267.066384] ------------[ cut here ]------------                        =
    =20
[  267.071053] WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:303 dev_wa=
tchdog+0x1e5/0x200()                                                       =
         =20
[  267.079526] NETDEV WATCHDOG: eth1 (8139cp): transmit queue 0 timed out  =
    =20
[  267.086051] Modules linked in: 8139cp sch_teql mii iptable_nat pppoe nf_=
nat_ipv4 nf_conntrack_ipv6 nf_conntrack_ipv4 ipt_REJECT ipt_MASQUERADE xt_t=
ime xt_tcpudp xt_state xt_nat xt_multiport xt_mark xt_mac xt_limit xt_connt=
rack xt_comment xt_TCPMSS xt_REDIRECT xt_LOG xt_CT solos_pci pppox ppp_asyn=
c nf_reject_ipv4 nf_nat_redirect nf_nat_masquerade_ipv4 nf_nat_ftp nf_nat n=
f_log_ipv4 nf_defrag_ipv6 nf_defrag_ipv4 nf_conntrack_ftp nf_conntrack ipta=
ble_raw iptable_mangle iptable_filter ip_tables crc_ccitt act_skbedit act_m=
irred em_u32 cls_u32 cls_tcindex cls_flow cls_route cls_fw sch_hfsc sch_ing=
ress ledtrig_heartbeat ledtrig_gpio ip6t_REJECT nf_reject_ipv6 nf_log_ipv6 =
nf_log_common ip6table_raw ip6table_mangle ip6table_filter ip6_tables x_tab=
les pppoatm ppp_generic slhc br2684 atm geode_aes cbc arc4 aes_i586 [last u=
nloaded: 8139cp]                                      =20
[  267.161698] CPU: 0 PID: 0 Comm: swapper Not tainted 4.2.0-gx+ #26       =
    =20
[  267.167800]  00000000 c10313eb ddc53000 00000000 fffffde1 00000258 c1031=
446 00000009                                                               =
         =20
[  267.171408]  dec0bf74 c13c3afc dec0bf8c c1272ef5 c13bfe82 0000012f c13c3=
afc ddc53000                                                               =
         =20
[  267.183847]  e06f9dec 00000000 ddc53000 ddc53240 00000258 80000100 c1272=
d10 ddc53000                                                               =
         =20
[  267.191812] Call Trace:                                                 =
    =20
[  267.194376]  [<c10313eb>] ? warn_slowpath_common+0x5b/0x90              =
    =20
[  267.199874]  [<c1031446>] ? warn_slowpath_fmt+0x26/0x30                 =
    =20
[  267.205200]  [<c1272ef5>] ? dev_watchdog+0x1e5/0x200                    =
    =20
[  267.210179]  [<c1272d10>] ? qdisc_rcu_free+0x30/0x30                    =
    =20
[  267.215250]  [<c105b19e>] ? call_timer_fn.isra.7+0xe/0x60               =
    =20
[  267.220661]  [<c1272d10>] ? qdisc_rcu_free+0x30/0x30                    =
    =20
[  267.225739]  [<c105b33d>] ? run_timer_softirq+0xfd/0x1b0                =
    =20
[  267.231071]  [<c1033777>] ? __do_softirq+0xa7/0x190                     =
    =20
[  267.236054]  [<c10336d0>] ? __hrtimer_tasklet_trampoline+0x20/0x20      =
    =20
[  267.242274]  [<c100336b>] ? do_softirq_own_stack+0x1b/0x20              =
    =20
[  267.247768]  <IRQ>  [<c1003165>] ? do_IRQ+0x35/0xa0                     =
    =20
[  267.252248]  [<c131e2a9>] ? common_interrupt+0x29/0x30                  =
    =20
[  267.258062]  [<c104007b>] ? put_unbound_pool+0x17b/0x1a0                =
    =20
[  267.263391]  [<c1008bf2>] ? default_idle+0x2/0x10                       =
    =20
[  267.268186]  [<c1009106>] ? arch_cpu_idle+0x6/0x10                      =
    =20
[  267.272999]  [<c104eee5>] ? cpu_startup_entry+0xf5/0x190                =
    =20
[  267.278410]  [<c142a9b9>] ? start_kernel+0x2e5/0x2e8                    =
    =20
[  267.283378] ---[ end trace a08600e9030733fc ]---                        =
    =20
[  267.288100] cp_tx_timeout                                               =
    =20
[  267.290750] 8139cp 0000:00:0b.0 eth1: Transmit timeout, status  c   2b  =
  1 c0ac                                                                   =
         =20
[  267.298166] will lock...                                                =
    =20
[  267.300709] Handling tx timeout, flags 200286                           =
    =20
[  267.305281] Will wake queue...                                          =
    =20
[  267.308153] Will unlock... flags 200286                                 =
    =20
[  292.120424] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 23s! [swapp=
er:0]
[  292.127561] Modules linked in: 8139cp sch_teql mii iptable_nat pppoe nf_=
nat_i...
[  292.130412] CPU: 0 PID: 0 Comm: swapper Tainted: G        W       4.2.0-=
gx+ #26                                                                    =
         =20
[  292.130412] task: c13f7540 ti: c13f0000 task.ti: c13f0000               =
    =20
[  292.130412] EIP: 0060:[<c131d6fa>] EFLAGS: 00200286 CPU: 0              =
    =20
[  292.130412] EIP is at _raw_spin_unlock_irqrestore+0xa/0x10              =
    =20
[  292.130412] EAX: 00000000 EBX: 00200286 ECX: c1409ee4 EDX: 00200286     =
    =20
[  292.130412] ESI: 00200286 EDI: ddc53428 EBP: ddc53420 ESP: dec0bf68     =
    =20
[  292.130412]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068               =
    =20
[  292.130412] CR0: 8005003b CR2: 0805244c CR3: 1edf6000 CR4: 00000090     =
    =20
[  292.130412] Stack:                                                      =
    =20
[  292.130412]  ddc53000 e06f8055 e06f9e2e 00200286 e06f9e18 e06f9f0c 00200=
286 ddc53000                                                               =
         =20
[  292.130412]  00000000 fffffde1 00000258 c1272ecb ddc53000 ddc53240 00000=
258 80000100                                                               =
         =20
[  292.130412]  c1272d10 ddc53000 00000100 c105b19e 00000442 c1272d10 c105b=
33d ddc7c444                                                               =
         =20
[  292.130412] Call Trace:                                                 =
    =20
[  292.130412]  [<e06f8055>] ? cp_tx_timeout+0x1a5/0x1c0 [8139cp]          =
    =20
[  292.130412]  [<c1272ecb>] ? dev_watchdog+0x1bb/0x200                    =
    =20
[  292.130412]  [<c1272d10>] ? qdisc_rcu_free+0x30/0x30                    =
    =20
[  292.130412]  [<c105b19e>] ? call_timer_fn.isra.7+0xe/0x60               =
    =20
[  292.130412]  [<c1272d10>] ? qdisc_rcu_free+0x30/0x30                    =
    =20
[  292.130412]  [<c105b33d>] ? run_timer_softirq+0xfd/0x1b0                =
    =20
[  292.130412]  [<c1033777>] ? __do_softirq+0xa7/0x190                     =
    =20
[  292.130412]  [<c10336d0>] ? __hrtimer_tasklet_trampoline+0x20/0x20      =
    =20
[  292.130412]  [<c100336b>] ? do_softirq_own_stack+0x1b/0x20              =
    =20
[  292.130412]  <IRQ>                                                      =
    =20
[  292.130412]  [<c1003165>] ? do_IRQ+0x35/0xa0                            =
    =20
[  292.130412]  [<c131e2a9>] ? common_interrupt+0x29/0x30                  =
    =20
[  292.130412]  [<c104007b>] ? put_unbound_pool+0x17b/0x1a0                =
    =20
[  292.130412]  [<c1008bf2>] ? default_idle+0x2/0x10                       =
    =20
[  292.130412]  [<c1009106>] ? arch_cpu_idle+0x6/0x10                      =
    =20
[  292.130412]  [<c104eee5>] ? cpu_startup_entry+0xf5/0x190                =
    =20
[  292.130412]  [<c142a9b9>] ? start_kernel+0x2e5/0x2e8                    =
    =20
[  292.130412] Code: 00 b8 01 00 00 00 c3 8d 76 00 8d bc 27 00 00 00 00 e8 =
db 2e d3 ff c3 8d 76 00 8d bc 27 00 00 00 00 53 89 d3 e8 c8 2e d3 ff 53 9d =
<5b> c3 8d 74 26 00 e8 bb 2e d3 ff fb c3 89 f6 8d bc 27 00 00 00           =
              =20
[  292.130412] Kernel panic - not syncing: softlockup: hung tasks          =
    =20
[  292.130412] CPU: 0 PID: 0 Comm: swapper Tainted: G        W    L  4.2.0-=
gx+ #26                                                                    =
         =20
[  292.130412]  00000000 c1319a5f c13f7540 00000000 00000000 000000f9 c1071=
439 c1399de4                                                               =
         =20
[  292.130412]  dec0bf2c c140b660 c10712f0 00000001 c140aac0 c105bf8e 00000=
000 03bbae55                                                               =
         =20
[  292.130412]  00000044 c140aacc 03bbae55 00000044 00000003 c141b860 c141b=
801 ffffffff                                                               =
         =20
[  292.130412] Call Trace:                                                 =
    =20
[  292.130412]  [<c1319a5f>] ? panic+0x76/0x161                            =
    =20
[  292.130412]  [<c1071439>] ? watchdog_timer_fn+0x149/0x150               =
    =20
[  292.130412]  [<c10712f0>] ? watchdog_cleanup+0x10/0x10                  =
    =20
[  292.130412]  [<c105bf8e>] ? __hrtimer_run_queues.constprop.7+0xae/0x180 =
    =20
[  292.130412]  [<c105c187>] ? hrtimer_interrupt+0x87/0x1d0                =
    =20
[  292.130412]  [<c106817f>] ? tick_handle_oneshot_broadcast+0xcf/0x130    =
    =20
[  292.130412]  [<c100388a>] ? timer_interrupt+0xa/0x10                    =
    =20
[  292.130412]  [<c1054d6f>] ? handle_irq_event_percpu+0x4f/0xf0           =
    =20
[  292.130412]  [<c1054e3d>] ? handle_irq_event+0x2d/0x50                  =
    =20
[  292.130412]  [<c1056c39>] ? handle_level_irq+0x69/0xf0                  =
    =20
[  292.130412]  [<c1056bd0>] ? handle_simple_irq+0x80/0x80                 =
    =20
[  292.130412]  [<c10033b3>] ? handle_irq+0x43/0x70                        =
    =20
[  292.130412]  <IRQ>  [<c100315c>] ? do_IRQ+0x2c/0xa0                     =
    =20
[  292.130412]  [<c131e2a9>] ? common_interrupt+0x29/0x30                  =
    =20
[  292.130412]  [<c105007b>] ? remove_waiter+0x11b/0x120                   =
    =20
[  292.130412]  [<c131d6fa>] ? _raw_spin_unlock_irqrestore+0xa/0x10        =
    =20
[  292.130412]  [<e06f8055>] ? cp_tx_timeout+0x1a5/0x1c0 [8139cp]          =
    =20

--=20
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation


--=-FQJJ6HqpySPGOClVJDBz
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIISjjCCBicw
ggUPoAMCAQICAw3vNzANBgkqhkiG9w0BAQUFADCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0
YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcx
ODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENB
MB4XDTE1MDUwNTA5NDM0MVoXDTE2MDUwNTA5NTMzNlowQjEcMBoGA1UEAwwTZHdtdzJAaW5mcmFk
ZWFkLm9yZzEiMCAGCSqGSIb3DQEJARYTZHdtdzJAaW5mcmFkZWFkLm9yZzCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAMkbm9kPbx1j/X4RVyf/pPKSYwelcco69TvnQQbKM8m8xkWjXJI1
jpJ1jMaGUZGFToINMSZi7lZawUozudWbXSKy1SikENSTJHffsdRAIlsp+hR8vWvjsKUry6sEdqPG
doa5RY7+N4WRusWZDYW/RRWE6i9EL9qV86CVPYqw22UBOUw4/j/HVGCV6TSB8yE5iEwhk/hUuzRr
FZm1MJMR7mCS7BCR8Lr5jFY61lWpBiXNXIxLZCvDc26KR5L5tYX43iUVO3fzES1GRVoYnxxk2tmz
fcsZG5vK+Trc9L8OZJfkYrEHH3+Iw41MQ0w/djVtYr1+HYldx0QmYXAtnhIj+UMCAwEAAaOCAtkw
ggLVMAkGA1UdEwQCMAAwCwYDVR0PBAQDAgSwMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcD
BDAdBgNVHQ4EFgQUszC96C3w5/2+d+atSr0IpT26YI4wHwYDVR0jBBgwFoAUU3Ltkpzg2ssBXHx+
ljVO8tS4UYIwHgYDVR0RBBcwFYETZHdtdzJAaW5mcmFkZWFkLm9yZzCCAUwGA1UdIASCAUMwggE/
MIIBOwYLKwYBBAGBtTcBAgMwggEqMC4GCCsGAQUFBwIBFiJodHRwOi8vd3d3LnN0YXJ0c3NsLmNv
bS9wb2xpY3kucGRmMIH3BggrBgEFBQcCAjCB6jAnFiBTdGFydENvbSBDZXJ0aWZpY2F0aW9uIEF1
dGhvcml0eTADAgEBGoG+VGhpcyBjZXJ0aWZpY2F0ZSB3YXMgaXNzdWVkIGFjY29yZGluZyB0byB0
aGUgQ2xhc3MgMSBWYWxpZGF0aW9uIHJlcXVpcmVtZW50cyBvZiB0aGUgU3RhcnRDb20gQ0EgcG9s
aWN5LCByZWxpYW5jZSBvbmx5IGZvciB0aGUgaW50ZW5kZWQgcHVycG9zZSBpbiBjb21wbGlhbmNl
IG9mIHRoZSByZWx5aW5nIHBhcnR5IG9ibGlnYXRpb25zLjA2BgNVHR8ELzAtMCugKaAnhiVodHRw
Oi8vY3JsLnN0YXJ0c3NsLmNvbS9jcnR1MS1jcmwuY3JsMIGOBggrBgEFBQcBAQSBgTB/MDkGCCsG
AQUFBzABhi1odHRwOi8vb2NzcC5zdGFydHNzbC5jb20vc3ViL2NsYXNzMS9jbGllbnQvY2EwQgYI
KwYBBQUHMAKGNmh0dHA6Ly9haWEuc3RhcnRzc2wuY29tL2NlcnRzL3N1Yi5jbGFzczEuY2xpZW50
LmNhLmNydDAjBgNVHRIEHDAahhhodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS8wDQYJKoZIhvcNAQEF
BQADggEBAHMQmxHHodpS85X8HRyxhvfkys7r+taCNOaNU9cxQu/cZ/6k5nS2qGNMzZ6jb7ueY/V7
7p+4DW/9ZWODDTf4Fz00mh5SSVc20Bz7t+hhxwHd62PZgENh5i76Qq2tw48U8AsYo5damHby1epf
neZafLpUkLLO7AGBJIiRVTevdvyXQ0qnixOmKMWyvrhSNGuVIKVdeqLP+102Dwf+dpFyw+j1hz28
jEEKpHa+NR1b2kXuSPi/rMGhexwlJOh4tK8KQ6Ryr0rIN//NSbOgbyYZrzc/ZUWX9V5OA84ChFb2
vkFl0OcYrttp/rhDBLITwffPxSZeoBh9H7zYzkbCXKL3BUIwggYnMIIFD6ADAgECAgMN7zcwDQYJ
KoZIhvcNAQEFBQAwgYwxCzAJBgNVBAYTAklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSswKQYD
VQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0aWZpY2F0ZSBTaWduaW5nMTgwNgYDVQQDEy9TdGFydENv
bSBDbGFzcyAxIFByaW1hcnkgSW50ZXJtZWRpYXRlIENsaWVudCBDQTAeFw0xNTA1MDUwOTQzNDFa
Fw0xNjA1MDUwOTUzMzZaMEIxHDAaBgNVBAMME2R3bXcyQGluZnJhZGVhZC5vcmcxIjAgBgkqhkiG
9w0BCQEWE2R3bXcyQGluZnJhZGVhZC5vcmcwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
AQDJG5vZD28dY/1+EVcn/6TykmMHpXHKOvU750EGyjPJvMZFo1ySNY6SdYzGhlGRhU6CDTEmYu5W
WsFKM7nVm10istUopBDUkyR337HUQCJbKfoUfL1r47ClK8urBHajxnaGuUWO/jeFkbrFmQ2Fv0UV
hOovRC/alfOglT2KsNtlATlMOP4/x1Rglek0gfMhOYhMIZP4VLs0axWZtTCTEe5gkuwQkfC6+YxW
OtZVqQYlzVyMS2Qrw3NuikeS+bWF+N4lFTt38xEtRkVaGJ8cZNrZs33LGRubyvk63PS/DmSX5GKx
Bx9/iMONTENMP3Y1bWK9fh2JXcdEJmFwLZ4SI/lDAgMBAAGjggLZMIIC1TAJBgNVHRMEAjAAMAsG
A1UdDwQEAwIEsDAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUHAwQwHQYDVR0OBBYEFLMwvegt
8Of9vnfmrUq9CKU9umCOMB8GA1UdIwQYMBaAFFNy7ZKc4NrLAVx8fpY1TvLUuFGCMB4GA1UdEQQX
MBWBE2R3bXcyQGluZnJhZGVhZC5vcmcwggFMBgNVHSAEggFDMIIBPzCCATsGCysGAQQBgbU3AQID
MIIBKjAuBggrBgEFBQcCARYiaHR0cDovL3d3dy5zdGFydHNzbC5jb20vcG9saWN5LnBkZjCB9wYI
KwYBBQUHAgIwgeowJxYgU3RhcnRDb20gQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwAwIBARqBvlRo
aXMgY2VydGlmaWNhdGUgd2FzIGlzc3VlZCBhY2NvcmRpbmcgdG8gdGhlIENsYXNzIDEgVmFsaWRh
dGlvbiByZXF1aXJlbWVudHMgb2YgdGhlIFN0YXJ0Q29tIENBIHBvbGljeSwgcmVsaWFuY2Ugb25s
eSBmb3IgdGhlIGludGVuZGVkIHB1cnBvc2UgaW4gY29tcGxpYW5jZSBvZiB0aGUgcmVseWluZyBw
YXJ0eSBvYmxpZ2F0aW9ucy4wNgYDVR0fBC8wLTAroCmgJ4YlaHR0cDovL2NybC5zdGFydHNzbC5j
b20vY3J0dTEtY3JsLmNybDCBjgYIKwYBBQUHAQEEgYEwfzA5BggrBgEFBQcwAYYtaHR0cDovL29j
c3Auc3RhcnRzc2wuY29tL3N1Yi9jbGFzczEvY2xpZW50L2NhMEIGCCsGAQUFBzAChjZodHRwOi8v
YWlhLnN0YXJ0c3NsLmNvbS9jZXJ0cy9zdWIuY2xhc3MxLmNsaWVudC5jYS5jcnQwIwYDVR0SBBww
GoYYaHR0cDovL3d3dy5zdGFydHNzbC5jb20vMA0GCSqGSIb3DQEBBQUAA4IBAQBzEJsRx6HaUvOV
/B0csYb35MrO6/rWgjTmjVPXMULv3Gf+pOZ0tqhjTM2eo2+7nmP1e+6fuA1v/WVjgw03+Bc9NJoe
UklXNtAc+7foYccB3etj2YBDYeYu+kKtrcOPFPALGKOXWph28tXqX53mWny6VJCyzuwBgSSIkVU3
r3b8l0NKp4sTpijFsr64UjRrlSClXXqiz/tdNg8H/naRcsPo9Yc9vIxBCqR2vjUdW9pF7kj4v6zB
oXscJSToeLSvCkOkcq9KyDf/zUmzoG8mGa83P2VFl/VeTgPOAoRW9r5BZdDnGK7baf64QwSyE8H3
z8UmXqAYfR+82M5Gwlyi9wVCMIIGNDCCBBygAwIBAgIBHjANBgkqhkiG9w0BAQUFADB9MQswCQYD
VQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwg
Q2VydGlmaWNhdGUgU2lnbmluZzEpMCcGA1UEAxMgU3RhcnRDb20gQ2VydGlmaWNhdGlvbiBBdXRo
b3JpdHkwHhcNMDcxMDI0MjEwMTU1WhcNMTcxMDI0MjEwMTU1WjCBjDELMAkGA1UEBhMCSUwxFjAU
BgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRl
IFNpZ25pbmcxODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUg
Q2xpZW50IENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxwmDzM4t2BqxKaQuE6uW
vooyg4ymiEGWVUet1G8SD+rqvyNH4QrvnEIaFHxOhESip7vMz39ScLpNLbL1QpOlPW/tFIzNHS3q
d2XRNYG5Sv9RcGE+T4qbLtsjjJbi6sL7Ls/f/X9ftTyhxvxWkf8KW37iKrueKsxw2HqolH7GM6FX
5UfNAwAu4ZifkpmZzU1slBhyWwaQPEPPZRsWoTb7q8hmgv6Nv3Hg9rmA1/VPBIOQ6SKRkHXG0Hhm
q1dOFoAFI411+a/9nWm5rcVjGcIWZ2v/43Yksq60jExipA4l5uv9/+Hm33mbgmCszdj/Dthf13tg
Av2O83hLJ0exTqfrlwIDAQABo4IBrTCCAakwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMC
AQYwHQYDVR0OBBYEFFNy7ZKc4NrLAVx8fpY1TvLUuFGCMB8GA1UdIwQYMBaAFE4L7xqkQFulF2mH
MMo0aEPQQa7yMGYGCCsGAQUFBwEBBFowWDAnBggrBgEFBQcwAYYbaHR0cDovL29jc3Auc3RhcnRz
c2wuY29tL2NhMC0GCCsGAQUFBzAChiFodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS9zZnNjYS5jcnQw
WwYDVR0fBFQwUjAnoCWgI4YhaHR0cDovL3d3dy5zdGFydHNzbC5jb20vc2ZzY2EuY3JsMCegJaAj
hiFodHRwOi8vY3JsLnN0YXJ0c3NsLmNvbS9zZnNjYS5jcmwwgYAGA1UdIAR5MHcwdQYLKwYBBAGB
tTcBAgEwZjAuBggrBgEFBQcCARYiaHR0cDovL3d3dy5zdGFydHNzbC5jb20vcG9saWN5LnBkZjA0
BggrBgEFBQcCARYoaHR0cDovL3d3dy5zdGFydHNzbC5jb20vaW50ZXJtZWRpYXRlLnBkZjANBgkq
hkiG9w0BAQUFAAOCAgEACoMIfXirLAZcuGOMXq4cuSN3TaFx2H2GvD5VSy/6rV55BYHbWNaPeQn3
oBSU8KgQZn/Kck1JxbLpAxVCNtsxeW1R87ifhsYZ0qjdrA9anrW2MAWCtosmAOT4OxK9QPoSjCMx
M3HbkZCDJgnlE8jMopH21BbyAYr7b5EfGRQJNtgWcvqSXwKHnTutR08+Kkn0KAkXCzeQNLeA5LlY
UzFyM7kPAp8pIRMQ+seHunmyG642S2+y/qHEdMuGIwpfz3eDF1PdctL04qYK/zu+Qg1Bw0RwgigV
Zs/0c5HP2/e9DBHh7eSwtzYlk4AUr6yxLlcwSjOfOmKEQ/Q8tzh0IFiNu9IPuTGAPBn4CPxD0+Ru
8T2wg8/s43R/PT3kd1OEqOJUl7q+h+r6fpvU0Fzxd2tC8Ga6fDEPme+1Nbi+03pVjuZQKbGwKJ66
gEn06WqaxVZC+J8hh/jR0k9mST1iAZPNYulcNJ8tKmVtjYsv0L1TSm2+NwON58tO+pIVzu3DWwSE
XSf+qkDavQam+QtEOZxLBXI++aMUEapSn+k3Lxm48ZCYfAWLb/Xj7F5JQMbZvCexglAbYR0kIHqW
5DnsYSdMD/IplJMojx0NBrxJ3fN9dvX2Y6BIXRsF1du4qESm4/3CKuyUV7p9DW3mPlHTGLvYxnyK
Qy7VFBkoLINszBrOUeIxggNvMIIDawIBATCBlDCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0
YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcx
ODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENB
AgMN7zcwCQYFKw4DAhoFAKCCAa8wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0B
CQUxDxcNMTUwOTE3MTIwMjMwWjAjBgkqhkiG9w0BCQQxFgQUkvG/IldB+TRkQXgQCarkIhSw1O8w
gaUGCSsGAQQBgjcQBDGBlzCBlDCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0
ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNVBAMT
L1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENBAgMN7zcwgacG
CyqGSIb3DQEJEAILMYGXoIGUMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRk
LjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzE4MDYGA1UEAxMv
U3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IEludGVybWVkaWF0ZSBDbGllbnQgQ0ECAw3vNzANBgkq
hkiG9w0BAQEFAASCAQCBxEYUDv7oNq4wz/x4y9954B6L8ChG2nQbc2Zatl2EuHCwsrgKZUH350gu
fl7Qk+T4G8K9KrwMtse8iBaQ7uvoonzI3spqWOrVY8CN3vbvh8niG66mAS0MVGA9iwkRMUrZ0A2x
dbttI76pF342z60fDYBalcz3ky9gpjAlP44P5zuB8p8lUE0phPjw3O18NhBgxmA7pmXHKidwkno/
oeAefV2iZS3WKzZRZuutcbJJLKlx0QCfGpGwjsSEVL/mb4K6oiCGILgU9XxkrXTyeoG+6XOz0yG9
E9rEi0qDsfylNAeHTGHOCKDCNrB/RYSYHOxlrMfq0JwANlImplpPgeAwAAAAAAAA


--=-FQJJ6HqpySPGOClVJDBz--
