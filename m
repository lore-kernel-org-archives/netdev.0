From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 10/13] net: add paged frag destructor to skb_fill_page_desc()
Date: Fri, 22 Jul 2011 21:58:51 +0200
Message-ID: <CAHXqBFLQFKqK=ORpDQx6s2ud8mWkx=YC_AT60GVS+4XK0H61pw@mail.gmail.com>
References: <1311340095.12772.57.camel@zakaz.uk.xensource.com> <1311340653-19336-10-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"James E.J. Bottomley" <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	"Pekka Savola (ipv6)" <pekkas-UjJjq++bwZ7HOG6cAo2yLw@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devel-s9riP+hp16TNLxjTenLetw@public.gmane.org
To: Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1311340653-19336-10-git-send-email-ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

MjAxMS83LzIyIElhbiBDYW1wYmVsbCA8aWFuLmNhbXBiZWxsQGNpdHJpeC5jb20+Ogo+IGRpZmYg
LS1naXQgYS9pbmNsdWRlL2xpbnV4L3NrYnVmZi5oIGIvaW5jbHVkZS9saW51eC9za2J1ZmYuaAo+
IGluZGV4IDk4MThmZTIuLmZhZWU4ZDMgMTAwNjQ0Cj4gLS0tIGEvaW5jbHVkZS9saW51eC9za2J1
ZmYuaAo+ICsrKyBiL2luY2x1ZGUvbGludXgvc2tidWZmLmgKPiBAQCAtMTEzNCwxMiArMTEzNCwx
NCBAQCBzdGF0aWMgaW5saW5lIGludCBza2JfcGFnZWxlbihjb25zdCBzdHJ1Y3Qgc2tfYnVmZiAq
c2tiKQo+IMKgKiBEb2VzIG5vdCB0YWtlIGFueSBhZGRpdGlvbmFsIHJlZmVyZW5jZSBvbiB0aGUg
ZnJhZ21lbnQuCj4gwqAqLwo+IMKgc3RhdGljIGlubGluZSB2b2lkIF9fc2tiX2ZpbGxfcGFnZV9k
ZXNjKHN0cnVjdCBza19idWZmICpza2IsIGludCBpLAo+IC0gwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgc3RydWN0IHBhZ2UgKnBhZ2UsIGlu
dCBvZmYsIGludCBzaXplKQo+ICsgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgc3RydWN0IHBhZ2UgKnBhZ2UsCj4gKyDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBzdHJ1Y3Qgc2tiX2Zy
YWdfZGVzdHJ1Y3RvciAqZGVzdHJveSwKPiArIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIGludCBvZmYsIGludCBzaXplKQo+IMKgewo+IMKg
IMKgIMKgIMKgc2tiX2ZyYWdfdCAqZnJhZyA9ICZza2Jfc2hpbmZvKHNrYiktPmZyYWdzW2ldOwo+
Cj4gwqAgwqAgwqAgwqBmcmFnLT5wYWdlLnAgwqAgwqAgwqAgwqAgwqAgwqAgwqA9IHBhZ2U7Cj4g
LSDCoCDCoCDCoCBmcmFnLT5wYWdlLmRlc3RydWN0b3IgwqAgwqAgPSBOVUxMOwo+ICsgwqAgwqAg
wqAgZnJhZy0+cGFnZS5kZXN0cnVjdG9yIMKgIMKgID0gZGVzdHJveTsKPiDCoCDCoCDCoCDCoGZy
YWctPnBhZ2Vfb2Zmc2V0IMKgIMKgIMKgIMKgID0gb2ZmOwo+IMKgIMKgIMKgIMKgZnJhZy0+c2l6
ZSDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoD0gc2l6ZTsKPiDCoH0KCllvdSBjb3VsZCBqdXN0IHJl
bmFtZSB0aGlzIGZ1bmN0aW9uIHRvIGUuZy4KX19za2JfZmlsbF9mcmFnaWxlX3BhZ2VfZGVzYygp
IChvciB3aGF0ZXZlciBuYW1lKSBhZGQgYW4gaW5saW5lCndyYXBwZXIgY2FsbGluZyBpdCB3aXRo
IGRlc3Ryb3kgPT0gTlVMTC4gVGhpcyB3aWxsIGF2b2lkIHRvdWNoaW5nIGFsbAp0aG9zZSBkcml2
ZXJzIHdoaWNoIHdvbid0IGV2ZXIgbmVlZCB0aGlzIGZ1bmN0aW9uYWxpdHkuCgpCZXN0IFJlZ2Fy
ZHMsCk1pY2hhxYIgTWlyb3PFgmF3Cg==
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
