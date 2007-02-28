From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: TCP minisock tcp_create_openreq_child() typo?
Date: Wed, 28 Feb 2007 09:10:10 -0300
Message-ID: <39e6f6c70702280410k2d13afc7k1f870c73b6862676@mail.gmail.com>
References: <200702281203.38112@nienna>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_33857_13348391.1172664610218"
Cc: netdev@vger.kernel.org
To: "KOVACS Krisztian" <hidden@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.230]:5414 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932165AbXB1MKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 07:10:11 -0500
Received: by nz-out-0506.google.com with SMTP id s1so126625nze
        for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 04:10:10 -0800 (PST)
In-Reply-To: <200702281203.38112@nienna>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_33857_13348391.1172664610218
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 2/28/07, KOVACS Krisztian <hidden@balabit.hu> wrote:
>
>   Hi,
>
>   While reading TCP minisock code I've found this suspiciously looking
> code fragment:
>
> - 8< -
> struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req, struct sk_buff *skb)
> {
>         struct sock *newsk = inet_csk_clone(sk, req, GFP_ATOMIC);
>
>         if (newsk != NULL) {
>                 const struct inet_request_sock *ireq = inet_rsk(req);
>                 struct tcp_request_sock *treq = tcp_rsk(req);
>                 struct inet_connection_sock *newicsk = inet_csk(sk);
>                 struct tcp_sock *newtp;
> - 8< -
>
>   The above code initializes newicsk to inet_csk(sk), isn't that supposed
> to be inet_csk(newsk)?  As far as I can tell this might leave
> icsk_ack.last_seg_size zero even if we do have received data.

Good catch!

David, please apply the attached patch.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Thanks Krisztian!

- Arnaldo

------=_Part_33857_13348391.1172664610218
Content-Type: text/x-patch; name=newicsk.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_eypq7kqv
Content-Disposition: attachment; filename="newicsk.patch"

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L3RjcF9taW5pc29ja3MuYyBiL25ldC9pcHY0L3RjcF9taW5p
c29ja3MuYwppbmRleCAzMGIxZTUyLi42YjVjNjRmIDEwMDY0NAotLS0gYS9uZXQvaXB2NC90Y3Bf
bWluaXNvY2tzLmMKKysrIGIvbmV0L2lwdjQvdGNwX21pbmlzb2Nrcy5jCkBAIC0zODEsNyArMzgx
LDcgQEAgc3RydWN0IHNvY2sgKnRjcF9jcmVhdGVfb3BlbnJlcV9jaGlsZChzdHJ1Y3Qgc29jayAq
c2ssIHN0cnVjdCByZXF1ZXN0X3NvY2sgKnJlcSwKIAlpZiAobmV3c2sgIT0gTlVMTCkgewogCQlj
b25zdCBzdHJ1Y3QgaW5ldF9yZXF1ZXN0X3NvY2sgKmlyZXEgPSBpbmV0X3JzayhyZXEpOwogCQlz
dHJ1Y3QgdGNwX3JlcXVlc3Rfc29jayAqdHJlcSA9IHRjcF9yc2socmVxKTsKLQkJc3RydWN0IGlu
ZXRfY29ubmVjdGlvbl9zb2NrICpuZXdpY3NrID0gaW5ldF9jc2soc2spOworCQlzdHJ1Y3QgaW5l
dF9jb25uZWN0aW9uX3NvY2sgKm5ld2ljc2sgPSBpbmV0X2NzayhuZXdzayk7CiAJCXN0cnVjdCB0
Y3Bfc29jayAqbmV3dHA7CiAKIAkJLyogTm93IHNldHVwIHRjcF9zb2NrICovCg==
------=_Part_33857_13348391.1172664610218--
