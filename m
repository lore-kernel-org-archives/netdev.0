From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: Re: [RFC] NET: PHY: adds driver for Lantiq PHY11G
Date: Sun, 22 May 2016 22:36:38 +0200
Message-ID: <57421856.90506@hauke-m.de>
References: <1463945631-29273-1-git-send-email-hauke@hauke-m.de>
 <574216F8.7070300@kresin.me>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-256; boundary="------------ms060301090605060901020707"
Cc: alexander.stein@systec-electronic.com, netdev@vger.kernel.org,
	andrew@lunn.ch, john@phrozen.org, openwrt@kresin.me,
	hauke.mehrtens@intel.com
To: Mathias Kresin <m@kresin.me>, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from hauke-m.de ([5.39.93.123]:51601 "EHLO hauke-m.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752557AbcEVUgm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 May 2016 16:36:42 -0400
In-Reply-To: <574216F8.7070300@kresin.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms060301090605060901020707
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable

On 05/22/2016 10:30 PM, Mathias Kresin wrote:
> Hi Hauke,
>=20
> find my comments in-line.
>=20
> Am 22.05.2016 um 21:33 schrieb Hauke Mehrtens:
>> Supports the Lantiq / Intel CHD 11G and 22E PHYs.
>> These PHYs are also named PEF 7061, PEF 7071, PEF 7072
>>
>> Signed-off-by: John Crispin <john@phrozen.org>
>> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
>> ---
>>
>> This is based on a driver from OpenWrt / LEDE. This is send as a RFC
>> because the merge window is open now and it adds a new driver. This
>> patch was cleaned up on request of Alexander.
>>
>>
>>   .../devicetree/bindings/phy/phy-lanitq.txt         | 216
>> +++++++++++++++++
>=20
> Looks like a typo in the filename. lantiq !=3D lanitq

Thanks for spotting this, I just copied it from OpenWrt. ;-)

>=20
>>   drivers/net/phy/Kconfig                            |   6 +
>>   drivers/net/phy/Makefile                           |   1 +
>>   drivers/net/phy/lantiq.c                           | 269
>> +++++++++++++++++++++
>>   4 files changed, 492 insertions(+)
>>   create mode 100644 Documentation/devicetree/bindings/phy/phy-lanitq.=
txt
>>   create mode 100644 drivers/net/phy/lantiq.c
>>
>> diff --git a/Documentation/devicetree/bindings/phy/phy-lanitq.txt
>> b/Documentation/devicetree/bindings/phy/phy-lanitq.txt
>> new file mode 100644
>> index 0000000..d9746e8
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/phy/phy-lanitq.txt
>> @@ -0,0 +1,216 @@
>> +Lanitq PHY binding
>=20
> Same typo as mentioned above.
>=20

Will change this too.

=2E....

