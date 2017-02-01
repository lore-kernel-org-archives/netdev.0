From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: sock_create_kern() and network namespace reference counts
Date: Wed, 1 Feb 2017 09:19:39 -0800
Message-ID: <CAM_iQpUuvibN=kgj-zwPKuFAEcA6yjTEoLwf4itrcADX3WxX1g@mail.gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6DB0276D58@AcuExch.aculab.com>
 <CAM_iQpVs-_p8VeoRpUjBPSOCkCAi0q8gWWSx29699-UuLKQTrg@mail.gmail.com> <063D6719AE5E284EB5DD2968C1650D6DB0276FD9@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35248 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752960AbdBARUB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 12:20:01 -0500
Received: by mail-wm0-f50.google.com with SMTP id b65so48864131wmf.0
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 09:20:00 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0276FD9@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 31, 2017 at 9:57 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Cong Wang
>> Sent: 31 January 2017 17:38
>> On Tue, Jan 31, 2017 at 7:41 AM, David Laight <David.Laight@aculab.com> wrote:
>> > Commit 26abe1437 changed sock_create_kern() so that it stopped
>> > holding a reference to the network namespace.
>> > The rational seemed to be 'to allow to stop it' (presumably 'be deleted').
>> > Prior to this change some kernel paths used sk_change_net() (etc) to
>> > change the namespace after the socket was created.
>> >
>> > If the socket doesn't hold a reference to the namespace, what actually
>> > happens when the namespace is deleted?
>>
>> Kernel socket should have the same lifetime with the net namespace,
>> that is, created in net_init and released in net_exit. Think about it, if it
>> really held a refcnt to this netns, how could this netns be teared down?
>
> That rather depends on what they are being used for.
> Consider something like an in kernel ftp client, it doesn't really care
> about namespaces except in as much as the connections it creates must
> be inside the correct namespace.
> The namespace shouldn't be torn down while that connection exists any more
> than it should be torn down while a user process has an open connection.
> (Listening sockets are likely to be more of a problem.)

If you don't care about netns, why not just use init_net which is never
torn down and make your kernel socket global so that each netns
can access it too?
