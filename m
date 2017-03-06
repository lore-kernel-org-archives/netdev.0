From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 27/29] drivers,
	usb: convert ep_data.count from atomic_t to refcount_t
Date: Mon,  6 Mar 2017 16:21:14 +0200
Message-ID: <1488810076-3754-28-git-send-email-elena.reshetova@intel.com>
References: <1488810076-3754-1-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: peterz@infradead.org, linux-pci@vger.kernel.org,
 target-devel@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
 Elena Reshetova <elena.reshetova@intel.com>, devel@driverdev.osuosl.org,
 linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org,
 linux-serial@vger.kernel.org, fcoe-devel@open-fcoe.org,
 xen-devel@lists.xenproject.org, open-iscsi@googlegroups.com,
 linux-media@vger.kernel.org, Kees Cook <keescook@chromium.org>,
 linux-raid@vger.kernel.org, linux-bcache@vger.kernel.org,
 Hans Liljestrand <ishkamiel@gmail.com>, David Windsor <dwindsor@gmail.com>,
 netdev@vger.kernel.org, linux-usb@vger.kernel.org,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: gregkh@linuxfoundation.org
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1488810076-3754-1-git-send-email-elena.reshetova@intel.com>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

cmVmY291bnRfdCB0eXBlIGFuZCBjb3JyZXNwb25kaW5nIEFQSSBzaG91bGQgYmUKdXNlZCBpbnN0
ZWFkIG9mIGF0b21pY190IHdoZW4gdGhlIHZhcmlhYmxlIGlzIHVzZWQgYXMKYSByZWZlcmVuY2Ug
Y291bnRlci4gVGhpcyBhbGxvd3MgdG8gYXZvaWQgYWNjaWRlbnRhbApyZWZjb3VudGVyIG92ZXJm
bG93cyB0aGF0IG1pZ2h0IGxlYWQgdG8gdXNlLWFmdGVyLWZyZWUKc2l0dWF0aW9ucy4KClNpZ25l
ZC1vZmYtYnk6IEVsZW5hIFJlc2hldG92YSA8ZWxlbmEucmVzaGV0b3ZhQGludGVsLmNvbT4KU2ln
bmVkLW9mZi1ieTogSGFucyBMaWxqZXN0cmFuZCA8aXNoa2FtaWVsQGdtYWlsLmNvbT4KU2lnbmVk
LW9mZi1ieTogS2VlcyBDb29rIDxrZWVzY29va0BjaHJvbWl1bS5vcmc+ClNpZ25lZC1vZmYtYnk6
IERhdmlkIFdpbmRzb3IgPGR3aW5kc29yQGdtYWlsLmNvbT4KLS0tCiBkcml2ZXJzL3VzYi9nYWRn
ZXQvbGVnYWN5L2lub2RlLmMgfCA4ICsrKystLS0tCiAxIGZpbGUgY2hhbmdlZCwgNCBpbnNlcnRp
b25zKCspLCA0IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2RyaXZlcnMvdXNiL2dhZGdldC9s
ZWdhY3kvaW5vZGUuYyBiL2RyaXZlcnMvdXNiL2dhZGdldC9sZWdhY3kvaW5vZGUuYwppbmRleCA4
MWQ3NmYzLi5kMjFhNWY4IDEwMDY0NAotLS0gYS9kcml2ZXJzL3VzYi9nYWRnZXQvbGVnYWN5L2lu
b2RlLmMKKysrIGIvZHJpdmVycy91c2IvZ2FkZ2V0L2xlZ2FjeS9pbm9kZS5jCkBAIC0xOTEsNyAr
MTkxLDcgQEAgZW51bSBlcF9zdGF0ZSB7CiBzdHJ1Y3QgZXBfZGF0YSB7CiAJc3RydWN0IG11dGV4
CQkJbG9jazsKIAllbnVtIGVwX3N0YXRlCQkJc3RhdGU7Ci0JYXRvbWljX3QJCQljb3VudDsKKwly
ZWZjb3VudF90CQkJY291bnQ7CiAJc3RydWN0IGRldl9kYXRhCQkJKmRldjsKIAkvKiBtdXN0IGhv
bGQgZGV2LT5sb2NrIGJlZm9yZSBhY2Nlc3NpbmcgZXAgb3IgcmVxICovCiAJc3RydWN0IHVzYl9l
cAkJCSplcDsKQEAgLTIwNiwxMiArMjA2LDEyIEBAIHN0cnVjdCBlcF9kYXRhIHsKIAogc3RhdGlj
IGlubGluZSB2b2lkIGdldF9lcCAoc3RydWN0IGVwX2RhdGEgKmRhdGEpCiB7Ci0JYXRvbWljX2lu
YyAoJmRhdGEtPmNvdW50KTsKKwlyZWZjb3VudF9pbmMgKCZkYXRhLT5jb3VudCk7CiB9CiAKIHN0
YXRpYyB2b2lkIHB1dF9lcCAoc3RydWN0IGVwX2RhdGEgKmRhdGEpCiB7Ci0JaWYgKGxpa2VseSAo
IWF0b21pY19kZWNfYW5kX3Rlc3QgKCZkYXRhLT5jb3VudCkpKQorCWlmIChsaWtlbHkgKCFyZWZj
b3VudF9kZWNfYW5kX3Rlc3QgKCZkYXRhLT5jb3VudCkpKQogCQlyZXR1cm47CiAJcHV0X2RldiAo
ZGF0YS0+ZGV2KTsKIAkvKiBuZWVkcyBubyBtb3JlIGNsZWFudXAgKi8KQEAgLTE1NjIsNyArMTU2
Miw3IEBAIHN0YXRpYyBpbnQgYWN0aXZhdGVfZXBfZmlsZXMgKHN0cnVjdCBkZXZfZGF0YSAqZGV2
KQogCQlpbml0X3dhaXRxdWV1ZV9oZWFkICgmZGF0YS0+d2FpdCk7CiAKIAkJc3RybmNweSAoZGF0
YS0+bmFtZSwgZXAtPm5hbWUsIHNpemVvZiAoZGF0YS0+bmFtZSkgLSAxKTsKLQkJYXRvbWljX3Nl
dCAoJmRhdGEtPmNvdW50LCAxKTsKKwkJcmVmY291bnRfc2V0ICgmZGF0YS0+Y291bnQsIDEpOwog
CQlkYXRhLT5kZXYgPSBkZXY7CiAJCWdldF9kZXYgKGRldik7CiAKLS0gCjIuNy40CgoKX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KWGVuLWRldmVsIG1haWxp
bmcgbGlzdApYZW4tZGV2ZWxAbGlzdHMueGVuLm9yZwpodHRwczovL2xpc3RzLnhlbi5vcmcveGVu
LWRldmVsCg==
