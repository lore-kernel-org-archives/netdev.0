From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH v2 net-next 0/8] API set for HW Buffer management
Date: Thu, 18 Feb 2016 18:32:23 +0100
Message-ID: <877fi1rkk8.fsf@free-electrons.com>
References: <1455636823-14470-1-git-send-email-gregory.clement@free-electrons.com>
	<20160217225958.GA31113@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Timor Kardashov <timork@marvell.com>,
	Sebastian Careba <nitroshift@yahoo.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160217225958.GA31113@1wt.eu> (Willy Tarreau's message of "Wed,
	17 Feb 2016 23:59:58 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Willy,
=20
 On mer., f=C3=A9vr. 17 2016, Willy Tarreau <w@1wt.eu> wrote:

> Hi Gregory,
>
> On Tue, Feb 16, 2016 at 04:33:35PM +0100, Gregory CLEMENT wrote:
>> Hello,
>>=20
>> A few weeks ago I sent a proposal for a API set for HW Buffer
>> management, to have a better view of the motivation for this API see
>> the cover letter of this proposal:
>> http://thread.gmane.org/gmane.linux.kernel/2125152
>>=20
>> Since this version I took into account the review from Florian:
>> - The hardware buffer management helpers are no more built by defaul=
t
>>   and now depend on a hidden config symbol which has to be selected
>>   by the driver if needed
>> - The hwbm_pool_refill() and hwbm_pool_add() now receive a gfp_t as
>>   argument allowing the caller to specify the flag it needs.
>> - buf_num is now tested to ensure there is no wrapping
>> - A spinlock has been added to protect the hwbm_pool_add() function =
in
>>   SMP or irq context.
>>=20
>> I also used pr_warn instead of pr_debug in case of errors.
>>=20
>> I fixed the mvneta implementation by returning the buffer to the poo=
l
>> at various place instead of ignoring it.
>>=20
>> About the series itself I tried to make this series easier to merge:
>> - Squashed "bus: mvenus-mbus: Fix size test for
>>    mvebu_mbus_get_dram_win_info" into bus: mvebu-mbus: provide api f=
or
>>    obtaining IO and DRAM window information.
>> - Added my signed-otf-by on all the patches as submitter of the seri=
es.
>> - Renamed the dts patches with the pattern "ARM: dts: platform:"
>> - Removed the patch "ARM: mvebu: enable SRAM support in
>>   mvebu_v7_defconfig" of this series and already applied it
>> - Rodified the order of the patches.
>>=20
>> In order to ease the test the branch mvneta-BM-framework-v2 is
>> available at git@github.com:MISL-EBU-System-SW/mainline-public.git.
>
> Well, I tested this patch series on top of latest master (from today)
> on my fresh new clearfog board. I compared carefully with and without
> the patchset. My workload was haproxy receiving connections and forwa=
rding
> them to my PC via the same port. I tested both with short connections
> (HTTP GET of an empty file) and long ones (1 MB or more). No trouble
> was detected at all, which is pretty good. I noticed a very tiny
> performance drop which is more noticeable on short connections (high
> packet rates), my forwarded connection rate went down from 17500/s to
> 17300/s. But I have not checked yet what can be tuned when using the
> BM, nor did I compare CPU usage. I remember having run some tests in
> the past, I guess it was on the XP-GP board, and noticed that the BM
> could save a significant amount of CPU and improve cache efficiency,
> so if this is the case here, we don't really care about a possible 1%
> performance drop.
>
> I'll try to provide more results as time permits.
>
> In the mean time if you want (or plan to submit a next batch), feel
> free to add a Tested-by: Willy Tarreau <w@1wt.eu>.

Great!  thanks for testing.

Gregory

>
> cheers,
> Willy
>

--=20
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
