From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: linux-next: merge of the wireless-next tree into the net-next
 tree
Date: Wed, 4 Jan 2012 10:02:33 +0200
Message-ID: <4F040799.7080604@qca.qualcomm.com>
References: <20120104105947.8bac77d1d7198a49e6feeca8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120104105947.8bac77d1d7198a49e6feeca8@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 01/04/2012 01:59 AM, Stephen Rothwell wrote:

> I noticed that the wireless-next tree has been merged into the net-next
> tree today.  Has anything been done about the build failure I reported in
> the wireless-next a while ago:
> 
> On 12/22/2011 16:58 +1100, Stephen Rothwell wrote:
>>
>> After merging the final tree, today's linux-next build (powerpc
>> allyesconfig) failed like this:
>>
>> drivers/net/wireless/ath/ath6kl/cfg80211.c:27:1: error: expected ')' before 'KBUILD_MODNAME'
>> drivers/net/wireless/ath/ath6kl/cfg80211.c:27:1: error: 'KBUILD_MODNAME' undeclared here (not in a function)
>> drivers/net/wireless/ath/ath6kl/cfg80211.c:27:1: error: expected ',' or ';' before string constant
>> drivers/net/wireless/ath/ath6kl/init.c:32:1: error: expected ')' before 'KBUILD_MODNAME'
>> drivers/net/wireless/ath/ath6kl/init.c:32:1: error: 'KBUILD_MODNAME' undeclared here (not in a function)
>> drivers/net/wireless/ath/ath6kl/init.c:32:1: error: expected ',' or ';' before string constant
>> drivers/net/wireless/ath/ath6kl/init.c:33:1: error: expected ')' before 'KBUILD_MODNAME'
>> drivers/net/wireless/ath/ath6kl/init.c:33:1: error: invalid initializer
>> drivers/net/wireless/ath/ath6kl/init.c:33:1: error: expected ',' or ';' before string constant
>> drivers/net/wireless/ath/ath6kl/init.c:34:1: error: expected ')' before 'KBUILD_MODNAME'
>> drivers/net/wireless/ath/ath6kl/init.c:34:1: error: invalid initializer
>> drivers/net/wireless/ath/ath6kl/init.c:34:1: error: expected ',' or ';' before string constant
>>
>> I can't figure out what goes wrong here.  On the compile command line,
>> KBUILD_MODNAME is not defined, but KBUILD_BASE_NAME is.
>>
>> However, reverting commit fde57764ef87 ("ath6kl: enable USB support")
>> made the problem go away.  That commit caused the above two files to be
>> built into two separate modules.
> 
> 
> There was some discussion, but I did not notice any fix (I may have
> missed it).  I have been reverting that above commit ...

I started working on adding ath6kl_core.ko module which would fix this,
but unfortunately I got distracted with other things and the patches are
not ready yet. For a temporary solution I'll send a patch which forces
ath6kl to build only as a module and I'll send ath6kl_core.ko patches
ASAP after that.

Kalle
