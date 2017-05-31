From: Manohar Kumar <forwardinglnx@gmail.com>
Subject: Re: Deleting a dynamic mac entry..
Date: Tue, 30 May 2017 18:50:35 -0700
Message-ID: <CA+N+6-xBtWg1+cUeCvdEK1fJbHHVdXpdORWvALosUZtWWG4C8g@mail.gmail.com>
References: <CA+N+6-xY7+coc6zFqzP665WMhbGFFMHOfre9wNxRAcSF2Bthzw@mail.gmail.com>
 <e6143108-3eb4-6f6a-c58b-857722f706b9@lab.ntt.co.jp> <CA+N+6-xtSgQ4eDN7SBMg43WXEc=6quPNE4L1-3xjLuTMte0DSA@mail.gmail.com>
 <fbf9c273-d326-c26e-593f-ccf139bc0049@lab.ntt.co.jp> <CA+N+6-wErt=9XX6u8tPnLbb2DrLqADOnCBn3mDe=qvxCoLCFyg@mail.gmail.com>
 <45967005-7501-6c96-eb95-f83c5f631277@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:33739 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750992AbdEaBuh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 21:50:37 -0400
Received: by mail-qk0-f193.google.com with SMTP id c206so294333qkb.0
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 18:50:36 -0700 (PDT)
In-Reply-To: <45967005-7501-6c96-eb95-f83c5f631277@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please see inline..

On Fri, May 26, 2017 at 1:15 AM, Toshiaki Makita
<makita.toshiaki@lab.ntt.co.jp> wrote:
> On 2017/05/26 14:08, Manohar Kumar wrote:
>> On Wed, May 24, 2017 at 6:11 PM, Toshiaki Makita
>> <makita.toshiaki@lab.ntt.co.jp> wrote:
>>> On 2017/05/25 3:05, Manohar Kumar wrote:
>>>> Thanks, Toshiaki.
>>>>
>>>> What is the right way to set the default_pvid using the bridge command
>>>> ? I tried this, which fails..
>>>>
>>>> root@net-3:~# ip link set dev vxlan0 name untagged type vlan id 0
>>>> RTNETLINK answers: Operation not supported
>>>> root@net-3:~#
>>>>
>>>> All the interfaces in the bridge are untagged.
>>>
>>> # ip link set br0 down
>>> # echo 0 > /sys/class/net/br0/bridge/default_pvid
>>>
>>
>> I have the bridge inside a network namespace. There is no
>> /sys/class/net entry for the bridge interface inside the namespace.
>>
>> I see online references to this concept of 'tagged' sysfs directories
>> to support namespaces. But its not clear how to access the sysfs
>> entries for a particular namespace.
>
> Did you remount /sys after entering netns?

No, that was the problem. Mounting /sys did the trick. Appreciate your help.

Trying to understanding this better. How is the sysfs tree maintained
per network namespace ? I assume only the /sys/class/net is per
network namespace and the rest of the /sys is shared with the host
namespace ? Also, how does mounting /sys in the network namespace make
the new /sys/class/net tree visible ?

thanks,
Manohar.


> If not, remount /sys or use "ip netns" which automatically do it.
>
>> Is there any other way to set the default_pvid for the bridge
>> interface inside namespace ?
>
> No, as of 3.19.
>
>
> Toshiaki Makita
>
