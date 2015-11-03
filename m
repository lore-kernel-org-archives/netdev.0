From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: net: lockdep warning in ip_mc_msfget (net/ipv4/igmp.c:2400)
Date: Tue, 3 Nov 2015 09:21:09 -0200
Message-ID: <563898A5.9050200@gmail.com>
References: <56377FC9.90601@oracle.com>
 <CAHA+R7NsSCsLuAuYu9HNmAOvbRdi35U8zLwSmLv0Rq4T4sHKFw@mail.gmail.com>
 <CAHA+R7OsGmYPWtHFK8QmuzaZW9WBfVCVviReEopTRF_zjxzKKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>, syzkaller@googlegroups.com,
	Dmitry Vyukov <dvyukov@google.com>
To: Cong Wang <cwang@twopensource.com>,
	Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHA+R7OsGmYPWtHFK8QmuzaZW9WBfVCVviReEopTRF_zjxzKKA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em 02-11-2015 22:38, Cong Wang escreveu:
> On Mon, Nov 2, 2015 at 1:31 PM, Cong Wang <cwang@twopensource.com> wrote:
>>
>> Good catch!
>>
>> This is probably introduced by:
>>
>> commit baf606d9c9b12517e47e0d1370e8aa9f7323f210
>> Author: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
>> Date:   Wed Mar 18 14:50:42 2015 -0300
>>
>>      ipv4,ipv6: grab rtnl before locking the socket

Yes, that commit introduced this inverse order situation by not fixing 
the get path of it.

>> I am thinking what is the right way to fix it...
>
> Please try the attached patch.
>
> Thanks!

Patch LGTM, same design and covered all rtnl_lock()s I could find on get 
path now. Thanks!

   Marcelo
