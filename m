From: "Christian Eggers" <ceggers@gmx.de>
Subject: Re: Buffer allocation for USB transfers
Date: Thu, 15 Jan 2009 19:50:51 +0100
Message-ID: <496F939B.3755.1E4CA7@ceggers.gmx.de>
References: <496E43F4.24792.158F9B@ceggers.gmx.de>, <200901151643.50635.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed; boundary=Message-Boundary-10569
To: Oliver Neukum <oliver@neukum.org>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout4.freenet.de ([195.4.92.94]:43607 "EHLO mout4.freenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756104AbZAOTMy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 14:12:54 -0500
In-reply-to: <200901151643.50635.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Message-Boundary-10569
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Content-description: Mail message body

Am 15 Jan 2009 um 16:43 hat Oliver Neukum geschrieben:
> Am Wednesday 14 January 2009 19:58:44 schrieb Christian Eggers:
> > At least the latter does not work on my SH-4 platform. It seems that other 
> > variables on the stack are overwritten after calling usb_control_msg(), probably as 
> > result of incorrect alignment.
> 
> Does this make it run on SH-4?
> 
> 	Regards
> 		Oliver
> 

Sorry, you have been to fast... I've already prepared a solution for this: (see attached diff)

The driver asix.c has been fixed in a similar way some time ago:

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-
2.6.git;a=commitdiff;h=51bf2976b55d07f9daae9697a0a3ac9f58abcedc

I've tested this change with 2.6.17 and 2.6.23 on a SH-4. The patch should compile with 
the current version. Could you please apply this for me? I've no routine in preparing 
patches for lkml.

Thanks
Christian Eggers



--Message-Boundary-10569
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: Quoted-printable
Content-disposition: inline
Content-description: Attachment information.

Der folgende Teil dieser Nachricht enth=E4lt einen Anhang im 
sogenannten Internet MIME Nachrichtenformat.
Wenn Sie Pegasus Mail oder ein beliebiges anderes MIME-kompatibles
Email-System verwenden, sollte Sie den Anhang mit Ihrem Email-System
speichern oder anzeigen k=F6nnen. Anderenfalls fragen Sie Ihren Administrator.

The following section of this message contains a file attachment
prepared for transmission using the Internet MIME message format.
If you are using Pegasus Mail, or any another MIME-compliant system,
you should be able to save it or view it from within your mailer.
If you cannot, please ask your system administrator for assistance.

   ---- Datei Information/File information -----------
     Datei/File:  mcs7830.c.diff
     Datum/Date:  15 Jan 2009, 19:20
     Gr=F6=DFe/Size:  1006 bytes.
     Typ/Type:    Unbekannt

--Message-Boundary-10569
Content-type: Application/Octet-stream; name="mcs7830.c.diff"; type=Unbekannt
Content-disposition: attachment; filename="mcs7830.c.diff"
Content-transfer-encoding: BASE64

LS0tIG1jczc4MzAuYy5vcmcJMjAwOS0wMS0xNSAxOTowMToxMy4wMDAwMDAwMDAgKzAxMDAK
KysrIG1jczc4MzAuYwkyMDA5LTAxLTE1IDE5OjE5OjAwLjAwMDAwMDAwMCArMDEwMApAQCAt
OTQsMTAgKzk0LDE4IEBACiB7CiAJc3RydWN0IHVzYl9kZXZpY2UgKnhkZXYgPSBkZXYtPnVk
ZXY7CiAJaW50IHJldDsKKwl2b2lkICpidWZmZXI7CisKKwlidWZmZXIgPSBrbWFsbG9jKHNp
emUsIEdGUF9OT0lPKTsKKwlpZiAoYnVmZmVyID09IE5VTEwpCisJCXJldHVybiAtRU5PTUVN
OwogCiAJcmV0ID0gdXNiX2NvbnRyb2xfbXNnKHhkZXYsIHVzYl9yY3ZjdHJscGlwZSh4ZGV2
LCAwKSwgTUNTNzgzMF9SRF9CUkVRLAotCQkJICAgICAgTUNTNzgzMF9SRF9CTVJFUSwgMHgw
MDAwLCBpbmRleCwgZGF0YSwKKwkJCSAgICAgIE1DUzc4MzBfUkRfQk1SRVEsIDB4MDAwMCwg
aW5kZXgsIGJ1ZmZlciwKIAkJCSAgICAgIHNpemUsIE1DUzc4MzBfQ1RSTF9USU1FT1VUKTsK
KwltZW1jcHkoZGF0YSwgYnVmZmVyLCBzaXplKTsKKwlrZnJlZShidWZmZXIpOworCiAJcmV0
dXJuIHJldDsKIH0KIApAQCAtMTA1LDEwICsxMTMsMTggQEAKIHsKIAlzdHJ1Y3QgdXNiX2Rl
dmljZSAqeGRldiA9IGRldi0+dWRldjsKIAlpbnQgcmV0OworCXZvaWQgKmJ1ZmZlcjsKKwor
CWJ1ZmZlciA9IGttYWxsb2Moc2l6ZSwgR0ZQX05PSU8pOworCWlmIChidWZmZXIgPT0gTlVM
TCkKKwkJcmV0dXJuIC1FTk9NRU07CisKKwltZW1jcHkoYnVmZmVyLCBkYXRhLCBzaXplKTsK
IAogCXJldCA9IHVzYl9jb250cm9sX21zZyh4ZGV2LCB1c2Jfc25kY3RybHBpcGUoeGRldiwg
MCksIE1DUzc4MzBfV1JfQlJFUSwKLQkJCSAgICAgIE1DUzc4MzBfV1JfQk1SRVEsIDB4MDAw
MCwgaW5kZXgsIGRhdGEsCisJCQkgICAgICBNQ1M3ODMwX1dSX0JNUkVRLCAweDAwMDAsIGlu
ZGV4LCBidWZmZXIsCiAJCQkgICAgICBzaXplLCBNQ1M3ODMwX0NUUkxfVElNRU9VVCk7CisJ
a2ZyZWUoYnVmZmVyKTsKIAlyZXR1cm4gcmV0OwogfQogCg==

--Message-Boundary-10569--
