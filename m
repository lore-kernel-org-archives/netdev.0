From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next 2/2] bnxt_en: define sriov_lock unconditionally
Date: Tue, 25 Jul 2017 09:36:23 -0700
Message-ID: <CACKFLimnZx7v9jV7v27XMP62BWG577D8=zkTijQYa6Pi1Ct7yA@mail.gmail.com>
References: <20170725153046.44726-1-arnd@arndb.de> <20170725153046.44726-2-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Sathya Perla <sathya.perla@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Deepak Khungar <deepak.khungar@broadcom.com>,
        Netdev <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170725153046.44726-2-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 25, 2017 at 8:29 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> The sriov_lock is used to serialize the sriov code with the vfr code.
> However, when SRIOV is disabled, the lock is not there at all, leading
> to a build error:
>
> drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c: In function 'bnxt_dl_eswitch_mode_set':
> drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c:410:16: error: 'struct bnxt' has no member named 'sriov_lock'
>
> We can either provide the mutex in this configuration, too, or
> disable both SRIOV and VFR together. This implements the first
> approach, since it seems like a reasonable configuration for
> guest kernels to have, and the extra lock will be harmless when
> there is no contention.
>
> Fixes: 4ab0c6a8ffd7 ("bnxt_en: add support to enable VF-representors")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Sathya already sent 3 patches to fix some of these issues.  But I need
to rework one of his patch and resend.

Thanks.
