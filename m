From: Tom Herbert <therbert@google.com>
Subject: Re: Strange latency spikes/TX network stalls on Sun
 Fire X4150(x86) and e1000e
Date: Wed, 6 Jun 2012 11:21:40 -0700
Message-ID: <CA+mtBx-o4WB5gmHRMTQ6+haNrbeJyaaX9zXPhhYZydZbSPO98w@mail.gmail.com>
References: <668eeb0d42a1678d9083a58deb3ac40d@visp.net.lb>
	<88c43001441945e1431609db252b69e7@visp.net.lb>
	<df211722d18136698aeeda2f17b876e2@visp.net.lb>
	<d3a88d6c741394a48aee6179d58e4edf@visp.net.lb>
	<CA+mtBx9axFKCjLwDYMvXXP2nB_og896kAhG0UYWaK6PTAXhPcw@mail.gmail.com>
	<79d6b56fdf5f4be4656079568d5a7445@visp.net.lb>
	<CA+mtBx_sF5GCMRpLQuTruZ=xpFTFpd5z8SZJaG_dBqf4oCXpwg@mail.gmail.com>
	<20120529232518.e5b41759.shimoda.hiroaki@gmail.com>
	<1338959413.2760.3686.camel@edumazet-glaptop>
	<20120606174303.0bfc9868.shimoda.hiroaki@gmail.com>
	<20120606092635.00003b61@unknown>
	<20120607021937.a5638bfd.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	davem@davemloft.net
To: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20120607021937.a5638bfd.shimoda.hiroaki@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

I'm not exactly sure what the exact effect of WTHRESH is here.  Does
the device coalesce 5 completions regardless of size?  Would the
problem be avoided if bql limit_min were MTU, or could same issue be
hit with larger that 64 byte packets?

Tom

On Wed, Jun 6, 2012 at 10:19 AM, Hiroaki SHIMODA
<shimoda.hiroaki@gmail.com> wrote:
> On Wed, 6 Jun 2012 09:26:35 -0700
> Jesse Brandeburg <jesse.brandeburg@intel.com> wrote:
>
>> On Wed, 6 Jun 2012 Hiroaki SHIMODA <shimoda.hiroaki@gmail.com> wrote:
>> > Sorry for long delay. I'll post.
>> > (I have no idea how to fix this problem as keeping TXDCTL.WTHRESH to 5)
>>
>> I don't like changing WTHRESH wholesale because making the global change
>> to WTHRESH on e1000e just to fix this one bug (likely specific to a
>> particular chip/hardware) will adversely effect performance on many
>> models supported by e1000e not demonstrating any problem. =A0We could
>> possibly check something in for just ESB2LAN (S5000 chipset).
>>
>> Other people (tom herbert) with this same chipset have been unable to
>> reproduce this issue right?
>
> I understand your performance concern.
>
> The affected chip would be e1000_82571, e1000_82572, e1000_82574
> and e1000_80003es2lan which have FLAG2_DMA_BURST bit in
> adapter->flags2.
> Anyway, I have no objection intel guys NACK to my patch and
> provide right fix. But in that case please consider 82574L chip too
> which I observed similar behaviour.
>
> Thanks.

---------------------------------------------------------------------------=
---
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and =

threat landscape has changed and how IT managers can respond. Discussions =

will include endpoint security, mobile security and the latest in malware =

threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.co=
m/community/wired
