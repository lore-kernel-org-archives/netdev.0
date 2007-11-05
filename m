From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Mon, 05 Nov 2007 22:06:56 +0100
Message-ID: <472F85F0.8060205@o2.pl>
References: <1193939701.2987.82.camel@localhost.localdomain>	 <472B5EF1.4020206@o2.pl> <1194045830.4438.21.camel@localhost>	 <472D06B2.9040402@o2.pl> <472D0B1C.7000209@o2.pl> <472D128B.8030704@o2.pl>	 <472D1DC2.9000106@o2.pl> <1194220693.4438.75.camel@localhost>	 <20071105091231.GA1933@ff.dom.local>	 <1194267561.2987.141.camel@localhost.localdomain>	 <20071105135246.GB1933@ff.dom.local>  <1194271589.4438.113.camel@localhost> <1194283888.2987.186.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: Radu Rendec <radu.rendec@ines.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:53593 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751015AbXKEUz4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2007 15:55:56 -0500
In-Reply-To: <1194283888.2987.186.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Radu Rendec wrote, On 11/05/2007 06:31 PM:

> On Mon, 2007-11-05 at 09:06 -0500, jamal wrote:
>> On Mon, 2007-05-11 at 14:52 +0100, Jarek Poplawski wrote:
>>
> ...
>>> If we manage to convince Jamal, IMHO a patch to something current like
>>> 2.6.24-rc1-git14 (or maybe -rc2 soon), should suffice (plus some
>>> options to diff to get function names etc. eg.: diff -Nurp). Try with
>>> Documentation/SubmittingPatches. Git isn't necessary at all. And don't
>>> forget about a changelog.
>> That code hasnt changed at all in a few years, so even against
>> 2.6.24-rc1 should be fine and can be applied cleanly to Daves net-2.6.
>> Radu, please refer to my earlier email on things to try.
> 
> Ok, silly procmail rules + threaded view = bad idea. I just didn't see
> your last messages earlier when I replied. Sorry!
> 
> But still, Jamal, I need more explanations on what you meant by "cutdown
> on the conversion in u32_change()". And, before proceeding, I'd like to
> see your reply to Jarek's last email (at 15:49 +0100) about not getting
> 0xff in the end.


Radu, as far as I know Jamal (from reading) he most probably is busy with
some conference! Since these patches aren't so big I think you could
try Jamal's at first, and if it doesn't work, and nothing new from Jamal
in the meantime, resend your version. Cutdown in u32_change() seems to
add more to the fastpath, but maybe Jamal thinks about something else.

> 
> Jarek, because I have to test anyway, I'll include ffs(mask) in my patch
> and have it tested too.


Thanks! But, I did it wrong: + 1 is unnecessary. And since, ffs() checks
for 0 anyway, this should be simpler:

- {
- 	u8 i = 0;
- 	u32 mask = s->hmask;
- 	if (mask) {
- 		while (!(mask & 1)) {
- 			i++;
- 			mask>>=1;
- 		}
- 	}
- 	n->fshift = i;
+ 	n->fshift = ffs(s->hmask);
- }

Plus maybe (u8) cast on warnings...

On the other hand, only now I see here is some hack (or bug) with this
u8, so ffs() would mean a change here. I definitely need to rethink this.
So, it's probably better to make and test this ffs() patch separately
(2 parts).

> 
> I already have a clone of Dave's net-2.6 tree, so it shouldn't be such a
> big effort to use git after all. I can also make the patch against
> 2.6.24-rc1, so please tell me which is more convinient for you.


Since, there is only this one file, with no changes, there will be no
difference, so it's up to your taste.

Cheers,

Jarek P.
