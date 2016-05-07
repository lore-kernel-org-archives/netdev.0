From: Kevin Darbyshire-Bryant <kevin@darbyshire-bryant.me.uk>
Subject: Re: OpenWRT wrong adjustment of fq_codel defaults (Was: [Codel]
 fq_codel_drop vs a udp flood)
Date: Sat, 7 May 2016 10:57:53 +0100
Message-ID: <572DBC21.10209@darbyshire-bryant.me.uk>
References: <CAA93jw6QLyx9EaS+ntB0D3duoysu_Z-UYyQfHnRa=pfqPDfWOw@mail.gmail.com>
 <1462125592.5535.194.camel@edumazet-glaptop3.roam.corp.google.com>
 <865DA393-262D-40B6-A9D3-1B978CD5F6C6@gmail.com>
 <1462128385.5535.200.camel@edumazet-glaptop3.roam.corp.google.com>
 <C5D365DA-18EE-446E-9D25-41F48B1C583E@gmail.com>
 <1462136140.5535.219.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACiydbKUu11=zWitkDha0ddgk1-G_Z4-e1+=9ky776VktF5HHg@mail.gmail.com>
 <1462201620.5535.250.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACiydbKeKUENncrc-NmYRcku-DGVeGqqzYMqsCqKdxPsR7yUOQ@mail.gmail.com>
 <1462205669.5535.254.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACiydbL26Jj3EcEL4EmqaH=1Dm-Q0dpVwoWxqUSZ7ry10bRgeg@mail.gmail.com>
 <1462464776.13075.18.camel@edumazet-glaptop3.roam.corp.google.com>
 <CACiydbJYrFRMJvSHM6tJYWR8vmgV3xxnSUQsb-h5WcnLW=KXoQ@mail.gmail.com>
 <1462476207.13075.20.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160506114243.4eb4f95e@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0883436651636243535=="
Cc: make-wifi-fast@lists.bufferbloat.net, zajec5@gmail.com,
 ath10k <ath10k@lists.infradead.org>,
 "codel@lists.bufferbloat.net" <codel@lists.bufferbloat.net>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Jonathan Morton <chromatix99@gmail.com>,
 Roman Yeryomin <leroi.lists@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet
 <eric.dumazet@gmail.com>, Felix Fietkau <nbd@openwrt.org>, Dave Taht
 <dave.taht@gmail.com>
Return-path: <ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org>
In-Reply-To: <20160506114243.4eb4f95e@redhat.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/ath10k/>
List-Post: <mailto:ath10k@lists.infradead.org>
List-Help: <mailto:ath10k-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=subscribe>
Sender: "ath10k" <ath10k-bounces@lists.infradead.org>
Errors-To: ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

--===============0883436651636243535==
Content-Type: multipart/signed; protocol="application/pkcs7-signature";
	micalg=sha-512; boundary="------------ms020109070209090704010907"

--------------ms020109070209090704010907
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable



On 06/05/16 10:42, Jesper Dangaard Brouer wrote:
> Hi Felix,
>
> This is an important fix for OpenWRT, please read!
>
> OpenWRT changed the default fq_codel sch->limit from 10240 to 1024,
> without also adjusting q->flows_cnt.  Eric explains below that you must=

> also adjust the buckets (q->flows_cnt) for this not to break. (Just
> adjust it to 128)
>
> Problematic OpenWRT commit in question:
>  http://git.openwrt.org/?p=3Dopenwrt.git;a=3Dpatch;h=3D12cd6578084e
>  12cd6578084e ("kernel: revert fq_codel quantum override to prevent it =
from causing too much cpu load with higher speed (#21326)")
I 'pull requested' this to the lede-staging tree on github.
https://github.com/lede-project/staging/pull/11

One way or another Felix & co should see the change :-)
>
>
> I also highly recommend you cherry-pick this very recent commit:
>  net-next: 9d18562a2278 ("fq_codel: add batch ability to fq_codel_drop(=
)")
>  https://git.kernel.org/davem/net-next/c/9d18562a227
>
> This should fix very high CPU usage in-case fq_codel goes into drop mod=
e.
> The problem is that drop mode was considered rare, and implementation
> wise it was chosen to be more expensive (to save cycles on normal mode)=
=2E
> Unfortunately is it easy to trigger with an UDP flood. Drop mode is
> especially expensive for smaller devices, as it scans a 4K big array,
> thus 64 cache misses for small devices!
>
> The fix is to allow drop-mode to bulk-drop more packets when entering
> drop-mode (default 64 bulk drop).  That way we don't suddenly
> experience a significantly higher processing cost per packet, but
> instead can amortize this.
I haven't done the above cherry-pick patch & backport patch creation for
4.4/4.1/3.18 yet - maybe if $dayjob permits time and no one else beats
me to it :-)

