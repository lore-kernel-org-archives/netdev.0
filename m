From: Michal Marek <mmarek@suse.cz>
Subject: Re: [PATCH] build some drivers only when compile-testing
Date: Tue, 18 Jun 2013 10:44:52 +0200
Message-ID: <51C01E04.2050908@suse.cz>
References: <1369214326-6558-1-git-send-email-jslaby@suse.cz> <20130523022327.GB6159@kroah.com> <519D8876.9050405@suse.com> <51BF6BFF.7050705@suse.cz> <51BFE754.5080301@suse.cz> <20130618081858.GD5461@arwen.pp.htv.fi> <51C01948.9060708@suse.cz> <20130618083425.GI5461@arwen.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jslaby@suse.cz>, Jeff Mahoney <jeffm@suse.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	jirislaby@gmail.com, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	linux-usb@vger.kernel.org,
	Florian Tobias Schandinat <FlorianSchandinat@gmx.de>,
	linux-geode@lists.infradead.org, linux-fbdev@vger.kernel.org,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org, Ben Hutchings <ben@decadent.org.uk>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>, tomi.valkeinen@ti.com
To: balbi@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130618083425.GI5461@arwen.pp.htv.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dne 18.6.2013 10:34, Felipe Balbi napsal(a):
> Hi,
> 
> On Tue, Jun 18, 2013 at 10:24:40AM +0200, Jiri Slaby wrote:
>>>>> Sam Ravnborg (the kconfig ex-maintainer) once wrote that
>>>>> he doesn't want to extend the kconfig language for this
>>>>> purpose (which I support). That a config option is fine and
>>>>> sufficient in this case [1]. Except he called the config
>>>>> option "SHOW_ALL_DRIVERS". Adding the current maintainer to
>>>>> CCs ;).
>>>> 
>>>> I agree with Sam. 'depends on XY || COMPILE_TEST' is quite 
>>>> self-explanatory. And even if it's not, you can look up the
>>>> help text for COMPILE_TEST. With "archdepends on" or
>>>> "available on", you need to know what to look for to override
>>>> the dependency.
>>> 
>>> you will still end up with:
>>> 
>>> depends on (ARCH_OMAP || ARCH_EXYNOS || ARCH_DAVINCI ||
>>> ARCH_PPC || ...)
>>> 
>>> And every now and again that particular line will be updated
>>> to add another arch dependency.
>> 
>> But that is perfectly fine *when* the driver is supported on
>> those archs only.
>> 
>> And come on, how much often will this "every now and again"
>> happen? We don't have that much cases where a driver is augmented
>> to work on another arch or platform. It either works on all of
>> them => doesn't need COMPILE_TEST, or work on one or two arches
>> at most.
> 
> MUSB alone has 8 different arch choices. Before, it used to be that
> core driver was dependendent on all of them, so whenever someone
> wanted to build MUSB for another arch, they had to introdude their
> glue code and modify the dependency of the core driver.

But that you have complex dependencies in some drivers is mostly
orthogonal to the two choices of syntax, isn't it?

depends on ARCH1 || ARCH2 || .... || ARCH8 || COMPILE_TEST

vs.

archdepends on ARCH1 || ARCH2 || .... || ARCH8

Michal
