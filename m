From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [net-next 8/9] ixgbe: add interface to export thermal data
Date: Mon, 9 Jan 2012 18:08:51 +0000
Message-ID: <363B5007A0D944459CBE9CF6A37B891B01FB58@ORSMSX104.amr.corp.intel.com>
References: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1324631357-31789-9-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAHXqBFL_44T5nQVA=n03aT9Q1QpsLCY2dn9o6GE-9Rm66DSt-A@mail.gmail.com>
	 <F6FB0E698C9B3143BDF729DF22286646025656@ORSMSX102.amr.corp.intel.com>
	 <1325788584.3764.28.camel@bwh-desktop>
	 <F6FB0E698C9B3143BDF729DF22286646027184@ORSMSX102.amr.corp.intel.com>
	 <CAHXqBF+ZY-KH8hOi+QnDZVHx+8OOqP5CLXR44YtDLB3=1DDEOA@mail.gmail.com>
	 <363B5007A0D944459CBE9CF6A37B891B01E292@ORSMSX104.amr.corp.intel.com>
	 <1325873362.2850.20.camel@bwh-desktop>
	 <363B5007A0D944459CBE9CF6A37B891B01E718@ORSMSX104.amr.corp.intel.com>
 <1325874309.25896.2.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=SHA1;
	protocol="application/x-pkcs7-signature";
	boundary="----=_NextPart_000_0003_01CCCEB6.ADAEDE30"
Cc: Michal Miroslaw <mirqus@gmail.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56497 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755795Ab2AISIx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jan 2012 13:08:53 -0500
In-Reply-To: <1325874309.25896.2.camel@bwh-desktop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_NextPart_000_0003_01CCCEB6.ADAEDE30
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Ben Hutchings
> Sent: Friday, January 06, 2012 10:25 AM
> To: Waskiewicz Jr, Peter P
> Cc: Michal Miroslaw; Skidmore, Donald C; Kirsher, Jeffrey T;
> davem@davemloft.net; netdev@vger.kernel.org; gospo@redhat.com;
> sassmann@redhat.com
> Subject: RE: [net-next 8/9] ixgbe: add interface to export thermal =
data
>=20
> On Fri, 2012-01-06 at 18:20 +0000, Waskiewicz Jr, Peter P wrote:
> > > -----Original Message-----
> > > From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> > > Sent: Friday, January 06, 2012 10:09 AM
> > > To: Waskiewicz Jr, Peter P
> > > Cc: Michal Miroslaw; Skidmore, Donald C; Kirsher, Jeffrey T;
> > > davem@davemloft.net; netdev@vger.kernel.org; gospo@redhat.com;
> > > sassmann@redhat.com
> > > Subject: RE: [net-next 8/9] ixgbe: add interface to export thermal
> > > data
> > >
> > > On Fri, 2012-01-06 at 17:55 +0000, Waskiewicz Jr, Peter P wrote:
> > > > > -----Original Message-----
> > > > > From: Micha=C5=82 Miros=C5=82aw [mailto:mirqus@gmail.com]
> > > > > Sent: Thursday, January 05, 2012 3:51 PM
> > > > > To: Skidmore, Donald C
> > > > > Cc: Ben Hutchings; Kirsher, Jeffrey T; davem@davemloft.net;
> > > > > netdev@vger.kernel.org; gospo@redhat.com;
> sassmann@redhat.com;
> > > > > Waskiewicz Jr, Peter P
> > > > > Subject: Re: [net-next 8/9] ixgbe: add interface to export
> > > > > thermal data
> > > > >
> > > > > Drivers outside of drivers/hwmon just select HWMON in Kconfig.
> > > > > This adds a 3kB .c file to the kernel build for the first one =
that needs it.
> > > >
> > > > This is where we run into issues though.  We can put this
> > > > dependency in, but customers don't pull upstream kernels, they
> > > > rely on the OSV's to distribute updates.  The customer doesn't
> > > > want HWMON, and if their kernel doesn't ship with HWMON support
> for ixgbe, then we're sunk.
> > >
> > > So if !IS_ENABLED(CONFIG_HWMON), don't try to create an hwmon
> > > device, but create the attributes anyway.
> >
> > And if CONFIG_HWMON is not enabled, are we then responsible for
> > creating the hwmon area in sysfs to link in our attributes?  That
> > would make even less sense to include HWMON attributes if HWMON =
isn't
> > built in.
>=20
> No, the attributes actually appear under the parent device.

