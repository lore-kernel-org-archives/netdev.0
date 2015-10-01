From: Eric Dumazet <edumazet@google.com>
Subject: Re: Soft lockup issue in Linux 4.1.9
Date: Thu, 1 Oct 2015 04:52:18 -0700
Message-ID: <CANn89iKvTUKZTiWQYbjXLr4NvYKDgd_mKYVzZHiSqk0e0OfGxA@mail.gmail.com>
References: <1443650383.13282.10.camel@daevel.fr>
	<560D1223.3070606@googlemail.com>
	<CANn89i+B5T4Rhs8HnrC0+f+GhLvBFfpr4BVDvhkVOveSfy9B8Q@mail.gmail.com>
	<560D1C5A.3050508@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: =?UTF-8?Q?Holger_Hoffst=C3=A4tte?=
	<holger.hoffstaette@googlemail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <560D1C5A.3050508@googlemail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 1, 2015 at 4:43 AM, Holger Hoffst=C3=A4tte
<holger.hoffstaette@googlemail.com> wrote:
> On 10/01/15 13:29, Eric Dumazet wrote:

>> commit 83fccfc3940c4a2db90fd7e7079f5b465cd8c6af
>> Author: Eric Dumazet <edumazet@google.com>
>> Date:   Thu Aug 13 15:44:51 2015 -0700
>>
>>     inet: fix potential deadlock in reqsk_queue_unlink()
>>
>>     When replacing del_timer() with del_timer_sync(), I introduced
>>     a deadlock condition :
>>
>>     reqsk_queue_unlink() is called from inet_csk_reqsk_queue_drop()
>>
>>     inet_csk_reqsk_queue_drop() can be called from many contexts,
>>     one being the timer handler itself (reqsk_timer_handler()).
>>
>>     In this case, del_timer_sync() loops forever.
>>
>>     Simple fix is to test if timer is pending.
>>
>>     Fixes: 2235f2ac75fd ("inet: fix races with reqsk timers")
>>     Signed-off-by: Eric Dumazet <edumazet@google.com>
>>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
> Whohoo! It applies/builds cleanly to 4.1.10-rc1 and is running as
> we speak. Let's hope that this fixes the lockups.
>

It definitely should help !

David, since patch is not yet seen on
http://patchwork.ozlabs.org/bundle/davem/stable/?state=3D*
could you please add it to your queue ?

Thanks.
