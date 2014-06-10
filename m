From: Milos Vyletel <milos.vyletel@gmail.com>
Subject: Re: [patch net-next 3/5] ipv6: consider net.ipv6.conf.all sysctls
 when making decisions
Date: Tue, 10 Jun 2014 13:42:51 -0400
Message-ID: <CAAFXRd2QhXneN0RLe2+NZLTYVt9rq+COXyox91008QGuCzkd0w@mail.gmail.com>
References: <1402417153-2551-1-git-send-email-milos.vyletel@gmail.com>
	<1402417153-2551-4-git-send-email-milos.vyletel@gmail.com>
	<53973D42.4010209@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>, amwang@redhat.com,
	netdev@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	stephen hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	"open list:USB CDC ETHERNET..." <linux-usb@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53973D42.4010209@enst-bretagne.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Hello,
>
>>
>> IN6_DEV_MAXCONF
>>       IN6_DEV_HOPLIMIT
>>       IN6_DEV_MTU
>
> I'm a little bit surprise to set the MTU as the maximum of all/dev
> value. Since the default for "all" is IPV6_MIN_MTU, it is probably
> harmless, but it could be a little bit surprising for administrators.
>
>>  IN6_DEV_USE_TEMPADDR
>
> For this one, the default is zero, except for point-to-point and
> loopback, with -1. I didn't see any difference between 0 and -1 in the
> current kernel code, but if I missed something, it could be a little
> problem.

Hi,

these are both valid points. It does not make too much sense to get
max value for MTU and I'd say we should either get min or simply get
interface setting and don't change the current behavior for this particular
one.

use_tempaddr will have special treatment too since it can range from:
use_tempaddr - INTEGER
    Preference for Privacy Extensions (RFC3041).
      <= 0 : disable Privacy Extensions
      == 1 : enable Privacy Extensions, but prefer public
             addresses over temporary addresses.
      >  1 : enable Privacy Extensions and prefer temporary
             addresses over public addresses.
    Default:  0 (for most devices)
         -1 (for point-to-point devices and loopback devices)

Milos
