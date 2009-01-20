From: ohashi-h@mb.dnes.nec.co.jp
Subject: Re: [PATCH] e1000e: introduce new parameter to
	disableforce-link-up on serdes
Date: Tue, 20 Jan 2009 14:22:01 +0900
Message-ID: <20090120142201ohashi-h@mail.jp.nec.com>
References: <F169D4F5E1F1974DBFAFABF47F60C10A19FC55EE@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"ohashi-h@mb.dnes.nec.co.jp" <ohashi-h@mb.dnes.nec.co.jp>,
	"Ronciak, John" <john.ronciak@intel.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"h-shimamoto@ct.jp.nec.com" <h-shimamoto@ct.jp.nec.com>,
	"jgarzik@pobox.com" <jgarzik@pobox.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-reply-to: <F169D4F5E1F1974DBFAFABF47F60C10A19FC55EE@orsmsx507.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


Brandeburg, Jesse wrote (2009/01/20 04:06:46 +0900 )：
>ohashi-h@mb.dnes.nec.co.jp wrote:
>>>>> Also the Link LED is supposed to indicated that there is a
>>>>> "physical" link, in which case you can have a physical connection
>>>>> and still fail auto-neg.  So I do not necessarily agree with your
>>>>> interpretation of what a link LED is supposed to indicate.
>>>> 
>>>> My explanation was insufficiently.
>>>> My system was NOT connected LAN cable to NIC, but the Link LED
>>>> was indicated.
>>>> So the problem is the LED is indicated without connecting the cable.
>>>> 
>>> 
>>> I tried again using kernel 2.6.27.8 (e1000e driver).
>>> The LED of NIC was indicated, even when the system was not
>>> connected LAN cable.
>>> When I deleted logic of force-link-up (the following modification.),
>>> the LED was turned off.
>>> 
>>> I think it is a problem that LED indicates.
>>> If you have any good way to modify, please let me know.
>>> (Patches are considering.)
>> 
>> I send the patch to modify.
>
>I appreciate your work on this issue but I think you're making the wrong
>solution.  We've done some work on a similar issue, does the attached
>patch fix the issue for you?
>
>inline also, but (probably) whitespace damaged.
>
>
>Author: Jesse Brandeburg <jesse.brandeburg@intel.com>
>Date:   Mon Jan 19 11:04:11 2009 -0800
>
>    e1000e: do not force link on blades
>    
>    e1000 originally had a workaround to force link up based
>    on some hardware errata on ancient parts.  The e1000e driver
>    has carried over this workaround even though it doesn't support
>    the same hardware.
>    
>    letting rx sequence errors drive link up/down events is harming the
>logic of
>    the state machines that control link state on blade connected e1000e
>parts.
>    
>    remove rx sequence errors from causing link events.
>    
>    Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>
>diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
>index 91817d0..55b2f6b 100644
>--- a/drivers/net/e1000e/netdev.c
>+++ b/drivers/net/e1000e/netdev.c
>@@ -1152,7 +1152,7 @@ static irqreturn_t e1000_intr_msi(int irq, void
>*data)
> 	 * read ICR disables interrupts using IAM
> 	 */
> 
>-	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
>+	if (icr & E1000_ICR_LSC) {
> 		hw->mac.get_link_status = 1;
> 		/*
> 		 * ICH8 workaround-- Call gig speed drop workaround on
>cable
>@@ -1218,7 +1218,7 @@ static irqreturn_t e1000_intr(int irq, void *data)
> 	 * IMC write
> 	 */
> 
>-	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
>+	if (icr & E1000_ICR_LSC) {
> 		hw->mac.get_link_status = 1;
> 		/*
> 		 * ICH8 workaround-- Call gig speed drop workaround on
>cable
>

Thank you for your reply.
I tried this patch, but the issue was not solved.

The LED of NIC was indicated still, when the system was not 
linked the network. I think it is affected the
e1000e_check_for_serdes_link() that LED indicates.

Hiroki Ohashi


------------------------------------------------------------------------------
This SF.net email is sponsored by:
SourcForge Community
SourceForge wants to tell your story.
http://p.sf.net/sfu/sf-spreadtheword
