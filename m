From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v3 net-next 3/4] ixgbe: Add support for
	ndo_ll_poll
Date: Tue, 21 May 2013 11:31:10 +0300
Message-ID: <519B30CE.9020704@linux.intel.com>
References: <CAJZOPZJx8vpSWqOhmN65gn=vi7hWXQO_J01+hAwGY9RwetX3DA@mail.gmail.com>
	<519B1A2B.4010909@linux.intel.com>
	<1369120003.25971.2.camel@lb-tlvb-eilong.il.broadcom.com>
	<20130521.001444.1361294042663568537.davem@davemloft.net>
	<CAJZOPZJTA9A8T4R8MtRCeqcYj3XJWFCXF+ojmEqza5TMj-6G+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, hpa@zytor.com,
	jesse.brandeburg@intel.com, eliezer@tamir.org.il,
	linux-kernel@vger.kernel.org, andi@firstfloor.org,
	eilong@broadcom.com, David Miller <davem@davemloft.net>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <CAJZOPZJTA9A8T4R8MtRCeqcYj3XJWFCXF+ojmEqza5TMj-6G+w@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 21/05/2013 11:24, Or Gerlitz wrote:
> On Tue, May 21, 2013 at 10:14 AM, David Miller <davem@davemloft.net> wrote:
>> From: "Eilon Greenstein" <eilong@broadcom.com>
>> Date: Tue, 21 May 2013 10:06:43 +0300
>>
>>> Hopefully this series will be accepted so we can send follow up support
>>> for the bnx2x as well.
>>
>> I think in two or three more iterations it will be merged.
>>
>> There are no objections on the fundamentals, it's just implementation
>> details and coding style at this point.
>
> Dave, sorry, I might be a bit behind the rest of the reviewers, but I
> just fail to understand nor find any reference that explains the
> module param of ixgbe nor it makes sense to me to merge that piece of
> the code upstream (its not for staging, correct?), as I wrote here
> http://marc.info/?l=linux-netdev&m=136908123432072&w=2 basically, I
> know you're not a great fun of module params (to say the least) and
> surely not something named  "allow_unsafe_removal", thoughts?

from v2 0/4

6. To avoid the overhead of reference counting napi structs by skbs
and sockets in the fastpath, and increasing the size of the skb struct,
we no longer allow unloading the module once this feature has been used.

It seems that for most of the people interested in busy-polling, giving
up the ability to blindly remove the module for a slight but measurable
performance gain is a good tradeoff.
(There is a module parameter to override this behavior and if you know
what you are doing and are careful to stop the processes you can safely
unload, but we don't enforce this.)


------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_may
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
