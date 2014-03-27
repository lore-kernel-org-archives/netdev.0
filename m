From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [patch net-next RFC v2 2/6] skbuff: add "missed_flow"
	flag
Date: Thu, 27 Mar 2014 11:31:42 +0100
Message-ID: <5333FE0E.2090008@6wind.com>
References: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
 <1395851472-10524-3-git-send-email-jiri@resnulli.us>
Reply-To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
 jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org,
 dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1395851472-10524-3-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

TGUgMjYvMDMvMjAxNCAxNzozMSwgSmlyaSBQaXJrbyBhIMOpY3JpdCA6Cj4gVGhpcyBmbGFnIHNl
dHMgaW5jb21pbmcgc3dpdGNoIGRldmljZSBpbiBvcmRlciB0byBsZXQga25vdyB0aGF0IHRoZSBm
bG93Cj4gd2hpY2ggdGhlIHNrYiBpcyBwYXJ0IG9mIGlzIG1pc3NlZC4gTGlzdGVuZXIgbWF5IHJl
YWN0IHRvIGl0Cj4gYXBwcm9wcmlhdGVseSwKPgo+IFNpZ25lZC1vZmYtYnk6IEppcmkgUGlya28g
PGppcmlAcmVzbnVsbGkudXM+Cj4gLS0tCj4gICBpbmNsdWRlL2xpbnV4L2ZpbHRlci5oIHwgIDEg
Kwo+ICAgaW5jbHVkZS9saW51eC9za2J1ZmYuaCB8IDEzICsrKysrKysrKysrKysKPiAgIG5ldC9j
b3JlL2ZpbHRlci5jICAgICAgfCAgMyArKysKPiAgIDMgZmlsZXMgY2hhbmdlZCwgMTcgaW5zZXJ0
aW9ucygrKQo+Cj4gZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvZmlsdGVyLmggYi9pbmNsdWRl
L2xpbnV4L2ZpbHRlci5oCj4gaW5kZXggZTU2OGM4ZS4uMzhjN2MwNCAxMDA2NDQKPiAtLS0gYS9p
bmNsdWRlL2xpbnV4L2ZpbHRlci5oCj4gKysrIGIvaW5jbHVkZS9saW51eC9maWx0ZXIuaAo+IEBA
IC0xNTQsNiArMTU0LDcgQEAgZW51bSB7Cj4gICAJQlBGX1NfQU5DX1ZMQU5fVEFHLAo+ICAgCUJQ
Rl9TX0FOQ19WTEFOX1RBR19QUkVTRU5ULAo+ICAgCUJQRl9TX0FOQ19QQVlfT0ZGU0VULAo+ICsJ
QlBGX1NfQU5DX01JU1NFRF9GTE9XLAo+ICAgfTsKPgo+ICAgI2VuZGlmIC8qIF9fTElOVVhfRklM
VEVSX0hfXyAqLwo+IGRpZmYgLS1naXQgYS9pbmNsdWRlL2xpbnV4L3NrYnVmZi5oIGIvaW5jbHVk
ZS9saW51eC9za2J1ZmYuaAo+IGluZGV4IDAzZGI5NWEuLjAxMDBjMmYgMTAwNjQ0Cj4gLS0tIGEv
aW5jbHVkZS9saW51eC9za2J1ZmYuaAo+ICsrKyBiL2luY2x1ZGUvbGludXgvc2tidWZmLmgKPiBA
QCAtNTY3LDYgKzU2Nyw3IEBAIHN0cnVjdCBza19idWZmIHsKPiAgIAkgKiBoZWFkZXJzIGlmIG5l
ZWRlZAo+ICAgCSAqLwo+ICAgCV9fdTgJCQllbmNhcHN1bGF0aW9uOjE7Cj4gKwlfX3U4CQkJbWlz
c2VkX2Zsb3c6MTsKPiAgIAkvKiA2LzggYml0IGhvbGUgKGRlcGVuZGluZyBvbiBuZGlzY19ub2Rl
dHlwZSBwcmVzZW5jZSkgKi8KUGxlYXNlIGZpeCBhbHNvIHRoZSBjb21tZW50LgpfX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpkZXYgbWFpbGluZyBsaXN0CmRl
dkBvcGVudnN3aXRjaC5vcmcKaHR0cDovL29wZW52c3dpdGNoLm9yZy9tYWlsbWFuL2xpc3RpbmZv
L2Rldgo=
