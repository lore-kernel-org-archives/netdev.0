From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH v3 24/25] sunrpc: Change how dentry's d_lock field is
 accessed
Date: Mon, 8 Jul 2013 16:53:52 +0000
Message-ID: <1373302428.2231.9.camel@leira.trondhjem.org>
References: <1372883132-23410-1-git-send-email-Waiman.Long@hp.com>
	 <20130704042034.GM4165@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Waiman Long <Waiman.Long@hp.com>, Jeff Layton <jlayton@redhat.com>,
	"Miklos Szeredi" <mszeredi@suse.cz>,
	Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	"Steven Rostedt" <rostedt@goodmis.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Andi Kleen <andi@firstfloor.org>,
	"Chandramouleeswaran, Aswin" <aswin@hp.com>,
	"Norton, Scott J" <scott.norton@hp.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130704042034.GM4165@ZenIV.linux.org.uk>
Content-Language: en-US
Content-ID: <80EDF0303559BA419A6FC4A793CD17AD@hq.netapp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

T24gVGh1LCAyMDEzLTA3LTA0IGF0IDA1OjIwICswMTAwLCBBbCBWaXJvIHdyb3RlOg0KPiBPbiBX
ZWQsIEp1bCAwMywgMjAxMyBhdCAwNDoyNTozMlBNIC0wNDAwLCBXYWltYW4gTG9uZyB3cm90ZToN
Cj4gPiBUaGVyZSBpcyBubyBjaGFuZ2UgaW4gbG9naWMgYW5kIGV2ZXJ5dGhpbmcgc2hvdWxkIGp1
c3Qgd29yay4NCj4gDQo+ID4gLQkJc3Bpbl9sb2NrKCZmaWxlLT5mX3BhdGguZGVudHJ5LT5kX2xv
Y2spOw0KPiA+ICsJCWRfbG9jayhmaWxlLT5mX3BhdGguZGVudHJ5KTsNCj4gPiAgCQlpZiAoIWRf
dW5oYXNoZWQoZmlsZS0+Zl9wYXRoLmRlbnRyeSkpDQo+ID4gIAkJCWNsbnQgPSBSUENfSShpbm9k
ZSktPnByaXZhdGU7DQo+ID4gIAkJaWYgKGNsbnQgIT0gTlVMTCAmJiBhdG9taWNfaW5jX25vdF96
ZXJvKCZjbG50LT5jbF9jb3VudCkpIHsNCj4gPiAtCQkJc3Bpbl91bmxvY2soJmZpbGUtPmZfcGF0
aC5kZW50cnktPmRfbG9jayk7DQo+ID4gKwkJCWRfdW5sb2NrKGZpbGUtPmZfcGF0aC5kZW50cnkp
Ow0KPiANCj4gQ291bGQgc29tZWJvZHkgZXhwbGFpbiBXVEYgaXMgYmVpbmcgcHJvdGVjdGVkIGhl
cmU/ICBJdCdzIG5vdCAtPnByaXZhdGUgLQ0KPiB0aGF0IGdldHMgc2V0IChhbmQsIG1vcmUgaW1w
b3J0YW50bHksIGNsZWFyZWQpIHdpdGhvdXQgLT5kX2xvY2sgaW4gc2lnaHQuDQo+IFRyb25kLCB0
aGF0IHNlZW1zIHRvIGJlIHlvdXIgY29kZSBmcm9tIGFib3V0IHRocmVlIHllYXJzIGFnbyAoaW50
cm9kdWNlZA0KPiBpbiAiU1VOUlBDOiBGaXggYSByYWNlIGluIHJwY19pbmZvX29wZW4iKS4gIFdo
YXQncyBnb2luZyBvbiB0aGVyZT8NCg0KQUZBSUNSIHdlJ3JlIHVzaW5nIHRoZSBmYWN0IHRoYXQg
dGhlIGRlbnRyeSB3aWxsIHJlbWFpbiBoYXNoZWQgdW50aWwNCndlJ3JlIGluIHRoZSBwcm9jZXNz
IG9mIGZyZWVpbmcgdXAgdGhlIHJwY19jbGllbnQuIEJ5IHRlc3RpbmcgdGhhdCB0aGUNCmRlbnRy
eSBpcyBoYXNoZWQgdW5kZXIgdGhlIGRlbnRyeS0+ZF9sb2NrLCB3ZSBhcmUgYXNzdXJlZCB0aGF0
IHRoZQ0Kbm9uLU5VTEwgJ2NsbnQnIGlzIHN0aWxsIHBvaW50aW5nIHRvIGEgdmFsaWQgcnBjX2Ns
aWVudCwgYW5kIHRoYXQgaXQgaXMNCnNhZmUgdG8gYWNjZXNzIGNsbnQtPmNsX2NvdW50Lg0KDQot
LSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyDQoNCk5ldEFw
cA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3dy5uZXRhcHAuY29tDQo=