Ok, so how we have it now in the current patches.

> > > > The point is what we're trying to implement, based on what our
> customers'
> > > > requirements are, is something completely different than what
> > > > HWMON is providing.  Trying to wedge HWMON onto this framework
> > > > we're trying to provide just overcomplicates the entire thing =
we're trying
> to provide.
> > > > It's a generic interface to generic data in our drivers,
> > > [...]
> > >
> > > It sounds like you want to provide a "generic" ixgbe interface on
> > > different operating systems.  But that is not a valid argument for =
an in-
> tree driver.
> >
> > No, we're trying to provide a generic ixgbe interface on Linux
> > systems.  The reality is different OSV's pull our driver from =
upstream
> > to build their distros,
>=20
> Yes we know.
>=20
> [...]
> > The reality is these attributes of our thermal sensors are about 5% =
of
> > the data we need to export.
> [...]
>=20
> And I think all you need to do is (1) give these particular attributes =
the right
> names and (2) create a child hwmon device if possible.  Is that so =
hard?

Yes, it is.  The sensors that we have defined for this SKU are defined =
by the customers who this board was built for, so it fits with their =
BMC.  We don't have much control over the names.

Again, I'm failing to see why you are requiring us to put in this =
support when we don't benefit at all from it, we don't need it, and =
don't want it.  Perhaps you can add the HWMON support to ixgbe when you =
get around to adding the same support to your Solarflare driver that =
hasn't been completed yet?  We'd be happy to accept those patches.  =
Please don't hold us to a standard you won't hold your own driver to.

-PJ

