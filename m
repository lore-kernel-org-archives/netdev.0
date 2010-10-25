From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH v2 10/14] ixgbe: Update ixgbe to use new vlan
 accleration.
Date: Mon, 25 Oct 2010 10:50:09 -0700
Message-ID: <1288029009.1808.1.camel@pjaxe>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
	 <1287618974-4714-11-git-send-email-jesse@nicira.com>
	 <AANLkTindxJD1a5UPV+6vWbDEeMUTy1QgPs1X8pT-b69D@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha1"; protocol="application/x-pkcs7-signature"; boundary="=-IPK8BFyxmn7Pk9vlqLeL"
Cc: Jesse Gross <jesse@nicira.com>, David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47633 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752048Ab0JYRmQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Oct 2010 13:42:16 -0400
In-Reply-To: <AANLkTindxJD1a5UPV+6vWbDEeMUTy1QgPs1X8pT-b69D@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-IPK8BFyxmn7Pk9vlqLeL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2010-10-22 at 06:24 -0700, Micha=C5=82 Miros=C5=82aw wrote:
> 2010/10/21 Jesse Gross <jesse@nicira.com>:
> > Make the ixgbe driver use the new vlan accleration model.
> [...]
> > --- a/drivers/net/ixgbe/ixgbe_main.c
> > +++ b/drivers/net/ixgbe/ixgbe_main.c
> > @@ -954,17 +954,13 @@ static void ixgbe_receive_skb(struct ixgbe_q_vect=
or *q_vector,
> >        bool is_vlan =3D (status & IXGBE_RXD_STAT_VP);
> >        u16 tag =3D le16_to_cpu(rx_desc->wb.upper.vlan);
> >
> > -       if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL)) {
> > -               if (adapter->vlgrp && is_vlan && (tag & VLAN_VID_MASK))
> > -                       vlan_gro_receive(napi, adapter->vlgrp, tag, skb=
);
> > -               else
> > -                       napi_gro_receive(napi, skb);
> > -       } else {
> > -               if (adapter->vlgrp && is_vlan && (tag & VLAN_VID_MASK))
> > -                       vlan_hwaccel_rx(skb, adapter->vlgrp, tag);
> > -               else
> > -                       netif_rx(skb);
> > -       }
> > +       if (is_vlan && (tag & VLAN_VID_MASK))
> > +               __vlan_hwaccel_put_tag(skb, tag);
>=20
> I know that this is carried over from the driver, but why tag =3D=3D 0 is
> treated differently here? VID0 is somewhat special, as normally it
> means 802.1p packet, but i.e. in embedded world people are using it as
> normal VID. It would be nice to have this handled consistently in the
> VLAN core - deliver to base dev (tag stripped) if vlan 0 is not
> configured and to vlan dev if it is.

ixgbe handles VLAN 0 differently because that's the tag that's used when
DCB is enabled, and no VLAN is configured.  We have to insert the 802.1p
tag for DCB to work, but the OS won't know about the 802.1q tag, and
ends up dropping the frame.  So we enable VLAN ID 0 in the HW and tell
it to strip the tag, so we can still pass the frame up the stack.

