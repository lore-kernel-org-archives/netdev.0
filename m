From: Eric Lemoine <eric.lemoine@gmail.com>
Subject: Re: LLTX and netif_stop_queue
Date: Wed, 22 Dec 2004 19:49:48 +0100
Message-ID: <5cac192f04122210491d64d4b6@mail.gmail.com>
References: <52llbwoaej.fsf@topspin.com>
	<20041217214432.07b7b21e.davem@davemloft.net>
	<1103484675.1050.158.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_911_15124942.1103741388450"
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: hadi@cyberus.ca
In-Reply-To: <1103484675.1050.158.camel@jzny.localdomain>
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

------=_Part_911_15124942.1103741388450
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 19 Dec 2004 14:31:15 -0500, jamal <hadi@cyberus.ca> wrote:
> On Sat, 2004-12-18 at 00:44, David S. Miller wrote:
> 
> > Perhaps one way to fix this is to add a pointer to a spinlock to
> > the netdev struct, and have hold that the upper level grab that
> > when NETIF_F_LLTX when doing queue state checks.  Actually, that
> > could end up being racy too.
> 
> How about releasing the qlock only when the LLTX transmit lock is
> grabbed? That should bring it to par with what it was originally.

I dont like the idea of releasing inside the driver a lock taken
outside. That might be just me...

Instead, I would suggest to have LLTX drivers check whether queue is
stopped after they grab their private tx lock and before they check tx
ring fullness. That way we close the race window but keep the driver
bug check around.

See attached sungem patch.

-- 
Eric

------=_Part_911_15124942.1103741388450
Content-Type: application/octet-stream; name="sungem-lltx.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="sungem-lltx.patch"

PT09PT0gZHJpdmVycy9uZXQvc3VuZ2VtLmMgMS43MSB2cyBlZGl0ZWQgPT09PT0KLS0tIDEuNzEv
ZHJpdmVycy9uZXQvc3VuZ2VtLmMJMjAwNC0xMS0xNCAxMDo0NTozNiArMDE6MDAKKysrIGVkaXRl
ZC9kcml2ZXJzL25ldC9zdW5nZW0uYwkyMDA0LTEyLTIyIDE5OjM0OjA3ICswMTowMApAQCAtOTc2
LDYgKzk3NiwxMiBAQAogCQlyZXR1cm4gTkVUREVWX1RYX0xPQ0tFRDsKIAl9CiAKKwkvKiBUaGlz
IGhhbmRsZXMgYSBMTFRYLXJlbGF0ZWQgcmFjZSBjb25kaXRpb24gKi8KKwlpZiAobmV0aWZfcXVl
dWVfc3RvcHBlZChkZXYpKSB7CisJCXNwaW5fdW5sb2NrX2lycXJlc3RvcmUoJmdwLT50eF9sb2Nr
LCBmbGFncyk7CisJCXJldHVybiBORVRERVZfVFhfQlVTWTsKKwl9CisKIAkvKiBUaGlzIGlzIGEg
aGFyZCBlcnJvciwgbG9nIGl0LiAqLwogCWlmIChUWF9CVUZGU19BVkFJTChncCkgPD0gKHNrYl9z
aGluZm8oc2tiKS0+bnJfZnJhZ3MgKyAxKSkgewogCQluZXRpZl9zdG9wX3F1ZXVlKGRldik7Cg==

------=_Part_911_15124942.1103741388450
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


------=_Part_911_15124942.1103741388450--
