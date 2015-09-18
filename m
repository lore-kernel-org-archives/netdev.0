From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH net 2/2]  8139cp: reset BQL when ring tx ring cleared
Date: Fri, 18 Sep 2015 08:40:39 +0100
Message-ID: <1442562039.97487.31.camel@infradead.org>
References: <20130520095443.2d18b2cb@nehalam.linuxnetplumber.net>
	 <20130520213728.GA28252@electric-eye.fr.zoreil.com>
	 <20130520172749.2a4447b6@nehalam.linuxnetplumber.net>
	 <1442232308.30875.6.camel@infradead.org>
	 <20150914215913.GA24962@electric-eye.fr.zoreil.com>
	 <1442489793.131189.142.camel@infradead.org>
	 <1442502391.131189.160.camel@infradead.org>
	 <20150917204449.GA22105@electric-eye.fr.zoreil.com>
	 <1442528065.97487.6.camel@infradead.org>
	 <20150917234449.GA25782@electric-eye.fr.zoreil.com>
	 <1442538276.97487.21.camel@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha-1"; protocol="application/x-pkcs7-signature";
	boundary="=-qsW7C12mrn/Ow5OwTWTq"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40790 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606AbbIRHkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 03:40:43 -0400
In-Reply-To: <1442538276.97487.21.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qsW7C12mrn/Ow5OwTWTq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-09-18 at 02:04 +0100, David Woodhouse wrote:
> On Fri, 2015-09-18 at 01:44 +0200, Francois Romieu wrote:
> > The TxDmaOkLowDesc register may tell if the Tx dma part is still=20
> > making any progress. I have added a TxPoll request. See below.
>=20
> I've just added that into the original TX timeout handler, since that
> doesn't seem to be crashing the box for me as long as I avoid the IRQ
> storm.
>=20
> Not sure what we learn from it ('desc 6550' printed as hex)... I've
> also made it dump the TX descriptor ring (skb, addr, opts1, opts2):

The TxDmaOkLowDesc values look sane to me; they always match the low
bits of the last descriptor that *should* have been sent, according to
the ring dumps.

I made it store and dump the original contents of the TX descriptor
ring too (before it gets overwritten by the hardware). So we can see
what *was* being transmitted.

It isn't any more enlightening. I also tried just prodding the hardware
by writing to the TxPoll register. That wasn't sufficient to restart
it.

[26589.024750] 8139cp 0000:00:0b.0 eth1: Transmit timeout, status  c   2b h=
ead 52 tail 45 desc 96c0    0 80ff
[26589.034632] TX ring 00:   (null) 1de16e7c 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 01:   (null) 1de165ac 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 02:   (null) 1de1540c 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 03:   (null) 1de15cdc 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 04:   (null) 1de14b3c 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 05:   (null) 1de1399c 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 06:   (null) 1de130cc 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 07:   (null) 1de1426c 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 08:   (null) 1de127fc 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 09:   (null) 1de11f2c 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 10:   (null) 1de10d8c 30003130 0 (b0000056 0)       =
    =20
[26589.034632] TX ring 11:   (null) 1de1165c 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 12:   (null) 1df4774c 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 13:   (null) 1de104bc 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 14:   (null) 1df46e7c 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 15:   (null) 1df465ac 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 16:   (null) 1df45cdc 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 17:   (null) 1df44b3c 30003130 0 (b0000056 0)       =
    =20
[26589.034632] TX ring 18:   (null) 1df4426c 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 19:   (null) 1df4540c 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 20:   (null) 1df4399c 30004954 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 21:   (null) 1df430cc 30004954 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 22:   (null) 1df427fc 30004954 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 23:   (null) 1df4165c 30004954 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 24:   (null) 1df41f2c 30004954 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 25:   (null) 1df40d8c 30004954 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 26:   (null) 1dcc9602 3000796b 0 (b000006a 0)       =
    =20
[26589.034632] TX ring 27:   (null) 1de1774c 30000000 0 (b0000097 0)       =
    =20
[26589.034632] TX ring 28:   (null) 1de16e7c 30000000 0 (b0000467 0)       =
    =20
[26589.034632] TX ring 29:   (null) 1df404bc 30000000 0 (b0000557 0)       =
    =20
