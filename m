From: Eric Lemoine <eric.lemoine@gmail.com>
Subject: Re: LLTX and netif_stop_queue
Date: Mon, 3 Jan 2005 00:30:31 +0100
Message-ID: <5cac192f0501021530672a908a@mail.gmail.com>
References: <52llbwoaej.fsf@topspin.com>
	<20041217214432.07b7b21e.davem@davemloft.net>
	<1103484675.1050.158.camel@jzny.localdomain>
	<5cac192f04122210491d64d4b6@mail.gmail.com>
	<20041222202919.057b8331.davem@davemloft.net>
	<5cac192f0412230110628749e3@mail.gmail.com>
	<41CAF444.3000305@trash.net>
	<5cac192f04122408102129af43@mail.gmail.com>
	<1104240717.1100.66.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="----=_Part_709_5375345.1104708631807"
Cc: netdev@oss.sgi.com, Patrick McHardy <kaber@trash.net>,
	openib-general@openib.org, "David S. Miller" <davem@davemloft.net>
Return-path: <openib-general-bounces@openib.org>
To: hadi@cyberus.ca
In-Reply-To: <1104240717.1100.66.camel@jzny.localdomain>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

------=_Part_709_5375345.1104708631807
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 28 Dec 2004 08:31:57 -0500, jamal <hadi@cyberus.ca> wrote:
> On Fri, 2004-12-24 at 11:10, Eric Lemoine wrote:
> 
> > Yes but requiring drivers to release a lock that they should not even
> > be aware of doesn't sound good. Another way would be to keep
> > dev->queue_lock grabbed when entering start_xmit() and let the driver
> > drop it (and re-acquire it before it returns) only if it wishes so.
> > Although I don't like this too much either, that's the best way I can
> > think of up to now...
> 
> I am not a big fan of that patch either, but i cant think of a cleaner
> way to do it.
> The violation already happens with the LLTX flag. So maybe a big warning
> that says "Do this only if you driver is LLTX enabled". The other way to
> do it is put a check to see if LLTX is enabled before releasing that
> lock - but why the extra cycles? Driver writer should know.

Two (untested) patches implementing what I described above.

The first pach (sch_generic.patch) keeps queue_lock held in
qdisc_restart() when calling hard_start_xmit() of a LLTX driver. The
second (sungem.patch) makes sungem release queue_lock after grabbing
its private tx lock.

Note that the modifications made to qdisc_restart() are not compatible
with the current LLTX drivers. All LLTX drivers must be modified along
sungem.patch's lines. Take sungem.patch as an example of how things
must be done.

Patches apply to current davem bk snapshot.

-- 
Eric

------=_Part_709_5375345.1104708631807
Content-Type: application/octet-stream; name="sch_generic.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="sch_generic.patch"

