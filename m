From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v2] net: fix sleeping while atomic problem in sock mem_cgroup.
Date: Fri, 16 Dec 2011 13:53:12 +0400
Message-ID: <4EEB1508.3080405@parallels.com>
References: <1324026582-5214-1-git-send-email-glommer@parallels.com> <1324027869.2273.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>,
	Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1324027869.2273.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/16/2011 01:31 PM, Eric Dumazet wrote:
> Le vendredi 16 d=C3=A9cembre 2011 =C3=A0 13:09 +0400, Glauber Costa a=
 =C3=A9crit :
>> Since we can't scan the proto_list to initialize sock cgroups, as it
>> holds a rwlock, and we also want to keep the code generic enough to
>> avoid calling the initialization functions of protocols directly,
>> I propose we keep the interested parties in a separate list. This li=
st
>> is protected by a mutex so we can sleep and do the necessary allocat=
ions.
>>
>> Also fixes a reference problem found by Randy Dunlap's randconfig.
>>
>> Signed-off-by: Glauber Costa<glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
>> CC: Hiroyouki Kamezawa<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
>> CC: David S. Miller<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
>> CC: Eric Dumazet<eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> CC: Stephen Rothwell<sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
>> CC: Randy Dunlap<rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>
>> ---
>
> Sorry to come late, but why dont we convert proto_list_lock to a mute=
x ?

I didn't suggest this, as I imagined there could be some performance=20
implications to be drawn from it that may not be obvious to me.

But if it is okay with you net guys, it is certainly okay with me as we=
ll.
--
To unsubscribe from this list: send the line "unsubscribe cgroups" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