[26589.034632] TX ring 30:   (null) 1de165ac 30000000 0 (b00000e7 0)       =
    =20
[26589.034632] TX ring 31:   (null) 1de1540c 30000000 0 (b00000d7 0)       =
    =20
[26589.034632] TX ring 32:   (null) 1dcc9602 300087b2 0 (b0000062 0)       =
    =20
[26589.034632] TX ring 33:   (null) 1de15cdc 300087b2 0 (b0000046 0)       =
    =20
[26589.034632] TX ring 34:   (null) 1de14b3c 30000540 0 (b000008b 0)       =
    =20
[26589.034632] TX ring 35:   (null) 1de1426c 3000709e 0 (b0000097 0)       =
    =20
[26589.034632] TX ring 36:   (null) 1de1399c 3000709e 0 (b0000097 0)       =
    =20
[26589.034632] TX ring 37:   (null) 1de130cc 3000c169 0 (b0000084 0)       =
    =20
[26589.034632] TX ring 38:   (null) 1de127fc 3000a5eb 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 39:   (null) 1de11f2c 3000d4a3 0 (b0000557 0)       =
    =20
[26589.034632] TX ring 40:   (null) 1de10d8c 3000b57e 0 (b0000046 0)       =
    =20
[26589.034632] TX ring 41:   (null) 1de104bc 30000000 0 (b00000a7 0)       =
    =20
[26589.034632] TX ring 42:   (null) 1dce774c 30004000 0 (b0000046 0)       =
    =20
[26589.034632] TX ring 43:   (null) 1dce6e7c 300076f6 0 (b0000046 0)       =
    =20
[26589.034632] TX ring 44:   (null) 1dce5cdc 30002034 0 (b0000096 0)       =
    =20
[26589.034632] TX ring 45: dde4c3c0 1dce540c b0000557 0 (b0000557 0)       =
    =20
[26589.034632] TX ring 46: dddc1900 1dce426c b0000097 0 (b0000097 0)       =
    =20
[26589.034632] TX ring 47: defb3600 1dce4b3c b0000097 0 (b0000097 0)       =
    =20
[26589.034632] TX ring 48: dde5b240 1dcc9602 b000006a 0 (b000006a 0)       =
    =20
[26589.034632] TX ring 49: dde5b540 1dce30cc b0000097 0 (b0000097 0)       =
    =20
[26589.034632] TX ring 50: dde5b600 1dce399c b0000097 0 (b0000097 0)       =
    =20
[26589.034632] TX ring 51: dde5b180 1dce1f2c b00005ea 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 52:   (null) 1df4540c 30003130 0 (b0000056 0)       =
    =20
[26589.034632] TX ring 53:   (null) 1df45cdc 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 54:   (null) 1df4426c 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 55:   (null) 1df44b3c 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 56:   (null) 1df4399c 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 57:   (null) 1df430cc 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 58:   (null) 1df427fc 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 59:   (null) 1df41f2c 30003130 0 (b0000056 0)       =
    =20
[26589.034632] TX ring 60:   (null) 1df4165c 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 61:   (null) 1df404bc 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 62:   (null) 1df40d8c 30003130 0 (b00005ea 0)       =
    =20
[26589.034632] TX ring 63:   (null) 1de1774c 70003130 0 (f00005ea 0)       =
    =20

Those values we see in the low 16 bits of the opts1 field after TX
(0x3130 in the last 12 or so immediately above) look bogus. Those
are supposed to be the frame length that actually got transmitted. But
they bear no relation to the length of the packet it was actually asked
to transmit. And sometimes it's zero (but not really correlated with
the TX hang). We use this value in cp_tx() for the dma_unmap call, as
the length to unmap. I've augmented the debugging in cp_tx() and we
really are seeing the same bogus values there; I'm surprised we've
never seen DMA API debugging trip up on this.

At this point I have no idea what the device is putting in the "TX
status" after a transmit, but it doesn't seem to match what's in the
datasheet.

