From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: igbvf: add new driver to support 82576 virtual functions
Date: Wed, 25 Mar 2009 09:10:48 -0700
Message-ID: <49CA5788.2000402@intel.com>
References: <20090324.233843.61607506.davem@davemloft.net> <9929d2390903250145q2aae3046wb378d190576642c7@mail.gmail.com> <9929d2390903250203u42b50b54j2db3464967d48702@mail.gmail.com> <20090325094742.GA7760@yzhao-otc.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	Matthew Wilcox <willy@linux.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Zhao, Yu" <yu.zhao@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14690 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759613AbZCYQLI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Mar 2009 12:11:08 -0400
In-Reply-To: <20090325094742.GA7760@yzhao-otc.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zhao, Yu wrote:
> On Wed, Mar 25, 2009 at 05:03:29PM +0800, Kirsher, Jeffrey T wrote:
>> On Wed, Mar 25, 2009 at 1:45 AM, Jeff Kirsher
>> <jeffrey.t.kirsher@intel.com> wrote:
>>> On Tue, Mar 24, 2009 at 11:38 PM, David Miller <davem@davemloft.net> wrote:
>>>> This breaks the build:
>>>>
>>>> drivers/net/igbvf/ethtool.c: In function 'igbvf_set_ringparam':
>>>> drivers/net/igbvf/ethtool.c:299: error: implicit declaration of function 'vmalloc'
>>>> drivers/net/igbvf/ethtool.c:299: warning: assignment makes pointer from integer without a cast
>>>> drivers/net/igbvf/ethtool.c:346: error: implicit declaration of function 'vfree'
>>>> --
>>> Sorry Dave, I thought this was called out earlier, but I see it was
>>> not.  The igbvf driver requires the following patches applied to your
>>> tree to have them compile.  Last I heard, these SR-IOV patches were
>>> accepted for 2.6.30, in the PCI tree.
>>>
>>> Yu, can you confirm that these patches have been accepted for 2.6.30?
>>>
>>> Summary:
>>> http://marc.info/?l=linux-kernel&m=123751955907397&w=2
>>> Patches:
>>> http://marc.info/?l=linux-kernel&m=123751956107417&w=2
>>> http://marc.info/?l=linux-kernel&m=123751956207423&w=2
>>> http://marc.info/?l=linux-kernel&m=123751981407629&w=2
>>> http://marc.info/?l=linux-kernel&m=123751981507632&w=2
>>> http://marc.info/?l=linux-kernel&m=123751981707644&w=2
>>> http://marc.info/?l=linux-kernel&m=123751981607635&w=2
>>> http://marc.info/?l=linux-kernel&m=123751981607638&w=2
>>> http://marc.info/?l=linux-kernel&m=123751981707641&w=2
>> I confirmed that Jesse Barnes has these SR-IOV patches queued up for 2.6.30.
>> http://marc.info/?l=linux-kernel&m=123757169806111&w=2
> 
> Yes, it's in Jesse's linux-next branch:
> http://git.kernel.org/?p=linux/kernel/git/jbarnes/pci-2.6.git;a=shortlog;h=linux-next
> 
> Thanks,
> Yu

The problem isn't the SR-IOV patches it is a difference in 
architectures.  The x86/x86_64 architecture lets you be a bit more 
sloppy when it comes to including vmalloc.  I've seen it in the past 
with igb, and I suspect that is why we didn't catch this in testing.  We 
just need to add a #include of vmalloc.h in ethtool.c and the issue 
should be fixed.

Thanks,

Alex