Kevin


--------------ms020109070209090704010907
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExDzANBglghkgBZQMEAgMFADCABgkqhkiG9w0BBwEAAKCC
DYEwggY0MIIEHKADAgECAgEeMA0GCSqGSIb3DQEBBQUAMH0xCzAJBgNVBAYTAklMMRYwFAYD
VQQKEw1TdGFydENvbSBMdGQuMSswKQYDVQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0aWZpY2F0
ZSBTaWduaW5nMSkwJwYDVQQDEyBTdGFydENvbSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTAe
Fw0wNzEwMjQyMTAxNTVaFw0xNzEwMjQyMTAxNTVaMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UE
ChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUg
U2lnbmluZzE4MDYGA1UEAxMvU3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IEludGVybWVkaWF0
ZSBDbGllbnQgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDHCYPMzi3YGrEp
pC4Tq5a+ijKDjKaIQZZVR63UbxIP6uq/I0fhCu+cQhoUfE6ERKKnu8zPf1Jwuk0tsvVCk6U9
b+0UjM0dLep3ZdE1gblK/1FwYT5Pipsu2yOMluLqwvsuz9/9f1+1PKHG/FaR/wpbfuIqu54q
zHDYeqiUfsYzoVflR80DAC7hmJ+SmZnNTWyUGHJbBpA8Q89lGxahNvuryGaC/o2/ceD2uYDX
9U8Eg5DpIpGQdcbQeGarV04WgAUjjXX5r/2dabmtxWMZwhZna//jdiSyrrSMTGKkDiXm6/3/
4ebfeZuCYKzN2P8O2F/Xe2AC/Y7zeEsnR7FOp+uXAgMBAAGjggGtMIIBqTAPBgNVHRMBAf8E
BTADAQH/MA4GA1UdDwEB/wQEAwIBBjAdBgNVHQ4EFgQUU3Ltkpzg2ssBXHx+ljVO8tS4UYIw
HwYDVR0jBBgwFoAUTgvvGqRAW6UXaYcwyjRoQ9BBrvIwZgYIKwYBBQUHAQEEWjBYMCcGCCsG
AQUFBzABhhtodHRwOi8vb2NzcC5zdGFydHNzbC5jb20vY2EwLQYIKwYBBQUHMAKGIWh0dHA6
Ly93d3cuc3RhcnRzc2wuY29tL3Nmc2NhLmNydDBbBgNVHR8EVDBSMCegJaAjhiFodHRwOi8v
d3d3LnN0YXJ0c3NsLmNvbS9zZnNjYS5jcmwwJ6AloCOGIWh0dHA6Ly9jcmwuc3RhcnRzc2wu
Y29tL3Nmc2NhLmNybDCBgAYDVR0gBHkwdzB1BgsrBgEEAYG1NwECATBmMC4GCCsGAQUFBwIB
FiJodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS9wb2xpY3kucGRmMDQGCCsGAQUFBwIBFihodHRw
Oi8vd3d3LnN0YXJ0c3NsLmNvbS9pbnRlcm1lZGlhdGUucGRmMA0GCSqGSIb3DQEBBQUAA4IC
AQAKgwh9eKssBly4Y4xerhy5I3dNoXHYfYa8PlVLL/qtXnkFgdtY1o95CfegFJTwqBBmf8py
TUnFsukDFUI22zF5bVHzuJ+GxhnSqN2sD1qetbYwBYK2iyYA5Pg7Er1A+hKMIzEzcduRkIMm
CeUTyMyikfbUFvIBivtvkR8ZFAk22BZy+pJfAoedO61HTz4qSfQoCRcLN5A0t4DkuVhTMXIz
uQ8CnykhExD6x4e6ebIbrjZLb7L+ocR0y4YjCl/Pd4MXU91y0vTipgr/O75CDUHDRHCCKBVm
z/Rzkc/b970MEeHt5LC3NiWTgBSvrLEuVzBKM586YoRD9Dy3OHQgWI270g+5MYA8GfgI/EPT
5G7xPbCDz+zjdH89PeR3U4So4lSXur6H6vp+m9TQXPF3a0LwZrp8MQ+Z77U1uL7TelWO5lAp
sbAonrqASfTpaprFVkL4nyGH+NHST2ZJPWIBk81i6Vw0ny0qZW2Niy/QvVNKbb43A43ny076
khXO7cNbBIRdJ/6qQNq9Bqb5C0Q5nEsFcj75oxQRqlKf6TcvGbjxkJh8BYtv9ePsXklAxtm8
J7GCUBthHSQgepbkOexhJ0wP8imUkyiPHQ0GvEnd83129fZjoEhdGwXV27ioRKbj/cIq7JRX
un0NbeY+UdMYu9jGfIpDLtUUGSgsg2zMGs5R4jCCB0UwggYtoAMCAQICAw5ySjANBgkqhkiG
9w0BAQsFADCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzApBgNV
BAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNVBAMTL1N0YXJ0
Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENBMB4XDTE1MDYyMDIw
MzA1MloXDTE2MDYyMDE0MjY0N1owVjEmMCQGA1UEAwwda2V2aW5AZGFyYnlzaGlyZS1icnlh
bnQubWUudWsxLDAqBgkqhkiG9w0BCQEWHWtldmluQGRhcmJ5c2hpcmUtYnJ5YW50Lm1lLnVr
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAugCNtDhytCJ9HOfenUHr/vUGUECv
PL1IJXgHMl4cIJmwgLOkXhIcTMxHnX+kFweqvT+eDWv1hzA9yMWhvjLFC4eLoFaV0xiAat8O
XQ7t3MwKY5DW0mB1dOnjiFIcc/XMwyYI4KfEGnFMJQkzon0rDVpkl/Q1f/hu1sELO7Zc6TFL
wuuDuiP7S73zrz50TRoq0+Ob3x0uOMW2uVwVzf6NLwHgBE2LFleMXblyUMx0IlIcLan2nWiI
Vsa3XYd+C6KAGGwlmO4VAZ25KuX7hkj8f82lSapvtKTtvrSoDghXlHH2JXiIQX+Sn0UgOmbX
1KyOe9vN7WzQ+tpPRzpFRffnnnp1VQye3wVRPBumjDxQSFTOhUtslnvbefUQSPw6p5w9ZiXI
GJICLkX/MkYN/TwGCvuUG2PxBybSR1A2I5ap+VI/zGSG3XGVEA69SOZQyD+8YjJZfaY2nCu+
DuM64JrJUi2CvX6fwcdHNschJNrrfetpnrx3JrGnG9o+pWuUG1phBg+KKN2bhrdzY79qm7ha
86EMKSUOn5nBdGY3YxdXq/naoUQeOCUV2JMFGOulu7sKpiWcz7HVFacXjd9ebisVLv+jOwll
z14BWRb87s1+LBEJn/Ybn3ekhtgyEAhB4kgj0scl4hI8xCU6zrZyDnbXmxSvDXbClZA0PACt
f/jhGvUCAwEAAaOCAuMwggLfMAkGA1UdEwQCMAAwCwYDVR0PBAQDAgSwMB0GA1UdJQQWMBQG
CCsGAQUFBwMCBggrBgEFBQcDBDAdBgNVHQ4EFgQULkW2CpDiQpRNumQ7wdspjFfgX+AwHwYD
VR0jBBgwFoAUU3Ltkpzg2ssBXHx+ljVO8tS4UYIwKAYDVR0RBCEwH4Eda2V2aW5AZGFyYnlz
aGlyZS1icnlhbnQubWUudWswggFMBgNVHSAEggFDMIIBPzCCATsGCysGAQQBgbU3AQIDMIIB
KjAuBggrBgEFBQcCARYiaHR0cDovL3d3dy5zdGFydHNzbC5jb20vcG9saWN5LnBkZjCB9wYI
KwYBBQUHAgIwgeowJxYgU3RhcnRDb20gQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwAwIBARqB
vlRoaXMgY2VydGlmaWNhdGUgd2FzIGlzc3VlZCBhY2NvcmRpbmcgdG8gdGhlIENsYXNzIDEg
VmFsaWRhdGlvbiByZXF1aXJlbWVudHMgb2YgdGhlIFN0YXJ0Q29tIENBIHBvbGljeSwgcmVs
aWFuY2Ugb25seSBmb3IgdGhlIGludGVuZGVkIHB1cnBvc2UgaW4gY29tcGxpYW5jZSBvZiB0
aGUgcmVseWluZyBwYXJ0eSBvYmxpZ2F0aW9ucy4wNgYDVR0fBC8wLTAroCmgJ4YlaHR0cDov
L2NybC5zdGFydHNzbC5jb20vY3J0dTEtY3JsLmNybDCBjgYIKwYBBQUHAQEEgYEwfzA5Bggr
BgEFBQcwAYYtaHR0cDovL29jc3Auc3RhcnRzc2wuY29tL3N1Yi9jbGFzczEvY2xpZW50L2Nh
MEIGCCsGAQUFBzAChjZodHRwOi8vYWlhLnN0YXJ0c3NsLmNvbS9jZXJ0cy9zdWIuY2xhc3Mx
LmNsaWVudC5jYS5jcnQwIwYDVR0SBBwwGoYYaHR0cDovL3d3dy5zdGFydHNzbC5jb20vMA0G
CSqGSIb3DQEBCwUAA4IBAQBicQWe98eF/o09TXFsExc+WSyYjt3oSnXyocLzXQp82CQhIg21
5RqNZ1e+hsO7tq8S6hdItUDbKpecpIV59+57ke1zVl2slTRIT19fhYINHH78rVVRPzuHoiDt
MXnGrp9hbq3Cz8P4mm8INKDiYK46kyplRAQ3ZMouPG1lsnDzgQAvbCj74H8yAp7fK8if6cxs
28BCUmdP8D3c6M1ffdNNaqNT+4Z3mtOujXXg7zOfmXN0Zg/mEtZ0NrWE2uICGdWjTv9KZiI7
fi4hk2CRpCL63qzmu6BwtcgtwhgYYtuAk2N43+SiyDkyLKGAcjEor3t5f9HivN29E0F0MXTH
1OdgMYIFDTCCBQkCAQEwgZQwgYwxCzAJBgNVBAYTAklMMRYwFAYDVQQKEw1TdGFydENvbSBM
dGQuMSswKQYDVQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0aWZpY2F0ZSBTaWduaW5nMTgwNgYD
VQQDEy9TdGFydENvbSBDbGFzcyAxIFByaW1hcnkgSW50ZXJtZWRpYXRlIENsaWVudCBDQQID
DnJKMA0GCWCGSAFlAwQCAwUAoIICSTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqG
SIb3DQEJBTEPFw0xNjA1MDcwOTU3NTNaME8GCSqGSIb3DQEJBDFCBEBU5o6vDj4fefbyFFSd
1gsexnK4SVXKompbtsGvF+LVKuIvcVf93ai79vjdTa18z5YdKJx4KK1FYdE3i7cTNjdIMGwG
CSqGSIb3DQEJDzFfMF0wCwYJYIZIAWUDBAEqMAsGCWCGSAFlAwQBAjAKBggqhkiG9w0DBzAO
BggqhkiG9w0DAgICAIAwDQYIKoZIhvcNAwICAUAwBwYFKw4DAgcwDQYIKoZIhvcNAwICASgw
gaUGCSsGAQQBgjcQBDGBlzCBlDCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29t
IEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxODA2
BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENB
AgMOckowgacGCyqGSIb3DQEJEAILMYGXoIGUMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UEChMN
U3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2ln
bmluZzE4MDYGA1UEAxMvU3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IEludGVybWVkaWF0ZSBD
bGllbnQgQ0ECAw5ySjANBgkqhkiG9w0BAQEFAASCAgBYN7e5svY3TQN3sNfiKuObDrZMpfCD
X6Q7qIaNKSucniKFn4G2hQg9XJBojk8pVEf3dQD85yYBY68uBON+iLn15Mb2UKaLiwU2TUX5
a6LNKOGWlPL/SR0fwtSU4E6yHg/ZP2YGDqbo3fCDSNm/FxEzrtGSOVmU3mOxQc0OT67/P3RP
GOgaUAldW0efaN5gEfNOXD9EraoltDUZPnMHSBma9nwmPcnO6+hXfB6KqlUHGUJyQiJoMYmb
foBjv1UjWpdk/prHmIajrazD8c+mxeyx+EHxDJfc1eHwFqq6X3jeVelnNhxMvMzV1UNlCCGX
VtENOcobSJXzHiR6i2wzfH726X3gHbhuIL5CUz3U7tmCuHTFFVb/gssJFn1dpiq0WmIaAt83
YzzY2J+mSxXeDhR1zSFuBvbgfnD2trDcIRW+4N6DSvJCT96rOiKtviSDKHojOTHb5lxitMBk
JzB0Jn5lPQWEAK7jI0zBuigFr22M9AFmawZttfqcUoXRQ9df6EOAphmILWafJNm6ugh55VZP
coZDGZBDXaBubAW1RKStCvX8hMDNwOqbejFqAp3yWrc6QMY9kGD2/Ecrjgr2uY/Qe6oXjN1c
EUCfGZl+BBpHcOmblWiibgbVqSXijuvsUJnPDzyf/g1dyQo4BtqYSUKUJeWtYL9B5XQM8xTj
i3NkLQAAAAAAAA==
--------------ms020109070209090704010907--


--===============0883436651636243535==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
ath10k mailing list
ath10k@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/ath10k

--===============0883436651636243535==--
