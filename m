From: John Stultz <john.stultz@linaro.org>
Subject: Re: [REGRESSION] asix: Lots of asix_rx_fixup() errors and slow transmissions
Date: Fri, 6 May 2016 10:40:47 -0700
Message-ID: <CALAqxLUtASiOiOE6YGj8B1w+r8u+Q00WtJ9_D68Y6SMyXTyFcA@mail.gmail.com>
References: <CALAqxLUj+-yUGTNviHu4+KE9=JTxjZyHBv4pdUob=xndAr8ZmA@mail.gmail.com>
	<57286E15.2080900@mentor.com>
	<CAFGCpxx0f7g7rXyZ-P0EF7QVX7Z0ziK+7VMPKK7pQteBowkw3Q@mail.gmail.com>
	<5728837D.60702@mentor.com>
	<CALAqxLXbMuK3Sj45vbf_r4GYQR=8bGUrhDz9-7+S2pbO_dJZ4A@mail.gmail.com>
	<572B0023.9060505@mentor.com>
	<CAFGCpxyeXkbQXW6Dm9ZpUXpVDWgaQziPnsC9GcZPqeg5jnbJUA@mail.gmail.com>
	<572CB188.7050203@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Guodong Xu <guodong.xu@linaro.org>,
	lkml <linux-kernel@vger.kernel.org>,
	Mark Craske <Mark_Craske@mentor.com>,
	"David S. Miller" <davem@davemloft.net>,
	YongQin Liu <yongqin.liu@linaro.org>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Ivan Vecera <ivecera@redhat.com>,
	"David B. Robins" <linux@davidrobins.net>
To: Dean Jenkins <Dean_Jenkins@mentor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <572CB188.7050203@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 6, 2016 at 8:00 AM, Dean Jenkins <Dean_Jenkins@mentor.com> wrote:
> My conclusion is that your USB to Ethernet Adaptor is not running at high
> speed (480Mbps) mode which is causing a partial loss (corruption) of
> Ethernet frames across the USB link. A USB Protocol Analyser or software
> tool usbmon could be used to confirm this scenario.
>
> Therefore please retest with a working high-speed USB hub or remove the
> full-speed USB hub from the test environment and directly connect the USB to
> Ethernet Adaptor to the root hub of the USB port. Then repeat the tests to
> see whether anything improved.
>
> In other words, you need to eliminate the dmesg messages saying "not running
> at top speed; connect to a high speed hub".

The aarch64 system has a quirk that at the moment limits it to the
slower full-speed mode, which also exacerbates the issue (basically
taking a fairly slow 1.1.Mb/s network connection without your patch,
to an almost unusable 30Kb/s with it).

But that isn't the case on the x86_64 system, which is seeing a very
similar problem (though the performance effect isn't nearly as bad, as
the error rate in time seems relatively similar on both, and I think
my scp transmissions are cpu bound on this atom board :).

thanks
-john
