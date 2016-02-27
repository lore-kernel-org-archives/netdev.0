From: Ani Sinha <ani@arista.com>
Subject: ip v6 routing behavior difference between linux 3.4 and linux 3.18
Date: Fri, 26 Feb 2016 17:57:55 -0800
Message-ID: <CAOxq_8OtonFbUBzgaYnL+usB5gZMUjsU9b=EXJfqB8-8mBOsTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:35752 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752617AbcB0B6L convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 20:58:11 -0500
Received: by mail-ig0-f172.google.com with SMTP id hb3so45727973igb.0
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 17:58:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys,

I am a little puzzled with a behavior difference I see between linux
3.4 and linux 3.18. Here's my setup where the numbers in hex are ipv6
addresses of the interfaces in parenthesis :

fd7a:629f:52a4:fffd::1 (lo0)
      =E2=88=A3
      =E2=88=A3
 fd7a:629f:52a4:fffe::1 (vlan_dev1)
     =E2=88=A3         linux box 2 (unit under test)
 -----------------------
      =E2=88=A3       linux box1 (Test Driver)
      =E2=88=A3
 fd7a:629f:52a4:fffe::2 (e0)

Linux box2 is running linux kernel 3.4. Linux box1 is running linux
kernel 3.18.

I am running a small test script on box1 where I try to ping the
loopback interface. Before I do that, I set up a static route for
loopback device lo on box1, something like this :

fd7a:629f:52a4:fffd::1 via fd7a:629f:52a4:fffe::1 dev e0  metric 1024

Then I bring down the real device under the vlan_dev1 interface on
box2. The ping to loopback fails. So far so good.

Now I bring the real device under vlan_dev1 back up. This time, the
ping6 to lo0 on box1 keeps failing with "destination unreachable: no
route". I don't understand why the ping would fail even with a static
route programmed. I have also noticed that when I ping6 vlan_dev1 from
box1 and then ping6 lo0 from box1, the ping6 to lo0 then succeeds.
Alternatively, if I ping6 e0 from box2, then ping6 from box1 to lo0,
it succeeds.

Now as another experiment data point, I run linux kernel 3.4 on box1.
The behavior is slightly different.  The moment I bring back up the
underlying device for vlan_dev1, the pings succeed right away without
any tinkering. I don't understand why this subtle difference in
behavior in the two kernels?

Any pointers would be greatly appreciated.

thanks
ani
