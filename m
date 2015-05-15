From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH net-next 00/11] convert stmmac glue layers into platform
 drivers
Date: Fri, 15 May 2015 10:44:06 +0200
Message-ID: <5463867.jjPLKQomlR@wuerfel>
References: <1431598266-25736-1-git-send-email-manabian@gmail.com>
 <CAGb2v663efjkwgRjPdxV4CQxeesiu7jxkMf9j_oPU_bSHbNNiA@mail.gmail.com>
 <5555A42B.3040205@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Joachim Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 b.galvani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, Roger <roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
 dinguyen-yzvPICuk2ABMcg4IHK0kFoH6Mc4MB0Vx@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <5555A42B.3040205-qxv4g6HH51o@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 15 May 2015 09:45:47 Giuseppe CAVALLARO wrote:
> Hello
> 
> On 5/14/2015 5:24 PM, Chen-Yu Tsai wrote:
> > On Thu, May 14, 2015 at 6:10 PM, Joachim Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> >> This patch set aims to convert the current dwmac glue layers into
> >> proper platform drivers as request by Arnd[1]. These changes start
> >> from patch 3 and onwards.
> >>
> >> Overview:
> >> Platform driver functions like probe and remove are exported from
> >> the stmmac platform and then used in subsequent glue later
> >> conversions. The conversion involes adding the platform driver
> >> boiler plate code and adding it to the build system. The last patch
> >> removes the driver from the stmmac platform code thus making it into
> >> a library for common platform driver functions.
> >>
> >> The two first patches adds glue layer for my platform. I chose to
> >> first add old style glue layer and then convert it. The churn this
> >> creates is just 3 lines.
> >>
> >> I would be very nice if people could test this patch set on their
> >> respective platform. My testing has been limited to compiling and
> >> testing on my (LPC18xx) platform. Thanks!
> 
> I wonder if this will make the compatibility with old
> platforms (like SH4) not based on DT, where there was not used
> any glue-logic around the driver and just the platform was the
> reference.

With patch 11, this gets handled by the dwmac-generic driver.

> To be honest, I prefer to not have the Kconfig options.
> The device-tree compatibility will select the glue-logic
> needed and we will just pay some bytes when compile.
>
> In my opinion, the Koption(s) introduce a problem when touch
> the driver and we want to guarantee that, at least,
> all its parts build fine on all the platforms.

The current model is not scalable and requires modifying the base
driver for each variation, and the change brings the driver
in line with how we do things for other platform drivers.

We should always be able to build all soc-specific glue drivers
with 'allmodconfig' for build testing, and a lot of us run that
frequently to find regressions.

	Arnd
