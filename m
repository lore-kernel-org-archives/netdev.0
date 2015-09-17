From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH net 2/2]  8139cp: reset BQL when ring tx ring cleared
Date: Thu, 17 Sep 2015 12:36:33 +0100
Message-ID: <1442489793.131189.142.camel@infradead.org>
References: <20130520095443.2d18b2cb@nehalam.linuxnetplumber.net>
	 <20130520213728.GA28252@electric-eye.fr.zoreil.com>
	 <20130520172749.2a4447b6@nehalam.linuxnetplumber.net>
	 <1442232308.30875.6.camel@infradead.org>
	 <20150914215913.GA24962@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha-1"; protocol="application/x-pkcs7-signature";
	boundary="=-CuDxF8+gAynIV/WMem6O"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:60752 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750974AbbIQLgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 07:36:38 -0400
In-Reply-To: <20150914215913.GA24962@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-CuDxF8+gAynIV/WMem6O
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-09-14 at 23:59 +0200, Francois Romieu wrote:
>=20
> [...]
> > [308309.574551] 8139cp 0000:00:0b.0 eth1: Transmit timeout, status=20
> c   2b    0 80ff
>=20
> Rx and Tx are enabled.
>=20
> Instant (untested) hack below.

Thanks; I'll try that. In fact since updating to 4.2 the problem has
got worse =E2=80=94 now the whole machine dies:

[  232.064630] ------------[ cut here ]------------                        =
    =20
[  232.069282] WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:303 dev_wa=
tchdog+0x1e5/0x200()                                                       =
         =20
[  232.077840] NETDEV WATCHDOG: eth1 (8139cp): transmit queue 0 timed out  =
    =20
[  232.084380] Modules linked in: sch_teql 8139cp mii iptable_nat pppoe nf_=
nat_ipv4 nf_conntrack_ipv6 nf_conntrack_ipv4 ipt_REJECT ipt_MASQUERADE xt_t=
ime xt_tcpudp xt_state xt_nat xt_multiport xt_mark xt_mac xt_limit xt_connt=
rack xt_comment xt_TCPMSS xt_REDIRECT xt_LOG xt_CT solos_pci pppox ppp_asyn=
c nf_reject_ipv4 nf_nat_redirect nf_nat_masquerade_ipv4 nf_nat_ftp nf_nat n=
f_log_ipv4 nf_defrag_ipv6 nf_defrag_ipv4 nf_conntrack_ftp nf_conntrack ipta=
ble_raw iptable_mangle iptable_filter ip_tables crc_ccitt act_skbedit act_m=
irred em_u32 cls_u32 cls_tcindex cls_flow cls_route cls_fw sch_hfsc sch_ing=
ress ledtrig_heartbeat ledtrig_gpio ip6t_REJECT nf_reject_ipv6 nf_log_ipv6 =
nf_log_common ip6table_raw ip6table_mangle ip6table_filter ip6_tables x_tab=
les pppoatm ppp_generic slhc br2684 atm geode_aes cbc arc4 aes_i586        =
                                                      =20
[  232.157787] CPU: 0 PID: 0 Comm: swapper Not tainted 4.2.0-gx+ #25       =
    =20
[  232.163982]  00000000 c10313eb dee95000 00000000 ffffff32 00000258 c1031=
446 00000009                                                               =
         =20
[  232.171988]  dec0bf74 c13c3afc dec0bf8c c1272ef5 c13bfe82 0000012f c13c3=
afc dee95000                                                               =
         =20
[  232.179978]  e04cfd3c 00000000 dee95000 dee95240 00000258 80000100 c1272=
d10 dee95000                                                               =
         =20
[  232.188012] Call Trace:                                                 =
    =20
[  232.190482]  [<c10313eb>] ? warn_slowpath_common+0x5b/0x90              =
    =20
[  232.196063]  [<c1031446>] ? warn_slowpath_fmt+0x26/0x30                 =
    =20
[  232.201307]  [<c1272ef5>] ? dev_watchdog+0x1e5/0x200                    =
    =20
[  232.206317]  [<c1272d10>] ? qdisc_rcu_free+0x30/0x30                    =
    =20
[  232.211307]  [<c105b19e>] ? call_timer_fn.isra.7+0xe/0x60               =
    =20
[  232.216811]  [<c1272d10>] ? qdisc_rcu_free+0x30/0x30                    =
    =20
[  232.221794]  [<c105b33d>] ? run_timer_softirq+0xfd/0x1b0                =
    =20
[  232.227221]  [<c1033777>] ? __do_softirq+0xa7/0x190                     =
    =20
