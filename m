From: Mike Galbraith <umgwanakikbuti@gmail.com>
Subject: Re: [PATCH] rtlwifi: Add more checks for get_btc_status callback
Date: Wed, 05 Nov 2014 10:16:15 +0100
Message-ID: <1415178975.5402.66.camel@marge.simpson.net>
References: <1414625302-3654-1-git-send-email-mopsfelder@gmail.com>
	 <5451BED0.2060906@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Murilo Opsfelder Araujo <mopsfelder@gmail.com>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	Thadeu Cascardo <cascardo@cascardo.eti.br>,
	troy_tan@realsil.com.cn
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5451BED0.2060906@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-10-29 at 23:30 -0500, Larry Finger wrote: 
> On 10/29/2014 06:28 PM, Murilo Opsfelder Araujo wrote:
> > This is a complement of commit 08054200117a95afc14c3d2ed3a38bf4e345bf78
> > "rtlwifi: Add check for get_btc_status callback".
> >
> > With this patch, next-20141029 at least does not panic with rtl8192se
> > device.
> >
> 
> This patch is OK, but as noted it is not complete.
> 
> I have patches to fix all the kernel panics for rtl8192se AND rtl8192ce. There 
> are missing parts, but I would prefer submitting mine, which would conflict with 
> this one. For that reason, NACK for this one, and please apply the set I am 
> submitting now.

It's all in there now, but my RTL8191SEvB is still dead.  Squabbling
with it isn't going all that well either.

As soon as 38506ece rtlwifi: rtl_pci: Start modification for new drivers
is applied, explosions appear.  Subsequently applying...

08054200 rtlwifi: Add check for get_btc_status callback
c0386f15 rtlwifi: rtl8192ce: rtl8192de: rtl8192se: Fix handling for missing get_btc_status
50147969 rtlwifi: rtl8192se: Fix duplicate calls to ieee80211_register_hw()
30c5ccc6 rtlwifi: rtl8192se: Add missing section to read descriptor setting
75a916e1 rtlwifi: rtl8192se: Fix firmware loading

...fixes that mess up, but leaves the interface dead in the same manner
as if nothing has been reverted.  So it _seems_ the bustage lurks in
38506ece somewhere.  Too bad it's non-dinky, and written in wifi-ese :)

-Mike

Full revert series: 
patches/revert-75a916e1944fea8347d2245c62567187e4eff9dd
patches/revert-8ae3c16e41b02db8ffe4121468519d6352baedc1
patches/revert-30c5ccc6afee39754cff75ad8d775ad39a2ce989
patches/revert-501479699ff484ba8acc1d07022271f00cfc55a3
patches/revert-c0386f1584127442d0f2aea41bc948056d6b1337
patches/revert-08054200117a95afc14c3d2ed3a38bf4e345bf78
patches/revert-4f2b244c7d5b81ce4f0c6c0382f3a3b7c2dbec1c
patches/revert-cefe3dfdb9f5f498cae9871f7e52800f5e22c614
patches/revert-b2d624a5810203a1a8b7735e1ec5685109b22fc3
patches/revert-d514aefb8ce89562ef2d7dcddc530e5de6287c4b
patches/revert-598a0df07fc6c4642f9b0497cef1233e41d4c987
patches/revert-47481d977cb2987ab363202c68a79ec1bccd357c
patches/revert-1fca350b761631d182c2e8bce530896e66404bc2
patches/revert-3f08e47291879fb047d7d4464d2beaedfea4eb63
patches/revert-989377e1cc9e713822d148d2e638d6c63d8a94b1
patches/revert-574a7930d7c4d0fe4295868e52a5277bd9595b5e
patches/revert-ef09396ef622572c604d4977e76f6151ef68ed21
patches/revert-557f933113a42a48ec617b81b5ea53fd7202b1ed
patches/revert-9f087a924427c01190b205f0051be00808c99828
patches/revert-5c99f04fec93068147a3e95b439b345f203ac5b9
patches/revert-0529c6b8176135bcae1ab66bed6c1288456fbdec
patches/revert-b1a3bfc97cd95681c511515534b84843998f3ea0
patches/revert-7fe3b3abb5da3a105d87640db693c41259138294
patches/revert-34ed780a6afc4df5e3285d20fac721c591e0724e
patches/revert-21e4b0726dc671c423e2dc9a85364716219c4502
patches/revert-c151aed6aa146e9587590051aba9da68b9370f9b
patches/revert-f3a97e93814aeac3f13e857a0071726acc9bd626
patches/revert-d3feae41a3473a0f7b431d6af4e092865d586e52
patches/revert-3c67b8f9f3b5bb1207c9bb198e5ef04ff56921dd
patches/revert-9afa2e44f4d8f9d031f815c32bb8f225f0f6746b
patches/revert-f7953b2ad66cc5fc66e13d5c0a40e61b45cdfca8
patches/revert-38506ecefab911785d5e1aa5889f6eeb462e0954
patches/revert-fd09ff958777cf583d7541f180991c0fc50bd2f7
patches/revert-560e334dbd9907ecdd25318fbdb33179c5d5a3bd
patches/revert-5eef40e5687da4ad0123e231e4fe952a12655f0b
patches/revert-6b5447ce630cdc231caf4f958325f8fa925216bf
patches/revert-dbb30ebeefaf01121b32ae6b5baf29524f3a0b30
patches/revert-4f4378dead3792d21577739f07869fbd843dab23
patches/revert-ed364abffd6e19bec67b7ccda8237213b8b37640
patches/revert-c96fd200e9af8ad4c4891ef579044a75c659d8c7
patches/revert-2ec7f01c35727574953dbd884d7d45da940a25ee
patches/revert-f5b5869095819970333dc9de54eed5c552407d35
patches/revert-2187e9a2ce575ee85a1ce31fa2ecbc0f580c105f
patches/revert-e8f3fef412d4ffd8cb1bd5cd7a6e5572e21bf80a
patches/revert-e79fff28587c9437282c863722d1fa186143f62a
