From: Pau Espin <pau.espin@tessares.net>
Subject: Re: [PATCH net-next] tcp: accept RST if SEQ matches right edge of
 SACK block
Date: Fri, 3 Jun 2016 17:59:27 +0200
Message-ID: <CALCp7mkVeqxkg625HidKvaZ_8d9obp8mWBMVUs4sunZrs9pBFQ@mail.gmail.com>
References: <1464694717-22548-1-git-send-email-pau.espin@tessares.net>
	<1464796118.5939.156.camel@edumazet-glaptop3.roam.corp.google.com>
	<CALCp7mne5OEU1hT-XHoQR33S7tzCRuDMzCu-deXx18QbdBgmYA@mail.gmail.com>
	<1464966836.5939.189.camel@edumazet-glaptop3.roam.corp.google.com>
	<CADVnQymK9FfSS26CemJ-powG5WrbBrBr4YcLwO_5iVA6OJ6sGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:32775 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbcFCP72 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 11:59:28 -0400
Received: by mail-qg0-f48.google.com with SMTP id j96so4144981qge.0
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 08:59:28 -0700 (PDT)
In-Reply-To: <CADVnQymK9FfSS26CemJ-powG5WrbBrBr4YcLwO_5iVA6OJ6sGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Neal,
Sorry I saw your email just after sending the second version of the patch.
Indeed, it could make sense to do it as you say. I'll try to do some
tests in my environment and send a new version with those changes if I
don't find any problem with it.

On Fri, Jun 3, 2016 at 5:45 PM, Neal Cardwell <ncardwell@google.com> wrote:
> On Fri, Jun 3, 2016 at 11:13 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> I have no strict opinion on this.
>>
>> It seems to me that checking at most 4 right edges (at least in current
>> linux implementation) is not adding a huge risk, and allows for better
>> interoperability.
>>
>> I vote for no extra sysctl.
>
> I vote for no extra sysctl as well.
>
> But I would also vote to tighten up the proposed logic slightly, and
> only check the seq of the incoming RST against the right edge of the
> *right-most* SACK block. That is, the code could loop through the
> tp->selective_acks to find the right-most of the right edges of the
> SACK blocks (the end_seq that has no other end_seq after() it). AFAICT
> it makes sense to expect that a legitimate incoming RST might match
> rcv_nxt, or might match the right-most edge of the right-most SACK.
> But allowing a RST to match a sequence of some SACK in the middle of
> the sequence range would seem to only increase the attack surface for
> RST attacks.
>
> neal



-- 
Pau Espin Pedrol | R&D Engineer - External
pau.espin@tessares.net | +32 487 43 36 50
Tessares SA | Hybrid Access Solutions
www.tessares.net
6 Rue Louis de Geer, 1348 Louvain-la-Neuve, Belgium

-- 

------------------------------
DISCLAIMER.
This email and any files transmitted with it are confidential and intended 
solely for the use of the individual or entity to whom they are addressed. 
If you have received this email in error please notify the system manager. 
This message contains confidential information and is intended only for the 
individual named. If you are not the named addressee you should not 
disseminate, distribute or copy this e-mail. Please notify the sender 
immediately by e-mail if you have received this e-mail by mistake and 
delete this e-mail from your system. If you are not the intended recipient 
you are notified that disclosing, copying, distributing or taking any 
action in reliance on the contents of this information is strictly 
prohibited.
