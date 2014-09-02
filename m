From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: RTNL: assertion failed at net/ipv6/addrconf.c (1699)
Date: Tue, 02 Sep 2014 15:08:21 -0400
Message-ID: <540615A5.4070902@gmail.com>
References: <CA+ydwtoDwQVg_BWrxxdpUyJ7Up60GtxTCLYe_5vFdV2td_kGhQ@mail.gmail.com>	<CAHA+R7MZCDGRhSf=UuVCGQvNo03wVziZQB_X30rwNf6hmHipQA@mail.gmail.com>	<20140829195339.GA9780@kria>	<1409363489.2980.17.camel@localhost>	<CAHA+R7ODa+LrdwSrS7HcBfwwq8_fpj-Ld0OCDtcOqkpCdZCvxg@mail.gmail.com>	<1409680684.972417.162793869.03CF8A61@webmail.messagingengine.com>	<CAHA+R7Mwy1SCpEUgGf9BdLEro6N-3t89KU=xL0iuzgOppXELrQ@mail.gmail.com>	<1409681487.26422.1.camel@edumazet-glaptop2.roam.corp.google.com> <CAHA+R7PY=Pu7VKA3wp1DxeJRckxPNWL-xfv2XXkpaY935kt61A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sabrina Dubroca <sd@queasysnail.net>,
	Tommi Rantala <tt.rantala@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, trinity@vger.kernel.org,
	Dave Jones <davej@redhat.com>
To: Cong Wang <cwang@twopensource.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHA+R7PY=Pu7VKA3wp1DxeJRckxPNWL-xfv2XXkpaY935kt61A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/02/2014 02:15 PM, Cong Wang wrote:
> On Tue, Sep 2, 2014 at 11:11 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Tue, 2014-09-02 at 11:04 -0700, Cong Wang wrote:
>>> On Tue, Sep 2, 2014 at 10:58 AM, Hannes Frederic Sowa
>>
>>>> I definitely don't have a problem cleaning this up in net-next. I wanted
>>>> a minimal patch for stable because I didn't check history where and when
>>>> additional users of dev_get_by_flags_rcu were removed.
>>>
>>> `git grep` should show you we only have one caller. Apparently we don't
>>> care about any out-of-tree module.
>>
>> Point is : you did not check if some stable versions had more callers.
>>
>> Its very nice you checked current version, but it is not enough for a
>> stable candidate.
> 
> That is what we do when backporting patches, I can do that if David asks
> me to backport it, but you know for netdev that is David's work.
> 
> (I am not saying I don't want to help him, I just want to point out the fact.
> I am very pleased to help David for stable backports as long as he asks)

Instead of helping after the fact, why not arrange the patches so that it's
not such a big issue.  Leave the _rcu variant alone.  Add an _rtnl variant
of the function and use that in the patch.  Have a follow-on patch that
removes the _rcu variant all by itself.  This way backports become easier,
and if anyone wants the _rcu variant back, all they have to do is revert
a very simple commit.

-vlad
