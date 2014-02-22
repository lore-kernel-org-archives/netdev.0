From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 3/6] 6lowpan: move
	6lowpan.c to 6lowpan_rtnl.c
Date: Sat, 22 Feb 2014 15:03:48 +0100
Message-ID: <20140222140344.GA1032@omega>
References: <1392995711-19563-1-git-send-email-alex.aring@gmail.com>
	<1392995711-19563-4-git-send-email-alex.aring@gmail.com>
	<1393076452.15717.98.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1393076452.15717.98.camel-nDn/Rdv9kqW9Jme8/bJn5UCKIB8iOfG2tUK59QYPAWc@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Ben,

thanks for your reply.

On Sat, Feb 22, 2014 at 01:40:52PM +0000, Ben Hutchings wrote:
> On Fri, 2014-02-21 at 16:15 +0100, Alexander Aring wrote:
> > We have a 6lowpan.c file and 6lowpan.ko file. To avoid confusing we
> > should move 6lowpan.c to 6lowpan.ko. Then we can support multiple source
> 
> You put the wrong filename here ^
> 
mhh, I meant here:

Currently we have only one-file supporting like:

obj-$(CONFIG_IEEE802154_6LOWPAN) += 6lowpan.o


It's generate a 6lowpan.ko from a 6lowpan.c file.

Now we need some multiple-file supporting and I change it to:

obj-$(CONFIG_IEEE802154_6LOWPAN) += 6lowpan.o
6lowpan-y := 6lowpan_rtnl.o reassembly.o


to generate a still the 6lowpan.ko module with object files of
6lowpan_rtnl.o (which contains mostly some rtnl callbacks implementations
now) and reassembly.o file.

It's to support multiple files for a module only.


I can't do something like:

obj-$(CONFIG_IEEE802154_6LOWPAN) += 6lowpan.o
6lowpan-y := 6lowpan.o reassembly.o

because I have the same name for 6lowpan.c and 6lowpan.ko.

Is there maybe a better solution for this?



btw.

I also detected:

obj-$(CONFIG_6LOWPAN_IPHC) += 6lowpan_iphc.o

which is a seperate module. (if you selected it as module) but this
makes no sense, we should built it in 6lowpan.ko like:

6lowpan-y := 6lowpan_rtnl.o 6lowpan_iphc.o reassembly.o

aswell.


- Alex

------------------------------------------------------------------------------
Managing the Performance of Cloud-Based Applications
Take advantage of what the Cloud has to offer - Avoid Common Pitfalls.
Read the Whitepaper.
http://pubads.g.doubleclick.net/gampad/clk?id=121054471&iu=/4140/ostg.clktrk
