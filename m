From: Jeff Garzik <jeff@garzik.org>
Subject: Re: 2.6.23-rc4-mm1: e1000e napi lockup
Date: Fri, 07 Sep 2007 19:49:37 -0400
Message-ID: <46E1E391.7090907@garzik.org>
References: <46E0FB82.2040000@gmail.com>
	<20070907.010338.41638771.davem@davemloft.net>
	<46E17B41.4060200@intel.com> <46E1DF6E.6050801@garzik.org>
	<46E1E15E.7080406@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org, David Miller <davem@davemloft.net>,
	jirislaby@gmail.com
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <46E1E15E.7080406@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Jeff Garzik wrote:
>> Kok, Auke wrote:
>>> David Miller wrote:
>>>> From: Jiri Slaby <jirislaby@gmail.com>
>>>> Date: Fri, 07 Sep 2007 09:19:30 +0200
>>>>
>>>>> I found a regression in 2.6.23-rc4-mm1 (since -rc3-mm1) in e1000e 
>>>>> driver.
>>>>> napi_disable(&adapter->napi) in e1000_probe freezes the kernel on 
>>>>> boot.
>>>> Yes, the semantics changed slightly in the net-2.6.24 tree the
>>>> other week and someone needs to fix it up.
>>>>
>>>> The netif_napi_add() implicitly does a napi_disable() call.  Device
>>>> open must explicitly napi_enable() and device close must explicitly
>>>> napi_disable(), and if done elsewhere these calls must be strictly
>>>> balanced.
>>> I'll fix it... it's my patch that adds the new napi code to it and I 
>>> need to get it ready for the merge window anyway.
>>
>> well....  since its close to the merge window opening, we could see 
>> what happens if DaveM pulls branch 'upstream' of 
>> git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git
>>
>> That should make this class of pre-merge-window annoyance go away.
> 
> If I do that now I get a big merge conflict:

oh you are _guaranteed_ conflicts.  most of that is NAPI-area code that 
got changed by both.



-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
