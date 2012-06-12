From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [RFC] net/sched/em_canid: Ematch rule to match CAN frames according
 to their CAN IDs
Date: Tue, 12 Jun 2012 17:42:01 +0200
Message-ID: <4FD76349.6040407@hartkopp.net>
References: <1339508913-7784-1-git-send-email-lisovy@gmail.com>  <1339509809.22704.149.camel@edumazet-glaptop>  <1339511593.22704.157.camel@edumazet-glaptop> <1339512622.8536.3.camel@lolumad>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	lartc@vger.kernel.org, pisa@cmp.felk.cvut.cz, sojkam1@fel.cvut.cz
To: Rostislav Lisovy <lisovy@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:29060 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753417Ab2FLPm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 11:42:27 -0400
In-Reply-To: <1339512622.8536.3.camel@lolumad>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello Rostislav, hello Eric,

On 12.06.2012 16:50, Rostislav Lisovy wrote:

> On Tue, 2012-06-12 at 16:33 +0200, Eric Dumazet wrote: 
>> On Tue, 2012-06-12 at 16:03 +0200, Eric Dumazet wrote:
>>> On Tue, 2012-06-12 at 15:48 +0200, Rostislav Lisovy wrote:
>>>> em_canid is an ematch capable of classifying CAN frames according to
>>>> their CAN IDs.
>>>>
>>>> This RFC/Patch contains a reworked classifier initially posted in
>>>> http://www.spinics.net/lists/netdev/msg200114.html
>>>> The functionality is the same however there is almost 50% reduction
>>>> in the source code length.
>>>>
>>>> There is a slight difference between this ematch and other available
>>>> ematches. Other ematches implement only a simple match operation and
>>>> are meant to be combined with logic conjunctions (e.g. AND, OR).
>>>> Our ematch makes it possible to use up to 32 rules in single
>>>> 'configuration statement' (with OR semantics). This allows us to take
>>>> the advantage of the bit field data-structure in the implementation of
>>>> the match function.
>>>>
>>>> Example: canid(sff 0x123 eff 0x124 sff 0x230:0x7f0)
>>>> This ematch would match CAN SFF frames with the following IDs:
>>>> 0x123, 0x230--0x23f or EFF frame with ID 0x124.



i tried to figure out the difference between the implementation as classifier
(link above) and this implementation as an ematch.

Do we have any disadvantages using the ematch? E.g. is it still possible to
add additional ematches like checking for patterns inside can_frame.data[]
(which is located in skb->data) with ematch_u32 or e.g. ematch_text ??


...

Btw.

>>>> +struct canid_match {
>>>> +	struct can_filter rules_raw[EM_CAN_RULES_SIZE]; /* Raw rules copied
>>>> +		from netlink message; Used for sending information to
>>>> +		userspace (when 'tc filter show' is invoked) AND when
>>>> +		matching EFF frames*/
>>>> +	DECLARE_BITMAP(match_sff, (1 << CAN_SFF_ID_BITS)); /* For each SFF CAN
>>>> +		ID (11 bit) there is one record in this	bitfield */


these comments have a styling problem :-)

Additional to these checkpatch warnings:

WARNING: line over 80 characters
#144: FILE: net/sched/em_canid.c:48:
+static void em_canid_sff_match_add(struct canid_match *cm, u32 can_id, u32 can_mask)

WARNING: line over 80 characters
#231: FILE: net/sched/em_canid.c:135:
+	if (cm->rules_count > EM_CAN_RULES_SIZE) /* Be sure to fit into the array */

WARNING: line over 80 characters
#256: FILE: net/sched/em_canid.c:160:
+			memcpy(cm->rules_raw + cm->eff_rules_count + cm->sff_rules_count,



Tnx & regards,
Oliver
