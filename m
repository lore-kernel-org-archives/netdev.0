From: Dave Taht <dave.taht@gmail.com>
Subject: Re: am335x: cpsw: phy ignores max-speed setting
Date: Thu, 6 Nov 2014 08:51:09 -0800
Message-ID: <CAA93jw5=LDirktyC+rvpLi-kywUSosj6QV8-na5p3-f=PxKcWQ@mail.gmail.com>
References: <CAGm1_ktWK5ai85PZJTkq8Q1mAFH6JZ5XM1mDOHO3K_N2iGNLWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a113cd5d6d63d220507338080
Cc: netdev <netdev@vger.kernel.org>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>, mpa@pengutronix.de,
	lsorense@csclub.uwaterloo.ca, Daniel Mack <zonque@gmail.com>
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:36488 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752444AbaKFQvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 11:51:10 -0500
Received: by mail-ob0-f174.google.com with SMTP id uz6so1139726obc.5
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 08:51:09 -0800 (PST)
In-Reply-To: <CAGm1_ktWK5ai85PZJTkq8Q1mAFH6JZ5XM1mDOHO3K_N2iGNLWg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a113cd5d6d63d220507338080
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

ooh! ooh! I have a BQL enablement patch for the cpsw that I have no
means of testing against multiple phys. Could
you give the attached very small patch a shot along the way?

The results I get on the beaglebone vs netperf-wrapper are pretty
spectacular - huge increase in throughput, big reduction in
latency.

http://snapon.lab.bufferbloat.net/~d/beagle_bql/bql_makes_a_difference.png
http://snapon.lab.bufferbloat.net/~d/beagle_bql/beaglebonewithbql.png

On Thu, Nov 6, 2014 at 8:25 AM, Yegor Yefremov
<yegorslists@googlemail.com> wrote:
> I' m trying to override max-speed setting for both CPSW connected
> PHYs. This is my DTS section for configuring CPSW:
>
> &mac {
>         pinctrl-names =3D "default", "sleep";
>         pinctrl-0 =3D <&cpsw_default>;
>         pinctrl-1 =3D <&cpsw_sleep>;
>         dual_emac =3D <1>;
>
>         status =3D "okay";
> };
>
> &davinci_mdio {
>         pinctrl-names =3D "default", "sleep";
>         pinctrl-0 =3D <&davinci_mdio_default>;
>         pinctrl-1 =3D <&davinci_mdio_sleep>;
>
>         status =3D "okay";
> };
>
> &cpsw_emac0 {
>         phy_id =3D <&davinci_mdio>, <0>;
>         phy-mode =3D "rgmii-id";
>         dual_emac_res_vlan =3D <1>;
>         max-speed =3D <100>;
> };
>
> &cpsw_emac1 {
>         phy_id =3D <&davinci_mdio>, <1>;
>         phy-mode =3D "rgmii-id";
>         dual_emac_res_vlan =3D <2>;
>         max-speed =3D <100>;
> };
>
> But in drivers/net/phy/phy_device.c->of_set_phy_supported() routine I
> don't get through node check, i.e. node =3D=3D NULL. Any idea why?
>
> static void of_set_phy_supported(struct phy_device *phydev)
> {
>         struct device_node *node =3D phydev->dev.of_node;
>         u32 max_speed;
>
>         if (!IS_ENABLED(CONFIG_OF_MDIO))
>                 return;
>
>         if (!node)
>                 return;
>
>         if (!of_property_read_u32(node, "max-speed", &max_speed)) {
>                 /* The default values for phydev->supported are
> provided by the PHY
>                  * driver "features" member, we want to reset to sane
> defaults fist
>                  * before supporting higher speeds.
>                  */
>                 phydev->supported &=3D PHY_DEFAULT_FEATURES;
>
>                 switch (max_speed) {
>                 default:
>                         return;
>
>                 case SPEED_1000:
>                         phydev->supported |=3D PHY_1000BT_FEATURES;
>                 case SPEED_100:
>                         phydev->supported |=3D PHY_100BT_FEATURES;
>                 case SPEED_10:
>                         phydev->supported |=3D PHY_10BT_FEATURES;
>                 }
>         }
> }
>
> Yegor
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--=20
Dave T=C3=A4ht

