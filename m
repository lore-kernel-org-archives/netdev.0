From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: WARNING: at net/sched/sch_generic.c:219
Date: Mon, 3 Nov 2008 10:49:53 -0800
Message-ID: <F169D4F5E1F1974DBFAFABF47F60C10A0E873C1B@orsmsx507.amr.corp.intel.com>
References: <20081103092609.GA8659@ntm.vs.lam.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=SHA1;
	protocol="application/x-pkcs7-signature";
	boundary="----=_NextPart_000_0019_01C93DA1.E761B8E0"
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Milan Kocian <milon@wq.cz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41134 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751279AbYKCSuM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 13:50:12 -0500
In-Reply-To: <20081103092609.GA8659@ntm.vs.lam.cz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_NextPart_000_0019_01C93DA1.E761B8E0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Kocian wrote:
> hello,
> 
> for your info I have here one warning. Kernel 2.6.27.4.
> Machine have minimal load and traffic (I can say, it does nothing :-).
> Probably its related to link up/down. (kvm module is only loaded, not
> used)

what kind of hardware do you have? lspci -vvv output please.  you're
running a 64 bit kernel, does it happen to be an AMD system with a
hypertransport to PCI express bridge and >= 4GB ram?
 

> Nov  1 19:46:40 srw1 kernel: 0000:0d:00.0: eth0: Detected Tx Unit
> Hang: 
> Nov  1 19:46:40 srw1 kernel: TDH                  <bf>
> Nov  1 19:46:40 srw1 kernel: TDT                  <cd>
> Nov  1 19:46:40 srw1 kernel: next_to_use          <cd>
> Nov  1 19:46:40 srw1 kernel: next_to_clean        <bf>
> Nov  1 19:46:40 srw1 kernel: buffer_info[next_to_clean]:
> Nov  1 19:46:40 srw1 kernel: time_stamp           <1020c297e>
> Nov  1 19:46:40 srw1 kernel: next_to_watch        <bf>
> Nov  1 19:46:40 srw1 kernel: jiffies              <1020c3cb4>
> Nov  1 19:46:40 srw1 kernel: next_to_watch.status <0>
> Nov  1 19:46:42 srw1 kernel: 0000:0d:00.0: eth0: Detected Tx Unit
> Hang: 
> Nov  1 19:46:42 srw1 kernel: TDH                  <bf>
> Nov  1 19:46:42 srw1 kernel: TDT                  <cd>
> Nov  1 19:46:42 srw1 kernel: next_to_use          <cd>
> Nov  1 19:46:42 srw1 kernel: next_to_clean        <bf>
> Nov  1 19:46:42 srw1 kernel: buffer_info[next_to_clean]:
> Nov  1 19:46:42 srw1 kernel: time_stamp           <1020c297e>
> Nov  1 19:46:42 srw1 kernel: next_to_watch        <bf>
> Nov  1 19:46:42 srw1 kernel: jiffies              <1020c3f0c>
> Nov  1 19:46:42 srw1 kernel: next_to_watch.status <0>

this part looks like we are reporting a real tx hang, from hardware's
perspective at least.  Are you sure your duplex settings are correct?
are you forcing 10 Full?