------=_NextPart_000_0003_01CCCEB6.ADAEDE30
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIISJjCCAyAw
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
Mfr900fXZKj5XeqCJ+JP0mEhJGEdVCY+FFlksJjV86fDrq1QMIIFijCCBHKgAwIBAgIKYSCKYgAA
AAAACDANBgkqhkiG9w0BAQUFADBSMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9y
YXRpb24xJzAlBgNVBAMTHkludGVsIEV4dGVybmFsIEJhc2ljIFBvbGljeSBDQTAeFw0wOTA1MTUx
OTI3MjZaFw0xNTA1MTUxOTM3MjZaMFYxCzAJBgNVBAYTAlVTMRowGAYDVQQKExFJbnRlbCBDb3Jw
b3JhdGlvbjErMCkGA1UEAxMiSW50ZWwgRXh0ZXJuYWwgQmFzaWMgSXNzdWluZyBDQSAzQjCCASIw
DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKQEM1Wn9TU9vc9C+/Tc7KB+eiYElmrcEWE32WUd
HvWG+IcQHVQsikTmMyKKojNLw2B5s6Iekc8ivDo/wCfjZzX9JyftMnc+AArc0la87Olybzm8K9jX
EfTBvTnUSFSiI9ZYefITdiUgqlAFuljFZEHYKYtLuhrRacpmQfP4mV63NKdc2bT804HRf6YptZFa
4k6YN94zlrGNrBuQQ74WFzz/jLBusbUpEkro6Mu/ZYFOFWQrV9lBhF9Ruk8yN+3N6n9fUo/qBigi
F2kEn9xVh1ykl7SCGL2jBUkXx4qgV27a6Si8lRRdgrHGtN/HWnSWlLXTH5l575H4Lq++77OFv38C
AwEAAaOCAlwwggJYMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFA7GKvdZsggQkCVvw939imYx
MCvFMAsGA1UdDwQEAwIBhjASBgkrBgEEAYI3FQEEBQIDAQABMCMGCSsGAQQBgjcVAgQWBBQ5oFY2
ekKQ/5Ktim+VdMeSWb4QWTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAfBgNVHSMEGDAWgBQa
xgxKxEdvqNutK/D0Vgaj7TdUDDCBvQYDVR0fBIG1MIGyMIGvoIGsoIGphk5odHRwOi8vd3d3Lmlu
dGVsLmNvbS9yZXBvc2l0b3J5L0NSTC9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBQb2xpY3kl
MjBDQS5jcmyGV2h0dHA6Ly9jZXJ0aWZpY2F0ZXMuaW50ZWwuY29tL3JlcG9zaXRvcnkvQ1JML0lu
dGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMFBvbGljeSUyMENBLmNybDCB4wYIKwYBBQUHAQEEgdYw
gdMwYwYIKwYBBQUHMAKGV2h0dHA6Ly93d3cuaW50ZWwuY29tL3JlcG9zaXRvcnkvY2VydGlmaWNh
dGVzL0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMFBvbGljeSUyMENBLmNydDBsBggrBgEFBQcw
AoZgaHR0cDovL2NlcnRpZmljYXRlcy5pbnRlbC5jb20vcmVwb3NpdG9yeS9jZXJ0aWZpY2F0ZXMv
SW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIwUG9saWN5JTIwQ0EuY3J0MA0GCSqGSIb3DQEBBQUA
A4IBAQCxtQEHchVQhXyjEqtMVUMe6gkmPsIczHxSeqNbo9dsD+6xbT65JT+oYgpIAtfEsYXeUJu1
cChqpb22U5bMAz7eaQcW5bzefufWvA6lg2048B8oczBj/q+5P5NpYrUO8jOmN4jTjfJq3ElZ7yFW
py7rB3Vm/aN6ATYqWfMbS/xfh+JCxmH3droUmMJI0/aZJHsLtjbjFnNsHDNrJZX1vxlM78Lb1hjs
kTENPmhbVbfTj5i/ZGnhv4tmI8QZPCNtcegXJrfhRl2D9bWpdTOPrWiLDUqzy1Z6KL7TcOS/PCl8
RHCJXkPau/thTQCpIoDa2+c+3XA++gRTfAQ4svTO260NMIIGLzCCBRegAwIBAgIKf0es/QABAABR
FTANBgkqhkiG9w0BAQUFADBWMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9yYXRp
b24xKzApBgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3VpbmcgQ0EgM0IwHhcNMTAwNDA5
MDgyNzMwWhcNMTMwMzI0MDgyNzMwWjBRMR8wHQYDVQQDExZXYXNraWV3aWN6IEpyLCBQZXRlciBQ
MS4wLAYJKoZIhvcNAQkBFh9wZXRlci5wLndhc2tpZXdpY3ouanJAaW50ZWwuY29tMIIBIjANBgkq
hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxNvzDG+qS7UFSaYiqMqQr7exXHirCVe1tapLZoFlJZLP
fqZsBsAAUqARnY+v3RQj3WDmoIOtTMHxtnmo4pd5UXrsk+PraedGAilso9tkfp5ZjRjZo9LL06AZ
zjiBVfAxgvyxMPsoKhdfFijzqSJRpc12kB662PAJWfyJO+f6lg5+Cd4KgRVGrpGI4bvBKEVGMeOq
wD+kcVtiwRcqNygx35GqdcpJCCJqOSAJsLI3DR7tDvATeNzsasweaHgWonaK4D6qaHkoGx4VHknC
6uNn/FK/wXtFbXkeOrnRGJIzaZNsOBVhTou9w3NYU1EjuK75hZJ4Fd4/r1gHafxWD+VzrwIDAQAB
o4IDAjCCAv4wCwYDVR0PBAQDAgeAMDwGCSsGAQQBgjcVBwQvMC0GJSsGAQQBgjcVCIbDjHWEmeVR
g/2BKIWOn1OCkcAJZ4HevTmV8EMCAWQCAQgwHQYDVR0OBBYEFLtB44dRTSgY1071RY+nMiKRkn1P
MB8GA1UdIwQYMBaAFA7GKvdZsggQkCVvw939imYxMCvFMIHPBgNVHR8EgccwgcQwgcGggb6ggbuG
V2h0dHA6Ly93d3cuaW50ZWwuY29tL3JlcG9zaXRvcnkvQ1JML0ludGVsJTIwRXh0ZXJuYWwlMjBC
YXNpYyUyMElzc3VpbmclMjBDQSUyMDNCKDEpLmNybIZgaHR0cDovL2NlcnRpZmljYXRlcy5pbnRl
bC5jb20vcmVwb3NpdG9yeS9DUkwvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIwSXNzdWluZyUy
MENBJTIwM0IoMSkuY3JsMIH1BggrBgEFBQcBAQSB6DCB5TBsBggrBgEFBQcwAoZgaHR0cDovL3d3
dy5pbnRlbC5jb20vcmVwb3NpdG9yeS9jZXJ0aWZpY2F0ZXMvSW50ZWwlMjBFeHRlcm5hbCUyMEJh
c2ljJTIwSXNzdWluZyUyMENBJTIwM0IoMSkuY3J0MHUGCCsGAQUFBzAChmlodHRwOi8vY2VydGlm
aWNhdGVzLmludGVsLmNvbS9yZXBvc2l0b3J5L2NlcnRpZmljYXRlcy9JbnRlbCUyMEV4dGVybmFs
JTIwQmFzaWMlMjBJc3N1aW5nJTIwQ0ElMjAzQigxKS5jcnQwHwYDVR0lBBgwFgYIKwYBBQUHAwQG
CisGAQQBgjcKAwwwKQYJKwYBBAGCNxUKBBwwGjAKBggrBgEFBQcDBDAMBgorBgEEAYI3CgMMMFsG
A1UdEQRUMFKgLwYKKwYBBAGCNxQCA6AhDB9wZXRlci5wLndhc2tpZXdpY3ouanJAaW50ZWwuY29t
gR9wZXRlci5wLndhc2tpZXdpY3ouanJAaW50ZWwuY29tMA0GCSqGSIb3DQEBBQUAA4IBAQBYea1K
ThIl9gNf1uIob1trWtsthhWAXsdUu1V+gl10RBChuM4okZccJf1JXItFA2z7J2UR4cu/tRZBRFar
tVPhGBjKntLofxsaW7wwzfsinbNy30gHGShG83XDADdGUteL8PmupDcDf/MtbRIlfjEknLiuOnrM
25WVajtB3fB1pOA2jmLaaNmasza9ordaD3afJD3IWr/Zj+aevMu4zrKzwdOZqBZW1J1Qc7uog8Mn
+mm+wRMmEY0z7VFdjsZjJH9EQA0UbF1aYcshv0a/M2deKN9TdYuJ1eTKRSZdzSiRG5w75xujFMYZ
go4ETlu1Behgey1jvJiyWdOsPt7at08QMYICLDCCAigCAQEwZDBWMQswCQYDVQQGEwJVUzEaMBgG
A1UEChMRSW50ZWwgQ29ycG9yYXRpb24xKzApBgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElz
c3VpbmcgQ0EgM0ICCn9HrP0AAQAAURUwCQYFKw4DAhoFAKCBnjAYBgkqhkiG9w0BCQMxCwYJKoZI
hvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xMjAxMDkxODA4NDhaMCMGCSqGSIb3DQEJBDEWBBQDfu41
vqUu6B77mYVnatyBbM/GeDA/BgkqhkiG9w0BCQ8xMjAwMAcGBSsOAwIaMAsGCWCGSAFlAwQCAzAL
BglghkgBZQMEAgIwCwYJYIZIAWUDBAIBMA0GCSqGSIb3DQEBAQUABIIBAJnfXJud+7rHyshwjnZT
dHWZCjZmKZMInRjSnCTw3qRZqU41V+QP7PlS9Abj1XpzlQ25pMUmq+4nXyi/n9B3k2727ELtXsdD
Vg+FLGI4QZ5TRHzYfeyxFg73u5upSU3Lt5xxMxuY1EU/ALZ8jmvH45v920KKCjqHt84imZbcOc/Q
jJ8NiqlWuJIu6CoW22iL9PdhovzaevvCZeNCYUjeMeytDxuX+vwm1j/WNnsX499dDBrHqBuFVuDW
c183cHp202ge0527FQZB/Zaesm3klcms2gWMxWslk14sYuX8QduvlquUebDuR8QgG9Vxx9TLbATw
/jS8I7ivsPoMXA6LaJ0AAAAAAAA=

------=_NextPart_000_0003_01CCCEB6.ADAEDE30--
