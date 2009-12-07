From: Michal Marek <mmarek@suse.cz>
Subject: Re: linux-next: net/kbuild trees build failure
Date: Mon, 07 Dec 2009 22:42:09 +0100
Message-ID: <4B1D76B1.6070601@suse.cz>
References: <20091207200317.57820f0a.sfr@canb.auug.org.au>	 <20091207114158.GA2428@merkur.ravnborg.org> <4B1CF39A.5050806@suse.cz>	 <20091207160903.GB18939@tuxdriver.com> <1260209537.4653.778.camel@rc-desk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Sam Ravnborg <sam@ravnborg.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: reinette chatre <reinette.chatre@intel.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1260209537.4653.778.camel@rc-desk>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

reinette chatre napsal(a):
> Hi John,
> 
> On Mon, 2009-12-07 at 08:09 -0800, John W. Linville wrote:
>> On Mon, Dec 07, 2009 at 01:22:50PM +0100, Michal Marek wrote:
>>> On 7.12.2009 12:41, Sam Ravnborg wrote:
>>>> On Mon, Dec 07, 2009 at 08:03:17PM +1100, Stephen Rothwell wrote:
>>>>> Hi Dave,
>>>>>
>>>>> Today's linux-next build (powerpc allyesconfig) failed like this:
>>>>>
>>>>> In file included from drivers/net/wireless/iwlwifi/iwl3945-base.c:57:
>>>>> drivers/net/wireless/iwlwifi/iwl-core.h:66:30: error: linux/utsrelease.h: No such file or directory
>>>>>
>>>>> Caused by commit 250cce26d5d03337aec4ff8405121f026adb4a89 ("iwlwifi:
>>>>> driver version track kernel version") from the net tree interacting with
>>>>> commit 8e5c76aace9705b6983cfbf5eb2f2e869dab6738 ("kbuild: move
>>>>> utsrelease.h to include/generated") from the kbuild tree.
>>>>>
>>>>> I applied this patch for today (and will carry it as necessary):
>>>> The right fix would be to use 'utsname()->sysname' (I think sysname
>>>> is the right member).
>>> ->release would be the right one. One could also question why iwlwifi
>>> needs to repeat the kernel version it was built / is running against,
>>> but I that's not the point here :). Dave, John, can we agree that
>>> whichever tree gets merged first, the other tree applies the one-liner?
>> Hmmm...well, the suggested fixes are fine for the printk (i.e. runtime)
>> usage.  But (other than Stephen's) they don't seem to help with the
>> MODULE_VERSION (i.e. compile time) usage.  Is there an approved
>> solution for that?
> 
> Right - could we please use the solution that works at compile time? I
> used UTS_RELEASE after learning about its use in init/version.c, would
> that not make it an approved solution?

It seems there is some misunderstanding.
The original problem reported by Stephen was that linux/utsrelease.h was
moved to generated/utsrelease.h in the kbuild tree (that commit also
patched init/version.c and all other users known at that time). This
change in kbuild broke the new iwlwifi in the net tree. Stephen attached
the most obvious fix, i.e. change linux/utsrelease.h to
generated/utsrelease.h in the iwlwifi source
(http://lkml.org/lkml/2009/12/7/121). My suggestion was to let Stephen
carry the fix in linux-next for now, and once one of the trees (kbuild
or net) hits mainline, the other tree would apply Stephen's patch. Would
that work for everyone?

Now if someone wants to remove the DRV_VERSION macro from iwlwifi or rip
the UTS_RELEASE part out of it, that would make this problem go away,
but I don't think it's necessary _just_ because of the kbuild change.

Michal
