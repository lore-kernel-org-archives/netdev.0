From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: cross namespace interface notification for tun devices
Date: Mon, 2 Oct 2017 14:06:59 +0200
Message-ID: <52f84baf-8027-d01f-8ece-db4f39a2f76f@6wind.com>
References: <CAHmME9pD_kees+xrjTeWXgi26UdhbMVgvoddbCyueTZkbguvAg@mail.gmail.com>
 <f80d9afa-0ce2-903d-9bf9-b7bb8765086b@6wind.com>
 <CAHmME9pAvv7ebKC-uZGPJRi9Jasgrd2tgCvS1Lji+cgM1mV2qw@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Netdev <netdev@vger.kernel.org>, Mathias <mathias@hall-andersen.dk>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:56119 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750978AbdJBMHD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 08:07:03 -0400
Received: by mail-wm0-f46.google.com with SMTP id u138so10110450wmu.4
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 05:07:02 -0700 (PDT)
In-Reply-To: <CAHmME9pAvv7ebKC-uZGPJRi9Jasgrd2tgCvS1Lji+cgM1mV2qw@mail.gmail.com>
Content-Language: fr
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/10/2017 à 13:11, Jason A. Donenfeld a écrit :
> On Mon, Oct 2, 2017 at 11:32 AM, Nicolas Dichtel
> <nicolas.dichtel@6wind.com> wrote:
>> 1. Move the process to netns B, open the netlink socket and move back the
>> process to netns A. The socket will remain in netns B and you will receive all
>> netlink messages related to netns B.
>>
>> 2. Assign a nsid to netns B in netns A and use NETLINK_LISTEN_ALL_NSID on your
>> netlink socket (see iproute2).
> 
> Both of these seem to rely on the process knowing where the device is
> being moved and having access to that namespace. I don't think these
> two things are a given though. Unless I'm missing something?
I didn't understand correctly.
Your control process cannot monitor or control an interface which is in a
unkown/hidden netns. But x-netns interfaces are special. We already add a way to
identify peer netns for this kind of interfaces.
If an handler get_link_net was added to the rtnl_link_ops of the tun driver, it
will help to identify netns A when you are in netns B. But you need the opposite.
I already try a patch to advertise via netlink the dst netns when an interface
moves to a new netns. I think that it is valid for x-netns interfaces.
As soon as you can identify the dst netns, your problem is solved, right?


Nicolas