[  232.232117]  [<c10336d0>] ? __hrtimer_tasklet_trampoline+0x20/0x20      =
    =20
[  232.238395]  [<c100336b>] ? do_softirq_own_stack+0x1b/0x20              =
    =20
[  232.243881]  <IRQ>  [<c1003165>] ? do_IRQ+0x35/0xa0                     =
    =20
[  232.248904]  [<c131e2a9>] ? common_interrupt+0x29/0x30                  =
    =20
[  232.254141]  [<c104007b>] ? put_unbound_pool+0x17b/0x1a0                =
    =20
[  232.259470]  [<c1008bf2>] ? default_idle+0x2/0x10                       =
    =20
[  232.264213]  [<c1009106>] ? arch_cpu_idle+0x6/0x10                      =
    =20
[  232.269026]  [<c104eee5>] ? cpu_startup_entry+0xf5/0x190                =
    =20
[  232.274459]  [<c142a9b9>] ? start_kernel+0x2e5/0x2e8                    =
    =20
[  232.279432] ---[ end trace 30ae4e701c36b431 ]---                        =
    =20
[  232.284167] 8139cp 0000:00:0b.0 eth1: Transmit timeout, status  c   2b  =
  1 80ac                                                                   =
         =20
[  260.106382] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 23s! [swapp=
er:0]
[  260.113515] Modules linked in: sch_teql 8139cp mii iptable_nat pppoe nf_=
nat_ipv4 nf_conntrack_ipv6 nf_conntrack_ipv4 ipt_REJECT ipt_MASQUERADE xt_t=
ime xt_tcpudp xt_state xt_nat xt_multiport xt_mark xt_mac xt_limit xt_connt=
rack xt_comment xt_TCPMSS xt_REDIRECT xt_LOG xt_CT solos_pci pppox ppp_asyn=
c nf_reject_ipv4 nf_nat_redirect nf_nat_masquerade_ipv4 nf_nat_ftp nf_nat n=
f_log_ipv4 nf_defrag_ipv6 nf_defrag_ipv4 nf_conntrack_ftp nf_conntrack ipta=
ble_raw iptable_mangle iptable_filter ip_tables crc_ccitt act_skbedit act_m=
irred em_u32 cls_u32 cls_tcindex cls_flow cls_route cls_fw sch_hfsc sch_ing=
ress ledtrig_heartbeat ledtrig_gpio ip6t_REJECT nf_reject_ipv6 nf_log_ipv6 =
nf_log_common ip6table_raw ip6table_mangle ip6table_filter ip6_tables x_tab=
les pppoatm ppp_generic slhc br2684 atm geode_aes cbc arc4 aes_i586        =
                                                      =20
[  260.116369] CPU: 0 PID: 0 Comm: swapper Tainted: G        W       4.2.0-=
gx+ #25                                                                    =
         =20
[  260.116369] task: c13f7540 ti: c13f0000 task.ti: c13f0000               =
    =20
[  260.116369] EIP: 0060:[<c131d6fa>] EFLAGS: 00200292 CPU: 0              =
    =20
[  260.116369] EIP is at _raw_spin_unlock_irqrestore+0xa/0x10              =
    =20
[  260.116369] EAX: 00000000 EBX: 00200292 ECX: e04d8100 EDX: 00200292     =
    =20
[  260.116369] ESI: 00000000 EDI: ffffff32 EBP: 00000258 ESP: dec0bf90     =
    =20
[  260.116369]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068               =
    =20
[  260.116369] CR0: 8005003b CR2: 098c4c50 CR3: 1ef88000 CR4: 00000090     =
    =20
[  260.116369] Stack:                                                      =
    =20
[  260.116369]  dee95000 c1272ecb dee95000 dee95240 00000258 80000100 c1272=
d10 dee95000                                                               =
         =20
[  260.116369]  00000100 c105b19e 00000410 c1272d10 c105b33d 00000000 c146d=
524 00000001                                                               =
         =20
[  260.116369]  00000002 c1033777 00000002 ffffe577 c13f2000 0000000a 00200=
000 c13f1f70                                                               =
         =20
[  260.116369] Call Trace:                                                 =
    =20
[  260.116369]  [<c1272ecb>] ? dev_watchdog+0x1bb/0x200                    =
    =20
[  260.116369]  [<c1272d10>] ? qdisc_rcu_free+0x30/0x30                    =
    =20
[  260.116369]  [<c105b19e>] ? call_timer_fn.isra.7+0xe/0x60               =
    =20
