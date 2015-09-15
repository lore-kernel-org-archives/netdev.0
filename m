From: David Woodhouse <dwmw2@infradead.org>
Subject: IPv6 routing/fragmentation panic
Date: Tue, 15 Sep 2015 16:53:20 +0100
Message-ID: <1442332400.131189.21.camel@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha-1"; protocol="application/x-pkcs7-signature";
	boundary="=-8R10D2qpPmIFcsVzBrFB"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:45534 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753364AbbIOPxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 11:53:23 -0400
Received: from [2001:8b0:10b:1:21e:67ff:fecb:7a92] (helo=i7.infradead.org)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1ZbsXq-0007L6-H7
	for netdev@vger.kernel.org; Tue, 15 Sep 2015 15:53:22 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-8R10D2qpPmIFcsVzBrFB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

I can repeatably crash my router with 'ping6 -s 2000' to an external
machine:

[   61.741618] skbuff: skb_under_panic: text:c1277f1e len:1294 put:14 head:=
dec98000 data:dec97ffc tail:0xdec9850a end:0xdec98f40 dev:br-lan
[   61.754128] ------------[ cut here ]------------
[   61.758754] Kernel BUG at c1201b1f [verbose debug info unavailable]
[   61.764005] invalid opcode: 0000 [#1]=20
[   61.764005] Modules linked in: sch_teql 8139cp mii iptable_nat pppoe nf_=
nat_ipv4 nf_conntrack_ipv6 nf_conntrack_ipv4 ipt_REJECT ipt_MASQUERADE xt_t=
ime xt_tcpudp xt_state xt_nat xt_multiport xt_mark xt_mac xt_limit xt_connt=
rack xt_comment xt_TCPMSS xt_REDIRECT xt_LOG xt_CT solos_pci pppox ppp_asyn=
c nf_reject_ipv4 nf_nat_redirect nf_nat_masquerade_ipv4 nf_nat_ftp nf_nat n=
f_log_ipv4 nf_defrag_ipv6 nf_defrag_ipv4 nf_conntrack_ftp nf_conntrack ipta=
ble_raw iptable_mangle iptable_filter ip_tables crc_ccitt act_skbedit act_m=
irred em_u32 cls_u32 cls_tcindex cls_flow cls_route cls_fw sch_hfsc sch_ing=
ress ledtrig_heartbeat ledtrig_gpio ip6t_REJECT nf_reject_ipv6 nf_log_ipv6 =
nf_log_common ip6table_raw ip6table_mangle ip6table_filter ip6_tables x_tab=
les pppoatm ppp_generic slhc br2684 atm geode_aes cbc arc4 aes_i586
[   61.764005] CPU: 0 PID: 0 Comm: swapper Not tainted 4.2.0+ #2
[   61.764005] task: c138d540 ti: c1386000 task.ti: c1386000
[   61.764005] EIP: 0060:[<c1201b1f>] EFLAGS: 00210286 CPU: 0
[   61.764005] EIP is at skb_panic+0x3b/0x3d
[   61.764005] EAX: 0000007c EBX: deca3000 ECX: c13a0910 EDX: c139f3c4
[   61.764005] ESI: dee85d8c EDI: dec9800a EBP: defe3b40 ESP: dec0bd50
[   61.764005]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
[   61.764005] CR0: 8005003b CR2: b7704474 CR3: 1ef0d000 CR4: 00000090
[   61.764005] Stack:
[   61.764005]  c135e48c c12e1580 c1277f1e 0000050e 0000000e dec98000 dec97=
ffc dec9850a
[   61.764005]  dec98f40 deca3000 dee85d00 c120337b c12e1580 c1277f1e 00000=
000 0000000e
[   61.764005]  dee85d7c ff671e02 deca3000 c109afd3 00200282 00001d91 00000=
028 dec98012
[   61.764005] Call Trace:
[   61.764005]  [<c1277f1e>] ? ip6_finish_output2+0x196/0x4da
[   61.764005]  [<c120337b>] ? skb_push+0x2c/0x2c
[   61.764005]  [<c1277f1e>] ? ip6_finish_output2+0x196/0x4da
[   61.764005]  [<c109afd3>] ? __kmalloc_track_caller+0x5a/0xd9
[   61.764005]  [<c10840d6>] ? kmemdup+0x15/0x4a
[   61.764005]  [<c1277d88>] ? ip6_forward_finish+0xa/0xa
[   61.764005]  [<c127aad4>] ? ip6_fragment+0x924/0xb49
[   61.764005]  [<c1277d88>] ? ip6_forward_finish+0xa/0xa
[   61.764005]  [<c122fda6>] ? nf_hook_slow+0x50/0x92
[   61.764005]  [<c127ae23>] ? ip6_output+0x85/0xeb
[   61.764005]  [<c127acf9>] ? ip6_fragment+0xb49/0xb49
[   61.764005]  [<c1279fa0>] ? ip6_forward+0x4a9/0x6b9
[   61.764005]  [<c1277d7e>] ? ac6_proc_exit+0xd/0xd
[   61.764005]  [<c127b46c>] ? ip6_make_skb+0x15f/0x15f
[   61.764005]  [<c127b4e6>] ? ip6_rcv_finish+0x7a/0x7e
[   61.764005]  [<e02bb0c4>] ? ipv6_defrag+0xc3/0xc5 [nf_defrag_ipv6]
[   61.764005]  [<c127b46c>] ? ip6_make_skb+0x15f/0x15f
[   61.764005]  [<c122fd4d>] ? nf_iterate+0x5b/0x64
[   61.764005]  [<c122fda6>] ? nf_hook_slow+0x50/0x92
[   61.764005]  [<c127babb>] ? ipv6_rcv+0x305/0x470
[   61.764005]  [<c127b46c>] ? ip6_make_skb+0x15f/0x15f
[   61.764005]  [<c120c04d>] ? __netif_receive_skb_core+0x643/0x836
[   61.764005]  [<c100632a>] ? nommu_map_page+0x2d/0x4d
[   61.764005]  [<e036a153>] ? solos_bh+0x681/0x751 [solos_pci]
[   61.764005]  [<c120dc51>] ? process_backlog+0x45/0x96
[   61.764005]  [<c120d6a9>] ? net_rx_action+0x15b/0x238
[   61.764005]  [<c102dcfc>] ? __do_softirq+0xb4/0x18a
[   61.764005]  [<c102dc48>] ? __hrtimer_tasklet_trampoline+0x12/0x12
[   61.764005]  [<c1002feb>] ? do_softirq_own_stack+0x1b/0x20
[   61.764005]  <IRQ>=20
[   61.764005]  [<c1002e24>] ? do_IRQ+0x38/0x9a
[   61.764005]  [<c12bbd89>] ? common_interrupt+0x29/0x30
[   61.764005]  [<c1007d2e>] ? default_idle+0x2/0x3
[   61.764005]  [<c10080fc>] ? arch_cpu_idle+0x6/0x7
[   61.764005]  [<c1044cf6>] ? cpu_startup_entry+0xed/0x189
[   61.764005]  [<c13bc9ac>] ? start_kernel+0x2e5/0x2e8
[   61.764005] Code: ff b0 9c 00 00 00 ff b0 98 00 00 00 ff b0 a4 00 00 00 =
ff b0 a0 00 00 00 52 ff 70 54 51 ff 74 24 28 68 8c e4 35 c1 e8 9c 73 0b 00 =
<0f> 0b 89 c1 83 79 58 00 8b 80 98 00 00 00 75 17 53 8d 1c 10 01
[   61.764005] EIP: [<c1201b1f>] skb_panic+0x3b/0x3d SS:ESP 0068:dec0bd50
[   62.120408] ---[ end trace 45d5375a04f3aef4 ]---
[   62.125034] Kernel panic - not syncing: Fatal exception in interrupt
[   62.130381] Kernel Offset: disabled
[   62.130381] Rebooting in 3 seconds..<FF>

I can 'fix' it thus (which demonstrates that the issue was with incoming
packets arriving over PPPoATM and being routed out the internal Ethernet):

--- drivers/atm/solos-pci.c~	2015-08-31 23:19:23.000000000 +0100
+++ drivers/atm/solos-pci.c	2015-09-15 15:10:42.534125968 +0100
@@ -869,8 +869,9 @@ static void solos_bh(unsigned long card_
 		/* Allocate RX skbs for any ports which need them */
 		if (card->using_dma && card->atmdev[port] &&
 		    !card->rx_skb[port]) {
-			struct sk_buff *skb =3D alloc_skb(RX_DMA_SIZE, GFP_ATOMIC);
+			struct sk_buff *skb =3D alloc_skb(RX_DMA_SIZE + 16, GFP_ATOMIC);
 			if (skb) {
+				skb_reserve(skb, 16);
 				SKB_CB(skb)->dma_addr =3D
 					pci_map_single(card->dev, skb->data,
 						       RX_DMA_SIZE, PCI_DMA_FROMDEVICE);

Now, I probably should have done this a long time ago, because that
lack of headroom probably meant that the machine was always having to
reallocate buffers just to fit the Ethernet header on the front of them
when routing incoming packets. So I might be happy enough with
submitting a variant of the above patch and calling it a performance
improvement.

But should the kernel *panic* without it? If there are requirements on
the headroom I must leave on received packets, where are they
documented? Or is this a bug in the IPv6 fragmentation code, to make
such assumptions?

I'm not entirely sure how to interpret the above stack trace. Is the
incoming IPv6 packet being reassembled for netfilter's benefit, then re
-fragmented for transmission?
=20
--=20
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation


--=-8R10D2qpPmIFcsVzBrFB
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
CQUxDxcNMTUwOTE1MTU1MzIwWjAjBgkqhkiG9w0BCQQxFgQUgCV6MY5P9QhcNr9CQlM2t9IlqCow
gaUGCSsGAQQBgjcQBDGBlzCBlDCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0
ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNVBAMT
L1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENBAgMN7zcwgacG
CyqGSIb3DQEJEAILMYGXoIGUMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRk
LjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzE4MDYGA1UEAxMv
U3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IEludGVybWVkaWF0ZSBDbGllbnQgQ0ECAw3vNzANBgkq
hkiG9w0BAQEFAASCAQA45IMq32XWUvTZ0Bxt6nQDcNdCvXI9LY8z988pe84rNPM43OkoE2iSS68K
yfOnFkYMmE8CyAjLyAqbrd5xfWtSmebgZyAQjtu8k76+syNeUa11JQdYo4O4ILY9/8BF1yuib97Y
jj9xoSejMAN+JAIJ6Ww8l7Cthq8XsPC+ocv77/gbf3yccNQQMQTKFO77Y3zFN7MzT7qaLbdHEPi8
O+AgdkjjIoqSRjp3Jnhzx/C4Kj+6YGUJzR2IFRUVQOQI3+eTlVGkdue0Ldv6YJcwdCyAKnf8HqZV
gYJstXRy0RvsFMlJ+ZLpe2Xk1xxXyEsDT6Ex3lgYyvDUlimcpdSyvCIbAAAAAAAA


--=-8R10D2qpPmIFcsVzBrFB--
