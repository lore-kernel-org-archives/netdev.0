From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Tue, 06 Nov 2007 01:02:49 +0100
Message-ID: <472FAF29.7050704@o2.pl>
References: <1193939701.2987.82.camel@localhost.localdomain>	 <472B5EF1.4020206@o2.pl> <1194045830.4438.21.camel@localhost>	 <472D06B2.9040402@o2.pl> <472D0B1C.7000209@o2.pl> <472D128B.8030704@o2.pl>	 <472D1DC2.9000106@o2.pl> <1194220693.4438.75.camel@localhost>	 <20071105091231.GA1933@ff.dom.local>	 <1194267561.2987.141.camel@localhost.localdomain>	 <20071105135246.GB1933@ff.dom.local> <1194271589.4438.113.camel@localhost>	 <1194283888.2987.186.camel@localhost.localdomain>  <472F85F0.8060205@o2.pl> <1194301667.4430.28.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Radu Rendec <radu.rendec@ines.ro>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:40891 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754219AbXKEXu3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2007 18:50:29 -0500
In-Reply-To: <1194301667.4430.28.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote, On 11/05/2007 11:27 PM:

> On Mon, 2007-05-11 at 22:06 +0100, Jarek Poplawski wrote:
>> Radu Rendec wrote, On 11/05/2007 06:31 PM:
> 
>>> But still, Jamal, I need more explanations on what you meant by "cutdown
>>> on the conversion in u32_change()". 
> 
> I meant that it didnt seem necessary to me you have to do the conversion
> back and forth of the hmask as you do in the u32_change(). The basis of
> the patch i posted - which is based on yours - is to remove that change.
> If that doesnt work, please just send your patch as is and we can think
> of optimization later.
> 

>>> And, before proceeding, I'd like to

>>> see your reply to Jarek's last email (at 15:49 +0100) about not getting
>>> 0xff in the end.
> 
> On paper i get the same result with the new or old scheme for the bucket selection.
> As i stated on the patch - i never did test the theory.
> 


In Radu's patch all calculations are done with data in host order, and
still only this one transformation on the fast path. In your version orders
are mixed, and this makes a difference. And, since the old scheme gives
wrong result on little endian, I don't get it why you would want it again?
So, with your patch with the same address and mask: 00.00.0f.f0 (host order
on little endian) we have:

on big endian (net and host order):
f0.0f.00.00 >> 4  gives: ff.00.00.00 with lsb: ff
on little endian (net order):
f0.0f.00.00 >> 4  gives: 0f.00.0f.00 then ntohl: 00.0f.00.0f with lsb: 0f
on little endian with Radu's patch (host order):
00.00.0f.f0 >> 4  gives: 00.00.00.ff with lsb: ff


>> Radu, as far as I know Jamal (from reading) he most probably is busy with
>> some conference! 
> 
> I actually have a day job and have to show up and meet TheMan, Jarek;->
> Most of the days at work, i dont have time to look at external email
> account - but you can bet all horses you own i will get back to you
> within a few hours if you CC me on email.


No offence! I've thought Radu gets a bit impatient, and don't know if he
knows about your scientific and international achievements. On the other
hand I can't imagine why anybody would ever like to go out of Canada!
(Btw, in Polish the second meaning of Kanada is something like paradise
or extreme welfare.) And, on the other hand, I'm very honoured, but I'm
a really modest guy, far from this universities' high life here...

> 
>> Since these patches aren't so big I think you could
>> try Jamal's at first, and if it doesn't work, and nothing new from Jamal
>> in the meantime, resend your version. Cutdown in u32_change() seems to
>> add more to the fastpath, but maybe Jamal thinks about something else.
> 
> I mean do most work on slow/config path.
> 


We have hshift & hamask from there.

Cheers,
Jarek P.
