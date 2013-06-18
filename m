From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: [PATCH] build some drivers only when compile-testing
Date: Tue, 18 Jun 2013 11:21:23 +0200
Message-ID: <51C02693.9040304@suse.cz>
References: <1369214326-6558-1-git-send-email-jslaby@suse.cz> <20130523022327.GB6159@kroah.com> <519D8876.9050405@suse.com> <51BF6BFF.7050705@suse.cz> <51BFE754.5080301@suse.cz> <20130618081858.GD5461@arwen.pp.htv.fi> <51C01948.9060708@suse.cz> <20130618083425.GI5461@arwen.pp.htv.fi> <51C01E04.2050908@suse.cz> <20130618085154.GN5461@arwen.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Mahoney <jeffm@suse.com>,
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
To: balbi@ti.com, Michal Marek <mmarek@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130618085154.GN5461@arwen.pp.htv.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/18/2013 10:51 AM, Felipe Balbi wrote:
> right, but my argument is that I rather not have either. Depend on
> PCI if you us PCI, depend on EXTCON if you use extcon, but no
> driver should have an ARCH dependency. Specially since it lets
> people include mach/* and asm/* headers because "it doesn't break
> compilation for anyone".

The argument is elsewhere. If I understand correctly, Kconfig is for
users, not to be hi-jacked by kernel developers. And users should not
really care about our development processes, cross compilations or
whatever bells and whistles we use. They just don't want to see
drivers which they have no way to *use*, they indeed don't care
whether some more compile at all. We do not want every kernel packager
for every distro out in the wild, to go through all the help texts, to
see whether they should compile and package a driver or not. It's a
tedious work and this option would save time to the packagers.

Try to package and maintain a kernel for a distribution, you will find
out what a cool and surprising work that is...

In the best case I would vote for hard dependencies as cross-compilers
are easy to obtain and set up nowadays. But well, we still want to
("cross") compile drivers, so let's add COMPILE_TEST and use that to
save time to automatic builds.

-- 
js
suse labs