> Nov  1 19:46:43 srw1 kernel: ------------[ cut here ]------------
> Nov  1 19:46:43 srw1 kernel: WARNING: at net/sched/sch_generic.c:219
> dev_watchdog+0x22e/0x240() Nov  1 19:46:43 srw1 kernel: NETDEV
> WATCHDOG: eth0 (e1000e): transmit timed out 
> Nov  1 19:46:43 srw1 kernel: Modules linked in: kvm_intel kvm ipv6
> loop e1000e 
> Nov  1 19:46:43 srw1 kernel: Pid: 0, comm: swapper Not tainted
> 2.6.27.4 #2 
> Nov  1 19:46:43 srw1 kernel:
> Nov  1 19:46:43 srw1 kernel: Call Trace:
> Nov  1 19:46:43 srw1 kernel: <IRQ>  [<ffffffff8023449d>]
> warn_slowpath+0xcd/0x120 
> Nov  1 19:46:43 srw1 kernel: [<ffffffff8023521d>] vprintk+0x16d/0x3c0
> Nov  1 19:46:43 srw1 kernel: [<ffffffff8038b829>] __next_cpu+0x19/0x30
> Nov  1 19:46:43 srw1 kernel: [<ffffffff8022bcec>]
> find_busiest_group+0x1dc/0x950 
> Nov  1 19:46:43 srw1 kernel: [<ffffffff803914d1>] strlcpy+0x41/0x50
> Nov  1 19:46:43 srw1 kernel: [<ffffffff8042e49e>]
> dev_watchdog+0x22e/0x240 
> Nov  1 19:46:43 srw1 kernel: [<ffffffff80424c56>]
> neigh_periodic_timer+0x146/0x1c0 
> Nov  1 19:46:43 srw1 kernel: [<ffffffff8024f178>]
> getnstimeofday+0x48/0xc0 
> Nov  1 19:46:43 srw1 kernel: [<ffffffff8042e270>]
> dev_watchdog+0x0/0x240 
> Nov  1 19:46:43 srw1 kernel: [<ffffffff8023e6be>]
> run_timer_softirq+0x12e/0x200 
> Nov  1 19:46:43 srw1 kernel: [<ffffffff80239e43>]
> __do_softirq+0x73/0xf0 
> Nov  1 19:46:43 srw1 kernel: [<ffffffff8020cb8c>]
> call_softirq+0x1c/0x30 
> Nov  1 19:46:43 srw1 kernel: [<ffffffff8020eb75>] do_softirq+0x35/0x70
> Nov  1 19:46:43 srw1 kernel: [<ffffffff8021c13e>]
> smp_apic_timer_interrupt+0x7e/0xc0 
> Nov  1 19:46:43 srw1 kernel: [<ffffffff8020c5d6>]
> apic_timer_interrupt+0x66/0x70 
> Nov  1 19:46:43 srw1 kernel: <EOI>  [<ffffffff8021329c>]
> mwait_idle+0x3c/0x50 
> Nov  1 19:46:43 srw1 kernel: [<ffffffff8020a86c>] cpu_idle+0x5c/0x90
> Nov  1 19:46:43 srw1 kernel:
> Nov  1 19:46:43 srw1 kernel: ---[ end trace c45f300d9ee4877c ]---
> Nov  1 19:46:45 srw1 kernel: 0000:0d:00.0: eth0: Link is Up 10 Mbps
> Full Duplex, Flow Control: None Nov  1 19:46:45 srw1 kernel:
> 0000:0d:00.0: eth0: 10/100 speed: disabling TSO 
> Nov  1 19:48:40 srw1 kernel: 0000:0d:00.0: eth0: Detected Tx Unit
> Hang: 

hm, roughly 2 minutes from link up to hang, and at least 0xd7 packets
enqueued (215)  

> Nov  1 19:48:40 srw1 kernel: TDH                  <cc>
> Nov  1 19:48:40 srw1 kernel: TDT                  <d7>
> Nov  1 19:48:40 srw1 kernel: next_to_use          <d7>
> Nov  1 19:48:40 srw1 kernel: next_to_clean        <ca>
> Nov  1 19:48:40 srw1 kernel: buffer_info[next_to_clean]:
> Nov  1 19:48:40 srw1 kernel: time_stamp           <1020cb4e0>
> Nov  1 19:48:40 srw1 kernel: next_to_watch        <cc>
> Nov  1 19:48:40 srw1 kernel: jiffies              <1020cc828>
> Nov  1 19:48:40 srw1 kernel: next_to_watch.status <0>
> Nov  1 19:48:43 srw1 kernel: 0000:0d:00.0: eth0: Link is Up 10 Mbps
> Full Duplex, Flow Control: None Nov  1 19:48:43 srw1 kernel:
> 0000:0d:00.0: eth0: 10/100 speed: disabling TSO 

