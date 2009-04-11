From: Jeff Chua <jeff.chua.linux@gmail.com>
Subject: Re: iptables very slow after commit 784544739a25c30637397ace5489eeb6e15d7d49
Date: Sun, 12 Apr 2009 00:05:34 +0800
Message-ID: <b6a2187b0904110905kc2cca83ted751b42693b1565@mail.gmail.com>
References: <Pine.LNX.4.64.0904101656190.2093@boston.corp.fedex.com>
	 <20090410095246.4fdccb56@s6510>
	 <20090410.182507.140306636.davem@davemloft.net>
	 <alpine.LFD.2.00.0904101828490.4583@localhost.localdomain>
	 <20090411041533.GB6822@linux.vnet.ibm.com>
	 <alpine.LSU.2.00.0904110657410.26485@fbirervta.pbzchgretzou.qr>
	 <20090411080739.4cb77370@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@medozas.de>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Lai Jiangshan <laijs@cn.fujitsu.com>, dada1@cosmosbay.com,
	kaber@trash.net, r000n@r000n.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090411080739.4cb77370@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 11, 2009 at 11:07 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
>> iptables works in whole tables. Userspace submits a table, checkentr=
y is
>> called for all rules in the new table, things are swapped, then dest=
roy
>> is called for all rules in the old table. By that logic (which exist=
ed
>> since dawn I think), only the swap operation needs to be locked.
> Part of the overhead is the API choice to take counter values from us=
er
> space during the replace. =A0If the rule replacement just always star=
ted with
> zero counters it could be done with less overhead.

It's always good practice to start from zero with these ...

# iptables -F
# iptables -t nat -F
# iptables -X

And most of the time, rules should be put into a file so that it can
rerun easily after reboot. So if it can be speed up for just this
case, it'll help many out there.

Thanks,
Jeff.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
