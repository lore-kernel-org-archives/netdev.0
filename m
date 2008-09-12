From: Elad Lahav <elahav@uwaterloo.ca>
Subject: Re: Performance degradration 2.6.25->2.6.26
Date: Fri, 12 Sep 2008 10:58:37 -0400
Message-ID: <48CA839D.308@uwaterloo.ca>
References: <489C0F2C.9040101@users.sourceforge.net>
	<alpine.WNT.1.10.0808080906590.5428@jbrandeb-MOBL1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Elad Lahav <elad_lahav@users.sourceforge.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.WNT.1.10.0808080906590.5428@jbrandeb-MOBL1.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

>> HyperThreading, for a total of 4 logical processors, and 4 Intel Gigabit
>>   NICs on a PCI 64/66 bus (82546EB). In the experiments, I am pinning
>> four sending processes (one per NIC) to logical processors 0 and 2, and
>> the NIC interrupts to logical processors 1 and 3, such that interrupts
>> are serviced by the sibling logical processor of the one sending the
>> packets. I have used both the driver that comes with the Linux kernel
>> (7.3.20-k2-NAPI), as well as a more recent one (7.6.15.5).

I believe I have found the problem, and it has nothing to do with the driver.
Up to the latest kernel, logical processors on the same chip had sequential CPU IDs. So 
CPU 0 and CPU 1 were two logical processors on the first physical one, 2 and 3 on the 
second physical one, etc.
It seems that now this ordering has changed. I was running my experiments on logical 
processors 0 and 2, assuming they were on different physical processors, when, in fact, 
they were sharing the same one. When pinning the processes to logical processor 0 and 1, I 
get at least as good a performance as I do on previous kernels.

Thanks,
Elad


-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
