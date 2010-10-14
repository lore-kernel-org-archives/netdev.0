From: Michal Marek <mmarek@suse.cz>
Subject: Re: [RFC PATCH net-next] drivers/net
 Documentation/networking: Create directory intel_wired_lan
Date: Thu, 14 Oct 2010 23:37:33 +0200
Message-ID: <4CB7781D.80103@suse.cz>
References: <1286743352.11039.165.camel@Joe-Laptop>	
	<AANLkTikVKufQRuMGd=cdig7ff4k2aw9Q1FWwMz3pgon-@mail.gmail.com>	
	<1286841648.26045.17.camel@Joe-Laptop>	
	<1287008906.1117.428.camel@Joe-Laptop>	
	<1287032255.4113.14.camel@jtkirshe-MOBL1>	
	<1287035857.1117.528.camel@Joe-Laptop>	
	<1287048849.3319.20.camel@jtkirshe-MOBL1>
	<1287084643.1117.602.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kbuild@vger.kernel.org,
	e1000-devel <e1000-devel@lists.sourceforge.net>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>, "Ronciak,
	John" <john.ronciak@intel.com>, jeffrey.t.kirsher@intel.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sam Ravnborg <sam@ravnborg.org>
To: Joe Perches <joe@perches.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1287084643.1117.602.camel@Joe-Laptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 14.10.2010 21:30, Joe Perches wrote:
> On Thu, 2010-10-14 at 02:34 -0700, Jeff Kirsher wrote:
>> On Wed, 2010-10-13 at 22:57 -0700, Joe Perches wrote:
>>> On Wed, 2010-10-13 at 21:57 -0700, Jeff Kirsher wrote:
>>>> On Wed, 2010-10-13 at 15:28 -0700, Joe Perches wrote:
>>>> Sorry I am not ignoring you, I was taking a closer look at your patch.
>>>>> What regression testing would actually be done?
>>>> The Makefile and Kconfig needs more work.  I applied your patch and none
>>>> of the Intel Wired drivers build.
>>> Care to describe the Makefile/Kconfig issues you have seen?
>>> I built it allyesconfig, defconfig, allmodconfig and allnoconfig.
>> Yeah, I found all of those built without errors, but if you build the
>> Intel Wired LAN drivers as modules, you will not find the *.ko files
>> after the build.  The Kconfig files look fine, the problem was with the
>> Makefiles.  Instead of creating a drivers/net/intel_wired_lan/Makefile,
>> I simply changed the path in drivers/net/Makefile to the updated path
>> and that resolved the issue.
> 
> (adding a few cc's and a link for history)
> 
> http://lkml.org/lkml/2010/10/10/207
> 
> That's the way I had done it originally as well, but I found
> you couldn't build the directory with:
> 
> 	make drivers/net/intel_wired_lan/
> 
> so I created a Makefile in the new directory below with
> the elements necessary.
> 
> Perhaps there's some missing functionality in the build system
> when the Kconfig file resides in a higher directory and the
> directory being built doesn't have a Kconfig file?

This has nothing to do with Kconfig files, I assume you meant Makefiles.


> I think it'd wrong to duplicate the makefile components in
> 2 places to allow "make subdir/" and I wonder if there's a
> good solution for this.

There is no duplication needed, drivers/net/Makefile needs to contain
obj-y += intel_wired_lan/ and drivers/net/intel_wired_lan/Makefile
similar lines for its subdirs. I see your original patch was lacking an
entry in drivers/net/Makefile, so perhaps that was the problem Jeff was
seeing?

Michal

------------------------------------------------------------------------------
Download new Adobe(R) Flash(R) Builder(TM) 4
The new Adobe(R) Flex(R) 4 and Flash(R) Builder(TM) 4 (formerly 
Flex(R) Builder(TM)) enable the development of rich applications that run
across multiple browsers and platforms. Download your free trials today!
http://p.sf.net/sfu/adobe-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
