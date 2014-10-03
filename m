From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH linux 2/2] fs/proc: use a hash table for the directory
 entries
Date: Fri, 03 Oct 2014 09:28:27 +0200
Message-ID: <542E501B.1010109@6wind.com>
References: <20131003.150947.2179820478039260398.davem@davemloft.net>	<1412263501-6572-1-git-send-email-nicolas.dichtel@6wind.com>	<1412263501-6572-3-git-send-email-nicolas.dichtel@6wind.com>	<87h9zmpcz5.fsf@x220.int.ebiederm.org>	<20141002200639.GA3497@p183.telecom.by> <87h9zmji3q.fsf@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, akpm@linux-foundation.org,
	rui.xiang@huawei.com, viro@zeniv.linux.org.uk, oleg@redhat.com,
	gorcunov@openvz.org, kirill.shutemov@linux.intel.com,
	grant.likely@secretlab.ca, tytso@mit.edu,
	Thierry Herbelot <thierry.herbelot@6wind.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:47393 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754AbaJCH2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 03:28:31 -0400
Received: by mail-wg0-f44.google.com with SMTP id y10so745928wgg.15
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 00:28:29 -0700 (PDT)
In-Reply-To: <87h9zmji3q.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/10/2014 23:07, Eric W. Biederman a =C3=A9crit :
> Alexey Dobriyan <adobriyan@gmail.com> writes:
>
>> On Thu, Oct 02, 2014 at 11:01:50AM -0700, Eric W. Biederman wrote:
>>> Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:
>>>
>>>> From: Thierry Herbelot <thierry.herbelot@6wind.com>
>>>>
>>>> The current implementation for the directories in /proc is using a=
 single
>>>> linked list. This is slow when handling directories with large num=
bers of
>>>> entries (eg netdevice-related entries when lots of tunnels are ope=
ned).
>>>>
>>>> This patch enables multiple linked lists. A hash based on the entr=
y name is
>>>> used to select the linked list for one given entry.
>>>>
>>>> The speed creation of netdevices is faster as shorter linked lists=
 must be
>>>> scanned when adding a new netdevice.
>>>
>>> Is the directory of primary concern /proc/net/dev/snmp6 ?
>>>
>>> Unless I have configured my networking stack weird by mistake that
>>> is the only directory under /proc/net that grows when we add an
>>> interface.
>>>
>>> I just want to make certain I am seeing the same things that you ar=
e
>>> seeing.
>>>
>>> I feel silly for overlooking this directory when the rest of the
>>> scalability work was done.
>>
>> Slowdown comes from "duplicate name" check:
>>
>>          for (tmp =3D dir->subdir; tmp; tmp =3D tmp->next)
>>                  if (strcmp(tmp->name, dp->name) =3D=3D 0) {
>>                          WARN(1, "proc_dir_entry '%s/%s' already reg=
istered\n",
>>                                  dir->name, dp->name);
>>                          break;
>>                  }
>>
>> Removal can be made O(1) after switching to doubly-linked list.
>
> Yes.  There is the however unfortunate fact that proc directories exi=
st
> to be used.  If we don't switch to a better data structure than a lin=
ked
> list the actual use will then opening of the files under
> /proc/net/dev/snmp6/ will become O(N^2).  Which doesn't help much
> (assuming those files are good for something).
>
> If those files aren't actually useful we should just make registering
> them a config option.  Deprecate them strongly and let only people wh=
o
> need extreme backwards compatibility enable them.
>
> Alexey do you know that those files aren't useful?  Unless we know
> otherwise we should make those files useful.
This was proposed and nacked in a first version:
http://thread.gmane.org/gmane.linux.network/285840/


Regards,
Nicolas
