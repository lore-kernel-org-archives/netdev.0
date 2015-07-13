From: Austin S Hemmelgarn <ahferroin7@gmail.com>
Subject: Re: [PATCH v2] add stealth mode
Date: Mon, 13 Jul 2015 09:03:56 -0400
Message-ID: <55A3B73C.4090507@gmail.com>
References: <CAFnufp059tojfKYBye4eayOCvNNkAE9w_s_6E-PiG-EYp9K0Gg@mail.gmail.com> <21611.1436179798@turing-police.cc.vt.edu> <CAFnufp3xP3xjd8zy0uLKEGgbBAb0motLva=f1EbMJCfcKG=Y-w@mail.gmail.com> <559D2688.5020302@gmail.com> <CAFnufp1_JAutAm7LZsQXXPspipUy4n2C9K3Li+jsWzNpgqYBJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha1; boundary="------------ms030102080309040605010705"
Cc: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Matteo Croce <matteo@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFnufp1_JAutAm7LZsQXXPspipUy4n2C9K3Li+jsWzNpgqYBJw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a cryptographically signed message in MIME format.

--------------ms030102080309040605010705
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: quoted-printable

On 2015-07-12 19:13, Matteo Croce wrote:
> 2015-07-08 15:32 GMT+02:00 Austin S Hemmelgarn <ahferroin7@gmail.com>:
>> On 2015-07-06 15:44, Matteo Croce wrote:
>> Just to name a few that I know of off the top of my head:
>> 1. IP packets with any protocol number not supported by your current k=
ernel
>> (these return a special ICMP message).
>
> Right, I'll handle them
>
>> 2. SCTP INIT and COOKIE_ECHO chunks when you have SCTP enabled in the
>> kernel.
>
> Well, I've never played with SCTP before
It should still be checked, as should DCCP and RDS (those are the only=20
other Layer 3 protocols that I have ever actually seen people try to=20
scan hosts with besides TCP/UDP/SCTP).  SCTP itself is not hugely=20
prevalent outside of some clustering uses, but it is still seen on the=20
internet sometimes (for example, Gentoo has optional patches for OpenSSH =

to use SCTP).
>
>> 3. Theoretically, some IGMP messages.
>> 4. NDP messages.
>> 5. ARP queries looking for the machine's IP addresses.
>
> Yes I know, but it's unlikely to receive this packets from WAN, right?
> My flag is intended to be used mostly on WAN interfaces,
> machines in LAN should be easily discoverable IMHO.
In theory it's unlikely, but if you use any kind of IPv4 multicast on=20
the WAN you will get IGMP (and MLD for IPv6 multicast).  You may also=20
get some NDP queries also if you are using IPv6 and your WAN is itself=20
behind a NAT router (and yes, there are ISP's who do that).
>
>> 6. Certain odd flag combinations on single TCP packets (check the
>> documentation for Nmap for more info regarding these), which I believe=

>> (although I may be reading the code wrong) you aren't accounting for.
>
> I've tried many TCP flags combination with hping3, NUL, SYN/ACK, ACK,
> SYN/FIN, etc.
> They doesn't get any response when the flag is set
How about FIN/ACK and FIN/PSH/URG?
>
>> 7. DAD queries.
>
> Never looked at this packets, are a subset of NDP?
Kind of, it's an ICMPv6 extension for detecting if SLACC configured=20
address is already in use.  Most distro's have support for it enabled by =

default.
>> 8. ICMP address mask queries (which you also don't appear to account f=
or).
>
> It's deprecated and actually it doesn't get any response already
Just because it's deprecated doesn't mean you shouldn't account for it,=20
although it does appear to get dropped by default by the kernel.

You should also test how different combinations of sysctls under=20
/proc/sys/net affect this (there are for example already sysctls for=20
ignoring certain types of ICMP packets).


--------------ms030102080309040605010705
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIGuDCC
BrQwggScoAMCAQICAxBuVTANBgkqhkiG9w0BAQ0FADB5MRAwDgYDVQQKEwdSb290IENBMR4w
HAYDVQQLExVodHRwOi8vd3d3LmNhY2VydC5vcmcxIjAgBgNVBAMTGUNBIENlcnQgU2lnbmlu
ZyBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEWEnN1cHBvcnRAY2FjZXJ0Lm9yZzAeFw0xNTAz
MjUxOTM0MzhaFw0xNTA5MjExOTM0MzhaMGMxGDAWBgNVBAMTD0NBY2VydCBXb1QgVXNlcjEj
MCEGCSqGSIb3DQEJARYUYWhmZXJyb2luN0BnbWFpbC5jb20xIjAgBgkqhkiG9w0BCQEWE2Fo
ZW1tZWxnQG9oaW9ndC5jb20wggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCdD/zW
2rRAFCLnDfXpWxU1+ODqRVUgzHvrRO7ADUxRo1CBDc3JSX5TIW2OGmQ3DAKGOACp8Z0sgxMc
B05tzAZ/M7m4jajVrwwdVCdrwVGxTdAai7Kwg4ZCVfyMVhcwo8R2eW3QahBx34G0RKumK9sZ
ZQSQ+zULAzpY6uz7T1sAk/erMoivRXF6u8WvOsLkOD1F/Xyv1ZccSUG5YeDgZgc0nZUBvyIp
zXSHjgWerFkrxEM3y2z/Ff3eL1sgGYecV/I1F+I5S01V7Kclt/qRW10c/4JEGRcI1FmrJBPu
BtMYPbg/3Y9LZROYN+mVIFxZxOfrmjfFZ96xt/TaMXo8vcEKtWcNEjhGBjEbfMUEm4aq8ygQ
4MuEcpJc8DJCHBkg2KBk13DkbU2qNepTD6Uip1C+g+KMr0nd6KOJqSH27ZuNY4xqV4hIxFHp
ex0zY7mq6fV2o6sKBGQzRdI20FDYmNjsLJwjH6qJ8laxFphZnPRpBThmu0AjuBWE72GnI1oA
aO+bs92MQGJernt7hByCnDO82W/ykbVz+Ge3Sax8NY0m2Xdvp6WFDY/PjD9CdaJ9nwQGsUSa
N54lrZ2qMTeCI9Vauwf6U69BA42xgk65VvxvTNqji+tZ4aZbarZ7el2/QDHOb/rRwlCFplS/
z4l1f1nOrE6bnDl5RBJyW3zi74P6GwIDAQABo4IBWTCCAVUwDAYDVR0TAQH/BAIwADBWBglg
hkgBhvhCAQ0ESRZHVG8gZ2V0IHlvdXIgb3duIGNlcnRpZmljYXRlIGZvciBGUkVFIGhlYWQg
b3ZlciB0byBodHRwOi8vd3d3LkNBY2VydC5vcmcwDgYDVR0PAQH/BAQDAgOoMEAGA1UdJQQ5
MDcGCCsGAQUFBwMEBggrBgEFBQcDAgYKKwYBBAGCNwoDBAYKKwYBBAGCNwoDAwYJYIZIAYb4
QgQBMDIGCCsGAQUFBwEBBCYwJDAiBggrBgEFBQcwAYYWaHR0cDovL29jc3AuY2FjZXJ0Lm9y
ZzAxBgNVHR8EKjAoMCagJKAihiBodHRwOi8vY3JsLmNhY2VydC5vcmcvcmV2b2tlLmNybDA0
BgNVHREELTArgRRhaGZlcnJvaW43QGdtYWlsLmNvbYETYWhlbW1lbGdAb2hpb2d0LmNvbTAN
BgkqhkiG9w0BAQ0FAAOCAgEAGvl7xb42JMRH5D/vCIDYvFY3dR2FPd5kmOqpKU/fvQ8ovmJa
p5N/FDrsCL+YdslxPY+AAn78PYmL5pFHTdRadT++07DPIMtQyy2qd+XRmz6zP8Il7vGcEDmO
WmMLYMq4xV9s/N7t7JJp6ftdIYUcoTVChUgilDaRWMLidtslCdRsBVfUjPb1bF5Ua31diKDP
e0M9/e2CU36rbcTtiNCXhptMigzuL3zJXUf2B9jyUV8pnqNEQH36fqJ7YTBLcpq3aYa2XbAH
Hgx9GehJBIqwspDmhPCFZ/QmqUXCkt+XfvinQ2NzKR6P3+OdYbwqzVX8BdMeojh7Ig8x/nIx
mQ+/ufstL1ZYp0bg13fyK/hPYSIBpayaC76vzWovkIm70DIDRIFLi20p/qTd7rfDYy831Hjm
+lDdCECF9bIXEWFk33kA97dgQIMbf5chEmlFg8S0e4iw7LMjvRqMX3eCD8GJ2+oqyZUwzZxy
S0Mx+rBld5rrN7LsXwZ671HsGqNeYbYeU25e7t7/Gcc6Bd/kPfA+adEuUGFcvUKH3trDYqNq
6mOkAd8WO/mQadlc3ztS++XDMhmIpfBre9MPAr6usqf+wc+R8Nk9KLK39kEgrqVfzc/fgf8L
MaD4rHnusdg4gca6Yi+kNrm99anw7SwaBrBvULYBp7ixNRUhaYiNW4YjTrYxggShMIIEnQIB
ATCBgDB5MRAwDgYDVQQKEwdSb290IENBMR4wHAYDVQQLExVodHRwOi8vd3d3LmNhY2VydC5v
cmcxIjAgBgNVBAMTGUNBIENlcnQgU2lnbmluZyBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEW
EnN1cHBvcnRAY2FjZXJ0Lm9yZwIDEG5VMAkGBSsOAwIaBQCgggH1MBgGCSqGSIb3DQEJAzEL
BgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE1MDcxMzEzMDM1NlowIwYJKoZIhvcNAQkE
MRYEFNuwdWisZD7FAma6giYH/qJ1dwbnMGwGCSqGSIb3DQEJDzFfMF0wCwYJYIZIAWUDBAEq
MAsGCWCGSAFlAwQBAjAKBggqhkiG9w0DBzAOBggqhkiG9w0DAgICAIAwDQYIKoZIhvcNAwIC
AUAwBwYFKw4DAgcwDQYIKoZIhvcNAwICASgwgZEGCSsGAQQBgjcQBDGBgzCBgDB5MRAwDgYD
VQQKEwdSb290IENBMR4wHAYDVQQLExVodHRwOi8vd3d3LmNhY2VydC5vcmcxIjAgBgNVBAMT
GUNBIENlcnQgU2lnbmluZyBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEWEnN1cHBvcnRAY2Fj
ZXJ0Lm9yZwIDEG5VMIGTBgsqhkiG9w0BCRACCzGBg6CBgDB5MRAwDgYDVQQKEwdSb290IENB
MR4wHAYDVQQLExVodHRwOi8vd3d3LmNhY2VydC5vcmcxIjAgBgNVBAMTGUNBIENlcnQgU2ln
bmluZyBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEWEnN1cHBvcnRAY2FjZXJ0Lm9yZwIDEG5V
MA0GCSqGSIb3DQEBAQUABIICAI6Dh+XVKDtfzZWoxnV9+zkXsGyWMQgqXTB6WYGFXuvbRHu+
u+KoKDX3I0zJP4Idt/YXRXTS6SAiG8oV5fjZ2Q3le0NpeN6Twgp/5Av9vaZyHDBLwD1U8l+p
1HYjD5p69Ij18iU9UZal6X5DO/G+e+NGfP/vLP6DjOGfwAFKsbei+1O2AldZdxYlS7lIRgNB
1ItJTXp1EjcCZiIWSvv/rF/G2rVWrtcrTvtIiZG34ogvRaf4HRq3lFd1nttiNEcqYBgwutiH
qneWamur7eGzlITdotFUMd7MM1CCR9ZU4+tDUtJhsiG9qbHRRdC8OMme7xShJhbXshRdInDN
qme2IbZamGXIOf+r2WAixmSkohNyeV7v2gJHG4YewuZKOVpU5za4bKmz1Uvtd7sZmLxZlDgT
hFl5nJbFaeiT8HNolLmWx0LEb8CU1XR9SjjrFjk+qSMHXBWVRkQmFB+cf+z9wP6M6fv4EVf4
2240CpAordmg/SKyHoK+WKg8q9U+wpUvUWOiorFRgNAFEiWvItj70+xyDdVCPxoi7uVw4n/X
D5Vmy6AnCDq5oghUWDu1aWiXBhFmsMizQ8hSRkcB/eXJNqlBnVxmWKYYUwCE+YkDyxg7cS/I
niketahhHK3KHzGOelGpQOwQ5+nNcdBOEBqu2UAgbrvUm6FnSh7/Dzr4mEz2AAAAAAAA
--------------ms030102080309040605010705--
