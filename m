From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: net: heap out-of-bounds in
 fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone
Date: Mon, 6 Mar 2017 16:41:02 -0700
Message-ID: <14c01aea-6c2f-6ba5-6aee-52c55f410da7@cumulusnetworks.com>
References: <CACT4Y+YrA45diWz_8f4St8oX6aTC1kuGXMUvniGRbqXSGwawZQ@mail.gmail.com>
 <f707c195-251f-6058-5f4c-d55710533b11@cumulusnetworks.com>
 <CACT4Y+YCPxKkaZBfAabxtAV71R0ghLT-vUKVewJpm9wb2GXaEQ@mail.gmail.com>
 <1488658514.9415.356.camel@edumazet-glaptop3.roam.corp.google.com>
 <4e4d7d51-82de-b21e-cb5d-d804f7b88999@cumulusnetworks.com>
 <CACT4Y+Z1MvKbb35-jhaY=jEoR+t2u2TiUpkCR_oG3=VNmKjqvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------1A0E691925F1F9471C290CC7"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+Z1MvKbb35-jhaY=jEoR+t2u2TiUpkCR_oG3=VNmKjqvQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------1A0E691925F1F9471C290CC7
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

On 3/6/17 11:51 AM, Dmitry Vyukov wrote:
> We hit it several thousand times, but we get only several dozens of
> crashes per day on ~80 VMs. So if you try to reproduce it on a single
> machine it can take days for a single crash.
> If you are ready to go that route, here are some instructions on
> setting up syzkaller:
> https://github.com/google/syzkaller
> You also need kernel built with CONFIG_KASAN.

ack and I have it setup on ubuntu 16.10 which has a fairly new compiler.

> I am ready to help with resolving any issues.
> 
> Another possible route is if you give me a patch with some additional
> WARNINGs. Then I can deploy it to bots and collect stacks.

try the attached.