thttp://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks

--001a113cd5d6d63d220507338080
Content-Type: text/x-patch; charset=US-ASCII;
	name="0001-Add-BQL-support-to-the-TI-cpsw-driver.patch"
Content-Disposition: attachment;
	filename="0001-Add-BQL-support-to-the-TI-cpsw-driver.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_i26cpsg20

RnJvbSA3ZWNjYjI2ZGM4ZjZkMDk2NjBiMjJmY2JkODY4NTcyZDA1MGRmMjZmIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBEYXZlIFRhaHQgPGRhdmUudGFodEBidWZmZXJibG9hdC5uZXQ+
CkRhdGU6IFRodSwgNiBOb3YgMjAxNCAwODo0NTozMCAtMDgwMApTdWJqZWN0OiBbUEFUQ0hdIEFk
ZCBCUUwgc3VwcG9ydCB0byB0aGUgVEkgY3BzdyBkcml2ZXIKClRlc3RlZCBvbiB0aGUgYmVhZ2xl
Ym9uZSBibGFjay4KCkkgZ2V0IGEgaHVnZSBpbXByb3ZlbWVudCBpbiBib3RoIHRocm91Z2hwdXQg
YW5kIGxhdGVuY3kuCgpMYXRlbmN5IGdvZXMgZnJvbSA2MG1zIHdvcnN0IGNhc2Ugd2l0aCBwZmlm
b19mYXN0LCBhbmQgMTJtcyB3b3JzdCBjYXNlIHdpdGgKc2NoX2ZxIHRvIDIuNW1zIHdpdGggQlFM
IGVuYWJsZWQuCgpUaHJvdWdocHV0IGltcHJvdmVkIGFsc28uCi0tLQogZHJpdmVycy9uZXQvZXRo
ZXJuZXQvdGkvY3Bzdy5jIHwgMTEgKysrKysrKysrLS0KIDEgZmlsZSBjaGFuZ2VkLCA5IGluc2Vy
dGlvbnMoKyksIDIgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQvZXRoZXJu
ZXQvdGkvY3Bzdy5jIGIvZHJpdmVycy9uZXQvZXRoZXJuZXQvdGkvY3Bzdy5jCmluZGV4IGQ4Nzk0
NDguLjU5MzRmYmMgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L3RpL2Nwc3cuYwor
KysgYi9kcml2ZXJzL25ldC9ldGhlcm5ldC90aS9jcHN3LmMKQEAgLTExOCw3ICsxMTgsNyBAQCBk
byB7CQkJCQkJCQlcCiAjZGVmaW5lIENQRE1BX1RYQ1AJCTB4NDAKICNkZWZpbmUgQ1BETUFfUlhD
UAkJMHg2MAogCi0jZGVmaW5lIENQU1dfUE9MTF9XRUlHSFQJNjQKKyNkZWZpbmUgQ1BTV19QT0xM
X1dFSUdIVAkxNgogI2RlZmluZSBDUFNXX01JTl9QQUNLRVRfU0laRQk2MAogI2RlZmluZSBDUFNX
X01BWF9QQUNLRVRfU0laRQkoMTUwMCArIDE0ICsgNCArIDQpCiAKQEAgLTY5Myw2ICs2OTMsNyBA
QCBzdGF0aWMgdm9pZCBjcHN3X3R4X2hhbmRsZXIodm9pZCAqdG9rZW4sIGludCBsZW4sIGludCBz
dGF0dXMpCiAJY3B0c190eF90aW1lc3RhbXAocHJpdi0+Y3B0cywgc2tiKTsKIAluZGV2LT5zdGF0
cy50eF9wYWNrZXRzKys7CiAJbmRldi0+c3RhdHMudHhfYnl0ZXMgKz0gbGVuOworCW5ldGRldl9j
b21wbGV0ZWRfcXVldWUobmRldiwxLGxlbik7CiAJZGV2X2tmcmVlX3NrYl9hbnkoc2tiKTsKIH0K
IApAQCAtMTMwNyw2ICsxMzA4LDggQEAgc3RhdGljIGludCBjcHN3X25kb19vcGVuKHN0cnVjdCBu
ZXRfZGV2aWNlICpuZGV2KQogCQljcHN3X3NldF9jb2FsZXNjZShuZGV2LCAmY29hbCk7CiAJfQog
CisJbmV0ZGV2X3Jlc2V0X3F1ZXVlKG5kZXYpOworCWRldl9pbmZvKHByaXYtPmRldiwgIkJRTCBl
bmFibGVkXG4iKTsKIAluYXBpX2VuYWJsZSgmcHJpdi0+bmFwaSk7CiAJY3BkbWFfY3Rscl9zdGFy
dChwcml2LT5kbWEpOwogCWNwc3dfaW50cl9lbmFibGUocHJpdik7CkBAIC0xMzQxLDYgKzEzNDQs
NyBAQCBzdGF0aWMgaW50IGNwc3dfbmRvX3N0b3Aoc3RydWN0IG5ldF9kZXZpY2UgKm5kZXYpCiAJ
bmV0aWZfc3RvcF9xdWV1ZShwcml2LT5uZGV2KTsKIAluYXBpX2Rpc2FibGUoJnByaXYtPm5hcGkp
OwogCW5ldGlmX2NhcnJpZXJfb2ZmKHByaXYtPm5kZXYpOworCW5ldGRldl9yZXNldF9xdWV1ZShw
cml2LT5uZGV2KTsKIAogCWlmIChjcHN3X2NvbW1vbl9yZXNfdXNhZ2Vfc3RhdGUocHJpdikgPD0g
MSkgewogCQljcHRzX3VucmVnaXN0ZXIocHJpdi0+Y3B0cyk7CkBAIC0xMzYxLDYgKzEzNjUsNyBA
QCBzdGF0aWMgbmV0ZGV2X3R4X3QgY3Bzd19uZG9fc3RhcnRfeG1pdChzdHJ1Y3Qgc2tfYnVmZiAq
c2tiLAogewogCXN0cnVjdCBjcHN3X3ByaXYgKnByaXYgPSBuZXRkZXZfcHJpdihuZGV2KTsKIAlp
bnQgcmV0OworCWludCBsZW47CiAKIAluZGV2LT50cmFuc19zdGFydCA9IGppZmZpZXM7CiAKQEAg
LTEzNzUsOSArMTM4MCwxMSBAQCBzdGF0aWMgbmV0ZGV2X3R4X3QgY3Bzd19uZG9fc3RhcnRfeG1p
dChzdHJ1Y3Qgc2tfYnVmZiAqc2tiLAogCQlza2Jfc2hpbmZvKHNrYiktPnR4X2ZsYWdzIHw9IFNL
QlRYX0lOX1BST0dSRVNTOwogCiAJc2tiX3R4X3RpbWVzdGFtcChza2IpOwotCisJbGVuID0gbWF4
KHNrYi0+bGVuLCBDUFNXX01JTl9QQUNLRVRfU0laRSk7CisJbmV0ZGV2X3NlbnRfcXVldWUobmRl
dixsZW4pOwogCXJldCA9IGNwc3dfdHhfcGFja2V0X3N1Ym1pdChuZGV2LCBwcml2LCBza2IpOwog
CWlmICh1bmxpa2VseShyZXQgIT0gMCkpIHsKKwkJbmV0ZGV2X2NvbXBsZXRlZF9xdWV1ZShuZGV2
LDEsbGVuKTsKIAkJY3Bzd19lcnIocHJpdiwgdHhfZXJyLCAiZGVzYyBzdWJtaXQgZmFpbGVkXG4i
KTsKIAkJZ290byBmYWlsOwogCX0KLS0gCjEuOS4xCgo=
--001a113cd5d6d63d220507338080--