we have a patch that can dump the hardware state of the transmit ring in
much more detail, once we get more information maybe we'll have to run
that to figure out whats up.

Thanks for the report,
  Jesse

------=_NextPart_000_0019_01C93DA1.E761B8E0
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIXMTCCAyAw
ggKJoAMCAQICBDXe9M8wDQYJKoZIhvcNAQEFBQAwTjELMAkGA1UEBhMCVVMxEDAOBgNVBAoTB0Vx
dWlmYXgxLTArBgNVBAsTJEVxdWlmYXggU2VjdXJlIENlcnRpZmljYXRlIEF1dGhvcml0eTAeFw05
ODA4MjIxNjQxNTFaFw0xODA4MjIxNjQxNTFaME4xCzAJBgNVBAYTAlVTMRAwDgYDVQQKEwdFcXVp
ZmF4MS0wKwYDVQQLEyRFcXVpZmF4IFNlY3VyZSBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkwgZ8wDQYJ
KoZIhvcNAQEBBQADgY0AMIGJAoGBAMFdsVhnCGLuoJotHwhtkRRomAoe/toEbxOEYiHD0XzOnwXg
uAHwTjTs4oqVBGSs8WtTXwWzy2eAv0ICjv7dAQns4QAUT/z78AzdQ7pbK+EfgHCZFVeTFvEPl2q3
wmgjHMxNWTCsUR47ryvW7mNFe8XZX1DS41APOojnvxT94Me5AgMBAAGjggEJMIIBBTBwBgNVHR8E
aTBnMGWgY6BhpF8wXTELMAkGA1UEBhMCVVMxEDAOBgNVBAoTB0VxdWlmYXgxLTArBgNVBAsTJEVx
dWlmYXggU2VjdXJlIENlcnRpZmljYXRlIEF1dGhvcml0eTENMAsGA1UEAxMEQ1JMMTAaBgNVHRAE
EzARgQ8yMDE4MDgyMjE2NDE1MVowCwYDVR0PBAQDAgEGMB8GA1UdIwQYMBaAFEjmaPkr0rKV10fY
IyAQTzOYkJ/UMB0GA1UdDgQWBBRI5mj5K9KylddH2CMgEE8zmJCf1DAMBgNVHRMEBTADAQH/MBoG
CSqGSIb2fQdBAAQNMAsbBVYzLjBjAwIGwDANBgkqhkiG9w0BAQUFAAOBgQBYzinq/Pfetc4CuRe1
hdG54+CVzCUxDQCmkm5/tpJjnlCV0Zpv5BHeY4VumO6o/1rI01WyZnFX3sAh6z0qpyNJAQSGQnv8
7n+iFlK1Z2fTQNs7JliyKHc9rhR3Ydb6KmYnoA36p3Nc6nDxlCFlRF/6/O8paKmih3nvee9PrAd3
ODCCAz0wggKmoAMCAQICAwWw/zANBgkqhkiG9w0BAQUFADBOMQswCQYDVQQGEwJVUzEQMA4GA1UE
ChMHRXF1aWZheDEtMCsGA1UECxMkRXF1aWZheCBTZWN1cmUgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
MB4XDTA2MDIxNjE4MDEzMFoXDTE2MDIxOTE4MDEzMFowUjELMAkGA1UEBhMCVVMxGjAYBgNVBAoT
EUludGVsIENvcnBvcmF0aW9uMScwJQYDVQQDEx5JbnRlbCBFeHRlcm5hbCBCYXNpYyBQb2xpY3kg
Q0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDBpd/XOb9QVqEZ8mQ1042TdOIq3ATD
IsV2xDyt30yLyMR5Wjtus0bn3B+he89BiNO/LP6+rFzEwlD55PlX+HLGIKeNNG97dqyc30FElEUj
ZzTZFq2N4e3kVJ/XAEEgANzV8v9qp7qWwxugPgfc3z9BkYot+CifozexHLb/hEZj+yISCU61kRZv
uSQ0E11yYL4dRgcglJeaHo3oX57rvIckaLsYV5/1Aj+R8DM1Ppk965XQAKsHfnyT7C4S50T4lVn4
lz36wOdNZn/zegG1zp41lnoTFfT4KuKVJH5x7YD1p6KbgJCKLovnujGuohquBNfdXKpZkvz6pGv+
iC1HawJdAgMBAAGjgaAwgZ0wDgYDVR0PAQH/BAQDAgEGMB0GA1UdDgQWBBQaxgxKxEdvqNutK/D0
Vgaj7TdUDDA6BgNVHR8EMzAxMC+gLaArhilodHRwOi8vY3JsLmdlb3RydXN0LmNvbS9jcmxzL3Nl
Y3VyZWNhLmNybDAfBgNVHSMEGDAWgBRI5mj5K9KylddH2CMgEE8zmJCf1DAPBgNVHRMBAf8EBTAD
AQH/MA0GCSqGSIb3DQEBBQUAA4GBABMQOK2kVKVIlUWwLTdywJ+e2O+PC/uQltK2F3lRyrPfBn69
tOkIP4SgDJOfsxyobIrPLe75kBLw+Dom13OBDp/EMZJZ1CglQfVV8co9mT3aZMjSGGQiMgkJLR3j
Mfr900fXZKj5XeqCJ+JP0mEhJGEdVCY+FFlksJjV86fDrq1QMIIFYzCCBEugAwIBAgIKYSyUiQAA
AAAABTANBgkqhkiG9w0BAQUFADBSMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9y
YXRpb24xJzAlBgNVBAMTHkludGVsIEV4dGVybmFsIEJhc2ljIFBvbGljeSBDQTAeFw0wNjAzMjIy
MjIyNDJaFw0xMjAzMjIyMjMyNDJaMFYxCzAJBgNVBAYTAlVTMRowGAYDVQQKExFJbnRlbCBDb3Jw
b3JhdGlvbjErMCkGA1UEAxMiSW50ZWwgRXh0ZXJuYWwgQmFzaWMgSXNzdWluZyBDQSAzQTCCASIw
DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKvXqH/ah10uJc7YzQUh+XEDNqS6IsXOyqCtizr9
x6F+v6iRAbvddRRJRWixfV78qarSN9WMymJ90M8c9/Dfr1yzFuq95RgCAF3vdve3wKi7kJv6lkMJ
wyyB+uIYcWtljYx2LDqbb9S6Z6He3q8W/aGKvu23I9ksNx+cmZcDNZwGdXVIEHpEMyA4bp0RvYtf
p8BsGAyn6YuK63HugeyYdeFL+4+Wz2tGUqw9OWhob6oV1oDH3zboLhHJiQ2oIj3jAJ3/LrIkzcWP
2R20UIliDAPAAl6MNWJPdsNK5EEeuxEuUSpdFsMj5rBmPHH4U8i8rUmi6GEOcX5rwAw64AzS3gEC
AwEAAaOCAjUwggIxMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFAlpgTN7BnOPI0wKA9/3FoER
ghMFMAsGA1UdDwQEAwIBhjAQBgkrBgEEAYI3FQEEAwIBADAZBgkrBgEEAYI3FAIEDB4KAFMAdQBi
AEMAQTAfBgNVHSMEGDAWgBQaxgxKxEdvqNutK/D0Vgaj7TdUDDCBvQYDVR0fBIG1MIGyMIGvoIGs
oIGphk5odHRwOi8vd3d3LmludGVsLmNvbS9yZXBvc2l0b3J5L0NSTC9JbnRlbCUyMEV4dGVybmFs
JTIwQmFzaWMlMjBQb2xpY3klMjBDQS5jcmyGV2h0dHA6Ly9jZXJ0aWZpY2F0ZXMuaW50ZWwuY29t
L3JlcG9zaXRvcnkvQ1JML0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMFBvbGljeSUyMENBLmNy
bDCB4wYIKwYBBQUHAQEEgdYwgdMwYwYIKwYBBQUHMAKGV2h0dHA6Ly93d3cuaW50ZWwuY29tL3Jl
cG9zaXRvcnkvY2VydGlmaWNhdGVzL0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMFBvbGljeSUy
MENBLmNydDBsBggrBgEFBQcwAoZgaHR0cDovL2NlcnRpZmljYXRlcy5pbnRlbC5jb20vcmVwb3Np
dG9yeS9jZXJ0aWZpY2F0ZXMvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIwUG9saWN5JTIwQ0Eu
Y3J0MA0GCSqGSIb3DQEBBQUAA4IBAQCuNCnecJ+vDpXzsHOzMEyz4KgTNDbJROHag8H/ZVga7soc
oJyC+HKqDfQgxifVorbTbSajCBEAxqg6bbNWBJ6qKOFHneBrXkENf5WdD50eCTCFWRV3EIsHEOQ1
kP0eNYV5Ed4hp9y6wASV6z2z86O4+qouLJiow4AIhoCKD8rEyD7ODgTvjvLCKpsVyPlG1jOVSsOS
IF2VUmueAmK3RFU4np83zerK/j0G37owhniEDT6ZhwkUd0XL45nt1m7yApMEbnXUTHNaXnE+P98k
k3nDXdW25sB+5xWcYR3GpgMdQiZgP/f0KZ+yZKNE7gcp3I/O4pXqUNWIsLSYTi3soAR2MIIFizCC
BHOgAwIBAgIKTys7CwAAAAAWqTANBgkqhkiG9w0BAQUFADBWMQswCQYDVQQGEwJVUzEaMBgGA1UE
ChMRSW50ZWwgQ29ycG9yYXRpb24xKzApBgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3Vp
bmcgQ0EgM0EwHhcNMDcwODA3MDAyMzE2WhcNMTAwODA2MDAyMzE2WjBHMRowGAYDVQQDExFCcmFu
ZGVidXJnLCBKZXNzZTEpMCcGCSqGSIb3DQEJARYaamVzc2UuYnJhbmRlYnVyZ0BpbnRlbC5jb20w
gZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBALVYgP1o+Y7nwm5Lr6GerkzP9QweQWF7Ban1beaZ
Etba5ALpVHObkA/1pXF8sE/iJnu4CxUAxAmVArSVNHWFJDdS/rR43JOvekwVIKEo4a9JABCXF+rt
K/1ImEN+RDLfl/0Wd73CRfOvRtTSlg+pUqVyCtL9B3X1bzY+OPxicYahAgMBAAGjggLsMIIC6DAL
BgNVHQ8EBAMCB4AwHQYDVR0OBBYEFKqZruraVjeOWvjg3XEwVS5Kkvn0MDwGCSsGAQQBgjcVBwQv
MC0GJSsGAQQBgjcVCIbDjHWEmeVRg/2BKIWOn1OCkcAJZ4HevTmV8EMCAWQCAQMwHwYDVR0jBBgw
FoAUCWmBM3sGc48jTAoD3/cWgRGCEwUwgckGA1UdHwSBwTCBvjCBu6CBuKCBtYZUaHR0cDovL3d3
dy5pbnRlbC5jb20vcmVwb3NpdG9yeS9DUkwvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIwSXNz
dWluZyUyMENBJTIwM0EuY3Jshl1odHRwOi8vY2VydGlmaWNhdGVzLmludGVsLmNvbS9yZXBvc2l0
b3J5L0NSTC9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBJc3N1aW5nJTIwQ0ElMjAzQS5jcmww
ge8GCCsGAQUFBwEBBIHiMIHfMGkGCCsGAQUFBzAChl1odHRwOi8vd3d3LmludGVsLmNvbS9yZXBv
c2l0b3J5L2NlcnRpZmljYXRlcy9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBJc3N1aW5nJTIw
Q0ElMjAzQS5jcnQwcgYIKwYBBQUHMAKGZmh0dHA6Ly9jZXJ0aWZpY2F0ZXMuaW50ZWwuY29tL3Jl
cG9zaXRvcnkvY2VydGlmaWNhdGVzL0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMElzc3Vpbmcl
MjBDQSUyMDNBLmNydDAfBgNVHSUEGDAWBggrBgEFBQcDBAYKKwYBBAGCNwoDDDApBgkrBgEEAYI3
FQoEHDAaMAoGCCsGAQUFBwMEMAwGCisGAQQBgjcKAwwwUQYDVR0RBEowSKAqBgorBgEEAYI3FAID
oBwMGmplc3NlLmJyYW5kZWJ1cmdAaW50ZWwuY29tgRpqZXNzZS5icmFuZGVidXJnQGludGVsLmNv
bTANBgkqhkiG9w0BAQUFAAOCAQEAJL8raLZYyz2imhvIrmSaQNhCOEzTwIXqxhlMbnPpeZUKlUym
6Tg7VaGXsqSyNQRe2eOK3gv2Et1O1ZsJwRGLC9mzKug8xeE5doO7HbbO04C8bR4B7jID2xByDJsT
f99mrprSwng4brFaW9JiSbCQyxmmApPoVXEff3lUqphiotdebDeV8y8a+s/yJCviLUinLbs4Uowf
/SXu6k+b27ue/I/QmWq01CF9wT/QMPyyAkIR+62XCGjGAZJIfsoZzCtab9/ujU7B0d7wV1Tq/koX
L21E3rOyAZ6I+7jpV0HDqY9KjPdLQu2tQ7I1u6iPORDH29STos5g/xv48jMK+RemBTCCBdIwggS6
oAMCAQICCk82OTAAAAAAFqowDQYJKoZIhvcNAQEFBQAwVjELMAkGA1UEBhMCVVMxGjAYBgNVBAoT
EUludGVsIENvcnBvcmF0aW9uMSswKQYDVQQDEyJJbnRlbCBFeHRlcm5hbCBCYXNpYyBJc3N1aW5n
IENBIDNBMB4XDTA3MDgwNzAwMzUxM1oXDTEwMDgwNjAwMzUxM1owRzEaMBgGA1UEAxMRQnJhbmRl
YnVyZywgSmVzc2UxKTAnBgkqhkiG9w0BCQEWGmplc3NlLmJyYW5kZWJ1cmdAaW50ZWwuY29tMIGf
MA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDi2zY1Qs4T/t3n7P8HqwPt42qNN+oSkatx6IEcMpQ3
F0gPolrDmw2NqF4cC77He10MCA5vCd4dyL0wPDKguH0wcntGCaYVf4EitdnTl+TGPkuAoRaUZAhc
NjmPrL2pH8HtJf/ANHQPtVuCUnPbUl12c9HPOqvVWSdXniNBUVCM9QIDAQABo4IDMzCCAy8wCwYD
VR0PBAQDAgQwMEQGCSqGSIb3DQEJDwQ3MDUwDgYIKoZIhvcNAwICAgCAMA4GCCqGSIb3DQMEAgIA
gDAHBgUrDgMCBzAKBggqhkiG9w0DBzAdBgNVHQ4EFgQUvdfuEHaw1+wbTNraFaClPaDVErUwPQYJ
KwYBBAGCNxUHBDAwLgYmKwYBBAGCNxUIhsOMdYSZ5VGD/YEohY6fU4KRwAlnhLnZQYeE/04CAWQC
AQcwHwYDVR0jBBgwFoAUCWmBM3sGc48jTAoD3/cWgRGCEwUwgckGA1UdHwSBwTCBvjCBu6CBuKCB
tYZUaHR0cDovL3d3dy5pbnRlbC5jb20vcmVwb3NpdG9yeS9DUkwvSW50ZWwlMjBFeHRlcm5hbCUy
MEJhc2ljJTIwSXNzdWluZyUyMENBJTIwM0EuY3Jshl1odHRwOi8vY2VydGlmaWNhdGVzLmludGVs
LmNvbS9yZXBvc2l0b3J5L0NSTC9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBJc3N1aW5nJTIw
Q0ElMjAzQS5jcmwwge8GCCsGAQUFBwEBBIHiMIHfMGkGCCsGAQUFBzAChl1odHRwOi8vd3d3Lmlu
dGVsLmNvbS9yZXBvc2l0b3J5L2NlcnRpZmljYXRlcy9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMl
MjBJc3N1aW5nJTIwQ0ElMjAzQS5jcnQwcgYIKwYBBQUHMAKGZmh0dHA6Ly9jZXJ0aWZpY2F0ZXMu
aW50ZWwuY29tL3JlcG9zaXRvcnkvY2VydGlmaWNhdGVzL0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNp
YyUyMElzc3VpbmclMjBDQSUyMDNBLmNydDAfBgNVHSUEGDAWBggrBgEFBQcDBAYKKwYBBAGCNwoD
BDApBgkrBgEEAYI3FQoEHDAaMAoGCCsGAQUFBwMEMAwGCisGAQQBgjcKAwQwUQYDVR0RBEowSKAq
BgorBgEEAYI3FAIDoBwMGmplc3NlLmJyYW5kZWJ1cmdAaW50ZWwuY29tgRpqZXNzZS5icmFuZGVi
dXJnQGludGVsLmNvbTANBgkqhkiG9w0BAQUFAAOCAQEAWZ7lU8JqwDbBes8ezVkGWmY91zVg87Bi
0Qxh0u9J5fIF+8KZ6tt7GX3Q8GRj0bZnX4hzFk6+wxT+25hXUb7c0ZmEIMbr8LYvOWXHghvjQja1
mkIC2eArcr42E8Bwy3BcwF+0K38UsqAkmlBzDOEf/lleIjgEamarv94UvjwFNsK6/sRCVSgOIU1T
8QeeCx0Y7Roaqjwt+66CwpIT6upnfJdSfplPXeYqatHfvAb+6evOB2EG37ejQmWEN5co8dfXD+1L
kkqlNn2YZfj4SGJeYHq0s/EmDPHzyrZohSoPgZJape03LRR7JUUtesB9nNtBuCnzMfWQw/tfL3of
ae/0MDGCAsAwggK8AgEBMGQwVjELMAkGA1UEBhMCVVMxGjAYBgNVBAoTEUludGVsIENvcnBvcmF0
aW9uMSswKQYDVQQDEyJJbnRlbCBFeHRlcm5hbCBCYXNpYyBJc3N1aW5nIENBIDNBAgpPKzsLAAAA
ABapMAkGBSsOAwIaBQCgggGyMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkF
MQ8XDTA4MTEwMzE4NDk1M1owIwYJKoZIhvcNAQkEMRYEFEhGRcJci+auCdxapvdTh0R5GKYSMGcG
CSqGSIb3DQEJDzFaMFgwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFA
MAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMAcGBSsOAwIaMAoGCCqGSIb3DQIFMHMGCSsGAQQBgjcQ
BDFmMGQwVjELMAkGA1UEBhMCVVMxGjAYBgNVBAoTEUludGVsIENvcnBvcmF0aW9uMSswKQYDVQQD
EyJJbnRlbCBFeHRlcm5hbCBCYXNpYyBJc3N1aW5nIENBIDNBAgpPNjkwAAAAABaqMHUGCyqGSIb3
DQEJEAILMWagZDBWMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9yYXRpb24xKzAp
BgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3VpbmcgQ0EgM0ECCk82OTAAAAAAFqowDQYJ
KoZIhvcNAQEBBQAEgYBo0wOlXoZEaaoeQtPQ35yJS6FeUi7l3w27lDG2fdbN6nsBOJZIe2tiMAX0
kLCcUgeKMBpf68Miv+QVfYVapGAwstBTzgarzIesV8e35dXmdzSOcbjxNa2uobY4j27Tq+vk+q2P
HlXHgPIDdibGeJo7n+VXOEDXecht6cJyIfwgXAAAAAAAAA==

------=_NextPart_000_0019_01C93DA1.E761B8E0--
