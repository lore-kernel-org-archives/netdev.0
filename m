From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [resend] Passive OS fingerprint xtables match.
Date: Fri, 29 May 2009 11:49:51 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0905291144460.9095@fbirervta.pbzchgretzou.qr>
References: <20090511095343.GA30778@ioremap.net> <4A1D6A20.8050404@trash.net> <20090529085918.GA11887@ioremap.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090529085918.GA11887@ioremap.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Friday 2009-05-29 10:59, Evgeniy Polyakov wrote:
>> >+/* Defines for IANA option kinds */
>> >+
>> >+enum iana_options {
>> >+	OSFOPT_EOL = 0,		/* End of options */
>> >+	OSFOPT_NOP, 		/* NOP */
>> >+	OSFOPT_MSS, 		/* Maximum segment size */
>> >+	OSFOPT_WSO, 		/* Window scale option */
>> >+	OSFOPT_SACKP,		/* SACK permitted */
>> >+	OSFOPT_SACK,		/* SACK */
>> >+	OSFOPT_ECHO,
>> >+	OSFOPT_ECHOREPLY,
>> >+	OSFOPT_TS,		/* Timestamp option */
>> >+	OSFOPT_POCP,		/* Partial Order Connection Permitted */
>> >+	OSFOPT_POSP,		/* Partial Order Service Profile */
>> >+
>> >+	/* Others are not used in the current OSF */
>> >+	OSFOPT_EMPTY = 255,
>> >+};
>> 
>> Why do we need to duplicate these?
>
>Why duplicate? It is the only place of the constants describing used
>option numbers. include/net/tcp.h does not have 'partial order' options
>in particular.

Then you do one of these:

1. add TCPOPT_POCP/POSP to tcp.h or
2. define it locally:
#include <net/tcp.h>
enum {
	TCPOPT_POCP = 9,
	TCPOPT_POSP = 10,
};

>> >+config NETFILTER_XT_MATCH_OSF
>> >+	tristate '"osf" Passive OS fingerprint match'
>> >+	depends on NETFILTER_ADVANCED
>> 
>> && NFNETLINK
>
>Will add.

Does it really need to depend on nfnetlink? Even if I just want to
have it dumped to syslog?
