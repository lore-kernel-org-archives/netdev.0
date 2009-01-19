From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [PATCH] e1000e: introduce new parameter to disable
 force-link-up on serdes
Date: Mon, 19 Jan 2009 11:06:46 -0800
Message-ID: <F169D4F5E1F1974DBFAFABF47F60C10A19FC55EE@orsmsx507.amr.corp.intel.com>
References: <20090119194210ohashi-h@mail.jp.nec.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/x-pkcs7-signature";
	micalg=SHA1; boundary="----=_NextPart_000_0008_01C97A26.04E17480"
Cc: "Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"jgarzik@pobox.com" <jgarzik@pobox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"h-shimamoto@ct.jp.nec.com" <h-shimamoto@ct.jp.nec.com>,
	"Graham, David" <david.graham@intel.com>
To: "ohashi-h@mb.dnes.nec.co.jp" <ohashi-h@mb.dnes.nec.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:46867 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753023AbZASTGs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2009 14:06:48 -0500
In-Reply-To: <20090119194210ohashi-h@mail.jp.nec.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_NextPart_000_0008_01C97A26.04E17480
Content-Type: multipart/mixed;
	boundary="----=_NextPart_001_0009_01C97A26.04E17480"


------=_NextPart_001_0009_01C97A26.04E17480
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit

ohashi-h@mb.dnes.nec.co.jp wrote:
>>>> Also the Link LED is supposed to indicated that there is a
>>>> "physical" link, in which case you can have a physical connection
>>>> and still fail auto-neg.  So I do not necessarily agree with your
>>>> interpretation of what a link LED is supposed to indicate.
>>> 
>>> My explanation was insufficiently.
>>> My system was NOT connected LAN cable to NIC, but the Link LED
>>> was indicated.
>>> So the problem is the LED is indicated without connecting the cable.
>>> 
>> 
>> I tried again using kernel 2.6.27.8 (e1000e driver).
>> The LED of NIC was indicated, even when the system was not
>> connected LAN cable.
>> When I deleted logic of force-link-up (the following modification.),
>> the LED was turned off.
>> 
>> I think it is a problem that LED indicates.
>> If you have any good way to modify, please let me know.
>> (Patches are considering.)
> 
> I send the patch to modify.

I appreciate your work on this issue but I think you're making the wrong
solution.  We've done some work on a similar issue, does the attached
patch fix the issue for you?

inline also, but (probably) whitespace damaged.


Author: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date:   Mon Jan 19 11:04:11 2009 -0800

    e1000e: do not force link on blades
    
    e1000 originally had a workaround to force link up based
    on some hardware errata on ancient parts.  The e1000e driver
    has carried over this workaround even though it doesn't support
    the same hardware.
    
    letting rx sequence errors drive link up/down events is harming the
logic of
    the state machines that control link state on blade connected e1000e
parts.
    
    remove rx sequence errors from causing link events.
    
    Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 91817d0..55b2f6b 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1152,7 +1152,7 @@ static irqreturn_t e1000_intr_msi(int irq, void
*data)
 	 * read ICR disables interrupts using IAM
 	 */
 
-	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
+	if (icr & E1000_ICR_LSC) {
 		hw->mac.get_link_status = 1;
 		/*
 		 * ICH8 workaround-- Call gig speed drop workaround on
cable
@@ -1218,7 +1218,7 @@ static irqreturn_t e1000_intr(int irq, void *data)
 	 * IMC write
 	 */
 
-	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
+	if (icr & E1000_ICR_LSC) {
 		hw->mac.get_link_status = 1;
 		/*
 		 * ICH8 workaround-- Call gig speed drop workaround on
cable

------=_NextPart_001_0009_01C97A26.04E17480
Content-Type: application/octet-stream;
	name="e1000e_rxseq.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="e1000e_rxseq.patch"

commit 9ed41efac25a68e7daa1312c0a9a322d2b6a282d=0A=
Author: Jesse Brandeburg <jesse.brandeburg@intel.com>=0A=
Date:   Mon Jan 19 11:04:11 2009 -0800=0A=
=0A=
    e1000e: do not force link on blades=0A=
    =0A=
    e1000 originally had a workaround to force link up based=0A=
    on some hardware errata on ancient parts.  The e1000e driver=0A=
    has carried over this workaround even though it doesn't support=0A=
    the same hardware.=0A=
    =0A=
    letting rx sequence errors drive link up/down events is harming the =
logic of=0A=
    the state machines that control link state on blade connected e1000e =
parts.=0A=
    =0A=
    remove rx sequence errors from causing link events.=0A=
    =0A=
    Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>=0A=
=0A=
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c=0A=
index 91817d0..55b2f6b 100644=0A=
--- a/drivers/net/e1000e/netdev.c=0A=
+++ b/drivers/net/e1000e/netdev.c=0A=
@@ -1152,7 +1152,7 @@ static irqreturn_t e1000_intr_msi(int irq, void =
*data)=0A=
 	 * read ICR disables interrupts using IAM=0A=
 	 */=0A=
 =0A=
-	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {=0A=
+	if (icr & E1000_ICR_LSC) {=0A=
 		hw->mac.get_link_status =3D 1;=0A=
 		/*=0A=
 		 * ICH8 workaround-- Call gig speed drop workaround on cable=0A=
@@ -1218,7 +1218,7 @@ static irqreturn_t e1000_intr(int irq, void *data)=0A=
 	 * IMC write=0A=
 	 */=0A=
 =0A=
-	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {=0A=
+	if (icr & E1000_ICR_LSC) {=0A=
 		hw->mac.get_link_status =3D 1;=0A=
 		/*=0A=
 		 * ICH8 workaround-- Call gig speed drop workaround on cable=0A=

------=_NextPart_001_0009_01C97A26.04E17480--

------=_NextPart_000_0008_01C97A26.04E17480
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
MQ8XDTA5MDExOTE5MDY0NlowIwYJKoZIhvcNAQkEMRYEFNvz14NRtWk8IVbzpBpDawYAcgGyMGcG
CSqGSIb3DQEJDzFaMFgwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFA
MAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMAcGBSsOAwIaMAoGCCqGSIb3DQIFMHMGCSsGAQQBgjcQ
BDFmMGQwVjELMAkGA1UEBhMCVVMxGjAYBgNVBAoTEUludGVsIENvcnBvcmF0aW9uMSswKQYDVQQD
EyJJbnRlbCBFeHRlcm5hbCBCYXNpYyBJc3N1aW5nIENBIDNBAgpPNjkwAAAAABaqMHUGCyqGSIb3
DQEJEAILMWagZDBWMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9yYXRpb24xKzAp
BgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3VpbmcgQ0EgM0ECCk82OTAAAAAAFqowDQYJ
KoZIhvcNAQEBBQAEgYB8A1Gygl4zRPVrJKFLzQjbAQckSCx5A3Hpq7Lk7t6QHTEIvN2RSQgq3wlV
8jJ3Ke4KDLXryC/7O01GrU/gpMaBfdpNofta5MDd3Rp2lcK1wNLVCCKd3yEiZ+ROfZjIH8xlJAIb
NkbqM8DWRlKvZPwkolUzBx/8XONPovsoAn6OagAAAAAAAA==

------=_NextPart_000_0008_01C97A26.04E17480--
