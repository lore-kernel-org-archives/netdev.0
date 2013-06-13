From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 1/2] net: remove NET_LL_RX_POLL
	config menue
Date: Thu, 13 Jun 2013 10:00:26 +0200
Message-ID: <51B97C1A.8000302@redhat.com>
References: <20130611142415.17879.75569.stgit@ladj378.jer.intel.com>
	<20130611142428.17879.33582.stgit@ladj378.jer.intel.com>
	<20130612.151205.1822920389019274346.davem@davemloft.net>
	<20130612190103.1545e310@nehalam.linuxnetplumber.net>
	<51B92ACE.7000307@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, or.gerlitz@gmail.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, hpa@zytor.com, amirv@mellanox.com,
	jesse.brandeburg@intel.com, eliezer@tamir.org.il,
	linux-kernel@vger.kernel.org, andi@firstfloor.org,
	bhutchings@solarflare.com, erdnetdev@gmail.com,
	eilong@broadcom.com, David Miller <davem@davemloft.net>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <51B92ACE.7000307@linux.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 06/13/2013 04:13 AM, Eliezer Tamir wrote:
> On 13/06/2013 05:01, Stephen Hemminger wrote:
>> On Wed, 12 Jun 2013 15:12:05 -0700 (PDT)
>> David Miller <davem@davemloft.net> wrote:
>>
>>> From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
>>> Date: Tue, 11 Jun 2013 17:24:28 +0300
>>>
>>>>       depends on X86_TSC
>>>
>>> Wait a second, I didn't notice this before.  There needs to be a better
>>> way to test for the accuracy you need, or if the issue is lack of a proper
>>> API for cycle counter reading, fix that rather than add ugly arch
>>> specific dependencies to generic networking code.
>>
>> This should be sched_clock(), rather than direct TSC access.
>> Also any code using TSC or sched_clock has to be carefully audited to deal with
>> clocks running at different rates on different CPU's. Basically value is only
>> meaning full on same CPU.
>
> OK,
>
> If we covert to sched_clock(), would adding a define such as HAVE_HIGH_PRECISION_CLOCK to architectures that have both a high precision clock and a 64 bit cycles_t be a good solution?
>
> (if not any other suggestion?)

Hm, probably cpu_clock() and similar might be better, since they use
sched_clock() in the background when !CONFIG_HAVE_UNSTABLE_SCHED_CLOCK
(meaning when sched_clock() provides synchronized highres time source from
the architecture), and, quoting ....

  Otherwise it tries to create a semi stable clock from a mixture of other
  clocks, including:

   - GTOD (clock monotomic)
   - sched_clock()
   - explicit idle events

But yeah, it needs to be evaluated regarding the drift between CPUs in
general.

Then, eventually, you could get rid of the entire NET_LL_RX_POLL config
option plus related ifdefs in the code and have it built-in in general?

------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
