From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 0/5] bonding: simple macro cleanup
Date: Wed, 14 May 2014 15:03:53 -0700
Message-ID: <1400105033.30384.34.camel@joe-AO725>
References: <1400072064-26095-1-git-send-email-vfalico@gmail.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1724466A@AcuExch.aculab.com>
	 <20140514132922.GA24104@mikrodark.usersys.redhat.com>
	 <CAADnVQKw3npBoeuQbVf4FtDiqiZuc7+1z7fwUL_6Vru-p3BwDQ@mail.gmail.com>
	 <1400084983.19788.15.camel@joe-AO725>
	 <CAADnVQ+6-KQRRLS6Nos7u1J1BA9KoS6bJFAsnWE6d4vC010Djg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Veaceslav Falico <vfalico@gmail.com>,
	David Laight <David.Laight@aculab.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0214.hostedemail.com ([216.40.44.214]:43524 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751059AbaENWD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 18:03:56 -0400
In-Reply-To: <CAADnVQ+6-KQRRLS6Nos7u1J1BA9KoS6bJFAsnWE6d4vC010Djg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-05-14 at 14:52 -0700, Alexei Starovoitov wrote:
> I cannot imagine the case where macro would be faster than static inline
> unless it wasn't inlined.

For an example, look at commit 4153577a8d
("tg3: Use different macros for pci_chip_rev_id accesses")

Converting these macros to static inline produces
larger/slower code.  (at least with gcc 4.7.3)

+#define tg3_chip_rev_id(tp)                                    \
+       ((tp)->pci_chip_rev_id)
+#define tg3_asic_rev(tp)                                       \
+       ((tp)->pci_chip_rev_id >> 12)
+#define tg3_chip_rev(tp)                                       \
+       ((tp)->pci_chip_rev_id >> 8)
