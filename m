From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/ipv6: slab-out-of-bounds in ip6_tnl_xmit
Date: Mon, 24 Apr 2017 22:04:04 -0700
Message-ID: <CAM_iQpWnPgn0+-y34nGTB0byonLWCdf3_VAKcH8tK5fdzF4CBg@mail.gmail.com>
References: <CAAeHK+w-EYicrLHhBR0LHMMTc22GjsB=PTmgswm44w4VpfQ_hA@mail.gmail.com>
 <CAM_iQpXLHx=NhSNYU_o4F_V6nNXUHGBSdV=QQnML0B+HD7MbBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=94eb2c1979e6538087054df6a8c2
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpXLHx=NhSNYU_o4F_V6nNXUHGBSdV=QQnML0B+HD7MbBQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--94eb2c1979e6538087054df6a8c2
Content-Type: text/plain; charset=UTF-8

On Mon, Apr 24, 2017 at 9:47 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>
> We use ipv4 dst in ip6_tunnel and cast an IPv4 neigh key as an
> IPv6 address...
>
>
>                 neigh = dst_neigh_lookup(skb_dst(skb),
>                                          &ipv6_hdr(skb)->daddr);
>                 if (!neigh)
>                         goto tx_err_link_failure;
>
>                 addr6 = (struct in6_addr *)&neigh->primary_key; // <=== HERE
>                 addr_type = ipv6_addr_type(addr6);
>
>                 if (addr_type == IPV6_ADDR_ANY)
>                         addr6 = &ipv6_hdr(skb)->daddr;
>
>                 memcpy(&fl6->daddr, addr6, sizeof(fl6->daddr));
>
> Also the network header of the skb at this point should be still IPv4?

Please try the attached patch.

I am not sure how we could handle 4in6 case better than just relying on
the config of ip6 tunnel.

--94eb2c1979e6538087054df6a8c2
Content-Type: text/plain; charset=US-ASCII; name="ip6_tunnel.diff"
Content-Disposition: attachment; filename="ip6_tunnel.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j1x35b7z0

