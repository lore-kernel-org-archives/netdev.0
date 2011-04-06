From: Michal Marek <mmarek@suse.cz>
Subject: Re: [PATCH 00/34] Make kernel build deterministic
Date: Wed, 06 Apr 2011 11:07:34 +0200
Message-ID: <4D9C2D56.70700@suse.cz>
References: <1302015561-21047-1-git-send-email-mmarek@suse.cz>	
	<20110405154918.GA31337@suse.de> <1302031447.2608.41.camel@koala>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: anil_ravindranath@pmc-sierra.com, mchehab@redhat.com,
	benh@kernel.crashing.org, mac@melware.de, aacraid@adaptec.com,
	linux-mtd@lists.infradead.org, allan.stephens@windriver.com,
	hpa@zytor.com, t.sailer@alumni.ethz.ch, gwingerde@gmail.com,
	x86@kernel.org, elf@buici.com, cluster-devel@redhat.com,
	ccaulfie@redhat.com, mingo@redhat.com, dougthompson@xmission.com,
	tipc-discussion@lists.sourceforge.net, dwmw2@infradead.org,
	linux-media@vger.kernel.org, arnaud.giersch@free.fr,
	linux-kbuild@vger.kernel.org, IvDoorn@gmail.com,
	teigland@redhat.com, tony.olech@elandigitalsystems.com,
	apw@canonical.com, linux-hams@vger.kernel.org,
	tglx@linutronix.de, swhiteho@redhat.com,
	linux-arm-kernel@lists.infradead.org, linux-edac@vger.kernel.org,
	jon.maloy@ericsson.com, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org, Greg KH <gregkh@suse.de>,
	linux-wireless@vger.kernel.org, linux-kernel@
To: dedekind1@gmail.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1302031447.2608.41.camel@koala>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 5.4.2011 21:24, Artem Bityutskiy wrote:
> On Tue, 2011-04-05 at 08:49 -0700, Greg KH wrote:
>> On Tue, Apr 05, 2011 at 04:58:47PM +0200, Michal Marek wrote:
>>>
>>> Hi,
>>>
>>> this series makes it possible to build bit-identical kernel image and
>>> modules from identical sources. Of course the build is already
>>> deterministic in terms of behavior of the code, but the various
>>> timestamps embedded in the object files make it hard to compare two
>>> builds, for instance to verify that a makefile cleanup didn't
>>> accidentally change something. A prime example is /proc/config.gz, which
>>> has both a timestamp in the gzip header and a timestamp in the payload
>>> data. With this series applied, a script like this will produce
>>> identical kernels each time:
>>
>> Very nice stuff.  Do you want to take the individual patches through one
>> of your trees, or do you mind if the subsystem maintainers take them
>> through theirs?
> 
> But unfortunately, it is very easy to break this and for sure it'll be
> broken very soon.

I'm not so pessimistic. 34 patches and 57 files might sound like a lot,
but given that this has been accumulating since day one, the cleanup
should last for some time.


> So additionally, I'd suggest:
> 1. Instrument checkpatch.pl and make it err or warn on timestamps.

This is patch 34/34 in this series: https://lkml.org/lkml/2011/4/5/198


> 2. Probably instrument linux-next to rise a warning when people break
>    this.

I'm not sure if Stephen has that much spare time, and I don't think it
is necessary. I think the checkpatch check is sufficient and I'll check
myself occasionally.

Michal