PT09PT0gbmV0L3NjaGVkL3NjaF9nZW5lcmljLmMgMS4zMiB2cyBlZGl0ZWQgPT09PT0KLS0tIDEu
MzIvbmV0L3NjaGVkL3NjaF9nZW5lcmljLmMJMjAwNC0xMi0yOCAwNTo1MToyMCArMDE6MDAKKysr
IGVkaXRlZC9uZXQvc2NoZWQvc2NoX2dlbmVyaWMuYwkyMDA1LTAxLTAyIDIzOjU1OjE4ICswMTow
MApAQCAtMTA0LDkgKzEwNCwxNyBAQAogCQkgKiBsb2NraW5nIGFnYWluLiBUaGVzZSBjaGVja3Mg
YXJlIHdvcnRoIGl0IGJlY2F1c2UKIAkJICogZXZlbiB1bmNvbmdlc3RlZCBsb2NrcyBjYW4gYmUg
cXVpdGUgZXhwZW5zaXZlLgogCQkgKiBUaGUgZHJpdmVyIGNhbiBkbyB0cnlsb2NrIGxpa2UgaGVy
ZSB0b28sIGluIGNhc2UKLQkJICogb2YgbG9jayBjb25nZXN0aW9uIGl0IHNob3VsZCByZXR1cm4g
LTEgYW5kIHRoZSBwYWNrZXQKLQkJICogd2lsbCBiZSByZXF1ZXVlZC4KKwkJICogb2YgbG9jayBj
b25nZXN0aW9uIGl0IHNob3VsZCByZXR1cm4gTkVUREVWX1RYX0xPQ0tFRAorCQkgKiBhbmQgdGhl
IHBhY2tldCB3aWxsIGJlIHJlcXVldWVkLgorCQkgKiAKKwkJICogTm90ZTogd2hlbiB0aGUgZHJp
dmVyIGhhcyBMTFRYIHNldCBxdWV1ZV9sb2NrIGNhbm5vdAorCQkgKiBiZSBkcm9wcGVkIGluIGhl
cmUgaWYgd2Ugd2FudCB0byBhdm9pZCBoYXZpbmcgcGFja2V0cworCQkgKiBwYXNzaW5nIGVhY2hv
dmVyIGR1cmluZyB0cmFuc21pdC4gcXVldWVfbG9jayBjYW4gb25seQorCQkgKiBiZSBkcm9wcGVk
IGluIGhhcmRfc3RhcnRfeG1pdCgpIGFmdGVyIHByaXZhdGUgdHggbG9jayAKKwkJICogaGFzIGJl
ZW4gZ3JhYmJlZC4gSWYgaGFyZF9zdGFydF94bWl0KCkgZG9lcyByZWxlYXNlIAorCQkgKiBxdWV1
ZV9sb2NrIGl0IG11c3QgZ3JhYiBpdCBhZ2FpbiBiZWZvcmUgaXQgcmV0dXJucy4KIAkJICovCisK
IAkJaWYgKCFub2xvY2spIHsKIAkJCWlmICghc3Bpbl90cnlsb2NrKCZkZXYtPnhtaXRfbG9jaykp
IHsKIAkJCWNvbGxpc2lvbjoKQEAgLTEyOCwxMiArMTM2LDEyIEBACiAJCQl9CiAJCQkvKiBSZW1l
bWJlciB0aGF0IHRoZSBkcml2ZXIgaXMgZ3JhYmJlZCBieSB1cy4gKi8KIAkJCWRldi0+eG1pdF9s
b2NrX293bmVyID0gc21wX3Byb2Nlc3Nvcl9pZCgpOworCisJCQkvKiBBbmQgcmVsZWFzZSBxdWV1
ZSAqLworCQkJc3Bpbl91bmxvY2soJmRldi0+cXVldWVfbG9jayk7CiAJCX0KIAkJCiAJCXsKLQkJ
CS8qIEFuZCByZWxlYXNlIHF1ZXVlICovCi0JCQlzcGluX3VubG9jaygmZGV2LT5xdWV1ZV9sb2Nr
KTsKLQogCQkJaWYgKCFuZXRpZl9xdWV1ZV9zdG9wcGVkKGRldikpIHsKIAkJCQlpbnQgcmV0Owog
CQkJCWlmIChuZXRkZXZfbml0KQpAQCAtMTQ0LDE0ICsxNTIsMTIgQEAKIAkJCQkJaWYgKCFub2xv
Y2spIHsKIAkJCQkJCWRldi0+eG1pdF9sb2NrX293bmVyID0gLTE7CiAJCQkJCQlzcGluX3VubG9j
aygmZGV2LT54bWl0X2xvY2spOworCQkJCQkJc3Bpbl9sb2NrKCZkZXYtPnF1ZXVlX2xvY2spOwog
CQkJCQl9Ci0JCQkJCXNwaW5fbG9jaygmZGV2LT5xdWV1ZV9sb2NrKTsKIAkJCQkJcmV0dXJuIC0x
OwogCQkJCX0KLQkJCQlpZiAocmV0ID09IE5FVERFVl9UWF9MT0NLRUQgJiYgbm9sb2NrKSB7Ci0J
CQkJCXNwaW5fbG9jaygmZGV2LT5xdWV1ZV9sb2NrKTsKKwkJCQlpZiAocmV0ID09IE5FVERFVl9U
WF9MT0NLRUQgJiYgbm9sb2NrKQogCQkJCQlnb3RvIGNvbGxpc2lvbjsgCi0JCQkJfQogCQkJfQog
CiAJCQkvKiBORVRERVZfVFhfQlVTWSAtIHdlIG5lZWQgdG8gcmVxdWV1ZSAqLwpAQCAtMTU5LDgg
KzE2NSw4IEBACiAJCQlpZiAoIW5vbG9jaykgeyAKIAkJCQlkZXYtPnhtaXRfbG9ja19vd25lciA9
IC0xOwogCQkJCXNwaW5fdW5sb2NrKCZkZXYtPnhtaXRfbG9jayk7CisJCQkJc3Bpbl9sb2NrKCZk
ZXYtPnF1ZXVlX2xvY2spOwogCQkJfSAKLQkJCXNwaW5fbG9jaygmZGV2LT5xdWV1ZV9sb2NrKTsK
IAkJCXEgPSBkZXYtPnFkaXNjOwogCQl9CiAK
------=_Part_709_5375345.1104708631807
Content-Type: application/octet-stream; name="sungem.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="sungem.patch"

