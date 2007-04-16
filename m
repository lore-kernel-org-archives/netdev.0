From: <vignesh.babu@wipro.com>
Subject: [KJ][PATCH]sb1250-mac.c-kzalloc
Date: Mon, 16 Apr 2007 11:35:23 +0530
Message-ID: <1176703523.13066.8.camel@wriver-t81fb058.linuxcoe>
Mime-Version: 1.0
Content-Type: multipart/signed;
	micalg=sha1;
	protocol="application/x-pkcs7-signature";
	boundary="=-DoE2RX+3uFQ3tloMudJr"
Cc: <netdev@vger.kernel.org>, <kernel-janitors@lists.osdl.org>
To: <mchan@broadcom.com>, <mpl@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wip-cdc-wd.wipro.com ([203.91.201.26]:49004 "EHLO
	wip-cdc-wd.wipro.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753962AbXDPGJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 02:09:53 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-DoE2RX+3uFQ3tloMudJr
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Replacing kmalloc/memset combination with kzalloc.

Signed-off-by: vignesh babu <vignesh.babu@wipro.com>
---
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 103c317..af7649f 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -735,8 +735,8 @@ static void sbdma_initctx(sbmacdma_t *d,
=20
 	d->sbdma_maxdescr =3D maxdescr;
=20
-	d->sbdma_dscrtable =3D (sbdmadscr_t *)
-		kmalloc((d->sbdma_maxdescr+1)*sizeof(sbdmadscr_t), GFP_KERNEL);
+	d->sbdma_dscrtable =3D
+		kzalloc((d->sbdma_maxdescr+1)*sizeof(sbdmadscr_t), GFP_KERNEL);
=20
 	/*
 	 * The descriptor table must be aligned to at least 16 bytes or the
@@ -745,8 +745,6 @@ static void sbdma_initctx(sbmacdma_t *d,
 	d->sbdma_dscrtable =3D (sbdmadscr_t *)
 		ALIGN((unsigned long)d->sbdma_dscrtable, sizeof(sbdmadscr_t));
=20
-	memset(d->sbdma_dscrtable,0,d->sbdma_maxdescr*sizeof(sbdmadscr_t));
-
 	d->sbdma_dscrtable_end =3D d->sbdma_dscrtable + d->sbdma_maxdescr;
=20
 	d->sbdma_dscrtable_phys =3D virt_to_phys(d->sbdma_dscrtable);
@@ -755,10 +753,8 @@ static void sbdma_initctx(sbmacdma_t *d,
 	 * And context table
 	 */
=20
-	d->sbdma_ctxtable =3D (struct sk_buff **)
-		kmalloc(d->sbdma_maxdescr*sizeof(struct sk_buff *), GFP_KERNEL);
-
-	memset(d->sbdma_ctxtable,0,d->sbdma_maxdescr*sizeof(struct sk_buff *));
+	d->sbdma_ctxtable =3D
+		kzalloc(d->sbdma_maxdescr*sizeof(struct sk_buff *), GFP_KERNEL);
=20
 #ifdef CONFIG_SBMAC_COALESCE
 	/*

--=20
Regards, =20
Vignesh Babu BM =20
_____________________________________________________________ =20
"Why is it that every time I'm with you, makes me believe in magic?"


--=-DoE2RX+3uFQ3tloMudJr
Content-Type: application/x-pkcs7-signature; name=smime.p7s
Content-Disposition: attachment; filename=smime.p7s
Content-Transfer-Encoding: base64

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
CQYDVQQGEwJaQTElMCMGA1UEChMcVGhhd3RlIENvbnN1bHRpbmcgKFB0eSkgTHRkLjEsMCoGA1UE
AxMjVGhhd3RlIFBlcnNvbmFsIEZyZWVtYWlsIElzc3VpbmcgQ0EwgZ8wDQYJKoZIhvcNAQEBBQAD
gY0AMIGJAoGBAMSmPFVzVftOucqZWh5owHUEcJ3f6f+jHuy9zfVb8hp2vX8MOmHyv1HOAdTlUAow
1wJjWiyJFXCO3cnwK4Vaqj9xVsuvPAsH5/EfkTYkKhPPK9Xzgnc9A74r/rsYPge/QIACZNenpruf
ZdHFKlSFD0gEf6e20TxhBEAeZBlyYLf7AgMBAAGjgZQwgZEwEgYDVR0TAQH/BAgwBgEB/wIBADBD
BgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLnRoYXd0ZS5jb20vVGhhd3RlUGVyc29uYWxGcmVl
bWFpbENBLmNybDALBgNVHQ8EBAMCAQYwKQYDVR0RBCIwIKQeMBwxGjAYBgNVBAMTEVByaXZhdGVM
YWJlbDItMTM4MA0GCSqGSIb3DQEBBQUAA4GBAEiM0VCD6gsuzA2jZqxnD3+vrL7CF6FDlpSdf0wh
uPg2H6otnzYvwPQcUCCTcDz9reFhYsPZOhl+hLGZGwDFGguCdJ4lUJRix9sncVcljd2pnDmOjCBP
ZV+V2vf3h9bGCE6u9uo05RAaWzVNd+NWIXiC3CEZNd4ksdMdRv9dX2VPMYIDEDCCAwwCAQEwdjBi
MQswCQYDVQQGEwJaQTElMCMGA1UEChMcVGhhd3RlIENvbnN1bHRpbmcgKFB0eSkgTHRkLjEsMCoG
A1UEAxMjVGhhd3RlIFBlcnNvbmFsIEZyZWVtYWlsIElzc3VpbmcgQ0ECEBRBWlnPDDQELOU4iM67
/5AwCQYFKw4DAhoFAKCCAW8wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUx
DxcNMDcwNDE2MDYwNTE5WjAjBgkqhkiG9w0BCQQxFgQU8CwC/+9ggOIwfAHwJmWAYKnBANAwgYUG
CSsGAQQBgjcQBDF4MHYwYjELMAkGA1UEBhMCWkExJTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5n
IChQdHkpIEx0ZC4xLDAqBgNVBAMTI1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENB
AhAUQVpZzww0BCzlOIjOu/+QMIGHBgsqhkiG9w0BCRACCzF4oHYwYjELMAkGA1UEBhMCWkExJTAj
BgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMTI1RoYXd0ZSBQZXJz
b25hbCBGcmVlbWFpbCBJc3N1aW5nIENBAhAUQVpZzww0BCzlOIjOu/+QMA0GCSqGSIb3DQEBAQUA
BIIBAEPaSNrGrucW5MCsbS/g0VvjIWojvFmGa1+0ZQSxEFpUbW53X58rQ7b+Ex2fGhrLk+b2j8im
Z6Yx3HKeaexeVOHtdMtdkFszJ6EADw9OLt6iYYdXbbrca/F4azBDhXgPs2UTHcsCKJw3LafCFYS2
wmZQ9jkqHExEpXjfpUXeiQr8jdxi06q8jjJfC9+sONkFahxUFKTgKt7AUydHFef3WkQ3zOlHyjiA
DMJQVogVWQF5kLv3hSUFXeDGd6oA8L8E9QfJlcbrb2DxzB69I1k8eQptH7p1EdeiirfLXsnrE9sa
YwXs3YL6Vh7f4PbpQ/fDt83+XaC0f2Hh6SOOtzhicBUAAAAAAAA=


--=-DoE2RX+3uFQ3tloMudJr--