ZGlmZiAtLWdpdCBhL25ldC9pcHY2L2lwNl90dW5uZWwuYyBiL25ldC9pcHY2L2lwNl90dW5uZWwu
YwppbmRleCA3NWZhYzkzLi5hOTY5MmVjIDEwMDY0NAotLS0gYS9uZXQvaXB2Ni9pcDZfdHVubmVs
LmMKKysrIGIvbmV0L2lwdjYvaXA2X3R1bm5lbC5jCkBAIC0xMDM3LDcgKzEwMzcsNyBAQCBpbnQg
aXA2X3RubF94bWl0KHN0cnVjdCBza19idWZmICpza2IsIHN0cnVjdCBuZXRfZGV2aWNlICpkZXYs
IF9fdTggZHNmaWVsZCwKIAlzdHJ1Y3QgaXA2X3RubCAqdCA9IG5ldGRldl9wcml2KGRldik7CiAJ
c3RydWN0IG5ldCAqbmV0ID0gdC0+bmV0OwogCXN0cnVjdCBuZXRfZGV2aWNlX3N0YXRzICpzdGF0
cyA9ICZ0LT5kZXYtPnN0YXRzOwotCXN0cnVjdCBpcHY2aGRyICppcHY2aCA9IGlwdjZfaGRyKHNr
Yik7CisJc3RydWN0IGlwdjZoZHIgKmlwdjZoOwogCXN0cnVjdCBpcHY2X3RlbF90eG9wdGlvbiBv
cHQ7CiAJc3RydWN0IGRzdF9lbnRyeSAqZHN0ID0gTlVMTCwgKm5kc3QgPSBOVUxMOwogCXN0cnVj
dCBuZXRfZGV2aWNlICp0ZGV2OwpAQCAtMTA1NywyNiArMTA1NywyOCBAQCBpbnQgaXA2X3RubF94
bWl0KHN0cnVjdCBza19idWZmICpza2IsIHN0cnVjdCBuZXRfZGV2aWNlICpkZXYsIF9fdTggZHNm
aWVsZCwKIAogCS8qIE5CTUEgdHVubmVsICovCiAJaWYgKGlwdjZfYWRkcl9hbnkoJnQtPnBhcm1z
LnJhZGRyKSkgewotCQlzdHJ1Y3QgaW42X2FkZHIgKmFkZHI2OwotCQlzdHJ1Y3QgbmVpZ2hib3Vy
ICpuZWlnaDsKLQkJaW50IGFkZHJfdHlwZTsKKwkJaWYgKHNrYi0+cHJvdG9jb2wgPT0gaHRvbnMo
RVRIX1BfSVBWNikpIHsKKwkJCXN0cnVjdCBpbjZfYWRkciAqYWRkcjY7CisJCQlzdHJ1Y3QgbmVp
Z2hib3VyICpuZWlnaDsKKwkJCWludCBhZGRyX3R5cGU7CiAKLQkJaWYgKCFza2JfZHN0KHNrYikp
Ci0JCQlnb3RvIHR4X2Vycl9saW5rX2ZhaWx1cmU7CisJCQlpZiAoIXNrYl9kc3Qoc2tiKSkKKwkJ
CQlnb3RvIHR4X2Vycl9saW5rX2ZhaWx1cmU7CiAKLQkJbmVpZ2ggPSBkc3RfbmVpZ2hfbG9va3Vw
KHNrYl9kc3Qoc2tiKSwKLQkJCQkJICZpcHY2X2hkcihza2IpLT5kYWRkcik7Ci0JCWlmICghbmVp
Z2gpCi0JCQlnb3RvIHR4X2Vycl9saW5rX2ZhaWx1cmU7CisJCQluZWlnaCA9IGRzdF9uZWlnaF9s
b29rdXAoc2tiX2RzdChza2IpLAorCQkJCQkJICZpcHY2X2hkcihza2IpLT5kYWRkcik7CisJCQlp
ZiAoIW5laWdoKQorCQkJCWdvdG8gdHhfZXJyX2xpbmtfZmFpbHVyZTsKIAotCQlhZGRyNiA9IChz
dHJ1Y3QgaW42X2FkZHIgKikmbmVpZ2gtPnByaW1hcnlfa2V5OwotCQlhZGRyX3R5cGUgPSBpcHY2
X2FkZHJfdHlwZShhZGRyNik7CisJCQlhZGRyNiA9IChzdHJ1Y3QgaW42X2FkZHIgKikmbmVpZ2gt
PnByaW1hcnlfa2V5OworCQkJYWRkcl90eXBlID0gaXB2Nl9hZGRyX3R5cGUoYWRkcjYpOwogCi0J
CWlmIChhZGRyX3R5cGUgPT0gSVBWNl9BRERSX0FOWSkKLQkJCWFkZHI2ID0gJmlwdjZfaGRyKHNr
YiktPmRhZGRyOworCQkJaWYgKGFkZHJfdHlwZSA9PSBJUFY2X0FERFJfQU5ZKQorCQkJCWFkZHI2
ID0gJmlwdjZfaGRyKHNrYiktPmRhZGRyOwogCi0JCW1lbWNweSgmZmw2LT5kYWRkciwgYWRkcjYs
IHNpemVvZihmbDYtPmRhZGRyKSk7Ci0JCW5laWdoX3JlbGVhc2UobmVpZ2gpOworCQkJbWVtY3B5
KCZmbDYtPmRhZGRyLCBhZGRyNiwgc2l6ZW9mKGZsNi0+ZGFkZHIpKTsKKwkJCW5laWdoX3JlbGVh
c2UobmVpZ2gpOworCQl9CiAJfSBlbHNlIGlmICghKHQtPnBhcm1zLmZsYWdzICYKIAkJICAgICAo
SVA2X1ROTF9GX1VTRV9PUklHX1RDTEFTUyB8IElQNl9UTkxfRl9VU0VfT1JJR19GV01BUkspKSkg
ewogCQkvKiBlbmFibGUgdGhlIGNhY2hlIG9ubHkgb25seSBpZiB0aGUgcm91dGluZyBkZWNpc2lv
biBkb2VzCg==
--94eb2c1979e6538087054df6a8c2--
