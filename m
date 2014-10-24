From: Jianhua Xie <jianhua.xie@freescale.com>
Subject: Re: [PATCH] ucc_geth: invalid rx checksum error values
Date: Fri, 24 Oct 2014 20:11:58 +0800
Message-ID: <544A420E.4000103@freescale.com>
References: <FDB831DFAAC88B42A50BA37D1BC5E13A29C63D1F@MCHP03MSX.global-ad.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3956806432227448486=="
Cc: Zhao Qiang <B45475@freescale.com>, netdev@vger.kernel.org,
 Timur Tabi <timur@tabi.org>
To: "Kokoris, Ioannis" <ioannis.kokoris@unify.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <FDB831DFAAC88B42A50BA37D1BC5E13A29C63D1F@MCHP03MSX.global-ad.net>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

--===============3956806432227448486==
Content-Type: multipart/alternative;
	boundary="------------000209050909000306030905"

--------------000209050909000306030905
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: quoted-printable

Hi Ioannis ,

Thank you very much for finding and reporting the issue.
I help to broadcast to netdev mailing-list.

Thanks & Best Regards,
Jianhua

=E5=9C=A8 2014=E5=B9=B410=E6=9C=8822=E6=97=A5 21:07, Kokoris, Ioannis =E5=
=86=99=E9=81=93:
> Hi,
>
> The value in QE UCC ethernet interfaces shows random values:
>
> # ethtool -S eth0
> NIC statistics:
>       ...
>       rx-ip-checksum-errors: 3933892214
>
> The problem is located in a mismatch between the rx_fw_stat_gstrings fi=
elds
> - used in ucc_geth_ethtool - and the ucc_geth_rx_firmware_statistics_pr=
am
> fields - used in ucc_geth.
> Although the QE UCC Ethernet Controller includes the Rx checksum error
> counter in the 'Rx firmware counters', the related field is missing fro=
m the
> ucc_geth driver.
> After adding the RxChecksumError field in
> ucc_geth_rx_firmware_statistics_pram structure the counter works fine.
>
>
>
> Signed-off-by: Ioannis Kokkoris <ioannis.kokoris@unify.com>
>
>
> diff -Nru a/drivers/net/ethernet/freescale/ucc_geth.h
> b/drivers/net/ethernet/freescale/ucc_geth.h
> --- a/drivers/net/ethernet/freescale/ucc_geth.h 2014-10-22
> 15:19:16.000000000 +0300
> +++ b/drivers/net/ethernet/freescale/ucc_geth.h 2014-10-22
> 15:24:39.000000000 +0300
> @@ -541,6 +541,8 @@
>                                     replaced */
>          u32 insertvlan;         /* total frames that had their VLAN ta=
g
>                                     inserted */
> +       u32 checksumerr;        /* total frames that have IP Checksum E=
rror
> +                                */
>   } __packed;
>
>   struct ucc_geth_rx_interrupt_coalescing_entry {
>
>
>
> Best Regards,
> Ioannis
>
>
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev


--------------000209050909000306030905
Content-Type: text/html; charset="utf-8"
Content-Transfer-Encoding: quoted-printable

<html>
  <head>
    <meta content=3D"text/html; charset=3Dutf-8" http-equiv=3D"Content-Ty=
pe">
  </head>
  <body text=3D"#000000" bgcolor=3D"#FFFFFF">
    Hi Ioannis
    ,<br>
    <br>
    Thank you very much for finding and reporting the issue.<br>
    I help to broadcast to netdev mailing-list.<br>
    <br>
    Thanks &amp; Best Regards,<br>
    Jianhua<br>
    <br>
    <div class=3D"moz-cite-prefix">=E5=9C=A8 2014=E5=B9=B410=E6=9C=8822=E6=
=97=A5 21:07, Kokoris, Ioannis
      =E5=86=99=E9=81=93:<br>
    </div>
    <blockquote
cite=3D"mid:FDB831DFAAC88B42A50BA37D1BC5E13A29C63D1F@MCHP03MSX.global-ad.=
net"
      type=3D"cite">
      <pre wrap=3D"">Hi,=20

The value in QE UCC ethernet interfaces shows random values:

# ethtool -S eth0
NIC statistics:
     ...
     rx-ip-checksum-errors: 3933892214

The problem is located in a mismatch between the rx_fw_stat_gstrings fiel=
ds
- used in ucc_geth_ethtool - and the ucc_geth_rx_firmware_statistics_pram
fields - used in ucc_geth.
Although the QE UCC Ethernet Controller includes the Rx checksum error
counter in the 'Rx firmware counters', the related field is missing from =
the
ucc_geth driver. =20
After adding the RxChecksumError field in
ucc_geth_rx_firmware_statistics_pram structure the counter works fine.



Signed-off-by: Ioannis Kokkoris <a class=3D"moz-txt-link-rfc2396E" href=3D=
"mailto:ioannis.kokoris@unify.com">&lt;ioannis.kokoris@unify.com&gt;</a>


diff -Nru a/drivers/net/ethernet/freescale/ucc_geth.h
b/drivers/net/ethernet/freescale/ucc_geth.h
--- a/drivers/net/ethernet/freescale/ucc_geth.h 2014-10-22
15:19:16.000000000 +0300
+++ b/drivers/net/ethernet/freescale/ucc_geth.h 2014-10-22
15:24:39.000000000 +0300
@@ -541,6 +541,8 @@
                                   replaced */
        u32 insertvlan;         /* total frames that had their VLAN tag
                                   inserted */
+       u32 checksumerr;        /* total frames that have IP Checksum Err=
or
+                                */
 } __packed;

 struct ucc_geth_rx_interrupt_coalescing_entry {



Best Regards,
Ioannis
</pre>
      <br>
      <fieldset class=3D"mimeAttachmentHeader"></fieldset>
      <br>
      <pre wrap=3D"">_______________________________________________
Linuxppc-dev mailing list
<a class=3D"moz-txt-link-abbreviated" href=3D"mailto:Linuxppc-dev@lists.o=
zlabs.org">Linuxppc-dev@lists.ozlabs.org</a>
<a class=3D"moz-txt-link-freetext" href=3D"https://lists.ozlabs.org/listi=
nfo/linuxppc-dev">https://lists.ozlabs.org/listinfo/linuxppc-dev</a></pre=
>
    </blockquote>
    <br>
  </body>
</html>

--------------000209050909000306030905--

--===============3956806432227448486==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: inline

X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KTGludXhwcGMt
ZGV2IG1haWxpbmcgbGlzdApMaW51eHBwYy1kZXZAbGlzdHMub3psYWJzLm9yZwpodHRwczovL2xp
c3RzLm96bGFicy5vcmcvbGlzdGluZm8vbGludXhwcGMtZGV2

--===============3956806432227448486==--
