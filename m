From: "Sangtae Ha" <sangtae.ha@gmail.com>
Subject: Re: A Linux TCP SACK Question
Date: Sat, 5 Apr 2008 17:17:45 -0400
Message-ID: <649aecc70804051417l4cf9b30asec8ca8d55e79e051@mail.gmail.com>
References: <fc471cb97cfd.47f5520e@fnal.gov>
	 <1e41a3230804040927j3ce53a84u6a95ec37dff1b5b0@mail.gmail.com>
	 <000001c8967c$496efa20$c95ee183@D2GT6T71>
	 <Pine.LNX.4.64.0804042253000.415@wrl-59.cs.helsinki.fi>
	 <000b01c89699$00e99590$c95ee183@D2GT6T71>
	 <Pine.LNX.4.64.0804050031400.8186@wrl-59.cs.helsinki.fi>
	 <Pine.LNX.4.64.0804050037380.8186@wrl-59.cs.helsinki.fi>
	 <000f01c896a1$3022fec0$c95ee183@D2GT6T71>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_11764_14107941.1207430265267"
Cc: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	"John Heffner" <johnwheffner@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: wenji@fnal.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:46005 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753674AbYDEVRq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Apr 2008 17:17:46 -0400
Received: by yw-out-2324.google.com with SMTP id 5so124295ywb.1
        for <netdev@vger.kernel.org>; Sat, 05 Apr 2008 14:17:45 -0700 (PDT)
In-Reply-To: <000f01c896a1$3022fec0$c95ee183@D2GT6T71>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_11764_14107941.1207430265267
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Can you run the attached script and run your testing again?
I think it might be the problem of your dual cores balance the
interrupts on your testing NIC.
As we do a lot of things with SACK, cache misses and etc. might affect
your performance.

In default setting, I disabled tcp segment offload and did a smp
affinity setting to CPU 0.
Please change "INF" to your interface name and let us know the results.

Sangtae


On Fri, Apr 4, 2008 at 6:14 PM, Wenji Wu <wenji@fnal.gov> wrote:
>
> >...Assuming it wasn't disabled already. If you find that there's
> >significant difference, you could try also with SACK+basic FRTO (set
> >the tcp_frto sysctl to 1).
>
> No, still the same. I tried tcp_frto with 0, 1, 2.
>
> SACK On is worse than SACK off.
>
> wenji
>
>
> --
>
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

------=_Part_11764_14107941.1207430265267
Content-Type: application/x-sh; name=tuning.sh
Content-Transfer-Encoding: base64
X-Attachment-Id: f_feooricd0
Content-Disposition: attachment; filename=tuning.sh

IyEvYmluL3NoCgojIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjCiMgU2FuZ3RhZSBIYSAKIyA8c2Fu
Z3RhZS5oYUBnbWFpbC5jb20+CiMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMKCiMjIyMjIyMjIyMj
IyMjIyMjIyMjIyMjIyMKIyBJbnRlcmZhY2UKIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIwpJTkY9
ZXRoMwoKIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIwojIE1heGltdW0gQnVmZmVyCiMjIyMjIyMj
IyMjIyMjIyMjIyMjIyMjIyMKTUFYQlVGX09OPTAKTUFYQlVGPTEzNDIxNzcyOCAjIE1heGltdW0g
VENQIGJ1ZmZlciBzaXplICgxMjhNQikKCiMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMKIyBNYXhp
bXVtIEJhY2tsb2cgCiMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMKTUFYQkFDS0xPR19PTj0wCk1B
WEJBQ0tMT0c9MzAwMCAjIE1heGltdW0gYmFja2xvZwoKIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMj
IwojIEludGVyZmFjZSBSaW5nIFBhcmFtcyAKIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIwpSSU5H
X09OPTAKVFhfUklORz00MDk2ICMgVFggcmluZyBidWZmZXIgc2l6ZQpSWF9SSU5HPTQwOTYgIyBS
WCByaW5nIGJ1ZmZlciBzaXplCgojIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjCiMgVFNPIChUQ1Ag
U2VnbWVudCBPZmZsb2FkKSAKIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIwpUU09fT049MQpUU089
b2ZmICMgVFNPKFRDUCBTZWdtZW50IE9mZmxvYWQpIG9mZi9vbgoKIyMjIyMjIyMjIyMjIyMjIyMj
IyMjIyMjIwojIFNNUCBhZmZpbml0eSAgCiMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMKU01QX0FG
RklOSVRZPTEKSU5UPWBjYXQgL3Byb2MvaW50ZXJydXB0cyB8IGdyZXAgJElORiB8IGN1dCAtZCA6
IC1mIDFgCkNQVT0xICMgcm91dGUgdGhlIHR4L3J4IGludGVycnVwdHMgdG8gMXN0IENQVQogICAg
ICAjIHRoZSBudW1iZXIgaXMgMl4obi0xKSBmb3IgdGhlICduJ3N0IENQVSAKCiMgd2Ugb25seSB0
b3VjaCB0aGUgbWF4aW11bSBUQ1AgYnVmZmVyIHNpemUsCiMgc28gbm9ybWFsIHVzZXJzIHdpbGwg
YmUgb2sgZm9yIHRoaXMgY2hhbmdlCmlmIFsgJE1BWEJVRl9PTiAtZXEgMSBdOyB0aGVuCi9zYmlu
L3N5c2N0bCAtdyBuZXQuY29yZS5ybWVtX21heD0kTUFYQlVGCi9zYmluL3N5c2N0bCAtdyBuZXQu
Y29yZS53bWVtX21heD0kTUFYQlVGCi9zYmluL3N5c2N0bCAtdyBuZXQuaXB2NC50Y3Bfcm1lbT0i
NDA5NiA4NzM4MCAkTUFYQlVGIgovc2Jpbi9zeXNjdGwgLXcgbmV0LmlwdjQudGNwX3dtZW09IjQw
OTYgNjU1MzYgJE1BWEJVRiIKL3NiaW4vc3lzY3RsIC13IG5ldC5pcHY0LnRjcF9ub19tZXRyaWNz
X3NhdmU9MQpmaQoKIyBtYXggYmFja2xvZwppZiBbICRNQVhCQUNLTE9HX09OIC1lcSAxIF07IHRo
ZW4KL3NiaW4vc3lzY3RsIC13IG5ldC5jb3JlLm5ldGRldl9tYXhfYmFja2xvZz0kTUFYQkFDS0xP
RwpmaQoKIyByeCBhbmQgdHggcmluZyBidWZmZXIgc2l6ZQppZiBbICRSSU5HX09OIC1lcSAxIF07
IHRoZW4KL3Vzci9zYmluL2V0aHRvb2wgLUcgJElORiByeCAkUlhfUklORwovdXNyL3NiaW4vZXRo
dG9vbCAtRyAkSU5GIHR4ICRUWF9SSU5HCmZpCgojIHRzbyBvbi9vZmYKaWYgWyAkVFNPX09OIC1l
cSAxIF07IHRoZW4KL3Vzci9zYmluL2V0aHRvb2wgLUsgJElORiB0c28gJFRTTwpmaQoKIyBTTVAg
YWZmaW5pdHkgc2V0dGluZwppZiBbICRTTVBfQUZGSU5JVFkgLWVxIDEgXTsgdGhlbgplY2hvICRD
UFUgPiAvcHJvYy9pcnEvYGV4cHIgJElOVGAvc21wX2FmZmluaXR5CmZpCg==
------=_Part_11764_14107941.1207430265267--