>> +
>> +static void lantiq_gphy_of_reg_init(struct phy_device *phydev)
>> +{
>> +    struct device_node *node =3D phydev->mdio.dev.of_node;
>> +    u32 tmp;
>> +
>> +    if (!IS_ENABLED(CONFIG_OF_MDIO))
>> +        return;
>> +
>> +    /* store the led values if one was passed by the device tree */
>> +    if (!of_property_read_u32(node, "lantiq,ledch", &tmp))
>> +        phy_write_mmd_indirect(phydev, 0x1e0, MDIO_MMD_VEND2, tmp);
>> +
>> +    if (!of_property_read_u32(node, "lantiq,ledcl", &tmp))
>> +        phy_write_mmd_indirect(phydev, 0x1e1, MDIO_MMD_VEND2, tmp);
>> +
>> +    if (!of_property_read_u32(node, "lantiq,led0h", &tmp))
>> +        phy_write_mmd_indirect(phydev, 0x1e2, MDIO_MMD_VEND2, tmp);
>> +
>> +    if (!of_property_read_u32(node, "lantiq,led0l", &tmp))
>> +        phy_write_mmd_indirect(phydev, 0x1e3, MDIO_MMD_VEND2, tmp);
>> +
>> +    if (!of_property_read_u32(node, "lantiq,led1h", &tmp))
>> +        phy_write_mmd_indirect(phydev, 0x1e4, MDIO_MMD_VEND2, tmp);
>> +
>> +    if (!of_property_read_u32(node, "lantiq,led1l", &tmp))
>> +        phy_write_mmd_indirect(phydev, 0x1e5, MDIO_MMD_VEND2, tmp);
>> +
>> +    if (!of_property_read_u32(node, "lantiq,led2h", &tmp))
>> +        phy_write_mmd_indirect(phydev, 0x1e6, MDIO_MMD_VEND2, tmp);
>> +
>> +    if (!of_property_read_u32(node, "lantiq,led2l", &tmp))
>> +        phy_write_mmd_indirect(phydev, 0x1e7, MDIO_MMD_VEND2, tmp);
>> +
>> +    /* The LED3 is only available in PEF 7072 package. */
>> +    if (!of_property_read_u32(node, "lantiq,led3h", &tmp))
>> +        phy_write_mmd_indirect(phydev, 0x1e8, MDIO_MMD_VEND2, tmp);
>> +
>> +    if (!of_property_read_u32(node, "lantiq,led3l", &tmp))
>> +        phy_write_mmd_indirect(phydev, 0x1e9, MDIO_MMD_VEND2, tmp);
>> +}
>> +
>> +static int lantiq_gphy_config_init(struct phy_device *phydev)
>> +{
>> +    int err;
>> +
>> +    /* Mask all interrupts */
>> +    err =3D phy_write(phydev, MII_VR9_11G_IMASK, 0);
>> +    if (err)
>> +        return err;
>> +
>> +    /* Clear all pending interrupts */
>> +    phy_read(phydev, MII_VR9_11G_ISTAT);
>> +
>> +    phy_write_mmd_indirect(phydev, 0x1e0, MDIO_MMD_VEND2, 0xc5);
>> +    phy_write_mmd_indirect(phydev, 0x1e1, MDIO_MMD_VEND2, 0x67);
>=20
> Any specific reason why the complex functions are enabled by default?

This is the same configuration the vendor SDK uses.

>> +    phy_write_mmd_indirect(phydev, 0x1e2, MDIO_MMD_VEND2, 0x42);
>> +    phy_write_mmd_indirect(phydev, 0x1e3, MDIO_MMD_VEND2, 0x10);
>> +    phy_write_mmd_indirect(phydev, 0x1e4, MDIO_MMD_VEND2, 0x70);
>> +    phy_write_mmd_indirect(phydev, 0x1e5, MDIO_MMD_VEND2, 0x03);
>> +    phy_write_mmd_indirect(phydev, 0x1e6, MDIO_MMD_VEND2, 0x20);
>> +    phy_write_mmd_indirect(phydev, 0x1e7, MDIO_MMD_VEND2, 0x00);
>> +    phy_write_mmd_indirect(phydev, 0x1e8, MDIO_MMD_VEND2, 0x40);
>> +    phy_write_mmd_indirect(phydev, 0x1e9, MDIO_MMD_VEND2, 0x20);
>=20
> I would suggest to use the same blink/permanent on configuration for al=
l
> led pins (as it is in LEDE/OpenWrt):
>=20
>     Constant On: 10/100/1000MBit
>     Blink Fast: None
>     Blink Slow: None
>     Pulse: TX/RX
>=20
> I'm aware of only one CPE that uses more than one led for status
> indication. All other have a single led attached to any of the pins.
>=20
> This way it's only required to change the default configuration via the=

> device tree bindings for the minority of the devices.

Ok, I am not aware on how all the boards are looking like. If most of
the boards only use on led it makes sense to make that the default, I
will change that.

=2E....

Hauke


--------------ms060301090605060901020707
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExDzANBglghkgBZQMEAgEFADCABgkqhkiG9w0BBwEAAKCC
DFowggYeMIIFBqADAgECAgMQVQswDQYJKoZIhvcNAQEFBQAwgYwxCzAJBgNVBAYTAklMMRYw
FAYDVQQKEw1TdGFydENvbSBMdGQuMSswKQYDVQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0aWZp
Y2F0ZSBTaWduaW5nMTgwNgYDVQQDEy9TdGFydENvbSBDbGFzcyAxIFByaW1hcnkgSW50ZXJt
ZWRpYXRlIENsaWVudCBDQTAeFw0xNTEyMDcxNjEyNTdaFw0xNjEyMDcwMTQzMzNaMDwxGTAX
BgNVBAMMEGhhdWtlQGhhdWtlLW0uZGUxHzAdBgkqhkiG9w0BCQEWEGhhdWtlQGhhdWtlLW0u
ZGUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDMrIKMLvG/uXJyWD39cPGJqjUd
QZIMocGMoOlXGLhn3ajwMQBe4mEsNHVMBM5IybM6bothUe/LLN18YHsXkS3Z/yLOV2kTtT7M
DUq89bEHVabcfU6Gz1V9PcJhu7v+wgm5BPHduWNBQTaDUEc0+ewFXlvRSQtM/9pjosrQTJ/F
HoAPp6PnL+l9/rzKH7antvGEdbPpaaAbH/dqH7m7P2r8P2nFyV6L2KgdozYo4Seck1ZBt81f
2ajr1SC5iOnw3eQRSLUeW4c56jdNSOybkQ0+5qRQ/apLEr3v9kzDyboLpnDmOLggcrkuTWxc
cv3qDvHqVgh+cbow+uhC7qyl14axAgMBAAGjggLWMIIC0jAJBgNVHRMEAjAAMAsGA1UdDwQE
AwIEsDAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUHAwQwHQYDVR0OBBYEFJ+boaq6nlyw
I9VWrCrokHD13g2+MB8GA1UdIwQYMBaAFFNy7ZKc4NrLAVx8fpY1TvLUuFGCMBsGA1UdEQQU
MBKBEGhhdWtlQGhhdWtlLW0uZGUwggFMBgNVHSAEggFDMIIBPzCCATsGCysGAQQBgbU3AQID
MIIBKjAuBggrBgEFBQcCARYiaHR0cDovL3d3dy5zdGFydHNzbC5jb20vcG9saWN5LnBkZjCB
9wYIKwYBBQUHAgIwgeowJxYgU3RhcnRDb20gQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwAwIB
ARqBvlRoaXMgY2VydGlmaWNhdGUgd2FzIGlzc3VlZCBhY2NvcmRpbmcgdG8gdGhlIENsYXNz
IDEgVmFsaWRhdGlvbiByZXF1aXJlbWVudHMgb2YgdGhlIFN0YXJ0Q29tIENBIHBvbGljeSwg
cmVsaWFuY2Ugb25seSBmb3IgdGhlIGludGVuZGVkIHB1cnBvc2UgaW4gY29tcGxpYW5jZSBv
ZiB0aGUgcmVseWluZyBwYXJ0eSBvYmxpZ2F0aW9ucy4wNgYDVR0fBC8wLTAroCmgJ4YlaHR0
cDovL2NybC5zdGFydHNzbC5jb20vY3J0dTEtY3JsLmNybDCBjgYIKwYBBQUHAQEEgYEwfzA5
BggrBgEFBQcwAYYtaHR0cDovL29jc3Auc3RhcnRzc2wuY29tL3N1Yi9jbGFzczEvY2xpZW50
L2NhMEIGCCsGAQUFBzAChjZodHRwOi8vYWlhLnN0YXJ0c3NsLmNvbS9jZXJ0cy9zdWIuY2xh
c3MxLmNsaWVudC5jYS5jcnQwIwYDVR0SBBwwGoYYaHR0cDovL3d3dy5zdGFydHNzbC5jb20v
MA0GCSqGSIb3DQEBBQUAA4IBAQB7P2kN1rYG0IvS2usRos3080OF9+kqQovZ7sFRBPJUilxn
tLBbszAtGWZOyfGOMfVaqv38sZCOkAQ5KvZj+v0Dht6cHeqtBUnJPdCcsFQgL5VCn9carSWp
eXd7yFLck3ACGtqxd62av9giqr+F92cjsPO2HkZXCQToQF10wXhBZvdT0AzX0Qm6fRGLYkFx
xHxSdP17ekw6OkL9btCJr081myLOJSJZsaNq5c+hpfFck2Fp7mALYsQSMupFKdSXTqCEpyBH
27rZi/aT+HsylVgT09vKfOTH33kGOYkkFBTFkBK/DP95N03T8gtWVHygveHGg/B/PS4D68GI
CN+8sU9nMIIGNDCCBBygAwIBAgIBHjANBgkqhkiG9w0BAQUFADB9MQswCQYDVQQGEwJJTDEW
MBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlm
aWNhdGUgU2lnbmluZzEpMCcGA1UEAxMgU3RhcnRDb20gQ2VydGlmaWNhdGlvbiBBdXRob3Jp
dHkwHhcNMDcxMDI0MjEwMTU1WhcNMTcxMDI0MjEwMTU1WjCBjDELMAkGA1UEBhMCSUwxFjAU
BgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmlj
YXRlIFNpZ25pbmcxODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1l
ZGlhdGUgQ2xpZW50IENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxwmDzM4t
2BqxKaQuE6uWvooyg4ymiEGWVUet1G8SD+rqvyNH4QrvnEIaFHxOhESip7vMz39ScLpNLbL1
QpOlPW/tFIzNHS3qd2XRNYG5Sv9RcGE+T4qbLtsjjJbi6sL7Ls/f/X9ftTyhxvxWkf8KW37i
KrueKsxw2HqolH7GM6FX5UfNAwAu4ZifkpmZzU1slBhyWwaQPEPPZRsWoTb7q8hmgv6Nv3Hg
9rmA1/VPBIOQ6SKRkHXG0Hhmq1dOFoAFI411+a/9nWm5rcVjGcIWZ2v/43Yksq60jExipA4l
5uv9/+Hm33mbgmCszdj/Dthf13tgAv2O83hLJ0exTqfrlwIDAQABo4IBrTCCAakwDwYDVR0T
AQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMCAQYwHQYDVR0OBBYEFFNy7ZKc4NrLAVx8fpY1TvLU
uFGCMB8GA1UdIwQYMBaAFE4L7xqkQFulF2mHMMo0aEPQQa7yMGYGCCsGAQUFBwEBBFowWDAn
BggrBgEFBQcwAYYbaHR0cDovL29jc3Auc3RhcnRzc2wuY29tL2NhMC0GCCsGAQUFBzAChiFo
dHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS9zZnNjYS5jcnQwWwYDVR0fBFQwUjAnoCWgI4YhaHR0
cDovL3d3dy5zdGFydHNzbC5jb20vc2ZzY2EuY3JsMCegJaAjhiFodHRwOi8vY3JsLnN0YXJ0
c3NsLmNvbS9zZnNjYS5jcmwwgYAGA1UdIAR5MHcwdQYLKwYBBAGBtTcBAgEwZjAuBggrBgEF
BQcCARYiaHR0cDovL3d3dy5zdGFydHNzbC5jb20vcG9saWN5LnBkZjA0BggrBgEFBQcCARYo
aHR0cDovL3d3dy5zdGFydHNzbC5jb20vaW50ZXJtZWRpYXRlLnBkZjANBgkqhkiG9w0BAQUF
AAOCAgEACoMIfXirLAZcuGOMXq4cuSN3TaFx2H2GvD5VSy/6rV55BYHbWNaPeQn3oBSU8KgQ
Zn/Kck1JxbLpAxVCNtsxeW1R87ifhsYZ0qjdrA9anrW2MAWCtosmAOT4OxK9QPoSjCMxM3Hb
kZCDJgnlE8jMopH21BbyAYr7b5EfGRQJNtgWcvqSXwKHnTutR08+Kkn0KAkXCzeQNLeA5LlY
UzFyM7kPAp8pIRMQ+seHunmyG642S2+y/qHEdMuGIwpfz3eDF1PdctL04qYK/zu+Qg1Bw0Rw
gigVZs/0c5HP2/e9DBHh7eSwtzYlk4AUr6yxLlcwSjOfOmKEQ/Q8tzh0IFiNu9IPuTGAPBn4
CPxD0+Ru8T2wg8/s43R/PT3kd1OEqOJUl7q+h+r6fpvU0Fzxd2tC8Ga6fDEPme+1Nbi+03pV
juZQKbGwKJ66gEn06WqaxVZC+J8hh/jR0k9mST1iAZPNYulcNJ8tKmVtjYsv0L1TSm2+NwON
58tO+pIVzu3DWwSEXSf+qkDavQam+QtEOZxLBXI++aMUEapSn+k3Lxm48ZCYfAWLb/Xj7F5J
QMbZvCexglAbYR0kIHqW5DnsYSdMD/IplJMojx0NBrxJ3fN9dvX2Y6BIXRsF1du4qESm4/3C
KuyUV7p9DW3mPlHTGLvYxnyKQy7VFBkoLINszBrOUeIxggPtMIID6QIBATCBlDCBjDELMAkG
A1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdp
dGFsIENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJp
bWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENBAgMQVQswDQYJYIZIAWUDBAIBBQCgggIpMBgG
CSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2MDUyMjIwMzYzOFow
LwYJKoZIhvcNAQkEMSIEIMbApa8HRxMpYppitjTS0dUuv+a/QU9I236n3XWudaOSMGwGCSqG
SIb3DQEJDzFfMF0wCwYJYIZIAWUDBAEqMAsGCWCGSAFlAwQBAjAKBggqhkiG9w0DBzAOBggq
hkiG9w0DAgICAIAwDQYIKoZIhvcNAwICAUAwBwYFKw4DAgcwDQYIKoZIhvcNAwICASgwgaUG
CSsGAQQBgjcQBDGBlzCBlDCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0
ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNV
BAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENBAgMQ
VQswgacGCyqGSIb3DQEJEAILMYGXoIGUMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3Rh
cnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2lnbmlu
ZzE4MDYGA1UEAxMvU3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IEludGVybWVkaWF0ZSBDbGll
bnQgQ0ECAxBVCzANBgkqhkiG9w0BAQEFAASCAQBTraFpxD1Ekbf4RHjW+akO3IauhBHaLgAG
pI0tWMqJSi/hYS342ufWo/s44gj93kO2MgZYp3AXU+F/qKyUOxq8gC7Bg8RUldXEXXi1WSz/
ZuqLg00TZppkggByOB2dlVszKLFc0CkRtajwQgM52U5NuVGxsc1y8GcgPww3iuVNiXUsOWEA
RLiMbjQ3OtH3VfLOABdw0hSX/zDKOTeG12XAPLI8vRfF8oVGvDg0h0A3RQQX9imciFQ82W73
V2MuD8SQQ6CpDmQr6Xo+q5a1eJzqRblSHRef24Qk7XqDNxcsHKXt7wLf4IDiH43i3tYSla3U
ZdI7P6Dxz/tB4ilH3Za3AAAAAAAA
--------------ms060301090605060901020707--