--------------1A0E691925F1F9471C290CC7
Content-Type: text/plain; charset=UTF-8; x-mac-type="0"; x-mac-creator="0";
 name="ipv6-debug.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="ipv6-debug.patch"

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L2RzdC5oIGIvaW5jbHVkZS9uZXQvZHN0LmgKaW5k
ZXggMDQ5YWYzM2RhM2I2Li5kMTY0ZWI4Y2VhYjggMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbmV0
L2RzdC5oCisrKyBiL2luY2x1ZGUvbmV0L2RzdC5oCkBAIC01OCw2ICs1OCw3IEBAIHN0cnVj
dCBkc3RfZW50cnkgewogI2RlZmluZSBEU1RfWEZSTV9UVU5ORUwJCTB4MDA4MAogI2RlZmlu
ZSBEU1RfWEZSTV9RVUVVRQkJMHgwMTAwCiAjZGVmaW5lIERTVF9NRVRBREFUQQkJMHgwMjAw
CisjZGVmaW5lIERTVF9JTl9GSUIJCTB4MDQwMAogCiAJc2hvcnQJCQllcnJvcjsKIApkaWZm
IC0tZ2l0IGEvbmV0L2NvcmUvZHN0LmMgYi9uZXQvY29yZS9kc3QuYwppbmRleCA5NjBlNTAz
YjVhNTIuLmM5ODQ0N2ZlODUxMCAxMDA2NDQKLS0tIGEvbmV0L2NvcmUvZHN0LmMKKysrIGIv
bmV0L2NvcmUvZHN0LmMKQEAgLTIzMiw2ICsyMzIsOSBAQCB2b2lkIF9fZHN0X2ZyZWUoc3Ry
dWN0IGRzdF9lbnRyeSAqZHN0KQogewogCXNwaW5fbG9ja19iaCgmZHN0X2dhcmJhZ2UubG9j
ayk7CiAJX19fZHN0X2ZyZWUoZHN0KTsKK2lmIChkc3QtPmZsYWdzICYgRFNUX0lOX0ZJQikK
Kwlwcl93YXJuKCJkc3QgJXAgaXMgbWFya2VkIGFzIGluIGZpYlxuIiwgZHN0KTsKKy8vV0FS
Tl9PTihkc3QtPmZsYWdzICYgRFNUX0lOX0ZJQik7CiAJZHN0LT5uZXh0ID0gZHN0X2dhcmJh
Z2UubGlzdDsKIAlkc3RfZ2FyYmFnZS5saXN0ID0gZHN0OwogCWlmIChkc3RfZ2FyYmFnZS50
aW1lcl9pbmMgPiBEU1RfR0NfSU5DKSB7CmRpZmYgLS1naXQgYS9uZXQvaXB2Ni9pcDZfZmli
LmMgYi9uZXQvaXB2Ni9pcDZfZmliLmMKaW5kZXggZTQyNjY3NDZlNGEyLi5hNGQ1NWJhMDBh
NDMgMTAwNjQ0Ci0tLSBhL25ldC9pcHY2L2lwNl9maWIuYworKysgYi9uZXQvaXB2Ni9pcDZf
ZmliLmMKQEAgLTE1NSw2ICsxNTUsNyBAQCBzdGF0aWMgdm9pZCBub2RlX2ZyZWUoc3RydWN0
IGZpYjZfbm9kZSAqZm4pCiAKIHN0YXRpYyB2b2lkIHJ0Nl9yY3VfZnJlZShzdHJ1Y3QgcnQ2
X2luZm8gKnJ0KQogeworV0FSTl9PTihydC0+ZHN0LmZsYWdzICYgRFNUX0lOX0ZJQik7CiAJ
Y2FsbF9yY3UoJnJ0LT5kc3QucmN1X2hlYWQsIGRzdF9yY3VfZnJlZSk7CiB9CiAKQEAgLTg3
OCw2ICs4NzksNyBAQCBzdGF0aWMgaW50IGZpYjZfYWRkX3J0Mm5vZGUoc3RydWN0IGZpYjZf
bm9kZSAqZm4sIHN0cnVjdCBydDZfaW5mbyAqcnQsCiAJCQlyZXR1cm4gZXJyOwogCiAJCXJ0
LT5kc3QucnQ2X25leHQgPSBpdGVyOworCQlydC0+ZHN0LmZsYWdzIHw9IERTVF9JTl9GSUI7
CiAJCSppbnMgPSBydDsKIAkJcnQtPnJ0Nmlfbm9kZSA9IGZuOwogCQlhdG9taWNfaW5jKCZy
dC0+cnQ2aV9yZWYpOwpAQCAtOTA3LDYgKzkwOSw3IEBAIHN0YXRpYyBpbnQgZmliNl9hZGRf
cnQybm9kZShzdHJ1Y3QgZmliNl9ub2RlICpmbiwgc3RydWN0IHJ0Nl9pbmZvICpydCwKIAkJ
KmlucyA9IHJ0OwogCQlydC0+cnQ2aV9ub2RlID0gZm47CiAJCXJ0LT5kc3QucnQ2X25leHQg
PSBpdGVyLT5kc3QucnQ2X25leHQ7CisJCXJ0LT5kc3QuZmxhZ3MgfD0gRFNUX0lOX0ZJQjsK
IAkJYXRvbWljX2luYygmcnQtPnJ0NmlfcmVmKTsKIAkJaWYgKCFpbmZvLT5za2lwX25vdGlm
eSkKIAkJCWluZXQ2X3J0X25vdGlmeShSVE1fTkVXUk9VVEUsIHJ0LCBpbmZvLCBOTE1fRl9S
RVBMQUNFKTsKQEAgLTk3NCw2ICs5NzcsMjAgQEAgaW50IGZpYjZfYWRkKHN0cnVjdCBmaWI2
X25vZGUgKnJvb3QsIHN0cnVjdCBydDZfaW5mbyAqcnQsCiAJCQkgIWF0b21pY19yZWFkKCZy
dC0+ZHN0Ll9fcmVmY250KSkpCiAJCXJldHVybiAtRUlOVkFMOwogCitpZiAocnQtPmRzdC5v
cHMtPmZhbWlseSAhPSBBRl9JTkVUNikgeworCXByX3dhcm4oImZpYjZfYWRkOiBhZGRpbmcg
cnQgd2l0aCBmYW1pbHkgaXMgJWQgZHN0IGZsYWdzICV4XG4iLAorCQlydC0+ZHN0Lm9wcy0+
ZmFtaWx5LCBydC0+ZHN0LmZsYWdzKTsKKworCVdBUk5fT04oMSk7Cit9CisvKiBkc3QubmV4
dCByZWFsbHkgc2hvdWxkIG5vdCBiZSBzZXQgYXQgdGhpcyBwb2ludCAqLworaWYgKHJ0LT5k
c3QubmV4dCAmJiBydC0+ZHN0Lm5leHQtPm9wcy0+ZmFtaWx5ICE9IEFGX0lORVQ2KSB7CisJ
cHJfd2FybigiZmliNl9hZGQ6IGFkZGluZyBydCB3aXRoIGJhZCBuZXh0IC0tIGZhbWlseSAl
ZCBkc3QgZmxhZ3MgJXhcbiIsCisJCXJ0LT5kc3QubmV4dC0+b3BzLT5mYW1pbHksIHJ0LT5k
c3QubmV4dC0+ZmxhZ3MpOworCisJV0FSTl9PTigxKTsKK30KKwogCWlmIChpbmZvLT5ubGgp
IHsKIAkJaWYgKCEoaW5mby0+bmxoLT5ubG1zZ19mbGFncyAmIE5MTV9GX0NSRUFURSkpCiAJ
CQlhbGxvd19jcmVhdGUgPSAwOwpAQCAtMTQ0NCw2ICsxNDYxLDcgQEAgc3RhdGljIHZvaWQg
ZmliNl9kZWxfcm91dGUoc3RydWN0IGZpYjZfbm9kZSAqZm4sIHN0cnVjdCBydDZfaW5mbyAq
KnJ0cCwKIAlyZWFkX3VubG9jaygmbmV0LT5pcHY2LmZpYjZfd2Fsa2VyX2xvY2spOwogCiAJ
cnQtPmRzdC5ydDZfbmV4dCA9IE5VTEw7CisJcnQtPmRzdC5mbGFncyAmPSB+RFNUX0lOX0ZJ
QjsKIAogCS8qIElmIGl0IHdhcyBsYXN0IHJvdXRlLCBleHB1bmdlIGl0cyByYWRpeCB0cmVl
IG5vZGUgKi8KIAlpZiAoIWZuLT5sZWFmKSB7CmRpZmYgLS1naXQgYS9uZXQvaXB2Ni9yb3V0
ZS5jIGIvbmV0L2lwdjYvcm91dGUuYwppbmRleCAyMjliZmNjNDUxZWYuLmU5MWQ3ODcxY2Nm
YyAxMDA2NDQKLS0tIGEvbmV0L2lwdjYvcm91dGUuYworKysgYi9uZXQvaXB2Ni9yb3V0ZS5j
CkBAIC0xMTM1LDYgKzExMzUsOCBAQCBzdHJ1Y3QgcnQ2X2luZm8gKmlwNl9wb2xfcm91dGUo
c3RydWN0IG5ldCAqbmV0LCBzdHJ1Y3QgZmliNl90YWJsZSAqdGFibGUsCiAKIAkJZHN0X2hv
bGQoJnVuY2FjaGVkX3J0LT5kc3QpOwogCisJCXVuY2FjaGVkX3J0LT5kc3QuZmxhZ3MgJj0g
fkRTVF9JTl9GSUI7CisKIAkJdHJhY2VfZmliNl90YWJsZV9sb29rdXAobmV0LCB1bmNhY2hl
ZF9ydCwgdGFibGUtPnRiNl9pZCwgZmw2KTsKIAkJcmV0dXJuIHVuY2FjaGVkX3J0OwogCkBA
IC0xMTYwLDYgKzExNjIsNyBAQCBzdHJ1Y3QgcnQ2X2luZm8gKmlwNl9wb2xfcm91dGUoc3Ry
dWN0IG5ldCAqbmV0LCBzdHJ1Y3QgZmliNl90YWJsZSAqdGFibGUsCiAJCQlkc3RfcmVsZWFz
ZSgmcnQtPmRzdCk7CiAJCX0KIAorCQlwY3B1X3J0LT5kc3QuZmxhZ3MgJj0gfkRTVF9JTl9G
SUI7CiAJCXRyYWNlX2ZpYjZfdGFibGVfbG9va3VwKG5ldCwgcGNwdV9ydCwgdGFibGUtPnRi
Nl9pZCwgZmw2KTsKIAkJcmV0dXJuIHBjcHVfcnQ7CiAK
--------------1A0E691925F1F9471C290CC7--
