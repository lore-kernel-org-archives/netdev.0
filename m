From: slavon@bigtelecom.ru
Subject: Re: Tc bug (kernel crash) more info
Date: Sat, 01 Sep 2007 14:36:38 +0400
Message-ID: <20070901143638.tv2cazm0v4k0g0kc@mail.himki.net>
References: <20070830072718.GC1677@ff.dom.local>
	<46D68937.7030305@bigtelecom.ru> <20070830123751.GA2778@ff.dom.local>
	<46D7BD75.3080008@bigtelecom.ru> <20070831075909.GA1772@ff.dom.local>
	<46D7D072.5060508@bigtelecom.ru> <20070831090509.GC1772@ff.dom.local>
	<46D7E050.1030303@bigtelecom.ru> <20070831101733.GA3108@ff.dom.local>
	<46D7F1FF.1000101@bigtelecom.ru> <20070831125917.GC3108@ff.dom.local>
	<46D8265B.6000405@bigtelecom.ru> <46D82AEC.5010404@bigtelecom.ru>
	<20070831215850.zf2xi256o00owk4s@mail.himki.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=UTF-8;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:54403 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752735AbXIAKgl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 06:36:41 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 9A4FFA6C229
	for <netdev@vger.kernel.org>; Sat,  1 Sep 2007 14:36:39 +0400 (MSD)
Received: from mail.bigtelecom.ru ([127.0.0.1])
	by localhost (mail.bigtelecom.ru [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 7Fg2LtJfimeo for <netdev@vger.kernel.org>;
	Sat,  1 Sep 2007 14:36:38 +0400 (MSD)
In-Reply-To: <20070831215850.zf2xi256o00owk4s@mail.himki.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Hi All!
> I found another bugs in HTB
>
> 1. HTB Wrong calculate LEVELS.
> - try run "./create_nodes.sh" in archive and do "tc -d class show dev eth0"

Hm.. i read
http://luxik.cdi.cz/~devik/qos/htb/manual/theory.htm
I understand that if Level calculation broken - HTB wrong work! I try  
to see sch_htb.c but i not see simple fix to this. Maybe anyone with  
expirince try to look sch_htb.c?

>
> 2. HTB miss qdisc what i add. (it's not added)
> - try run ./create_nodes.sh; sh tc_rules_last2 2>/dev/null
> - I add my output of "tc -d class show dev eth0" for you look
> (tc_class.txt in archive)

Not correct info.
"tc -d class show dev eth0 | grep -v leaf" ask many rules without  
leaf, but QDISC for this casses is created. How filter add packer to  
filter where not have LEAF?

I think HTB not property work.
Thanks.

Badalian Vyacheslav

>
> Anyone! I want test any patches to fix all HTB problems!
>
> Thanks
>
>
>> I found that bug in this place
>>
>> (gdb) l *0xc01c8973
>> 0xc01c8973 is in rb_insert_color (lib/rbtree.c:80).
>> 75
>> 76              while ((parent = rb_parent(node)) && rb_is_red(parent))
>> 77              {
>> 78                      gparent = rb_parent(parent);
>> 79
>> 80                      if (parent == gparent->rb_left)
>> 81                      {
>> 82                              {
>> 83                                      register struct rb_node *uncle
>> = gparent->rb_right;
>> 84                                      if (uncle && rb_is_red(uncle))
>>
>>
>> if i not wrong understand message "unable to handle kernel NULL pointer
>> dereference at virtual address 00000008" its was known that "gparent ==
>> Null"?
>> Or i hope or i try find a mare's-nest?
>>
>>> Ok =) I hope in next week you found bug place and fix it!
>>>
>>> PS. if you ask where i can read "kernel panic dump logic"     
>>> literature and try find bugline in code.
>>> I read dump and see that bug in function "rb_insert_color" + some   
>>>   shift (in asm?) that called from htb_dequeue? But in htb_dequeue  
>>>    not have calling rb_insert_color =( Or some nodes in trace was   
>>>   skipped?
>>>
>>> Its for change up my education ;)
>>>> I'll not be able to assist you until monday (but I'll try to look
>>>> into the code and maybe to prepare some new patch - but it needs
>>>> a lot of checking to not add too much of this locking as well).
>>>>
>>>> I think you can stay with a kernel whichever you like - I'm not sure
>>>> any config changes or even more debugging can change much, but maybe
>>>> I'm wrong. It looks to me like some locking is missing or interrupted.
>>>> If you are working weekends and find something new, don't wait: maybe
>>>> somebody else here could be interested too.
>>>> Cheers,
>>>> Jarek P.
>>>>
>>>
>>> -
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
>> -
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>
> ----------------------------------------------------------------
> This message was sent using IMP, the Internet Messaging Program.



----------------------------------------------------------------
This message was sent using IMP, the Internet Messaging Program.

