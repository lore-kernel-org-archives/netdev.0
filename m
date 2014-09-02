From: Cong Wang <cwang@twopensource.com>
Subject: Re: RTNL: assertion failed at net/ipv6/addrconf.c (1699)
Date: Tue, 2 Sep 2014 11:40:30 -0700
Message-ID: <CAHA+R7MMe+O9-sNHQvgOO78tBzDy+hO+GtJFsuJPKx0eG6eMaw@mail.gmail.com>
References: <CA+ydwtoDwQVg_BWrxxdpUyJ7Up60GtxTCLYe_5vFdV2td_kGhQ@mail.gmail.com>
	<CAHA+R7MZCDGRhSf=UuVCGQvNo03wVziZQB_X30rwNf6hmHipQA@mail.gmail.com>
	<20140829195339.GA9780@kria>
	<1409363489.2980.17.camel@localhost>
	<CAHA+R7ODa+LrdwSrS7HcBfwwq8_fpj-Ld0OCDtcOqkpCdZCvxg@mail.gmail.com>
	<1409680684.972417.162793869.03CF8A61@webmail.messagingengine.com>
	<CAHA+R7Mwy1SCpEUgGf9BdLEro6N-3t89KU=xL0iuzgOppXELrQ@mail.gmail.com>
	<1409681914.978561.162800349.5A7FA784@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sabrina Dubroca <sd@queasysnail.net>,
	Tommi Rantala <tt.rantala@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, trinity@vger.kernel.org,
	Dave Jones <davej@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <trinity-owner@vger.kernel.org>
In-Reply-To: <1409681914.978561.162800349.5A7FA784@webmail.messagingengine.com>
Sender: trinity-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 2, 2014 at 11:18 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Those ASSERT_RTNLs were misplaced and only caught the callers mostly
> from addrconf.c. I don't mind getting reports from stable kernel users
> and fixing those, too (or help fixing those). ASSERT_RTNL is not
> dangerous.
>
> We had a long history in not correctly using rtnl lock in ipv6/multicast
> code and those wrongfully placed ASSERT_RTNLs were my bad when I fixed
> the duplicate address detection handling.
>
> If enough multicast addresses are subscribed to an interface we might
> again get those splats because enabling promisc mode on an interface
> will also check for rtnl lock.
>

Sure, I never doubt adding ASSERT_RTNL() is helpful, I just still think
this should be for net-next, or at least a separated patch. I don't want
my patch to be blamed in others' "Fixes:". :)
