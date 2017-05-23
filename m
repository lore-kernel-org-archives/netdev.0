From: Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: 4.12-RC2 BUG: scheduling while atomic: irq/47-iwlwifi
Date: Tue, 23 May 2017 09:24:49 +0200
Message-ID: <ff02b9a1-94e1-8bbd-c48e-c2d05b0b75ec@broadcom.com>
References: <a54f3f4f-2365-2154-ad18-82e4cd572aac@eikelenboom.it>
 <1495450628.2653.14.camel@sipsolutions.net>
 <764a929c-ce8a-c859-a49e-2f20cb05ae44@broadcom.com>
 <532c257e-52a0-18c1-1afe-04d37c28e072@broadcom.com>
 <1495487095.26008.7.camel@sipsolutions.net>
 <09ddb018-7093-2e2a-c84b-148889f7f06d@broadcom.com>
 <1495524153.2464.2.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        Sander Eikelenboom <linux-6SM94LqRVpn6gRhOQ7JHfg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1495524153.2464.2.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 23-5-2017 9:22, Johannes Berg wrote:
> On Tue, 2017-05-23 at 09:19 +0200, Arend Van Spriel wrote:
>>
>>> 	WARN_ON_ONCE(!rcu_read_lock_held() && !lockdep_rtnl_is_held());
>>
>> Thought about something like this after sending the email. So there
>> are two call sites. One for scheduled scan results notification and
>> one in scheduled scan stop scenario. So for the latter it is not
>> needed to use the rcu_read_lock() as it should have RTNL lock hence
>> the two checks above?
> 
> Right. The latter can't even really use rcu_read_lock() since it also
> wants to modify the list, and that's not sufficient protection for
> modifying.

Hence the name ;-)

Regards,
Arend