[  260.116369]  [<c1272d10>] ? qdisc_rcu_free+0x30/0x30                    =
    =20
[  260.116369]  [<c105b33d>] ? run_timer_softirq+0xfd/0x1b0                =
    =20
[  260.116369]  [<c1033777>] ? __do_softirq+0xa7/0x190                     =
    =20
[  260.116369]  [<c10336d0>] ? __hrtimer_tasklet_trampoline+0x20/0x20      =
    =20
[  260.116369]  [<c100336b>] ? do_softirq_own_stack+0x1b/0x20              =
    =20
[  260.116369]  <IRQ>                                                      =
    =20
[  260.116369]  [<c1003165>] ? do_IRQ+0x35/0xa0                            =
    =20
[  260.116369]  [<c131e2a9>] ? common_interrupt+0x29/0x30                  =
    =20
[  260.116369]  [<c104007b>] ? put_unbound_pool+0x17b/0x1a0                =
    =20
[  260.116369]  [<c1008bf2>] ? default_idle+0x2/0x10                       =
    =20
[  260.116369]  [<c1009106>] ? arch_cpu_idle+0x6/0x10                      =
    =20
[  260.116369]  [<c104eee5>] ? cpu_startup_entry+0xf5/0x190                =
    =20
[  260.116369]  [<c142a9b9>] ? start_kernel+0x2e5/0x2e8                    =
    =20
[  260.116369] Code: 00 b8 01 00 00 00 c3 8d 76 00 8d bc 27 00 00 00 00 e8 =
db 2e d3 ff c3 8d 76 00 8d bc 27 00 00 00 00 53 89 d3 e8 c8 2e d3 ff 53 9d =
<5b> c3 8d 74 26 00 e8 bb 2e d3 ff fb c3 89 f6 8d bc 27 00 00 00           =
              =20

At this point even sysrq on the serial console isn't working; I'm
going to have to go and physically reset it.

(gdb) list *dev_watchdog+0x1bb
0xc1272ecb is in dev_watchdog (net/sched/sch_generic.c:304).
299				}
300=09
301				if (some_queue_timedout) {
302					WARN_ONCE(1, KERN_INFO
"NETDEV WATCHDOG: %s (%s): transmit queue %u timed out\n",
303					       dev->name,
netdev_drivername(dev), i);
304					dev->netdev_ops
->ndo_tx_timeout(dev);
305				}
306				if (!mod_timer(&dev->watchdog_timer,
307					       round_jiffies(jiffies
+
308							     dev
->watchdog_timeo)))

So that _raw_spin_unlock_irqrestore() is going to be a tailcall from
the end of cp_tx_timeout(). Moderately confused that it dies on *unlock*.

_raw_spin_lock_irqrestore+0xa is the instruction after a 'popf', which
makes me wonder if it dies in an IRQ storm. Although then *some* of the
NMI watchdog invocations would surely show an IRQ on the stack, but
they
don't; they're all right on the same instruction.


--=20
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation


--=-CuDxF8+gAynIV/WMem6O
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
CQUxDxcNMTUwOTE3MTEzNjMzWjAjBgkqhkiG9w0BCQQxFgQUyxdVi4DU5ivv3eTXG+HdlNWIi6Iw
gaUGCSsGAQQBgjcQBDGBlzCBlDCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0
ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNVBAMT
L1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENBAgMN7zcwgacG
CyqGSIb3DQEJEAILMYGXoIGUMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRk
LjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzE4MDYGA1UEAxMv
U3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IEludGVybWVkaWF0ZSBDbGllbnQgQ0ECAw3vNzANBgkq
hkiG9w0BAQEFAASCAQCClK1poST4uVrlk5NU2ToHSbDLMfx23UqeeBZdHxji+v7GsDjPr06r8zIS
66FPGnmp9cfMAi5/OyLiNpW6EX9G1uihVpYJN/eU+AS2Ghpt9r6UbACgHSWSbIsHr0wZQ/adP2bU
Ro89i8skhPYtsnCdh8+LiI0CWaT4NEhTQacx4RPKsCFb6Hnv/MHuQcFhZBdb6tZYq4RyVbGeqolY
w6l5xXFJ2x3ysQ7/x2aTtGy57pJM5P56PvvvbaCmxyIZ2gRr7kwg+C1IJiMoeYYuHdIpxbfXzm8f
XDewBRCnDcCnIdvBiTJux1wnhzNCBcaDehXK1ALhrpkzX1a9zlY5Le+ZAAAAAAAA


--=-CuDxF8+gAynIV/WMem6O--
