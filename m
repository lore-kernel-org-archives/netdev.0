From: Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
Subject: Re: QEMU PIC indirection patch for in-kernel APIC work
Date: Thu, 05 Apr 2007 12:58:30 +0300
Message-ID: <4614C846.7070605@qumranet.com>
References: <4613BC6B.1070708@codemonkey.ws>
	<4613BF07.50606@qumranet.com>	<4613C993.9020405@codemonkey.ws>
	<4613CC01.1090500@qumranet.com>	<4613CDB2.4000903@codemonkey.ws>	<4613D001.3040606@qumranet.com>
	<20070404200112.GA6070@elte.hu>	<4614098F.2030307@us.ibm.com>
	<20070404212103.GA19026@elte.hu>	<1175728768.12230.593.camel@localhost.localdomain>
	<20070405093033.GC25448@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20070405093033.GC25448-X9Un+BFzKDI@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=kvm-devel>
List-Post: <mailto:kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Ingo Molnar wrote:
> so right now the only option for a clean codebase is the KVM in-kernel 
> code.

I strongly disagree with this.  Bad code in userspace is not an excuse 
for shoving stuff into the kernel, where maintaining it is much more 
expensive, and the cause of a mistake can be system crashes and data 
loss, affecting unrelated processes.  If we move something into the 
kernel, we'd better have a really good reason for it.

Qemu code _is_ crufty.  We can do one of three things:
1. live with it
2. fork it and clean it up
3. clean it up incrementally and merge it upstream

Currently we're doing (1).  You're suggesting a variant of (2), fork 
plus move into the kernel.  The right thing to do IMO is (3), but I 
don't see anybody volunteering.  Qemu picked up additional committers 
recently and I believe they would be receptive to cleanups.

[In the *pic/pit case, we have other reasons to push things into the 
kernel.  But "this code is crap, let's rewrite it in the kernel" is not 
a justification I'll accept.  I'd be much happier if we could quantify 
these other reasons.]


-- 
error compiling committee.c: too many arguments to function


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