PT09PT0gZHJpdmVycy9uZXQvc3VuZ2VtLmMgMS43MSB2cyBlZGl0ZWQgPT09PT0KLS0tIDEuNzEv
ZHJpdmVycy9uZXQvc3VuZ2VtLmMJMjAwNC0xMS0xNCAxMDo0NTozNiArMDE6MDAKKysrIGVkaXRl
ZC9kcml2ZXJzL25ldC9zdW5nZW0uYwkyMDA1LTAxLTAzIDAwOjAwOjIyICswMTowMApAQCAtOTUw
LDYgKzk1MCw3IEBACiAJcmV0dXJuIDA7CiB9CiAKKy8qIENhbGxlZCB3aXRoIGRldi0+cXVldWVf
bG9jayBoZWxkICovCiBzdGF0aWMgaW50IGdlbV9zdGFydF94bWl0KHN0cnVjdCBza19idWZmICpz
a2IsIHN0cnVjdCBuZXRfZGV2aWNlICpkZXYpCiB7CiAJc3RydWN0IGdlbSAqZ3AgPSBkZXYtPnBy
aXY7CkBAIC05NzYsOCArOTc3LDE2IEBACiAJCXJldHVybiBORVRERVZfVFhfTE9DS0VEOwogCX0K
IAorCS8qIFdlIGNhbiBub3cgZHJvcCBxdWV1ZV9sb2NrIHNpbmNlIHR4X2xvY2sgcHJvdGVjdHMg
dXMuIEJ1dCByZW1lbWJlcgorCSAqIHRoYXQgcXVldWVfbG9jayBtdXN0IGJlIHJlYWNxdWlyZWQg
YmVmb3JlIHdlIHJldHVybi4gTW9yZW92ZXIgd2UKKwkgKiBtdXN0IHJlYWNxdWlyZSBpdCBiZWZv
cmUgcmVsZWFzaW5nIHR4X2xvY2sgdG8gYXZvaWQgYmVpbmcgY2FsbGVkCisJICogd2l0aCB0aGUg
cXVldWUgc3RvcHBlZC4KKwkgKi8KKwlzcGluX3VubG9jaygmZGV2LT5xdWV1ZV9sb2NrKTsKKwog
CS8qIFRoaXMgaXMgYSBoYXJkIGVycm9yLCBsb2cgaXQuICovCiAJaWYgKFRYX0JVRkZTX0FWQUlM
KGdwKSA8PSAoc2tiX3NoaW5mbyhza2IpLT5ucl9mcmFncyArIDEpKSB7CisJCXNwaW5fbG9jaygm
ZGV2LT5xdWV1ZV9sb2NrKTsKIAkJbmV0aWZfc3RvcF9xdWV1ZShkZXYpOwogCQlzcGluX3VubG9j
a19pcnFyZXN0b3JlKCZncC0+dHhfbG9jaywgZmxhZ3MpOwogCQlwcmludGsoS0VSTl9FUlIgUEZY
ICIlczogQlVHISBUeCBSaW5nIGZ1bGwgd2hlbiBxdWV1ZSBhd2FrZSFcbiIsCkBAIC0xMDY2LDYg
KzEwNzUsNyBAQAogCQkgICAgICAgZGV2LT5uYW1lLCBlbnRyeSwgc2tiLT5sZW4pOwogCW1iKCk7
CiAJd3JpdGVsKGdwLT50eF9uZXcsIGdwLT5yZWdzICsgVFhETUFfS0lDSyk7CisJc3Bpbl9sb2Nr
KCZkZXYtPnF1ZXVlX2xvY2spOwogCXNwaW5fdW5sb2NrX2lycXJlc3RvcmUoJmdwLT50eF9sb2Nr
LCBmbGFncyk7CiAKIAlkZXYtPnRyYW5zX3N0YXJ0ID0gamlmZmllczsK
------=_Part_709_5375345.1104708631807
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


------=_Part_709_5375345.1104708631807--
