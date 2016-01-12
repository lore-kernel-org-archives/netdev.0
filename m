From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 1/3] ifb: make device count build-time configurable
Date: Tue, 12 Jan 2016 17:04:26 +0100
Message-ID: <5695240A.1020803@iogearbox.net>
References: <1452599804-27284-1-git-send-email-lkundrak@v3.sk>	 <5695199E.2040303@iogearbox.net> <56951D49.5020800@iogearbox.net> <1452613429.18559.69.camel@v3.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Lubomir Rintel <lkundrak@v3.sk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452613429.18559.69.camel@v3.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/12/2016 04:43 PM, Lubomir Rintel wrote:
> On Tue, 2016-01-12 at 16:35 +0100, Daniel Borkmann wrote:
>> On 01/12/2016 04:19 PM, Daniel Borkmann wrote:
>>> On 01/12/2016 12:56 PM, Lubomir Rintel wrote:
> ...
>>>> -static int numifbs = 2;
>>>                 ^^^^^^^^^^^^
>>>> +static int numifbs = CONFIG_IFB_COUNT;
>>>>    module_param(numifbs, int, 0);
>>>>    MODULE_PARM_DESC(numifbs, "Number of ifb devices");
>>
>> Btw, perhaps there should also be a pr_info() or the like to warn the user
>> that relying on modprobe creating these devs is deprecated and scheduled
>> for removal in future, so they should switch to ip link instead ...
>
> I don't know, is it actually is scheduled for removal?
>
> I was under impression that changes in default behavior users can rely
> on are generally near impossible to do since the potential problems
> largely outweigh the benefits. The distributions will do the changes in
> their kernels anyway and changing behavior on kernel upgrades in random
> old systems might be risky.

BLK_DEV_LOOP_MIN_COUNT is 8 by default on upstream today, 0 in Fedora kernels
since Fedora 19 (2013) onwards [1] (F18 to F19 made the switch apparently).

If the same happens one day to these options here and all major distros
play along, then perhaps after still long enough time it might be an option
(and if not, people at least switched to use ip link ;)).

> That said, it's just an impression. I don't follow the development
> closely enough to be sure about anything.

   [1] http://pkgs.fedoraproject.org/cgit/rpms/kernel.git/tree/config-generic?h=f19
