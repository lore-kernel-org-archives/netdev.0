From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: Soft lockup issue in Linux 4.1.9
Date: Fri, 2 Oct 2015 22:04:44 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1510022200130.4500@nanos>
References: <1443650383.13282.10.camel@daevel.fr> <560D1223.3070606@googlemail.com> <CANn89i+B5T4Rhs8HnrC0+f+GhLvBFfpr4BVDvhkVOveSfy9B8Q@mail.gmail.com> <560D1C5A.3050508@googlemail.com> <CANn89iKvTUKZTiWQYbjXLr4NvYKDgd_mKYVzZHiSqk0e0OfGxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-791222658-1443816286=:4500"
Cc: =?ISO-8859-15?Q?Holger_Hoffst=E4tte?=
	<holger.hoffstaette@googlemail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CANn89iKvTUKZTiWQYbjXLr4NvYKDgd_mKYVzZHiSqk0e0OfGxA@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-791222658-1443816286=:4500
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Thu, 1 Oct 2015, Eric Dumazet wrote:
> On Thu, Oct 1, 2015 at 4:43 AM, Holger Hoffstätte
> <holger.hoffstaette@googlemail.com> wrote:
> > On 10/01/15 13:29, Eric Dumazet wrote:
> 
> >> commit 83fccfc3940c4a2db90fd7e7079f5b465cd8c6af
> >> Author: Eric Dumazet <edumazet@google.com>
> >> Date:   Thu Aug 13 15:44:51 2015 -0700
> >>
> >>     inet: fix potential deadlock in reqsk_queue_unlink()
> >>
> >>     When replacing del_timer() with del_timer_sync(), I introduced
> >>     a deadlock condition :
> >>
> >>     reqsk_queue_unlink() is called from inet_csk_reqsk_queue_drop()
> >>
> >>     inet_csk_reqsk_queue_drop() can be called from many contexts,
> >>     one being the timer handler itself (reqsk_timer_handler()).
> >>
> >>     In this case, del_timer_sync() loops forever.
> >>
> >>     Simple fix is to test if timer is pending.
> >>
> >>     Fixes: 2235f2ac75fd ("inet: fix races with reqsk timers")
> >>     Signed-off-by: Eric Dumazet <edumazet@google.com>
> >>     Signed-off-by: David S. Miller <davem@davemloft.net>
> >
> > Whohoo! It applies/builds cleanly to 4.1.10-rc1 and is running as
> > we speak. Let's hope that this fixes the lockups.
> >
> 
> It definitely should help !

What makes sure, that the timer cannot be readded while that timer
callback is running?

Thanks,

	tglx


--8323329-791222658-1443816286=:4500--
