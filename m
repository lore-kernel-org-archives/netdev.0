From: Paul Pluzhnikov <ppluzhnikov@google.com>
Subject: Re: [PATCH torvalds/linux.git] Make linux/tcp.h C++ friendly (trivial)
Date: Fri, 8 Jun 2012 22:45:20 -0700
Message-ID: <CALoOobMCio0GtxerOpXwB-Bxf-cKnLotPBA69oPC-6CWDfyPyg@mail.gmail.com>
References: <alpine.LNX.2.00.1202032232320.25026@pobox.suse.cz>
 <CALoOobMSXp4x_+En2gyHmpXcxq=sECQvMZN1LX_j3Yve7Ha6Aw@mail.gmail.com>
 <CALoOobNbt0Kbea8gHdNkQFa0+ydpH++6ND+fOBGvy5Rmf=_QpA@mail.gmail.com> <20120608.221755.927511342271201223.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=f46d043c8060243e6b04c203a163
Cc: jkosina@suse.cz, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:63609 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734Ab2FIFpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2012 01:45:52 -0400
Received: by weyu7 with SMTP id u7so991743wey.19
        for <netdev@vger.kernel.org>; Fri, 08 Jun 2012 22:45:51 -0700 (PDT)
In-Reply-To: <20120608.221755.927511342271201223.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--f46d043c8060243e6b04c203a163
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Jun 8, 2012 at 10:17 PM, David Miller <davem@davemloft.net> wrote:
> From: Paul Pluzhnikov <ppluzhnikov@google.com>
> Date: Fri, 8 Jun 2012 21:14:19 -0700
>
>> I thought the patch has been applied, and stopped pinging it.
>> But it appears that it never did get applied :-(
>
> Your submission is not properly formed, you need to post this as a
> fresh email with proper commit message and signoffs.
>
> Please read Documentation/SubmittingPatches if you want us to
> seriously consider this change.

Here is the original message I sent to <trivial@kernel.org> on
Thu, Dec 29, 2011 at 10:30 AM:

-----------------------------------------
Greetings,

Using linux/tcp.h from C++ results in:

cat t.cc
#include <linux/tcp.h>
int main() { }

g++ -c t.cc

In file included from t.cc:1:
/usr/include/linux/tcp.h:72: error: '__u32 __fswab32(__u32)' cannot
appear in a constant-expression
/usr/include/linux/tcp.h:72: error: a function call cannot appear in a
constant-expression
...

Attached trivial patch fixes this problem.

Tested:
- the t.cc above compiles with g++ and
- the following program generates the same output before/after
 the patch:

#include <linux/tcp.h>
#include <stdio.h>

int main ()
{
#define P(a) printf("%s: %08x\n", #a, (int)a)
 P(TCP_FLAG_CWR);
 P(TCP_FLAG_ECE);
 P(TCP_FLAG_URG);
 P(TCP_FLAG_ACK);
 P(TCP_FLAG_PSH);
 P(TCP_FLAG_RST);
 P(TCP_FLAG_SYN);
 P(TCP_FLAG_FIN);
 P(TCP_RESERVED_BITS);
 P(TCP_DATA_OFFSET);
#undef P
 return 0;
}

Signed-off-by: Paul Pluzhnikov <ppluzhnikov@google.com>


Thanks,

P.S. Google has blanket copyright assignment to FSF.
--
Paul Pluzhnikov

--f46d043c8060243e6b04c203a163
Content-Type: text/plain; charset=US-ASCII; name="linux-tcp_h-patch-20111229.txt"
Content-Disposition: attachment; filename="linux-tcp_h-patch-20111229.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_h389d7ie0

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvdGNwLmggYi9pbmNsdWRlL2xpbnV4L3RjcC5oCmlu
ZGV4IDdmNTllZTkuLjYzMzM0ZjcgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbGludXgvdGNwLmgKKysr
IGIvaW5jbHVkZS9saW51eC90Y3AuaApAQCAtNjksMTYgKzY5LDE2IEBAIHVuaW9uIHRjcF93b3Jk
X2hkciB7CiAjZGVmaW5lIHRjcF9mbGFnX3dvcmQodHApICggKCh1bmlvbiB0Y3Bfd29yZF9oZHIg
KikodHApKS0+d29yZHMgWzNdKSAKIAogZW51bSB7IAotCVRDUF9GTEFHX0NXUiA9IF9fY3B1X3Rv
X2JlMzIoMHgwMDgwMDAwMCksCi0JVENQX0ZMQUdfRUNFID0gX19jcHVfdG9fYmUzMigweDAwNDAw
MDAwKSwKLQlUQ1BfRkxBR19VUkcgPSBfX2NwdV90b19iZTMyKDB4MDAyMDAwMDApLAotCVRDUF9G
TEFHX0FDSyA9IF9fY3B1X3RvX2JlMzIoMHgwMDEwMDAwMCksCi0JVENQX0ZMQUdfUFNIID0gX19j
cHVfdG9fYmUzMigweDAwMDgwMDAwKSwKLQlUQ1BfRkxBR19SU1QgPSBfX2NwdV90b19iZTMyKDB4
MDAwNDAwMDApLAotCVRDUF9GTEFHX1NZTiA9IF9fY3B1X3RvX2JlMzIoMHgwMDAyMDAwMCksCi0J
VENQX0ZMQUdfRklOID0gX19jcHVfdG9fYmUzMigweDAwMDEwMDAwKSwKLQlUQ1BfUkVTRVJWRURf
QklUUyA9IF9fY3B1X3RvX2JlMzIoMHgwRjAwMDAwMCksCi0JVENQX0RBVEFfT0ZGU0VUID0gX19j
cHVfdG9fYmUzMigweEYwMDAwMDAwKQorCVRDUF9GTEFHX0NXUiA9IF9fY29uc3RhbnRfY3B1X3Rv
X2JlMzIoMHgwMDgwMDAwMCksCisJVENQX0ZMQUdfRUNFID0gX19jb25zdGFudF9jcHVfdG9fYmUz
MigweDAwNDAwMDAwKSwKKwlUQ1BfRkxBR19VUkcgPSBfX2NvbnN0YW50X2NwdV90b19iZTMyKDB4
MDAyMDAwMDApLAorCVRDUF9GTEFHX0FDSyA9IF9fY29uc3RhbnRfY3B1X3RvX2JlMzIoMHgwMDEw
MDAwMCksCisJVENQX0ZMQUdfUFNIID0gX19jb25zdGFudF9jcHVfdG9fYmUzMigweDAwMDgwMDAw
KSwKKwlUQ1BfRkxBR19SU1QgPSBfX2NvbnN0YW50X2NwdV90b19iZTMyKDB4MDAwNDAwMDApLAor
CVRDUF9GTEFHX1NZTiA9IF9fY29uc3RhbnRfY3B1X3RvX2JlMzIoMHgwMDAyMDAwMCksCisJVENQ
X0ZMQUdfRklOID0gX19jb25zdGFudF9jcHVfdG9fYmUzMigweDAwMDEwMDAwKSwKKwlUQ1BfUkVT
RVJWRURfQklUUyA9IF9fY29uc3RhbnRfY3B1X3RvX2JlMzIoMHgwRjAwMDAwMCksCisJVENQX0RB
VEFfT0ZGU0VUID0gX19jb25zdGFudF9jcHVfdG9fYmUzMigweEYwMDAwMDAwKQogfTsgCiAKIC8q
Cg==
--f46d043c8060243e6b04c203a163--