>=20
> > +
> > +       if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
> > +               napi_gro_receive(napi, skb);
> > +       else
> > +               netif_rx(skb);
> >  }
> >
> >  /**
>=20
> Best Regards,
> Micha=C5=82 Miros=C5=82aw

--=20
-----------------------------------------------------------
Peter P Waskiewicz Jr                   LAN Access Division
peter.p.waskiewicz.jr@intel.com         Intel Corp.

--=-IPK8BFyxmn7Pk9vlqLeL
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIPAjCCAz0w
ggKmoAMCAQICAwWw/zANBgkqhkiG9w0BAQUFADBOMQswCQYDVQQGEwJVUzEQMA4GA1UEChMHRXF1
aWZheDEtMCsGA1UECxMkRXF1aWZheCBTZWN1cmUgQ2VydGlmaWNhdGUgQXV0aG9yaXR5MB4XDTA2
MDIxNjE4MDEzMFoXDTE2MDIxOTE4MDEzMFowUjELMAkGA1UEBhMCVVMxGjAYBgNVBAoTEUludGVs
IENvcnBvcmF0aW9uMScwJQYDVQQDEx5JbnRlbCBFeHRlcm5hbCBCYXNpYyBQb2xpY3kgQ0EwggEi
MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDBpd/XOb9QVqEZ8mQ1042TdOIq3ATDIsV2xDyt
30yLyMR5Wjtus0bn3B+he89BiNO/LP6+rFzEwlD55PlX+HLGIKeNNG97dqyc30FElEUjZzTZFq2N
4e3kVJ/XAEEgANzV8v9qp7qWwxugPgfc3z9BkYot+CifozexHLb/hEZj+yISCU61kRZvuSQ0E11y
YL4dRgcglJeaHo3oX57rvIckaLsYV5/1Aj+R8DM1Ppk965XQAKsHfnyT7C4S50T4lVn4lz36wOdN
Zn/zegG1zp41lnoTFfT4KuKVJH5x7YD1p6KbgJCKLovnujGuohquBNfdXKpZkvz6pGv+iC1HawJd
AgMBAAGjgaAwgZ0wDgYDVR0PAQH/BAQDAgEGMB0GA1UdDgQWBBQaxgxKxEdvqNutK/D0Vgaj7TdU
DDA6BgNVHR8EMzAxMC+gLaArhilodHRwOi8vY3JsLmdlb3RydXN0LmNvbS9jcmxzL3NlY3VyZWNh
LmNybDAfBgNVHSMEGDAWgBRI5mj5K9KylddH2CMgEE8zmJCf1DAPBgNVHRMBAf8EBTADAQH/MA0G
CSqGSIb3DQEBBQUAA4GBABMQOK2kVKVIlUWwLTdywJ+e2O+PC/uQltK2F3lRyrPfBn69tOkIP4Sg
DJOfsxyobIrPLe75kBLw+Dom13OBDp/EMZJZ1CglQfVV8co9mT3aZMjSGGQiMgkJLR3jMfr900fX
ZKj5XeqCJ+JP0mEhJGEdVCY+FFlksJjV86fDrq1QMIIFijCCBHKgAwIBAgIKYSCKYgAAAAAACDAN
BgkqhkiG9w0BAQUFADBSMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9yYXRpb24x
JzAlBgNVBAMTHkludGVsIEV4dGVybmFsIEJhc2ljIFBvbGljeSBDQTAeFw0wOTA1MTUxOTI3MjZa
Fw0xNTA1MTUxOTM3MjZaMFYxCzAJBgNVBAYTAlVTMRowGAYDVQQKExFJbnRlbCBDb3Jwb3JhdGlv
bjErMCkGA1UEAxMiSW50ZWwgRXh0ZXJuYWwgQmFzaWMgSXNzdWluZyBDQSAzQjCCASIwDQYJKoZI
hvcNAQEBBQADggEPADCCAQoCggEBAKQEM1Wn9TU9vc9C+/Tc7KB+eiYElmrcEWE32WUdHvWG+IcQ
HVQsikTmMyKKojNLw2B5s6Iekc8ivDo/wCfjZzX9JyftMnc+AArc0la87Olybzm8K9jXEfTBvTnU
SFSiI9ZYefITdiUgqlAFuljFZEHYKYtLuhrRacpmQfP4mV63NKdc2bT804HRf6YptZFa4k6YN94z
lrGNrBuQQ74WFzz/jLBusbUpEkro6Mu/ZYFOFWQrV9lBhF9Ruk8yN+3N6n9fUo/qBigiF2kEn9xV
h1ykl7SCGL2jBUkXx4qgV27a6Si8lRRdgrHGtN/HWnSWlLXTH5l575H4Lq++77OFv38CAwEAAaOC
AlwwggJYMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFA7GKvdZsggQkCVvw939imYxMCvFMAsG
A1UdDwQEAwIBhjASBgkrBgEEAYI3FQEEBQIDAQABMCMGCSsGAQQBgjcVAgQWBBQ5oFY2ekKQ/5Kt
im+VdMeSWb4QWTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAfBgNVHSMEGDAWgBQaxgxKxEdv
qNutK/D0Vgaj7TdUDDCBvQYDVR0fBIG1MIGyMIGvoIGsoIGphk5odHRwOi8vd3d3LmludGVsLmNv
bS9yZXBvc2l0b3J5L0NSTC9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBQb2xpY3klMjBDQS5j
cmyGV2h0dHA6Ly9jZXJ0aWZpY2F0ZXMuaW50ZWwuY29tL3JlcG9zaXRvcnkvQ1JML0ludGVsJTIw
RXh0ZXJuYWwlMjBCYXNpYyUyMFBvbGljeSUyMENBLmNybDCB4wYIKwYBBQUHAQEEgdYwgdMwYwYI
KwYBBQUHMAKGV2h0dHA6Ly93d3cuaW50ZWwuY29tL3JlcG9zaXRvcnkvY2VydGlmaWNhdGVzL0lu
dGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMFBvbGljeSUyMENBLmNydDBsBggrBgEFBQcwAoZgaHR0
cDovL2NlcnRpZmljYXRlcy5pbnRlbC5jb20vcmVwb3NpdG9yeS9jZXJ0aWZpY2F0ZXMvSW50ZWwl
MjBFeHRlcm5hbCUyMEJhc2ljJTIwUG9saWN5JTIwQ0EuY3J0MA0GCSqGSIb3DQEBBQUAA4IBAQCx
tQEHchVQhXyjEqtMVUMe6gkmPsIczHxSeqNbo9dsD+6xbT65JT+oYgpIAtfEsYXeUJu1cChqpb22
U5bMAz7eaQcW5bzefufWvA6lg2048B8oczBj/q+5P5NpYrUO8jOmN4jTjfJq3ElZ7yFWpy7rB3Vm
/aN6ATYqWfMbS/xfh+JCxmH3droUmMJI0/aZJHsLtjbjFnNsHDNrJZX1vxlM78Lb1hjskTENPmhb
VbfTj5i/ZGnhv4tmI8QZPCNtcegXJrfhRl2D9bWpdTOPrWiLDUqzy1Z6KL7TcOS/PCl8RHCJXkPa
u/thTQCpIoDa2+c+3XA++gRTfAQ4svTO260NMIIGLzCCBRegAwIBAgIKf0es/QABAABRFTANBgkq
hkiG9w0BAQUFADBWMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9yYXRpb24xKzAp
BgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3VpbmcgQ0EgM0IwHhcNMTAwNDA5MDgyNzMw
WhcNMTMwMzI0MDgyNzMwWjBRMR8wHQYDVQQDExZXYXNraWV3aWN6IEpyLCBQZXRlciBQMS4wLAYJ
KoZIhvcNAQkBFh9wZXRlci5wLndhc2tpZXdpY3ouanJAaW50ZWwuY29tMIIBIjANBgkqhkiG9w0B
AQEFAAOCAQ8AMIIBCgKCAQEAxNvzDG+qS7UFSaYiqMqQr7exXHirCVe1tapLZoFlJZLPfqZsBsAA
UqARnY+v3RQj3WDmoIOtTMHxtnmo4pd5UXrsk+PraedGAilso9tkfp5ZjRjZo9LL06AZzjiBVfAx
gvyxMPsoKhdfFijzqSJRpc12kB662PAJWfyJO+f6lg5+Cd4KgRVGrpGI4bvBKEVGMeOqwD+kcVti
wRcqNygx35GqdcpJCCJqOSAJsLI3DR7tDvATeNzsasweaHgWonaK4D6qaHkoGx4VHknC6uNn/FK/
wXtFbXkeOrnRGJIzaZNsOBVhTou9w3NYU1EjuK75hZJ4Fd4/r1gHafxWD+VzrwIDAQABo4IDAjCC
Av4wCwYDVR0PBAQDAgeAMDwGCSsGAQQBgjcVBwQvMC0GJSsGAQQBgjcVCIbDjHWEmeVRg/2BKIWO
n1OCkcAJZ4HevTmV8EMCAWQCAQgwHQYDVR0OBBYEFLtB44dRTSgY1071RY+nMiKRkn1PMB8GA1Ud
IwQYMBaAFA7GKvdZsggQkCVvw939imYxMCvFMIHPBgNVHR8EgccwgcQwgcGggb6ggbuGV2h0dHA6
Ly93d3cuaW50ZWwuY29tL3JlcG9zaXRvcnkvQ1JML0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUy
MElzc3VpbmclMjBDQSUyMDNCKDEpLmNybIZgaHR0cDovL2NlcnRpZmljYXRlcy5pbnRlbC5jb20v
cmVwb3NpdG9yeS9DUkwvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIwSXNzdWluZyUyMENBJTIw
M0IoMSkuY3JsMIH1BggrBgEFBQcBAQSB6DCB5TBsBggrBgEFBQcwAoZgaHR0cDovL3d3dy5pbnRl
bC5jb20vcmVwb3NpdG9yeS9jZXJ0aWZpY2F0ZXMvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIw
SXNzdWluZyUyMENBJTIwM0IoMSkuY3J0MHUGCCsGAQUFBzAChmlodHRwOi8vY2VydGlmaWNhdGVz
LmludGVsLmNvbS9yZXBvc2l0b3J5L2NlcnRpZmljYXRlcy9JbnRlbCUyMEV4dGVybmFsJTIwQmFz
aWMlMjBJc3N1aW5nJTIwQ0ElMjAzQigxKS5jcnQwHwYDVR0lBBgwFgYIKwYBBQUHAwQGCisGAQQB
gjcKAwwwKQYJKwYBBAGCNxUKBBwwGjAKBggrBgEFBQcDBDAMBgorBgEEAYI3CgMMMFsGA1UdEQRU
MFKgLwYKKwYBBAGCNxQCA6AhDB9wZXRlci5wLndhc2tpZXdpY3ouanJAaW50ZWwuY29tgR9wZXRl
ci5wLndhc2tpZXdpY3ouanJAaW50ZWwuY29tMA0GCSqGSIb3DQEBBQUAA4IBAQBYea1KThIl9gNf
1uIob1trWtsthhWAXsdUu1V+gl10RBChuM4okZccJf1JXItFA2z7J2UR4cu/tRZBRFartVPhGBjK
ntLofxsaW7wwzfsinbNy30gHGShG83XDADdGUteL8PmupDcDf/MtbRIlfjEknLiuOnrM25WVajtB
3fB1pOA2jmLaaNmasza9ordaD3afJD3IWr/Zj+aevMu4zrKzwdOZqBZW1J1Qc7uog8Mn+mm+wRMm
EY0z7VFdjsZjJH9EQA0UbF1aYcshv0a/M2deKN9TdYuJ1eTKRSZdzSiRG5w75xujFMYZgo4ETlu1
Behgey1jvJiyWdOsPt7at08QMYIB6jCCAeYCAQEwZDBWMQswCQYDVQQGEwJVUzEaMBgGA1UEChMR
SW50ZWwgQ29ycG9yYXRpb24xKzApBgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3Vpbmcg
Q0EgM0ICCn9HrP0AAQAAURUwCQYFKw4DAhoFAKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEw
HAYJKoZIhvcNAQkFMQ8XDTEwMTAyNTE3NTAwNVowIwYJKoZIhvcNAQkEMRYEFPUAC5GcoCRJqelQ
5SwTWx9WHusaMA0GCSqGSIb3DQEBAQUABIIBAKzW5RGafQSUUdkm8Ds/fq65h5oBgUsTpHifKNRi
lPgXwKC8bgQrK9yWX1R20nXNeFjBN4R5jhjTPjogr4CcOVmJn4m2+vqPey2IgKVAv+4+4cYzXp9S
nR4iy2PvEw+ihh4DsfjGxSY7aLrPYKgBxoi1BozEHSdshat4BkWFdDxCrgVAMejmsp60sSWMhJyu
frRaUmSx6446q+uNYWpvFEaUpVHpo/Lndgd7+DBBtjpjDshC+nO82GRJ3chrrWhyhs6/tytJlF1J
IYa12olk1n15izHECSsrO65Ym/LjLuP97JDd1cq90287yL0M3EPTCoOVs5aZOgrzz7UkQuHP/joA
AAAAAAA=


--=-IPK8BFyxmn7Pk9vlqLeL--

