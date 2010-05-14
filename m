From: Tejun Heo <tj@kernel.org>
Subject: Re: loosing IPMI-card by loading netconsole
Date: Sat, 15 May 2010 00:18:53 +0200
Message-ID: <4BEDCC4D.9060600@kernel.org>
References: <20100514134544.GA26674@gretchen.aei.mpg.de>	
	<DDC57477F5D6F845A0DDCB99D3C4812D0CA63BB9E4@orsmsx510.amr.corp.intel.com>	
	<4BED79EB.1000204@kernel.org>
	<1273857641.3057.20.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>, "Ronciak,
	John" <john.ronciak@intel.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>, Matt Mackall <mpm@selenic.com>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1273857641.3057.20.camel@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hello,

On 05/14/2010 07:20 PM, "Brandeburg, Jesse" wrote:
> On Fri, 2010-05-14 at 09:27 -0700, Tejun Heo wrote:
> We've actually had quite a few problems like this over the years, so I'm
> not quite so surprised to hear about something like this.
> 
> Its easy to break the reception of IPMI packets because there are a
> couple of registers that if not correctly configured during all points
> of driver lifetime (probe only, administratively down, up)

Heh... yeah, haven't heard a lot of kind things about IPMI.  IPMI
which shares the usual network connection seems like a good idea on
paper but doesn't really seem to work as expected.  It is a pretty
backward idea to have low level debugging / management mechanism
depending on all the highlevel stuff working correctly.

> One thing that would really help us is to see the stats from ethtool -S
> ethX when interface is up, and not receiving IPMI
>  
> The other "smoking gun" indicator is the output of the register dump
> tool called ethregs that we have posted at sourceforge.  Please gather
> registers for the card in question before and after loading netconsole.
> 
> http://prdownloads.sf.net/e1000/ethregs-1.7.2.tar.gz

I think Henning would be able to provide these info early next week.

>> On 2.6.27.39, netconsole + IPMI works fine.  On 2.6.32.7, as soon as
>> netconsole is loaded, IPMI stops working.  Unloading netconsole
>> doesn't revive IPMI but detaching the driver from the controller does.
>> In both cases, usual networking works fine.
> 
> I think that "loading netconsole" means bringing the interface "UP", in
> this case, is this correct?

Nope, modprobing the netconsole module.  Usual networking and IPMI
work happily together until netconsole is loaded.  The weird thing tho
is that Henning is reporting that IPMI is using different interface
from the netconsole.  No idea how they could interfact.

> To ask another way: Is network traffic active on the interface in
> question before netconsole is loaded?

So, yeap.

Thanks.

-- 
tejun

------------------------------------------------------------------------------

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