[26906.679823] 8139cp 0000:00:0b.0 eth1: tx done, slot 35, status 0x3000f80=
4   =20
[26906.686910] 8139cp 0000:00:0b.0 eth1: tx done, slot 36, status 0x3000f80=
4   =20
[26906.693894] 8139cp 0000:00:0b.0 eth1: tx done, slot 37, status 0x30001e6=
9   =20
[26906.700912] 8139cp 0000:00:0b.0 eth1: tx done, slot 38, status 0x3000ca2=
4   =20
[26906.707800] 8139cp 0000:00:0b.0 eth1: tx done, slot 39, status 0x3000ca2=
4   =20
[26906.714902] 8139cp 0000:00:0b.0 eth1: tx done, slot 40, status 0x3000ca2=
4   =20
[26906.721787] 8139cp 0000:00:0b.0 eth1: tx done, slot 41, status 0x3000400=
6   =20
[26906.728942] 8139cp 0000:00:0b.0 eth1: tx done, slot 42, status 0x3000400=
6   =20
[26906.735921] 8139cp 0000:00:0b.0 eth1: tx done, slot 43, status 0x3000400=
6   =20
[26906.742948] 8139cp 0000:00:0b.0 eth1: tx done, slot 44, status 0x3000400=
6   =20

--=20
dwmw2


