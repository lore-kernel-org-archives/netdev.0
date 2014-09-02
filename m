From: Cong Wang <cwang@twopensource.com>
Subject: Re: RTNL: assertion failed at net/ipv6/addrconf.c (1699)
Date: Tue, 2 Sep 2014 11:04:38 -0700
Message-ID: <CAHA+R7Mwy1SCpEUgGf9BdLEro6N-3t89KU=xL0iuzgOppXELrQ@mail.gmail.com>
References: <CA+ydwtoDwQVg_BWrxxdpUyJ7Up60GtxTCLYe_5vFdV2td_kGhQ@mail.gmail.com>
	<CAHA+R7MZCDGRhSf=UuVCGQvNo03wVziZQB_X30rwNf6hmHipQA@mail.gmail.com>
	<20140829195339.GA9780@kria>
	<1409363489.2980.17.camel@localhost>
	<CAHA+R7ODa+LrdwSrS7HcBfwwq8_fpj-Ld0OCDtcOqkpCdZCvxg@mail.gmail.com>
	<1409680684.972417.162793869.03CF8A61@webmail.messagingengine.com>
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
In-Reply-To: <1409680684.972417.162793869.03CF8A61@webmail.messagingengine.com>
Sender: trinity-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 2, 2014 at 10:58 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hi Cong,
>
> On Tue, Sep 2, 2014, at 18:50, Cong Wang wrote:
>> On Fri, Aug 29, 2014 at 6:51 PM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>> >
>> > Also rtnl_lock and rcu_read_lock compose in that order, so we don't need
>> > to change dev_get_by_flags, but as this is the only user it sure is
>> > possible. RCU locked version is just easier composeable, so I wouldn't
>> > touch that if needed in future, just also take rcu lock as before.
>>
>> There is no point to keep RCU read lock if we have rtnl lock,
>> I don't know why you don't want to change dev_get_by_flags(),
>> it is pretty easy to do since it only has one caller.
>
> I definitely don't have a problem cleaning this up in net-next. I wanted
> a minimal patch for stable because I didn't check history where and when
> additional users of dev_get_by_flags_rcu were removed.

`git grep` should show you we only have one caller. Apparently we don't
care about any out-of-tree module.

>
>> Even if you really need RCU in future, you are always welcome
>> to bring it back when you do, sorry we should never be blocked by
>> code NOT merged yet.
>>
>> >
>> > Also we should move ASSERT_RTNL checks from addrconf_join_solict to
>> > ipv6_dev_mc_inc/dec.
>> >
>>
>> Make it another patch.
>
> It is just one logical change, moving ASSERT_RTNLs to places where they
> better catch invalid callstacks.
>

Conflicts with what you claimed above. :)
