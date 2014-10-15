From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: Netlink mmap tx security?
Date: Wed, 15 Oct 2014 16:58:39 -0700
Message-ID: <CALCETrUW6yX8B=ANyxYqhwPbKkosbuBGXO8omTD6rGA1A1XhvA@mail.gmail.com>
References: <CALCETrWDSG2EhxBnM8Jm55Ov8PYQ_w3Wf88SKYOB1q1WgRpbEw@mail.gmail.com>
 <20141014.220111.179628329028952302.davem@davemloft.net> <543F0712.8080503@redhat.com>
 <20141015.195737.1429281929513331763.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>,
	Network Development <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:61336 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751659AbaJOX7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 19:59:00 -0400
Received: by mail-la0-f45.google.com with SMTP id q1so1982908lam.18
        for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 16:58:59 -0700 (PDT)
In-Reply-To: <20141015.195737.1429281929513331763.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 15, 2014 at 4:57 PM, David Miller <davem@davemloft.net> wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Thu, 16 Oct 2014 01:45:22 +0200
>
>> On 10/15/2014 04:01 AM, David Miller wrote:
>>> From: Andy Lutomirski <luto@amacapital.net>
>>> Date: Tue, 14 Oct 2014 15:16:46 -0700
>>>
>>>> It's at least remotely possible that there's something that assumes
>>>> that assumes that the availability of NETLINK_RX_RING implies
>>>> NETLINK_TX_RING, which would be unfortunate.
>>>
>>> I already found one such case, nlmon :-/
>>
>> Hmm, can you elaborate? I currently don't think that nlmon cares
>> actually.
>
> nlmon cares, openvswitch cares, etc:

It'll still work, just slower, right?

+    if (setsockopt(sock->fd, SOL_NETLINK, NETLINK_RX_RING, &req,
sizeof(req)) < 0
+        || setsockopt(sock->fd, SOL_NETLINK, NETLINK_TX_RING, &req,
sizeof(req)) < 0) {
+        VLOG_INFO("mmap netlink is not supported");
+        return 0;
+    }
+

--Andy
