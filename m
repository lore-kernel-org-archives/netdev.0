From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 5/5] rocker: remove support for legacy VLAN ndo
 ops
Date: Tue, 02 Jun 2015 07:43:41 -0400
Message-ID: <556D96ED.9010309@mojatatu.com>
References: <1433183947-13095-1-git-send-email-sfeldma@gmail.com> <1433183947-13095-6-git-send-email-sfeldma@gmail.com> <556D363A.5010005@lab.ntt.co.jp> <20150601.222442.1854333703599698362.davem@davemloft.net> <CAE4R7bBL+=-akoNLPqPae=zrYe3DH59t=8UK_T7KhcHSNaKUtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>
To: Scott Feldman <sfeldma@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:33545 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753879AbbFBLno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 07:43:44 -0400
Received: by igbpi8 with SMTP id pi8so83542627igb.0
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 04:43:44 -0700 (PDT)
In-Reply-To: <CAE4R7bBL+=-akoNLPqPae=zrYe3DH59t=8UK_T7KhcHSNaKUtw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/02/15 03:10, Scott Feldman wrote:


> Actually, we're now consistent with bridge man page which says master
> is the default.
>
> Want we want, I believe, is to adjust what the man page says (and the
> bridge vlan command itself), by making the default master and self.
> The kernel and driver are fine, it's the default in the bridge command
> that needs adjusting.  Once we do this, we'll be back to transparent
> with software-only bridge.
>

Question to ask when looking at something of this nature:
Will it work with no suprises if you used today's unmodified app?
The default behavior shouldnt change and unfortunately it does here.

It is not just iproute2 - since this is breaking ABI expectations.
Looking at some app i wrote a while back based on analyzing kernel
expectations at the time, I see the following logic:

user can set master or self on command line.
...
....
if (user DID NOT set master_on || user set self on)
    then set self to on

iow, current behavior:
  01: master is only set if user explicitly asked.
  11: master|self when user explicitly sets both
  10: self is on by default when the user doesnt specify anything
  00: and the last option is to have none set which is not
      possible since we have defaults.

cheers,
jamal


So this is very similar to iproute2 - if nothing is set
it defaults to self.

cheers,
jamal
