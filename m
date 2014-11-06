From: Hariprasad S <hariprasad@chelsio.com>
Subject: Re: [PATCHv2 net-next 0/3] RDMA/cxgb4,cxgb4vf,cxgb4i,csiostor:
 Cleanup macros
Date: Thu, 6 Nov 2014 21:45:10 +0530
Message-ID: <20141106161444.GA8954@hariprasad-pc>
References: <1415069457-22277-1-git-send-email-hariprasad@chelsio.com>
 <20141105.145443.897956918105740779.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<linux-scsi@vger.kernel.org>, <roland@purestorage.com>,
	<JBottomley@parallels.com>, <hch@infradead.org>,
	<swise@opengridcomputing.com>, <leedom@chelsio.com>,
	<praveenm@chelsio.com>, <anish@chelsio.com>,
	<nirranjan@chelsio.com>, <kumaras@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141105.145443.897956918105740779.davem@davemloft.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 05, 2014 at 14:54:43 -0500, David Miller wrote:
> From: Hariprasad Shenai <hariprasad@chelsio.com>
> Date: Tue,  4 Nov 2014 08:20:54 +0530
>=20
> > It's not really the "hardware" which generates these hardware const=
ant symbolic
> > macros/register defines of course, it's scripts developed by the ha=
rdware team.
> > Various patches have ended up changing the style of the symbolic ma=
cros/register
> > defines and some of them used the macros/register defines that matc=
hes the
> > output of the script from the hardware team.
>=20
> We've told you that we don't care what format your internal whatever =
uses
> for these macros.
>=20
> We have standards, tastes, and desires and reasons for naming macros
> in a certain way in upstream kernel code.
>=20
> I consider it flat out unacceptable to use macros with one letter
> prefixes like "S_".  You simply should not do this.
>=20

Okay. We=E2=80=99ll clean up all of the macros to match the files' orig=
inal style. We
do need to change the sense of the *_MASK macros since they don=E2=80=99=
t match how we=20
use them as field tokens.  Also the *_SHIFT, *_MASK and *_GET names are
sucking up space and making lines wrap unnecessarily, creating readabil=
ity
problems.  Can we change these to *_S, *_M and *_G?  E.g.:

-#define  INGPADBOUNDARY_MASK    0x00000070U
-#define  INGPADBOUNDARY_SHIFT   4
-#define  INGPADBOUNDARY(x)      ((x) << INGPADBOUNDARY_SHIFT)
-#define  INGPADBOUNDARY_GET(x)  (((x) & INGPADBOUNDARY_MASK) \
-                                 >> INGPADBOUNDARY_SHIFT)
+#define  INGPADBOUNDARY_M       0x00000007U
+#define  INGPADBOUNDARY_S       4
+#define  INGPADBOUNDARY(x)      ((x) << INGPADBOUNDARY_S)
+#define  INGPADBOUNDARY_G(x)    (((x) >> INGPADBOUNDARY_S) \
+                                 & INGPADBOUNDARY_M)


=20
Thanks,
Hari
--
To unsubscribe from this list: send the line "unsubscribe linux-scsi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
