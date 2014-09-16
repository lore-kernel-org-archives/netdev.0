From: Steffen Maier <maier@linux.vnet.ibm.com>
Subject: Re: [PATCH -net] scsi: fix users of SCSI_FC_ATTRS to depend on NET
Date: Tue, 16 Sep 2014 16:56:55 +0200
Message-ID: <54184FB7.7020201@linux.vnet.ibm.com>
References: <5417DA29.4060205@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fengguang Wu <fengguang.wu@intel.com>
To: Randy Dunlap <rdunlap@infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	James Bottomley <jbottomley@parallels.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:48395 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753884AbaIPO5K convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 10:57:10 -0400
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <maier@linux.vnet.ibm.com>;
	Tue, 16 Sep 2014 15:57:08 +0100
In-Reply-To: <5417DA29.4060205@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/16/2014 08:35 AM, Randy Dunlap wrote:
> From: Randy Dunlap <rdunlap@infradead.org>
>
> There are other kconfig symbols which select SCSI_FC_ATTRS,
> so they also need to depend on NET to fix kconfig warnings and
> build errors:
>
> warning: (LIBFC && SCSI_IBMVFC && SCSI_QLA_FC && SCSI_LPFC && ZFCP &&=
 SCSI_BFA_FC && SCSI_CHELSIO_FCOE && FUSION_FC) selects SCSI_FC_ATTRS w=
hich has unmet direct dependencies (SCSI && NET)
> drivers/scsi/scsi_transport_fc.c: In function 'fc_host_post_event':
> drivers/scsi/scsi_transport_fc.c:543:7: error: 'scsi_nl_sock' undecla=
red (first use in this function)
> drivers/scsi/scsi_transport_fc.c: In function 'fc_host_post_vendor_ev=
ent':
> drivers/scsi/scsi_transport_fc.c:611:7: error: 'scsi_nl_sock' undecla=
red (first use in this function)
>
> Reported-by: Fengguang Wu <fengguang.wu@intel.com> [0-day test robot]
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> ---
>   drivers/message/fusion/Kconfig |    2 +-
>   drivers/scsi/Kconfig           |    9 +++++----
>   drivers/scsi/csiostor/Kconfig  |    2 +-
>   drivers/scsi/qla2xxx/Kconfig   |    2 +-
>   4 files changed, 8 insertions(+), 7 deletions(-)

> --- lnx-317-rc5.orig/drivers/scsi/Kconfig
> +++ lnx-317-rc5/drivers/scsi/Kconfig

> @@ -1675,7 +1676,7 @@ config SCSI_SUNESP
>
>   config ZFCP
>   	tristate "FCP host bus adapter driver for IBM eServer zSeries"
> -	depends on S390 && QDIO && SCSI
> +	depends on S390 && QDIO && SCSI && NET
>   	select SCSI_FC_ATTRS
>   	help
>             If you want to access SCSI devices attached to your IBM e=
Server

I think zfcp does not have any (direct) dependency on NET.

It looks like SCSI_FC_ATTRS selects SCSI_NETLINK (declaring=20
scsi_nl_sock) and only depends on SCSI but not on NET.
SCSI_NETLINK itself only selects NET but does not model its direct=20
depencency on NET?

Do I understand correctly, that the only solution is to make all=20
INdirect (transitive) dependencies explicit with the LLDDs instead of=20
making the direct exploiter SCSI_NETLINK(?) depend on NET?

--=20
Mit freundlichen Gr=C3=BC=C3=9Fen / Kind regards
Steffen Maier

Linux on System z Development

IBM Deutschland Research & Development GmbH
Vorsitzende des Aufsichtsrats: Martina Koederitz
Geschaeftsfuehrung: Dirk Wittkopp
Sitz der Gesellschaft: Boeblingen
Registergericht: Amtsgericht Stuttgart, HRB 243294
