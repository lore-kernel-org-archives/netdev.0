From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: Tc bug (kernel crash) more info
Date: Fri, 31 Aug 2007 18:51:24 +0400
Message-ID: <46D82AEC.5010404@bigtelecom.ru>
References: <20070830072718.GC1677@ff.dom.local> <46D68937.7030305@bigtelecom.ru> <20070830123751.GA2778@ff.dom.local> <46D7BD75.3080008@bigtelecom.ru> <20070831075909.GA1772@ff.dom.local> <46D7D072.5060508@bigtelecom.ru> <20070831090509.GC1772@ff.dom.local> <46D7E050.1030303@bigtelecom.ru> <20070831101733.GA3108@ff.dom.local> <46D7F1FF.1000101@bigtelecom.ru> <20070831125917.GC3108@ff.dom.local> <46D8265B.6000405@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:43159 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755267AbXHaOvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 10:51:31 -0400
In-Reply-To: <46D8265B.6000405@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I found that bug in this place

(gdb) l *0xc01c8973
0xc01c8973 is in rb_insert_color (lib/rbtree.c:80).
75
76              while ((parent = rb_parent(node)) && rb_is_red(parent))
77              {
78                      gparent = rb_parent(parent);
79
80                      if (parent == gparent->rb_left)
81                      {
82                              {
83                                      register struct rb_node *uncle = 
gparent->rb_right;
84                                      if (uncle && rb_is_red(uncle))


if i not wrong understand message "unable to handle kernel NULL pointer 
dereference at virtual address 00000008" its was known that "gparent == 
Null"?
Or i hope or i try find a mare's-nest?

> Ok =) I hope in next week you found bug place and fix it!
>
> PS. if you ask where i can read "kernel panic dump logic" literature 
> and try find bugline in code.
> I read dump and see that bug in function "rb_insert_color" + some 
> shift (in asm?) that called from htb_dequeue? But in htb_dequeue not 
> have calling rb_insert_color =( Or some nodes in trace was skipped?
>
> Its for change up my education ;)
>> I'll not be able to assist you until monday (but I'll try to look
>> into the code and maybe to prepare some new patch - but it needs
>> a lot of checking to not add too much of this locking as well).
>>
>> I think you can stay with a kernel whichever you like - I'm not sure
>> any config changes or even more debugging can change much, but maybe
>> I'm wrong. It looks to me like some locking is missing or interrupted.
>> If you are working weekends and find something new, don't wait: maybe
>> somebody else here could be interested too.
>>  
>> Cheers,
>> Jarek P.
>>   
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

