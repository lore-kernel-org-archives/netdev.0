From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: [3.8-rc1] Networking problems after pulling-in net.git#master
Date: Sun, 23 Dec 2012 15:14:59 +0100
Message-ID: <CA+icZUV4WEu6xp=-TyHH2z4Zcz8g0iHY2ZVk-jBJNt1azcXa2A@mail.gmail.com>
References: <CA+icZUXJeWNceo_y-TSUVzXmjbrauWmCdkgW3EJtr_vpbcrk-A@mail.gmail.com>
	<20121223114213.GB8386@liondog.tnic>
	<CA+icZUXeddp5UZ10ZWTsWLnmegHGJ+VHnr4=oAm34hXgHD2FDg@mail.gmail.com>
	<CA+icZUU2OdNq5WKd7abNNe2eevxZBbMRS0eBGyU_rzjVBAgcOg@mail.gmail.com>
	<CA+icZUVxdp-Lcf4FLfY-80qvVsTQn-ajfh8vn2T=FC6-QbLv7w@mail.gmail.com>
	<CAM_iQpVdqYceHejqyQOn5wqj-xQFjn6E4u5ws4MuoOd=SiVtww@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7b6777f2bd30d904d185b4f0
Cc: Borislav Petkov <bp@alien8.de>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpVdqYceHejqyQOn5wqj-xQFjn6E4u5ws4MuoOd=SiVtww@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--047d7b6777f2bd30d904d185b4f0
Content-Type: text/plain; charset=UTF-8

On Sun, Dec 23, 2012 at 2:44 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Sun, Dec 23, 2012 at 9:19 PM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
>>
>> The culprit commit here seems to be...
>>
>> commit 9650388b5c56578fdccc79c57a8c82fb92b8e7f1
>> Author: Eric Dumazet <edumazet@google.com>
>> Date:   Fri Dec 21 07:32:10 2012 +0000
>>
>>     ipv4: arp: fix a lockdep splat in arp_solicit()
>
> Can you try the following one-line fix?
>
> Thanks.
>
> ------------>
>
> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index 1169ed4..75e0d7c 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -365,7 +365,7 @@ static void arp_solicit(struct neighbour *neigh,
> struct sk_buff *skb)
>                         pr_debug("trying to ucast probe in NUD_INVALID\n");
>                 neigh_ha_snapshot(dst_ha, neigh, dev);
>         } else {
> -               memset(dst_ha, 0, dev->addr_len);
> +               memcpy(dst_ha, dev->broadcast, MAX_ADDR_LEN);
>                 probes -= neigh->parms->app_probes;
>                 if (probes < 0) {
>  #ifdef CONFIG_ARPD

[ CCing Eric ]

YES, thie fixes my problem.
But your patch was somehow malformed, so I attached mine.

- Sedat -

--047d7b6777f2bd30d904d185b4f0
Content-Type: application/octet-stream;
	name="0001-ipv4-arp-Fixup-to-commit-9650388b5c56578fdccc79c57a8.patch"
Content-Disposition: attachment;
	filename="0001-ipv4-arp-Fixup-to-commit-9650388b5c56578fdccc79c57a8.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hb29bxt40

RnJvbSA0OGVhMmRjNzlmNjQ1OTRlYjJiYjRlOWIxOWNiNjliNzQxNTZlYTZhIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBTZWRhdCBEaWxlayA8c2VkYXQuZGlsZWtAZ21haWwuY29tPgpE
YXRlOiBTdW4sIDIzIERlYyAyMDEyIDE1OjAwOjU0ICswMTAwClN1YmplY3Q6IFtQQVRDSF0gaXB2
NDogYXJwOiBGaXh1cCB0byBjb21taXQKIDk2NTAzODhiNWM1NjU3OGZkY2NjNzljNTdhOGM4MmZi
OTJiOGU3ZjEKClBhdGNoIGlzIGZyb20gPGh0dHA6Ly9wYXRjaHdvcmsub3psYWJzLm9yZy9wYXRj
aC8yMDc5NzIvPgotLS0KIG5ldC9pcHY0L2FycC5jIHwgICAgMiArLQogMSBmaWxlIGNoYW5nZWQs
IDEgaW5zZXJ0aW9uKCspLCAxIGRlbGV0aW9uKC0pCgpkaWZmIC0tZ2l0IGEvbmV0L2lwdjQvYXJw
LmMgYi9uZXQvaXB2NC9hcnAuYwppbmRleCAxMTY5ZWQ0Li43NWUwZDdjIDEwMDY0NAotLS0gYS9u
ZXQvaXB2NC9hcnAuYworKysgYi9uZXQvaXB2NC9hcnAuYwpAQCAtMzY1LDcgKzM2NSw3IEBAIHN0
YXRpYyB2b2lkIGFycF9zb2xpY2l0KHN0cnVjdCBuZWlnaGJvdXIgKm5laWdoLCBzdHJ1Y3Qgc2tf
YnVmZiAqc2tiKQogCQkJcHJfZGVidWcoInRyeWluZyB0byB1Y2FzdCBwcm9iZSBpbiBOVURfSU5W
QUxJRFxuIik7CiAJCW5laWdoX2hhX3NuYXBzaG90KGRzdF9oYSwgbmVpZ2gsIGRldik7CiAJfSBl
bHNlIHsKLQkJbWVtc2V0KGRzdF9oYSwgMCwgZGV2LT5hZGRyX2xlbik7CisJCW1lbWNweShkc3Rf
aGEsIGRldi0+YnJvYWRjYXN0LCBNQVhfQUREUl9MRU4pOwogCQlwcm9iZXMgLT0gbmVpZ2gtPnBh
cm1zLT5hcHBfcHJvYmVzOwogCQlpZiAocHJvYmVzIDwgMCkgewogI2lmZGVmIENPTkZJR19BUlBE
Ci0tIAoxLjcuOS41Cgo=
--047d7b6777f2bd30d904d185b4f0--
