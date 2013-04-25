From: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH 1/5] ibmebus: convert of_platform_driver to
 platform_driver
Date: Fri, 26 Apr 2013 03:35:30 +1000
Message-ID: <1366911329.2869.31.camel@pasglop>
References: <1366596798-9457-1-git-send-email-robherring2@gmail.com>
	 <1366596798-9457-2-git-send-email-robherring2@gmail.com>
	 <CAL_JsqKDF=hPEM0Jz-zZSXBCXBZ=gBjLWL6QDvq+nFWkqY3DMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org"
	<devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Hoang-Nam Nguyen <hnguyen-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Christoph Raisch <raisch-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Thadeu Lima de Souza Cascardo <cascardo-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rob Herring <robherring2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL_JsqKDF=hPEM0Jz-zZSXBCXBZ=gBjLWL6QDvq+nFWkqY3DMw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-04-25 at 10:23 -0500, Rob Herring wrote:
> Ben, Can I have your Ack for this? The change is straightforward and
> neither of the 2 drivers used the id parameter that is removed.

Didn't you get my mail about a compile failure caused by this patch ?

Or did you send an update that I missed ?

(Copy of the original email below)

Cheers,
Ben.

----

On Sun, 2013-04-21 at 21:13 -0500, Rob Herring wrote:
> From: Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>
> 
> ibmebus is the last remaining user of of_platform_driver and the
> conversion to a regular platform driver is trivial.

A quick build test leads to:

/home/benh/linux-powerpc-test/arch/powerpc/kernel/ibmebus.c: In function 'ibmebus_bus_device_probe':
/home/benh/linux-powerpc-test/arch/powerpc/kernel/ibmebus.c:344:2: error: implicit declaration of function 'to_platform_driver' [-Werror=implicit-function-declaration]
/home/benh/linux-powerpc-test/arch/powerpc/kernel/ibmebus.c:344:6: error: assignment makes pointer from integer without a cast [-Werror]
/home/benh/linux-powerpc-test/arch/powerpc/kernel/ibmebus.c: In function 'ibmebus_bus_device_remove':
/home/benh/linux-powerpc-test/arch/powerpc/kernel/ibmebus.c:363:32: error: initialization makes pointer from integer without a cast [-Werror]
/home/benh/linux-powerpc-test/arch/powerpc/kernel/ibmebus.c: In function 'ibmebus_bus_device_shutdown':
/home/benh/linux-powerpc-test/arch/powerpc/kernel/ibmebus.c:373:32: error: initialization makes pointer from integer without a cast [-Werror]
/home/benh/linux-powerpc-test/arch/powerpc/kernel/ibmebus.c: In function 'ibmebus_bus_legacy_suspend':
/home/benh/linux-powerpc-test/arch/powerpc/kernel/ibmebus.c:420:32: error: initialization makes pointer from integer without a cast [-Werror]
/home/benh/linux-powerpc-test/arch/powerpc/kernel/ibmebus.c: In function 'ibmebus_bus_legacy_resume':
/home/benh/linux-powerpc-test/arch/powerpc/kernel/ibmebus.c:431:32: error: initialization makes pointer from integer without a cast [-Werror]
cc1: all warnings being treated as errors
make[2]: *** [arch/powerpc/kernel/ibmebus.o] Error 1
make[2]: *** Waiting for unfinished jobs....

Haven't had a chance to look too closely today -EJETLAG :-)


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
