From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH ipsec-next 6/8] xfrm: policy: only use rcu in
 xfrm_sk_policy_lookup
Date: Wed, 16 Nov 2016 17:43:50 +0100
Message-ID: <0e235471-cb63-2376-c42d-5872e78e4c98@6wind.com>
References: <1470921479-25592-1-git-send-email-fw@strlen.de>
 <1470921479-25592-7-git-send-email-fw@strlen.de>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------2C05DDEA35E9A2EB87B3BA3B"
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
        Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:35597 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752409AbcKPQny (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 11:43:54 -0500
Received: by mail-wm0-f43.google.com with SMTP id a197so251065309wmd.0
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 08:43:53 -0800 (PST)
In-Reply-To: <1470921479-25592-7-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------2C05DDEA35E9A2EB87B3BA3B
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit

Le 11/08/2016 à 15:17, Florian Westphal a écrit :
> Don't acquire the readlock anymore and rely on rcu alone.
> 
> In case writer on other CPU changed policy at the wrong moment (after we
> obtained sk policy pointer but before we could obtain the reference)
> just repeat the lookup.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
Since this patch, our IKEv1 Transport tests (using charon) fail to establish the
connection. If I revert it, the IKE negociation is ok again.
charon logs are enclosed.

I didn't had time to investigate now, but any idea is welcomed ;-)

Regards,
Nicolas

--------------2C05DDEA35E9A2EB87B3BA3B
Content-Type: text/plain; charset=UTF-8;
 name="charon.txt"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="charon.txt"

L3Zhci9sb2cvc3lzbG9nOk5vdiAxNiAxNjoyODo0NyByb3V0ZXIgY2hhcm9uOiAwNFtDRkdd
IHJlY2VpdmVkIHN0cm9rZTogYWRkIGNvbm5lY3Rpb24gJ215dHVubmVsLTE3JwovdmFyL2xv
Zy9zeXNsb2c6Tm92IDE2IDE2OjI4OjQ3IHJvdXRlciBjaGFyb246IDA0W0NGR10gYWRkZWQg
Y29uZmlndXJhdGlvbiAnbXl0dW5uZWwtMTcnCi92YXIvbG9nL3N5c2xvZzpOb3YgMTYgMTY6
Mjg6NDcgcm91dGVyIGNoYXJvbjogMDhbQ0ZHXSByZWNlaXZlZCBzdHJva2U6IHJvdXRlICdt
eXR1bm5lbC0xNycKL3Zhci9sb2cvc3lzbG9nOk5vdiAxNiAxNjoyODo1MiByb3V0ZXIgY2hh
cm9uOiAxM1tLTkxdIGNyZWF0aW5nIGFjcXVpcmUgam9iIGZvciBwb2xpY3kgMTAuMTI1LjAu
MS8zMltncmVdID09PSAxMC4xMjUuMC4yLzMyW2dyZV0gd2l0aCByZXFpZCB7MX0KL3Zhci9s
b2cvc3lzbG9nOk5vdiAxNiAxNjoyODo1MiByb3V0ZXIgY2hhcm9uOiAxM1tJS0VdIGluaXRp
YXRpbmcgQWdncmVzc2l2ZSBNb2RlIElLRV9TQSBteXR1bm5lbC0xN1sxXSB0byAxMC4xMjUu
MC4yCi92YXIvbG9nL3N5c2xvZzpOb3YgMTYgMTY6Mjg6NTIgcm91dGVyIGNoYXJvbjogMTNb
RU5DXSBnZW5lcmF0aW5nIEFHR1JFU1NJVkUgcmVxdWVzdCAwIFsgU0EgS0UgTm8gSUQgViBW
IFYgViBWIF0KL3Zhci9sb2cvc3lzbG9nOk5vdiAxNiAxNjoyODo1MiByb3V0ZXIgY2hhcm9u
OiAxM1tORVRdIHNlbmRpbmcgcGFja2V0OiBmcm9tIDEwLjEyNS4wLjFbNTAwXSB0byAxMC4x
MjUuMC4yWzUwMF0gKDU0OCBieXRlcykKL3Zhci9sb2cvc3lzbG9nOk5vdiAxNiAxNjoyODo1
NiByb3V0ZXIgY2hhcm9uOiAwN1tJS0VdIHNlbmRpbmcgcmV0cmFuc21pdCAxIG9mIHJlcXVl
c3QgbWVzc2FnZSBJRCAwLCBzZXEgMQovdmFyL2xvZy9zeXNsb2c6Tm92IDE2IDE2OjI4OjU2
IHJvdXRlciBjaGFyb246IDA3W05FVF0gc2VuZGluZyBwYWNrZXQ6IGZyb20gMTAuMTI1LjAu
MVs1MDBdIHRvIDEwLjEyNS4wLjJbNTAwXSAoNTQ4IGJ5dGVzKQovdmFyL2xvZy9zeXNsb2c6
Tm92IDE2IDE2OjI5OjA0IHJvdXRlciBjaGFyb246IDA4W0lLRV0gc2VuZGluZyByZXRyYW5z
bWl0IDIgb2YgcmVxdWVzdCBtZXNzYWdlIElEIDAsIHNlcSAxCi92YXIvbG9nL3N5c2xvZzpO
b3YgMTYgMTY6Mjk6MDQgcm91dGVyIGNoYXJvbjogMDhbTkVUXSBzZW5kaW5nIHBhY2tldDog
ZnJvbSAxMC4xMjUuMC4xWzUwMF0gdG8gMTAuMTI1LjAuMls1MDBdICg1NDggYnl0ZXMpCi92
YXIvbG9nL3N5c2xvZzpOb3YgMTYgMTY6Mjk6MTcgcm91dGVyIGNoYXJvbjogMDlbSUtFXSBz
ZW5kaW5nIHJldHJhbnNtaXQgMyBvZiByZXF1ZXN0IG1lc3NhZ2UgSUQgMCwgc2VxIDEKL3Zh
ci9sb2cvc3lzbG9nOk5vdiAxNiAxNjoyOToxNyByb3V0ZXIgY2hhcm9uOiAwOVtORVRdIHNl
bmRpbmcgcGFja2V0OiBmcm9tIDEwLjEyNS4wLjFbNTAwXSB0byAxMC4xMjUuMC4yWzUwMF0g
KDU0OCBieXRlcykKL3Zhci9sb2cvc3lzbG9nOk5vdiAxNiAxNjoyOTo0MCByb3V0ZXIgY2hh
cm9uOiAxMVtJS0VdIHNlbmRpbmcgcmV0cmFuc21pdCA0IG9mIHJlcXVlc3QgbWVzc2FnZSBJ
RCAwLCBzZXEgMQovdmFyL2xvZy9zeXNsb2c6Tm92IDE2IDE2OjI5OjQwIHJvdXRlciBjaGFy
b246IDExW05FVF0gc2VuZGluZyBwYWNrZXQ6IGZyb20gMTAuMTI1LjAuMVs1MDBdIHRvIDEw
LjEyNS4wLjJbNTAwXSAoNTQ4IGJ5dGVzKQovdmFyL2xvZy9zeXNsb2c6Tm92IDE2IDE2OjMw
OjIyIHJvdXRlciBjaGFyb246IDA1W0lLRV0gc2VuZGluZyByZXRyYW5zbWl0IDUgb2YgcmVx
dWVzdCBtZXNzYWdlIElEIDAsIHNlcSAxCi92YXIvbG9nL3N5c2xvZzpOb3YgMTYgMTY6MzA6
MjIgcm91dGVyIGNoYXJvbjogMDVbTkVUXSBzZW5kaW5nIHBhY2tldDogZnJvbSAxMC4xMjUu
MC4xWzUwMF0gdG8gMTAuMTI1LjAuMls1MDBdICg1NDggYnl0ZXMpCi92YXIvbG9nL3N5c2xv
ZzpOb3YgMTYgMTY6MzE6Mzcgcm91dGVyIGNoYXJvbjogMTVbS05MXSBjcmVhdGluZyBkZWxl
dGUgam9iIGZvciBDSElMRF9TQSBFU1AvMHgwMDAwMDAwMC8xMC4xMjUuMC4yCi92YXIvbG9n
L3N5c2xvZzpOb3YgMTYgMTY6MzE6Mzcgcm91dGVyIGNoYXJvbjogMTNbSk9CXSBDSElMRF9T
QSBFU1AvMHgwMDAwMDAwMC8xMC4xMjUuMC4yIG5vdCBmb3VuZCBmb3IgZGVsZXRlCi92YXIv
bG9nL3N5c2xvZzpOb3YgMTYgMTY6MzE6Mzggcm91dGVyIGNoYXJvbjogMDlbSUtFXSBnaXZp
bmcgdXAgYWZ0ZXIgNSByZXRyYW5zbWl0cwovdmFyL2xvZy9zeXNsb2c6Tm92IDE2IDE2OjMx
OjM4IHJvdXRlciBjaGFyb246IDA5W0lLRV0gZXN0YWJsaXNoaW5nIElLRV9TQSBmYWlsZWQs
IHBlZXIgbm90IHJlc3BvbmRpbmcK
--------------2C05DDEA35E9A2EB87B3BA3B--