--=-qsW7C12mrn/Ow5OwTWTq
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIISjjCCBicw
ggUPoAMCAQICAw3vNzANBgkqhkiG9w0BAQUFADCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0
YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcx
ODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENB
MB4XDTE1MDUwNTA5NDM0MVoXDTE2MDUwNTA5NTMzNlowQjEcMBoGA1UEAwwTZHdtdzJAaW5mcmFk
ZWFkLm9yZzEiMCAGCSqGSIb3DQEJARYTZHdtdzJAaW5mcmFkZWFkLm9yZzCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAMkbm9kPbx1j/X4RVyf/pPKSYwelcco69TvnQQbKM8m8xkWjXJI1
jpJ1jMaGUZGFToINMSZi7lZawUozudWbXSKy1SikENSTJHffsdRAIlsp+hR8vWvjsKUry6sEdqPG
doa5RY7+N4WRusWZDYW/RRWE6i9EL9qV86CVPYqw22UBOUw4/j/HVGCV6TSB8yE5iEwhk/hUuzRr
FZm1MJMR7mCS7BCR8Lr5jFY61lWpBiXNXIxLZCvDc26KR5L5tYX43iUVO3fzES1GRVoYnxxk2tmz
fcsZG5vK+Trc9L8OZJfkYrEHH3+Iw41MQ0w/djVtYr1+HYldx0QmYXAtnhIj+UMCAwEAAaOCAtkw
ggLVMAkGA1UdEwQCMAAwCwYDVR0PBAQDAgSwMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcD
BDAdBgNVHQ4EFgQUszC96C3w5/2+d+atSr0IpT26YI4wHwYDVR0jBBgwFoAUU3Ltkpzg2ssBXHx+
ljVO8tS4UYIwHgYDVR0RBBcwFYETZHdtdzJAaW5mcmFkZWFkLm9yZzCCAUwGA1UdIASCAUMwggE/
MIIBOwYLKwYBBAGBtTcBAgMwggEqMC4GCCsGAQUFBwIBFiJodHRwOi8vd3d3LnN0YXJ0c3NsLmNv
bS9wb2xpY3kucGRmMIH3BggrBgEFBQcCAjCB6jAnFiBTdGFydENvbSBDZXJ0aWZpY2F0aW9uIEF1
dGhvcml0eTADAgEBGoG+VGhpcyBjZXJ0aWZpY2F0ZSB3YXMgaXNzdWVkIGFjY29yZGluZyB0byB0
aGUgQ2xhc3MgMSBWYWxpZGF0aW9uIHJlcXVpcmVtZW50cyBvZiB0aGUgU3RhcnRDb20gQ0EgcG9s
aWN5LCByZWxpYW5jZSBvbmx5IGZvciB0aGUgaW50ZW5kZWQgcHVycG9zZSBpbiBjb21wbGlhbmNl
IG9mIHRoZSByZWx5aW5nIHBhcnR5IG9ibGlnYXRpb25zLjA2BgNVHR8ELzAtMCugKaAnhiVodHRw
Oi8vY3JsLnN0YXJ0c3NsLmNvbS9jcnR1MS1jcmwuY3JsMIGOBggrBgEFBQcBAQSBgTB/MDkGCCsG
AQUFBzABhi1odHRwOi8vb2NzcC5zdGFydHNzbC5jb20vc3ViL2NsYXNzMS9jbGllbnQvY2EwQgYI
KwYBBQUHMAKGNmh0dHA6Ly9haWEuc3RhcnRzc2wuY29tL2NlcnRzL3N1Yi5jbGFzczEuY2xpZW50
LmNhLmNydDAjBgNVHRIEHDAahhhodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS8wDQYJKoZIhvcNAQEF
BQADggEBAHMQmxHHodpS85X8HRyxhvfkys7r+taCNOaNU9cxQu/cZ/6k5nS2qGNMzZ6jb7ueY/V7
7p+4DW/9ZWODDTf4Fz00mh5SSVc20Bz7t+hhxwHd62PZgENh5i76Qq2tw48U8AsYo5damHby1epf
neZafLpUkLLO7AGBJIiRVTevdvyXQ0qnixOmKMWyvrhSNGuVIKVdeqLP+102Dwf+dpFyw+j1hz28
jEEKpHa+NR1b2kXuSPi/rMGhexwlJOh4tK8KQ6Ryr0rIN//NSbOgbyYZrzc/ZUWX9V5OA84ChFb2
vkFl0OcYrttp/rhDBLITwffPxSZeoBh9H7zYzkbCXKL3BUIwggYnMIIFD6ADAgECAgMN7zcwDQYJ
KoZIhvcNAQEFBQAwgYwxCzAJBgNVBAYTAklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSswKQYD
VQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0aWZpY2F0ZSBTaWduaW5nMTgwNgYDVQQDEy9TdGFydENv
bSBDbGFzcyAxIFByaW1hcnkgSW50ZXJtZWRpYXRlIENsaWVudCBDQTAeFw0xNTA1MDUwOTQzNDFa
Fw0xNjA1MDUwOTUzMzZaMEIxHDAaBgNVBAMME2R3bXcyQGluZnJhZGVhZC5vcmcxIjAgBgkqhkiG
9w0BCQEWE2R3bXcyQGluZnJhZGVhZC5vcmcwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
AQDJG5vZD28dY/1+EVcn/6TykmMHpXHKOvU750EGyjPJvMZFo1ySNY6SdYzGhlGRhU6CDTEmYu5W
WsFKM7nVm10istUopBDUkyR337HUQCJbKfoUfL1r47ClK8urBHajxnaGuUWO/jeFkbrFmQ2Fv0UV
hOovRC/alfOglT2KsNtlATlMOP4/x1Rglek0gfMhOYhMIZP4VLs0axWZtTCTEe5gkuwQkfC6+YxW
OtZVqQYlzVyMS2Qrw3NuikeS+bWF+N4lFTt38xEtRkVaGJ8cZNrZs33LGRubyvk63PS/DmSX5GKx
Bx9/iMONTENMP3Y1bWK9fh2JXcdEJmFwLZ4SI/lDAgMBAAGjggLZMIIC1TAJBgNVHRMEAjAAMAsG
A1UdDwQEAwIEsDAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUHAwQwHQYDVR0OBBYEFLMwvegt
8Of9vnfmrUq9CKU9umCOMB8GA1UdIwQYMBaAFFNy7ZKc4NrLAVx8fpY1TvLUuFGCMB4GA1UdEQQX
MBWBE2R3bXcyQGluZnJhZGVhZC5vcmcwggFMBgNVHSAEggFDMIIBPzCCATsGCysGAQQBgbU3AQID
MIIBKjAuBggrBgEFBQcCARYiaHR0cDovL3d3dy5zdGFydHNzbC5jb20vcG9saWN5LnBkZjCB9wYI
KwYBBQUHAgIwgeowJxYgU3RhcnRDb20gQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwAwIBARqBvlRo
aXMgY2VydGlmaWNhdGUgd2FzIGlzc3VlZCBhY2NvcmRpbmcgdG8gdGhlIENsYXNzIDEgVmFsaWRh
dGlvbiByZXF1aXJlbWVudHMgb2YgdGhlIFN0YXJ0Q29tIENBIHBvbGljeSwgcmVsaWFuY2Ugb25s
eSBmb3IgdGhlIGludGVuZGVkIHB1cnBvc2UgaW4gY29tcGxpYW5jZSBvZiB0aGUgcmVseWluZyBw
YXJ0eSBvYmxpZ2F0aW9ucy4wNgYDVR0fBC8wLTAroCmgJ4YlaHR0cDovL2NybC5zdGFydHNzbC5j
b20vY3J0dTEtY3JsLmNybDCBjgYIKwYBBQUHAQEEgYEwfzA5BggrBgEFBQcwAYYtaHR0cDovL29j
c3Auc3RhcnRzc2wuY29tL3N1Yi9jbGFzczEvY2xpZW50L2NhMEIGCCsGAQUFBzAChjZodHRwOi8v
YWlhLnN0YXJ0c3NsLmNvbS9jZXJ0cy9zdWIuY2xhc3MxLmNsaWVudC5jYS5jcnQwIwYDVR0SBBww
GoYYaHR0cDovL3d3dy5zdGFydHNzbC5jb20vMA0GCSqGSIb3DQEBBQUAA4IBAQBzEJsRx6HaUvOV
/B0csYb35MrO6/rWgjTmjVPXMULv3Gf+pOZ0tqhjTM2eo2+7nmP1e+6fuA1v/WVjgw03+Bc9NJoe
UklXNtAc+7foYccB3etj2YBDYeYu+kKtrcOPFPALGKOXWph28tXqX53mWny6VJCyzuwBgSSIkVU3
r3b8l0NKp4sTpijFsr64UjRrlSClXXqiz/tdNg8H/naRcsPo9Yc9vIxBCqR2vjUdW9pF7kj4v6zB
oXscJSToeLSvCkOkcq9KyDf/zUmzoG8mGa83P2VFl/VeTgPOAoRW9r5BZdDnGK7baf64QwSyE8H3
z8UmXqAYfR+82M5Gwlyi9wVCMIIGNDCCBBygAwIBAgIBHjANBgkqhkiG9w0BAQUFADB9MQswCQYD
VQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwg
Q2VydGlmaWNhdGUgU2lnbmluZzEpMCcGA1UEAxMgU3RhcnRDb20gQ2VydGlmaWNhdGlvbiBBdXRo
b3JpdHkwHhcNMDcxMDI0MjEwMTU1WhcNMTcxMDI0MjEwMTU1WjCBjDELMAkGA1UEBhMCSUwxFjAU
BgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRl
IFNpZ25pbmcxODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUg
Q2xpZW50IENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxwmDzM4t2BqxKaQuE6uW
vooyg4ymiEGWVUet1G8SD+rqvyNH4QrvnEIaFHxOhESip7vMz39ScLpNLbL1QpOlPW/tFIzNHS3q
d2XRNYG5Sv9RcGE+T4qbLtsjjJbi6sL7Ls/f/X9ftTyhxvxWkf8KW37iKrueKsxw2HqolH7GM6FX
5UfNAwAu4ZifkpmZzU1slBhyWwaQPEPPZRsWoTb7q8hmgv6Nv3Hg9rmA1/VPBIOQ6SKRkHXG0Hhm
q1dOFoAFI411+a/9nWm5rcVjGcIWZ2v/43Yksq60jExipA4l5uv9/+Hm33mbgmCszdj/Dthf13tg
Av2O83hLJ0exTqfrlwIDAQABo4IBrTCCAakwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMC
AQYwHQYDVR0OBBYEFFNy7ZKc4NrLAVx8fpY1TvLUuFGCMB8GA1UdIwQYMBaAFE4L7xqkQFulF2mH
MMo0aEPQQa7yMGYGCCsGAQUFBwEBBFowWDAnBggrBgEFBQcwAYYbaHR0cDovL29jc3Auc3RhcnRz
c2wuY29tL2NhMC0GCCsGAQUFBzAChiFodHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS9zZnNjYS5jcnQw
WwYDVR0fBFQwUjAnoCWgI4YhaHR0cDovL3d3dy5zdGFydHNzbC5jb20vc2ZzY2EuY3JsMCegJaAj
hiFodHRwOi8vY3JsLnN0YXJ0c3NsLmNvbS9zZnNjYS5jcmwwgYAGA1UdIAR5MHcwdQYLKwYBBAGB
tTcBAgEwZjAuBggrBgEFBQcCARYiaHR0cDovL3d3dy5zdGFydHNzbC5jb20vcG9saWN5LnBkZjA0
BggrBgEFBQcCARYoaHR0cDovL3d3dy5zdGFydHNzbC5jb20vaW50ZXJtZWRpYXRlLnBkZjANBgkq
hkiG9w0BAQUFAAOCAgEACoMIfXirLAZcuGOMXq4cuSN3TaFx2H2GvD5VSy/6rV55BYHbWNaPeQn3
oBSU8KgQZn/Kck1JxbLpAxVCNtsxeW1R87ifhsYZ0qjdrA9anrW2MAWCtosmAOT4OxK9QPoSjCMx
M3HbkZCDJgnlE8jMopH21BbyAYr7b5EfGRQJNtgWcvqSXwKHnTutR08+Kkn0KAkXCzeQNLeA5LlY
UzFyM7kPAp8pIRMQ+seHunmyG642S2+y/qHEdMuGIwpfz3eDF1PdctL04qYK/zu+Qg1Bw0RwgigV
Zs/0c5HP2/e9DBHh7eSwtzYlk4AUr6yxLlcwSjOfOmKEQ/Q8tzh0IFiNu9IPuTGAPBn4CPxD0+Ru
8T2wg8/s43R/PT3kd1OEqOJUl7q+h+r6fpvU0Fzxd2tC8Ga6fDEPme+1Nbi+03pVjuZQKbGwKJ66
gEn06WqaxVZC+J8hh/jR0k9mST1iAZPNYulcNJ8tKmVtjYsv0L1TSm2+NwON58tO+pIVzu3DWwSE
XSf+qkDavQam+QtEOZxLBXI++aMUEapSn+k3Lxm48ZCYfAWLb/Xj7F5JQMbZvCexglAbYR0kIHqW
5DnsYSdMD/IplJMojx0NBrxJ3fN9dvX2Y6BIXRsF1du4qESm4/3CKuyUV7p9DW3mPlHTGLvYxnyK
Qy7VFBkoLINszBrOUeIxggNvMIIDawIBATCBlDCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0
YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcx
ODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENB
AgMN7zcwCQYFKw4DAhoFAKCCAa8wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0B
CQUxDxcNMTUwOTE4MDc0MDM5WjAjBgkqhkiG9w0BCQQxFgQUFXPNZjof3byPB0I3UpGNW//8IHgw
gaUGCSsGAQQBgjcQBDGBlzCBlDCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0
ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNVBAMT
L1N0YXJ0Q29tIENsYXNzIDEgUHJpbWFyeSBJbnRlcm1lZGlhdGUgQ2xpZW50IENBAgMN7zcwgacG
CyqGSIb3DQEJEAILMYGXoIGUMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRk
LjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzE4MDYGA1UEAxMv
U3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IEludGVybWVkaWF0ZSBDbGllbnQgQ0ECAw3vNzANBgkq
hkiG9w0BAQEFAASCAQBpohQbU7xoM2ucHNd8ApS3Xp9srhePDiOcgMbPoXBSyYiX9SdekTE1cSHa
JX6ez+ZBbf2LsHAygx+QEEZfaRg2CBN82qjPtCZ6ukz1SjxbtCTvmcPDI02IjIKuCcz4fbBlW+ML
gAOXCi0N6/NghWutKSNZSSe1PXuA78Acx8DTwb2C37OKf97XnBrvetoqmlO8dF3KQCa1kbhruAMT
MIpedRL2VUdr1ecJmEMMDG6ZLGrn3PkQoftXx6Uwl3DyLyeZmd4lriGl/pDmpuXO5dfMs87QkQ/j
jybqus8c60p/SYxlzBCOuV7f5YO/unNSt4+iazNsqpiopVcqrQtXh/ZOAAAAAAAA


--=-qsW7C12mrn/Ow5OwTWTq--
