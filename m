From: "Alexander Beregalov" <a.beregalov@gmail.com>
Subject: Re: [PATCH] simnet: convert to net_device_ops
Date: Wed, 10 Dec 2008 14:21:46 +0300
Message-ID: <a4423d670812100321qc93060evd0d3ae3f78418b29@mail.gmail.com>
References: <a4423d670812090611v715309adq3e9d2d95254e2e16@mail.gmail.com>
	 <20081209150827.GA8134@x200.localdomain>
	 <20081209.225728.07389385.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_85304_9826830.1228908106524"
Cc: adobriyan@gmail.com, linux-next@vger.kernel.org,
	netdev@vger.kernel.org, linux-ia64@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-ia64-owner@vger.kernel.org>
In-Reply-To: <20081209.225728.07389385.davem@davemloft.net>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_85304_9826830.1228908106524
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2008/12/10 David Miller <davem@davemloft.net>:
> From: Alexey Dobriyan <adobriyan@gmail.com>
> Date: Tue, 9 Dec 2008 18:08:27 +0300
>
>> On Tue, Dec 09, 2008 at 05:11:17PM +0300, Alexander Beregalov wrote:
>> >   CC      arch/ia64/hp/sim/simeth.o
>> > arch/ia64/hp/sim/simeth.c: In function 'simeth_probe1':
>> > arch/ia64/hp/sim/simeth.c:212: error: 'struct net_device' has no member named 'open'
>>
>> [PATCH] simeth: convert to net_device_ops
>>
>> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
>
> This doesn't explain the build failure.
>
> Using ->open() and friends should work perfectly fine for drivers not
> yet converted to netdev_ops.  The code protected by COMPAT_NET_DEV_OPS
> provides this, and we force that Kconfig option to always be on.
>
> I don't want to add this patch and just shrug off this build failure.
> If this build failures, we should be seeing 200 other drivers not
> build too.
>
> I suspect something is messed up with this person's kernel config
> or similar.
>

Thanks for explanation.
Is it better?


 arch/ia64/hp/sim/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/hp/sim/Kconfig b/arch/ia64/hp/sim/Kconfig
index f92306b..8d513a8 100644
--- a/arch/ia64/hp/sim/Kconfig
+++ b/arch/ia64/hp/sim/Kconfig
@@ -4,6 +4,7 @@ menu "HP Simulator drivers"

 config HP_SIMETH
        bool "Simulated Ethernet "
+       depends on NET

 config HP_SIMSERIAL
        bool "Simulated serial driver support"

------=_Part_85304_9826830.1228908106524
Content-Type: text/x-patch; name=hp-sim-kconfig.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fojw4ig10
Content-Disposition: attachment; filename=hp-sim-kconfig.patch

IGFyY2gvaWE2NC9ocC9zaW0vS2NvbmZpZyB8ICAgIDEgKwogMSBmaWxlcyBjaGFuZ2VkLCAxIGlu
c2VydGlvbnMoKyksIDAgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvYXJjaC9pYTY0L2hwL3Np
bS9LY29uZmlnIGIvYXJjaC9pYTY0L2hwL3NpbS9LY29uZmlnCmluZGV4IGY5MjMwNmIuLjhkNTEz
YTggMTAwNjQ0Ci0tLSBhL2FyY2gvaWE2NC9ocC9zaW0vS2NvbmZpZworKysgYi9hcmNoL2lhNjQv
aHAvc2ltL0tjb25maWcKQEAgLTQsNiArNCw3IEBAIG1lbnUgIkhQIFNpbXVsYXRvciBkcml2ZXJz
IgogCiBjb25maWcgSFBfU0lNRVRICiAJYm9vbCAiU2ltdWxhdGVkIEV0aGVybmV0ICIKKwlkZXBl
bmRzIG9uIE5FVAogCiBjb25maWcgSFBfU0lNU0VSSUFMCiAJYm9vbCAiU2ltdWxhdGVkIHNlcmlh
bCBkcml2ZXIgc3VwcG9ydCIK
------=_Part_85304_9826830.1228908106524--
