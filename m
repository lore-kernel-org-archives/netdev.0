From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: randconfig build error with next-20150421, in net/ceph
Date: Tue, 21 Apr 2015 09:16:13 -0700
Message-ID: <20150421161613.GA29133@roeck-us.net>
References: <CA+r1Zhgwq-t+M8XOxDqf5synesyHODOee2gNwAJpWE+wwmAAoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>, zyan@redhat.com,
	sage@redhat.com, "David S. Miller" <davem@davemloft.net>,
	ceph-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Jim Davis <jim.epost@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+r1Zhgwq-t+M8XOxDqf5synesyHODOee2gNwAJpWE+wwmAAoQ@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 21, 2015 at 08:10:44AM -0700, Jim Davis wrote:
> Building with the attached random configuration file,
> 
> ERROR: "__divdi3" [net/ceph/libceph.ko] undefined!

Commit 7321f19d ("crush: straw2 bucket type with an efficient 64-bit crush_ln()").

+                       draw = ln / w;

where 'ln' is 64 bit.

Some other oddies in that patch, such as 

+#if defined(__linux__)
+#include <linux/types.h>
+#elif defined(__FreeBSD__)
+#include <sys/types.h>
+#endif

and lots of coding style violations.

Guenter
