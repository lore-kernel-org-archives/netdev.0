From: Manohar Kumar <forwardinglnx@gmail.com>
Subject: Re: Deleting a dynamic mac entry..
Date: Wed, 24 May 2017 11:05:54 -0700
Message-ID: <CA+N+6-xtSgQ4eDN7SBMg43WXEc=6quPNE4L1-3xjLuTMte0DSA@mail.gmail.com>
References: <CA+N+6-xY7+coc6zFqzP665WMhbGFFMHOfre9wNxRAcSF2Bthzw@mail.gmail.com>
 <e6143108-3eb4-6f6a-c58b-857722f706b9@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34729 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932941AbdEXSF4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 14:05:56 -0400
Received: by mail-qk0-f196.google.com with SMTP id u75so27399065qka.1
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 11:05:55 -0700 (PDT)
In-Reply-To: <e6143108-3eb4-6f6a-c58b-857722f706b9@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, Toshiaki.

What is the right way to set the default_pvid using the bridge command
? I tried this, which fails..

root@net-3:~# ip link set dev vxlan0 name untagged type vlan id 0
RTNETLINK answers: Operation not supported
root@net-3:~#

All the interfaces in the bridge are untagged.

thanks,
Manohar.


On Mon, May 22, 2017 at 8:17 PM, Toshiaki Makita
<makita.toshiaki@lab.ntt.co.jp> wrote:
> On 2017/05/21 11:28, Manohar Kumar wrote:
>> Hello,
>>
>> In 3.19 the following bridge fdb command to delete a dynamically
>> learned entry fails..
>>
>> root@net-3:~# bridge fdb show | grep 02:42:0a:ff:00:06
>> 02:42:0a:ff:00:06 dev vxlan0 master br0
>> root@net-3:~# bridge fdb del 02:42:0a:ff:00:06 dev vxlan0 master
>> RTNETLINK answers: No such file or directory
>>
>> It works in 4.4.
>>
>> Can someone please point to the patch that made this change ?
>
> 25d3b493a52d ("bridge: Fix inability to add non-vlan fdb entry") might
> be what you are looking for, but you might want to do git-bisect to
> track down any regression or fix.
>
>> In kernels without this patch is there an alternative to delete
>> (actually I want to do it programmatically) dynamic mac entries ?
>
> If 25d3b493a52d is causing your problem, set default_pvid to 0 in order
> to disable default_pvid, and delete any vlans which is already
> configured in bridge's vlan_filtering. Then, delete the fdb entry.
>
> Toshiaki Makita
>
