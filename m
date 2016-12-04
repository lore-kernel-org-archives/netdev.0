From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] mlx4: Use kernel sizeof and alloc styles
Date: Sun, 04 Dec 2016 14:56:32 -0800
Message-ID: <1480892192.4534.11.camel@perches.com>
References: <8b20668cb08cce8b4af872863440e149bd25fa94.1480882180.git.joe@perches.com>
         <1480885139.18162.484.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-y53oe6CwC0cEvahfeSlP"
Cc: Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1480885139.18162.484.camel-XN9IlZ5yJG9HTL0Zs8A6p+yfmBU6pStAUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-y53oe6CwC0cEvahfeSlP
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

On Sun, 2016-12-04 at 12:58 -0800, Eric Dumazet wrote:
> On Sun, 2016-12-04 at 12:11 -0800, Joe Perches wrote:
> > Convert sizeof foo to sizeof(foo) and allocations with multiplications
> > to the appropriate kcalloc/kmalloc_array styles.
> > 
> > Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
> > ---
> 
> Gah.
> 
> This is one of the hotest NIC driver on linux at this moment, 
> with XDP and other efforts going on.
> 
> Some kmalloc() are becoming kmalloc_node() in some dev branches, and
> there is no kmalloc_array_node() yet.

Well that kmalloc_array_node, like this patch, is pretty trivial to add.
Something like the attached for kmalloc_array_node and kcalloc_node.

> This kind of patch is making rebases/backports very painful.

That's really not an issue for me.

> Could we wait ~6 months before doing such cleanup/changes please ?

This is certainly a trivial patch that could be
done at almost any time.

> If you believe a bug needs a fix, please send a patch to address it.
> 
> Thanks.

No worries.
--=-y53oe6CwC0cEvahfeSlP
Content-Disposition: attachment; filename="slab.diff"
Content-Type: text/x-patch; name="slab.diff"; charset="ISO-8859-1"
Content-Transfer-Encoding: base64

IGluY2x1ZGUvbGludXgvc2xhYi5oIHwgMzEgKysrKysrKysrKysrKysrKysrKysrKysrKysrKysr
KwogMSBmaWxlIGNoYW5nZWQsIDMxIGluc2VydGlvbnMoKykKCmRpZmYgLS1naXQgYS9pbmNsdWRl
L2xpbnV4L3NsYWIuaCBiL2luY2x1ZGUvbGludXgvc2xhYi5oCmluZGV4IDA4NGIxMmJhZDE5OC4u
ZDk4YzA3NzEzYzAzIDEwMDY0NAotLS0gYS9pbmNsdWRlL2xpbnV4L3NsYWIuaAorKysgYi9pbmNs
dWRlL2xpbnV4L3NsYWIuaApAQCAtNjQ3LDYgKzY0NywzNyBAQCBzdGF0aWMgaW5saW5lIHZvaWQg
Kmt6YWxsb2Nfbm9kZShzaXplX3Qgc2l6ZSwgZ2ZwX3QgZmxhZ3MsIGludCBub2RlKQogCXJldHVy
biBrbWFsbG9jX25vZGUoc2l6ZSwgZmxhZ3MgfCBfX0dGUF9aRVJPLCBub2RlKTsKIH0KIAorLyoq
CisgKiBrbWFsbG9jX2FycmF5X25vZGUgLSBhbGxvY2F0ZSBtZW1vcnkgZm9yIGFuIGFycmF5Cisg
KiBmcm9tIGEgcGFydGljdWxhciBtZW1vcnkgbm9kZS4KKyAqIEBuOiBudW1iZXIgb2YgZWxlbWVu
dHMuCisgKiBAc2l6ZTogZWxlbWVudCBzaXplLgorICogQGZsYWdzOiB0aGUgdHlwZSBvZiBtZW1v
cnkgdG8gYWxsb2NhdGUgKHNlZSBrbWFsbG9jKS4KKyAqIEBub2RlOiBtZW1vcnkgbm9kZSBmcm9t
IHdoaWNoIHRvIGFsbG9jYXRlCisgKi8KK3N0YXRpYyBpbmxpbmUgdm9pZCAqa21hbGxvY19hcnJh
eV9ub2RlKHNpemVfdCBuLCBzaXplX3Qgc2l6ZSwgZ2ZwX3QgZmxhZ3MsCisJCQkJICAgICAgIGlu
dCBub2RlKQoreworCWlmIChzaXplICE9IDAgJiYgbiA+IFNJWkVfTUFYIC8gc2l6ZSkKKwkJcmV0
dXJuIE5VTEw7CisJaWYgKF9fYnVpbHRpbl9jb25zdGFudF9wKG4pICYmIF9fYnVpbHRpbl9jb25z
dGFudF9wKHNpemUpKQorCQlyZXR1cm4ga21hbGxvY19ub2RlKG4gKiBzaXplLCBmbGFncywgbm9k
ZSk7CisJcmV0dXJuIF9fa21hbGxvY19ub2RlKG4gKiBzaXplLCBmbGFncywgbm9kZSk7Cit9CisK
Ky8qKgorICoga2NhbGxvY19ub2RlIC0gYWxsb2NhdGUgbWVtb3J5IGZvciBhbiBhcnJheSBmcm9t
IGEgcGFydGljdWxhciBtZW1vcnkgbm9kZS4KKyAqIFRoZSBtZW1vcnkgaXMgc2V0IHRvIHplcm8u
CisgKiBAbjogbnVtYmVyIG9mIGVsZW1lbnRzLgorICogQHNpemU6IGVsZW1lbnQgc2l6ZS4KKyAq
IEBmbGFnczogdGhlIHR5cGUgb2YgbWVtb3J5IHRvIGFsbG9jYXRlIChzZWUga21hbGxvYykuCisg
KiBAbm9kZTogbWVtb3J5IG5vZGUgZnJvbSB3aGljaCB0byBhbGxvY2F0ZQorICovCitzdGF0aWMg
aW5saW5lIHZvaWQgKmtjYWxsb2Nfbm9kZShzaXplX3Qgbiwgc2l6ZV90IHNpemUsIGdmcF90IGZs
YWdzLCBpbnQgbm9kZSkKK3sKKwlyZXR1cm4ga21hbGxvY19hcnJheV9ub2RlKG4sIHNpemUsIGZs
YWdzIHwgX19HRlBfWkVSTywgbm9kZSk7Cit9CisKIHVuc2lnbmVkIGludCBrbWVtX2NhY2hlX3Np
emUoc3RydWN0IGttZW1fY2FjaGUgKnMpOwogdm9pZCBfX2luaXQga21lbV9jYWNoZV9pbml0X2xh
dGUodm9pZCk7CiAK


--=-y53oe6CwC0cEvahfeSlP--

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
