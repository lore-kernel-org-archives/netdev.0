From: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Subject: Re: [PATCH 04/12] phylib: add a way to make PHY time stamps possible.
Date: Tue, 15 Jun 2010 10:33:51 -0600
Message-ID: <AANLkTimhAvu0_WuMCwnCrw9Rbcy6dKxvTlzepJm7ZDdR@mail.gmail.com>
References: <cover.1276615626.git.richard.cochran@omicron.at>
	<27c0ad283f025c2bb71e7ceb71be07f969939429.1276615626.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <27c0ad283f025c2bb71e7ceb71be07f969939429.1276615626.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 15, 2010 at 10:08 AM, Richard Cochran
<richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> This patch adds a new networking option to allow hardware time stamps
> from PHY devices. Using PHY time stamps will still require adding two
> inline function calls to each MAC driver. The CONFIG option makes these
> calls safe to add, since the calls become NOOPs when the option is
> disabled.
>
> Signed-off-by: Richard Cochran <richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
> ---
> =A0include/linux/phy.h =A0 =A0| =A0 =A04 ++++
> =A0include/linux/skbuff.h | =A0 32 ++++++++++++++++++++++++++++++++
> =A0net/Kconfig =A0 =A0 =A0 =A0 =A0 =A0| =A0 11 +++++++++++
> =A03 files changed, 47 insertions(+), 0 deletions(-)
>
[...]
> diff --git a/net/Kconfig b/net/Kconfig
> index 0d68b40..3fa7ae3 100644
> --- a/net/Kconfig
> +++ b/net/Kconfig
> @@ -86,6 +86,17 @@ config NETWORK_SECMARK
> =A0 =A0 =A0 =A0 =A0to nfmark, but designated for security purposes.
> =A0 =A0 =A0 =A0 =A0If you are unsure how to answer this question, answer =
N.
>
> +config NETWORK_PHY_TIMESTAMPING
> + =A0 =A0 =A0 bool "Timestamping in PHY devices"
> + =A0 =A0 =A0 depends on EXPERIMENTAL
> + =A0 =A0 =A0 help
> + =A0 =A0 =A0 =A0 This allows timestamping of network packets by PHYs with
> + =A0 =A0 =A0 =A0 hardware timestamping capabilities. This option adds so=
me
> + =A0 =A0 =A0 =A0 overhead in the transmit and receive paths. Note that t=
his
> + =A0 =A0 =A0 =A0 option also requires support in the MAC driver.

Some overhead?  At a brief glance of the series it looks like it could
add a lot of overhead, but I'm not fully clear on what the full
process is.  Can you describe how the hardware timestamping works?  I
could use an overview of what the kernel has to do.

g.

-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
