From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 5/5] rocker: remove support for legacy VLAN ndo
 ops
Date: Wed, 03 Jun 2015 08:08:39 -0400
Message-ID: <556EEE47.6060002@mojatatu.com>
References: <1433183947-13095-1-git-send-email-sfeldma@gmail.com> <1433183947-13095-6-git-send-email-sfeldma@gmail.com> <556D363A.5010005@lab.ntt.co.jp> <20150601.222442.1854333703599698362.davem@davemloft.net> <CAE4R7bBL+=-akoNLPqPae=zrYe3DH59t=8UK_T7KhcHSNaKUtw@mail.gmail.com> <556D96ED.9010309@mojatatu.com> <CAE4R7bAXA27cqBLv6MP0kak-L=1bXUoZPw7vxUyYpP=-dk=eAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:35773 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752126AbbFCMIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 08:08:47 -0400
Received: by iesa3 with SMTP id a3so11331603ies.2
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 05:08:46 -0700 (PDT)
In-Reply-To: <CAE4R7bAXA27cqBLv6MP0kak-L=1bXUoZPw7vxUyYpP=-dk=eAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/02/15 10:30, Scott Feldman wrote:
> On Tue, Jun 2, 2015 at 4:43 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> On 06/02/15 03:10, Scott Feldman wrote:
>>

>> Question to ask when looking at something of this nature:
>> Will it work with no suprises if you used today's unmodified app?
>> The default behavior shouldnt change and unfortunately it does here.
>
> The default behavior does change, yes, but there shouldn't be any
> surprises even if using today's unmodified app.

[..]

[....]

>
> Ha, you're giving the behavior for "bridge fdb" command, where self is
> the default.
>

Yes, sorry ;->

> For "bridge link" and "bridge vlan", the default is master.  The user
> must explicitly specify "self" to act on the device side of the port.
>


Not sure what "device side of the port" is intended to mean. But:
iproute2, user can specify device is either the bridge or bridge port.
I think that is the key.
This is used in combination with the self/master flags to decide
behavior in the kernel.
Summary, assuming flag bits master:self

user setting: 00 (none set - which is default iproute2 behavior).
Kernel behavior:
if (bridge port targeted)
         sets the vlan bitmap on the bridge port.
else
         sets the vlan bitmap on the bridge.

******* Above is what we want to maintain unchanged.
If you are saying it doesnt change, then we are fine.

user setting: 01 (self on)
kernel behavior: no difference from default

user setting: 1x (master on, self doesnt matter)
kernel behavior:
if (bridge port targeted)
         sets the bitmap on the bridge port.
         sets the bitmap on the bridge as well. <--------
else
         sets the bitmap on the bridge.


BTW: given the vlan change are reflected from the bowels of
br_vlan_info() - is it redundant there is a call in br_afset
afterwards which says something like
"if master is set and target is bridge port then call hardware
setting thing"?

dont have much time - so i may be confusing something.

> It's unfortunate the iproute2 defaults aren't consistent between
> commands.  Maybe someone knows the history here and can explain.
>

Not sure. Too many cooks with specific use cases? There are many
thing in bridge that i wish were different.
Unfortunately when things get to this level Dave's famous "a horse has
left the barn"  principle applies. Despite my whining, over time,
even shit doesnt smell anymore. I almost feel we need an
ABI police force (refer to Jiri's talk at netconf).
It is much easier to fix kernel changes.

cheers,
jamal
